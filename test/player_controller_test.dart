import 'package:audio_service/audio_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/features/player/player_controller.dart';
import 'package:podpine/features/player/podpine_audio_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('episode metadata includes now-playing artwork and audio identity', () {
    final episode = _episode(1, title: 'A useful episode');

    final item = mediaItemForEpisode(episode);

    expect(item.title, 'A useful episode');
    expect(item.album, 'Test Cast');
    expect(item.artist, 'Test Cast');
    expect(item.artUri, Uri.parse('https://example.test/artwork.png'));
    expect(item.duration, const Duration(minutes: 2));
    expect(item.extras?[audioUrlExtra], episode.audioUrl);
    expect(episodeIdForMediaItem(item), episode.id);
  });

  test('system controls expose podcast skip and seek actions', () {
    final pausedActions = PodpineAudioHandler.notificationControls(
      playing: false,
    ).map((control) => control.action);
    final playingActions = PodpineAudioHandler.notificationControls(
      playing: true,
    ).map((control) => control.action);

    expect(
      pausedActions,
      containsAll(<MediaAction>[
        MediaAction.rewind,
        MediaAction.play,
        MediaAction.fastForward,
      ]),
    );
    expect(pausedActions, isNot(contains(MediaAction.skipToNext)));
    expect(pausedActions, isNot(contains(MediaAction.skipToPrevious)));
    expect(playingActions, contains(MediaAction.pause));
    expect(
      PodpineAudioHandler.systemActions,
      containsAll(<MediaAction>[
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ]),
    );
  });

  test('controller sends a queue and routes playback commands', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final handler = _RecordingAudioHandler();
    final positions = <String>[];
    final completed = <int>[];
    final first = _episode(1, title: 'First');
    final second = _episode(2, title: 'Second');
    await database.into(database.podcastRows).insert(_podcast);
    await database.into(database.episodeRows).insert(first);
    await database.into(database.episodeRows).insert(second);
    await database.addToQueue(second.id);

    final controller = PlayerController(
      database,
      handler,
      (episode, position) async {
        positions.add('${episode.id}:${position.inSeconds}');
      },
      (episode, value) async {
        if (value) completed.add(episode.id);
      },
    );
    addTearDown(() {
      controller.dispose();
      return database.close();
    });

    await controller.playEpisode(first);

    expect(handler.receivedQueue.map(episodeIdForMediaItem), <int?>[1, 2]);
    expect(handler.selectedIndices, <int>[0]);
    expect(handler.playCalls, 1);
    expect(controller.current?.id, 1);

    await controller.seek(const Duration(seconds: 42));
    await controller.toggle();
    await controller.previous();
    await controller.next();

    expect(handler.seeks, contains(const Duration(seconds: 42)));
    expect(handler.pauseCalls, 1);
    expect(handler.previousCalls, 1);
    expect(handler.nextCalls, 1);
    expect(positions, contains('1:42'));

    handler.playbackState.add(
      PlaybackState(
        processingState: AudioProcessingState.ready,
        playing: true,
        queueIndex: 1,
        updatePosition: const Duration(seconds: 5),
      ),
    );
    handler.mediaItem.add(handler.receivedQueue[1]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.current?.id, 2);
    expect(
      (controller.position - const Duration(seconds: 5)).abs(),
      lessThan(const Duration(milliseconds: 50)),
    );
    expect(controller.isPlaying, isTrue);
  });

  test(
    'completion advances and marks the finished episode exactly once',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      final handler = _RecordingAudioHandler();
      final positions = <String>[];
      final completed = <int>[];
      final first = _episode(1, title: 'First');
      final second = _episode(2, title: 'Second');
      await database.into(database.podcastRows).insert(_podcast);
      await database.into(database.episodeRows).insert(first);
      await database.into(database.episodeRows).insert(second);
      await database.addToQueue(first.id);
      await database.addToQueue(second.id);

      final controller = PlayerController(
        database,
        handler,
        (episode, position) async {
          positions.add('${episode.id}:${position.inSeconds}');
        },
        (episode, value) async {
          if (value) completed.add(episode.id);
        },
      );
      addTearDown(() {
        controller.dispose();
        return database.close();
      });

      await controller.playEpisode(first);
      const completion = <String, dynamic>{
        playbackEventType: playbackCompletionEvent,
        'eventId': '1:0',
        episodeIdExtra: 1,
      };
      handler.customEvent.add(completion);
      handler.customEvent.add(completion);
      handler.mediaItem.add(handler.receivedQueue[1]);
      await pumpEventQueue();

      expect(completed, <int>[1]);
      expect(positions, contains('1:120'));
      expect(controller.current?.id, 2);
    },
  );

  test(
    'background and interruption pause flush the current position',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      final handler = _RecordingAudioHandler();
      final positions = <String>[];
      final episode = _episode(1, title: 'First');
      await database.into(database.podcastRows).insert(_podcast);
      await database.into(database.episodeRows).insert(episode);

      final controller = PlayerController(database, handler, (
        episode,
        position,
      ) async {
        positions.add('${episode.id}:${position.inSeconds}');
      }, (_, _) async {});
      addTearDown(() {
        controller.dispose();
        return database.close();
      });

      await controller.playEpisode(episode);
      handler.playbackState.add(
        PlaybackState(
          processingState: AudioProcessingState.ready,
          playing: true,
          updatePosition: const Duration(seconds: 31),
        ),
      );
      await pumpEventQueue();
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      await pumpEventQueue();
      expect(positions, contains('1:31'));

      handler.playbackState.add(
        PlaybackState(
          processingState: AudioProcessingState.ready,
          playing: false,
          updatePosition: const Duration(seconds: 47),
        ),
      );
      await pumpEventQueue();
      expect(positions, contains('1:47'));
    },
  );

  test('playback errors expose skip and retry states', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final handler = _RecordingAudioHandler();
    final episode = _episode(1, title: 'First');
    await database.into(database.podcastRows).insert(_podcast);
    await database.into(database.episodeRows).insert(episode);

    final controller = PlayerController(
      database,
      handler,
      (_, _) async {},
      (_, _) async {},
    );
    addTearDown(() {
      controller.dispose();
      return database.close();
    });
    await controller.playEpisode(episode);

    handler.customEvent.add(const <String, dynamic>{
      playbackEventType: playbackErrorEvent,
      episodeIdExtra: 1,
      'willSkip': true,
    });
    await pumpEventQueue();
    expect(controller.error, contains('Skipped'));
    expect(controller.errorCanRetry, isFalse);

    handler.customEvent.add(const <String, dynamic>{
      playbackEventType: playbackErrorEvent,
      episodeIdExtra: 1,
      'willSkip': false,
    });
    await pumpEventQueue();
    expect(controller.error, contains('try again'));
    expect(controller.errorCanRetry, isTrue);
  });
}

const _podcast = PodcastRecord(
  id: 7,
  title: 'Test Cast',
  author: 'Podpine',
  artworkUrl: 'https://example.test/artwork.png',
  description: '',
  feedUrl: 'https://example.test/feed.xml',
  episodeCount: 2,
);

EpisodeRecord _episode(int id, {required String title}) => EpisodeRecord(
  id: id,
  podcastId: 7,
  podcastTitle: 'Test Cast',
  title: title,
  description: 'Episode description',
  artworkUrl: 'https://example.test/artwork.png',
  audioUrl: 'https://example.test/$id.mp3',
  publishedAt: DateTime.utc(2026, 8, 10),
  durationSeconds: 120,
  positionSeconds: 12,
  completed: false,
  queued: false,
  downloaded: false,
  isYoutube: false,
  updatedAt: DateTime.utc(2026, 8, 10),
);

class _RecordingAudioHandler extends BaseAudioHandler {
  List<MediaItem> receivedQueue = <MediaItem>[];
  final selectedIndices = <int>[];
  final seeks = <Duration>[];
  int playCalls = 0;
  int pauseCalls = 0;
  int previousCalls = 0;
  int nextCalls = 0;

  @override
  Future<void> updateQueue(List<MediaItem> items) async {
    receivedQueue = List<MediaItem>.of(items);
    queue.add(receivedQueue);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    selectedIndices.add(index);
    mediaItem.add(receivedQueue[index]);
    playbackState.add(playbackState.value.copyWith(queueIndex: index));
  }

  @override
  Future<void> play() async {
    playCalls++;
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        playing: true,
      ),
    );
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    playbackState.add(playbackState.value.copyWith(playing: false));
  }

  @override
  Future<void> seek(Duration position) async {
    seeks.add(position);
    playbackState.add(playbackState.value.copyWith(updatePosition: position));
  }

  @override
  Future<void> setSpeed(double speed) async {
    playbackState.add(playbackState.value.copyWith(speed: speed));
  }

  @override
  Future<void> skipToPrevious() async {
    previousCalls++;
  }

  @override
  Future<void> skipToNext() async {
    nextCalls++;
  }
}
