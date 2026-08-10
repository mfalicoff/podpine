import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/database/app_database.dart';

const episodeIdExtra = 'episodeId';
const audioUrlExtra = 'audioUrl';

MediaItem mediaItemForEpisode(EpisodeRecord episode) {
  final artwork = Uri.tryParse(episode.artworkUrl.trim());
  return MediaItem(
    id: 'podpine:episode:${episode.id}',
    title: episode.title,
    album: episode.podcastTitle,
    artist: episode.podcastTitle,
    duration: episode.durationSeconds > 0
        ? Duration(seconds: episode.durationSeconds)
        : null,
    artUri: artwork != null && artwork.hasScheme ? artwork : null,
    displayTitle: episode.title,
    displaySubtitle: episode.podcastTitle,
    displayDescription: episode.description,
    extras: <String, dynamic>{
      episodeIdExtra: episode.id,
      audioUrlExtra: episode.audioUrl,
    },
  );
}

int? episodeIdForMediaItem(MediaItem item) {
  final value = item.extras?[episodeIdExtra];
  return value is int ? value : int.tryParse('$value');
}

Future<PodpineAudioHandler> initializeAudioService() => AudioService.init(
  builder: PodpineAudioHandler.new,
  config: const AudioServiceConfig(
    androidNotificationChannelId: 'app.podpine.podpine.playback',
    androidNotificationChannelName: 'Podcast playback',
    androidNotificationChannelDescription:
        'Playback controls for the active Podpine episode.',
    androidNotificationIcon: 'drawable/ic_stat_podpine',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    notificationColor: Color(0xFF173F35),
    fastForwardInterval: Duration(seconds: 30),
    rewindInterval: Duration(seconds: 15),
    preloadArtwork: true,
  ),
);

/// Owns the one [AudioPlayer] used by the app and exposes it to the operating
/// system through [audio_service]. UI code talks to this handler rather than
/// creating a second foreground-only player.
class PodpineAudioHandler extends BaseAudioHandler with SeekHandler {
  PodpineAudioHandler() {
    _ready = _configureAudioSession();
    _eventSubscription = _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object error, StackTrace stackTrace) {
        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
            errorMessage: '$error',
          ),
        );
      },
    );
    _indexSubscription = _player.currentIndexStream.listen(_broadcastItem);
  }

  final AudioPlayer _player = AudioPlayer(maxSkipsOnError: 3);
  late final Future<void> _ready;
  StreamSubscription<PlaybackEvent>? _eventSubscription;
  StreamSubscription<int?>? _indexSubscription;

  static const systemActions = <MediaAction>{
    MediaAction.seek,
    MediaAction.seekForward,
    MediaAction.seekBackward,
  };

  static List<MediaControl> notificationControls({required bool playing}) =>
      <MediaControl>[
        MediaControl.skipToPrevious,
        MediaControl.rewind,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward,
        MediaControl.skipToNext,
      ];

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await _player.stop();
    final newQueue = List<MediaItem>.unmodifiable(queue);
    this.queue.add(newQueue);
    mediaItem.add(null);
    if (newQueue.isEmpty) {
      await _player.clearAudioSources();
      _broadcastState(_player.playbackEvent);
      return;
    }

    final sources = newQueue
        .map((item) {
          final audioUrl = item.extras?[audioUrlExtra] as String? ?? '';
          final uri = Uri.tryParse(audioUrl);
          if (uri == null || !uri.hasScheme) {
            throw ArgumentError.value(
              audioUrl,
              audioUrlExtra,
              'Invalid audio URL',
            );
          }
          return AudioSource.uri(uri, tag: item);
        })
        .toList(growable: false);
    await _player.setAudioSources(sources, preload: false);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    var index = queue.value.indexWhere((queued) => queued.id == mediaItem.id);
    if (index < 0) {
      await updateQueue(<MediaItem>[mediaItem]);
      index = 0;
    }
    await skipToQueueItem(index);
    unawaited(play());
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final items = queue.value;
    if (index < 0 || index >= items.length) return;
    await _player.seek(Duration.zero, index: index);
    mediaItem.add(items[index]);
    _broadcastState(_player.playbackEvent);
  }

  @override
  Future<void> skipToNext() async {
    final index = _player.currentIndex;
    if (index == null || index + 1 >= queue.value.length) return;
    await skipToQueueItem(index + 1);
  }

  @override
  Future<void> skipToPrevious() async {
    final index = _player.currentIndex;
    if (index == null) return;
    if (_player.position > const Duration(seconds: 3)) {
      await seek(Duration.zero);
      return;
    }
    if (index > 0) await skipToQueueItem(index - 1);
  }

  @override
  Future<void> play() async {
    await _ready;
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> fastForward() =>
      seek(_boundedPosition(_player.position + const Duration(seconds: 30)));

  @override
  Future<void> rewind() =>
      seek(_boundedPosition(_player.position - const Duration(seconds: 15)));

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  Duration _boundedPosition(Duration position) {
    if (position < Duration.zero) return Duration.zero;
    final duration = _player.duration;
    if (duration != null && position > duration) return duration;
    return position;
  }

  void _broadcastItem(int? index) {
    final items = queue.value;
    if (index == null || index < 0 || index >= items.length) return;
    mediaItem.add(items[index]);
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      PlaybackState(
        controls: notificationControls(playing: _player.playing),
        systemActions: systemActions,
        androidCompactActionIndices: const <int>[0, 2, 4],
        processingState: switch (event.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: _player.playing,
        updatePosition: event.updatePosition,
        bufferedPosition: event.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
        errorCode: event.errorCode,
        errorMessage: event.errorMessage,
      ),
    );
  }

  Future<void> disposeHandler() async {
    await _eventSubscription?.cancel();
    await _indexSubscription?.cancel();
    await _player.dispose();
  }
}
