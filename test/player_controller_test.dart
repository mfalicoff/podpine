import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/features/player/player_controller.dart';
import 'package:podpine/features/player/playback_options.dart';
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

  test('controller prefers a completed local download for playback', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final handler = _RecordingAudioHandler();
    final episode = _episode(1, title: 'Offline episode');
    await database.into(database.podcastRows).insert(_podcast);
    await database.into(database.episodeRows).insert(episode);
    await database.upsertDownloadJob(
      DownloadJobRowsCompanion.insert(
        episodeId: const Value(1),
        sourceUrl: episode.audioUrl,
        filePath: '/downloads/offline.mp3',
        partialPath: '/downloads/offline.mp3.part',
        state: 'completed',
        bytesDownloaded: const Value(4),
        totalBytes: const Value(4),
        createdAt: DateTime.utc(2026, 8, 10),
        updatedAt: DateTime.utc(2026, 8, 10),
      ),
    );
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

    expect(
      handler.receivedQueue.single.extras?[audioUrlExtra],
      Uri.file('/downloads/offline.mp3').toString(),
    );
  });

  test(
    'active playback switches to a completed download at the same position',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      final handler = _RecordingAudioHandler();
      final episode = _episode(1, title: 'Downloading episode');
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
      handler.playbackState.add(
        PlaybackState(
          processingState: AudioProcessingState.ready,
          playing: true,
          updatePosition: const Duration(seconds: 42),
        ),
      );
      await pumpEventQueue();
      expect(handler.queueUpdates, hasLength(1));
      expect(
        handler.receivedQueue.single.extras?[audioUrlExtra],
        episode.audioUrl,
      );

      await database.upsertDownloadJob(
        DownloadJobRowsCompanion.insert(
          episodeId: const Value(1),
          sourceUrl: episode.audioUrl,
          filePath: '/downloads/completed.mp3',
          partialPath: '/downloads/completed.mp3.part',
          state: 'completed',
          bytesDownloaded: const Value(4),
          totalBytes: const Value(4),
          createdAt: DateTime.utc(2026, 8, 10),
          updatedAt: DateTime.utc(2026, 8, 10),
        ),
      );
      controller.syncDownloadJobs(await database.downloadJobs());
      await pumpEventQueue(times: 50);

      expect(handler.queueUpdates, hasLength(2));
      expect(handler.receivedQueue, hasLength(1));
      expect(
        handler.receivedQueue.single.extras?[audioUrlExtra],
        Uri.file('/downloads/completed.mp3').toString(),
      );
      expect(controller.current?.id, episode.id);
      expect(
        (controller.position - const Duration(seconds: 42)).abs(),
        lessThan(const Duration(milliseconds: 50)),
      );
      expect(controller.isPlaying, isTrue);
    },
  );

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

  test('queue setup cannot reset an episode resume position', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final handler = _RecordingAudioHandler(resetPositionWhileSelecting: true);
    final episode = _episode(1, title: 'Resume me');
    await database.into(database.podcastRows).insert(_podcast);
    await database.into(database.episodeRows).insert(episode);
    await database.addToQueue(episode.id);
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

    expect(handler.prepareCalls, 1);
    expect(handler.seeks.last, const Duration(seconds: 12));
    expect(controller.position, const Duration(seconds: 12));
  });

  test('queue reordering preserves the active episode and position', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final handler = _RecordingAudioHandler();
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
      (_, _) async {},
      (_, _) async {},
    );
    addTearDown(() {
      controller.dispose();
      return database.close();
    });

    await controller.playEpisode(first);
    await controller.seek(const Duration(seconds: 42));
    await database.reorderQueue([second.id, first.id]);
    await controller.syncQueue(await database.watchQueue().first);

    expect(handler.receivedQueue.map(episodeIdForMediaItem), <int?>[2, 1]);
    expect(handler.selectedIndices, [0]);
    expect(controller.current?.id, first.id);
    expect(
      (controller.position - const Duration(seconds: 42)).abs(),
      lessThan(const Duration(milliseconds: 50)),
    );
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

  test('effective podcast settings are applied before playback', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final handler = _RecordingAudioHandler();
    final episode = _episode(1, title: 'First');
    await database.into(database.podcastRows).insert(_podcast);
    await database.into(database.episodeRows).insert(episode);
    await database.setGlobalPlaybackPreferences(
      const PlaybackPreferences(
        speed: 1.25,
        skipSilence: SkipSilenceStrength.conservative,
      ),
    );
    await database.setPodcastPlaybackOverride(
      episode.podcastId,
      const PodcastPlaybackOverride(
        speed: 1.75,
        skipSilence: SkipSilenceStrength.moderate,
      ),
    );

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
    await pumpEventQueue();

    expect(controller.speed, 1.75);
    expect(controller.skipSilence, SkipSilenceStrength.moderate);
    expect(controller.hasPodcastSpeedOverride, isTrue);
    expect(handler.speedCalls, contains(1.75));
    expect(handler.customActions, contains('setSkipSilence:moderate'));
    expect(
      handler.commands.indexOf('speed:1.75'),
      lessThan(handler.commands.indexOf('play')),
    );
    expect(
      handler.commands.indexOf('setSkipSilence:moderate'),
      lessThan(handler.commands.indexOf('play')),
    );
  });

  test('global and podcast preferences persist independently', () async {
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

    await controller.setSpeed(1.4);
    await controller.setSkipSilence(SkipSilenceStrength.conservative);
    await controller.setSpeed(2.05, forPodcast: true);
    await controller.setSkipSilence(
      SkipSilenceStrength.aggressive,
      forPodcast: true,
    );

    final global = await database.playbackPreferences();
    final override = (await database.podcastPlaybackOverrides())[7];
    expect(global.speed, 1.4);
    expect(global.skipSilence, SkipSilenceStrength.conservative);
    expect(override?.speed, 2.05);
    expect(override?.skipSilence, SkipSilenceStrength.aggressive);

    await controller.clearPodcastSpeedOverride();
    await controller.clearPodcastSkipSilenceOverride();
    expect(controller.speed, 1.4);
    expect(controller.skipSilence, SkipSilenceStrength.conservative);
    expect(await database.podcastPlaybackOverrides(), isEmpty);
  });

  test('sleep timer commands include fixed and end-of-episode modes', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final handler = _RecordingAudioHandler();
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

    await controller.setSleepTimer(const Duration(minutes: 15));
    expect(handler.customActions, contains('setSleepTimer:900'));
    expect(controller.sleepTimerEndsAt, isNotNull);

    await controller.setSleepTimer(null, endOfEpisode: true);
    expect(handler.customActions, contains('setSleepTimer:end'));
    expect(controller.sleepAtEpisodeEnd, isTrue);
  });

  test('Podcasting 2.0 chapters hydrate without delaying playback', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final handler = _RecordingAudioHandler();
    final episode = _episode(1, title: 'First');
    await database.into(database.podcastRows).insert(_podcast);
    await database.into(database.episodeRows).insert(episode);
    final chapterRequest = Completer<String>();
    final controller = PlayerController(
      database,
      handler,
      (_, _) async {},
      (_, _) async {},
      chapterLoader: (_) => chapterRequest.future,
    );
    addTearDown(() {
      controller.dispose();
      return database.close();
    });

    await controller.playEpisode(episode);
    expect(handler.playCalls, 1);
    expect(controller.chapters, isEmpty);

    chapterRequest.complete(
      '[{"startTime":0,"title":"Opening"},{"startTime":30,"title":"Topic"}]',
    );
    await pumpEventQueue();

    expect(controller.chapters.map((chapter) => chapter.title), [
      'Opening',
      'Topic',
    ]);
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
  websiteUrl: '',
  categoriesJson: '[]',
  explicit: false,
  podcastIndexId: 0,
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
  chaptersJson: '[]',
  playbackIntent: 'progress',
  playbackMediaIdentity: 'https://example.test/$id.mp3',
  updatedAt: DateTime.utc(2026, 8, 10),
);

class _RecordingAudioHandler extends BaseAudioHandler {
  _RecordingAudioHandler({this.resetPositionWhileSelecting = false});

  final bool resetPositionWhileSelecting;
  List<MediaItem> receivedQueue = <MediaItem>[];
  final queueUpdates = <List<MediaItem>>[];
  final selectedIndices = <int>[];
  final seeks = <Duration>[];
  final speedCalls = <double>[];
  final customActions = <String>[];
  final commands = <String>[];
  int playCalls = 0;
  int pauseCalls = 0;
  int previousCalls = 0;
  int nextCalls = 0;
  int prepareCalls = 0;

  @override
  Future<void> updateQueue(List<MediaItem> items) async {
    receivedQueue = List<MediaItem>.of(items);
    queueUpdates.add(receivedQueue);
    queue.add(receivedQueue);
    if (resetPositionWhileSelecting) {
      playbackState.add(
        playbackState.value.copyWith(updatePosition: Duration.zero),
      );
      await pumpEventQueue();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    selectedIndices.add(index);
    mediaItem.add(receivedQueue[index]);
    playbackState.add(
      resetPositionWhileSelecting
          ? playbackState.value.copyWith(
              queueIndex: index,
              updatePosition: Duration.zero,
            )
          : playbackState.value.copyWith(queueIndex: index),
    );
    if (resetPositionWhileSelecting) await pumpEventQueue();
  }

  @override
  Future<void> play() async {
    playCalls++;
    commands.add('play');
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
        playing: true,
      ),
    );
  }

  @override
  Future<void> prepare() async {
    prepareCalls++;
    commands.add('prepare');
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
    speedCalls.add(speed);
    commands.add('speed:$speed');
    playbackState.add(playbackState.value.copyWith(speed: speed));
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    final Object? value;
    if (name == setSkipSilenceAction) {
      value = extras?['strength'];
    } else if (extras?['endOfEpisode'] == true) {
      value = 'end';
    } else {
      value = extras?['seconds'];
    }
    customActions.add('$name:$value');
    commands.add('$name:$value');
    if (name == setSkipSilenceAction) {
      return <String, dynamic>{
        'strength': value,
        'enabled': value != 'off',
        'supported': true,
      };
    }
    return null;
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
