import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/database/app_database.dart';

const episodeIdExtra = 'episodeId';
const audioUrlExtra = 'audioUrl';
const playbackEventType = 'type';
const playbackCompletionEvent = 'episodeCompleted';
const playbackErrorEvent = 'playbackError';
const sleepTimerExpiredEvent = 'sleepTimerExpired';
const skipSilenceDiagnosticEvent = 'skipSilenceDiagnostic';
const setSkipSilenceAction = 'setSkipSilence';
const setSleepTimerAction = 'setSleepTimer';

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
    _discontinuitySubscription = _player.positionDiscontinuityStream.listen(
      _onPositionDiscontinuity,
    );
    _errorSubscription = _player.errorStream.listen(_onPlayerError);
  }

  final AudioPlayer _player = AudioPlayer();
  late final Future<void> _ready;
  StreamSubscription<PlaybackEvent>? _eventSubscription;
  StreamSubscription<int?>? _indexSubscription;
  StreamSubscription<PositionDiscontinuity>? _discontinuitySubscription;
  StreamSubscription<PlayerException>? _errorSubscription;
  final Set<int> _completedIndices = <int>{};
  int _queueGeneration = 0;
  Timer? _sleepTimer;
  bool _sleepAtEpisodeEnd = false;

  static const systemActions = <MediaAction>{
    MediaAction.seek,
    MediaAction.seekForward,
    MediaAction.seekBackward,
  };

  static List<MediaControl> notificationControls({required bool playing}) =>
      <MediaControl>[
        MediaControl.rewind,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward,
      ];

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    final activeItem = mediaItem.value;
    final activePosition = _player.position;
    final wasPlaying = _player.playing;
    _queueGeneration++;
    _completedIndices.clear();
    final newQueue = List<MediaItem>.unmodifiable(queue);
    this.queue.add(newQueue);
    if (newQueue.isEmpty) {
      await _player.stop();
      await _player.clearAudioSources();
      mediaItem.add(null);
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
    final preservedIndex = activeItem == null
        ? -1
        : newQueue.indexWhere((item) => item.id == activeItem.id);
    await _player.setAudioSources(
      sources,
      initialIndex: preservedIndex < 0 ? 0 : preservedIndex,
      initialPosition: preservedIndex < 0 ? Duration.zero : activePosition,
      preload: false,
    );
    if (preservedIndex >= 0) {
      mediaItem.add(newQueue[preservedIndex]);
      if (wasPlaying) unawaited(_player.play());
    } else {
      mediaItem.add(null);
    }
    _broadcastState(_player.playbackEvent);
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
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    switch (name) {
      case setSkipSilenceAction:
        final strength = '${extras?['strength'] ?? 'off'}';
        final enabled = strength != 'off';
        Object? failure;
        try {
          await _player.setSkipSilenceEnabled(enabled);
        } catch (error) {
          failure = error;
        }
        final supported =
            !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
        final diagnostics = <String, dynamic>{
          'strength': strength,
          'enabled': enabled && failure == null,
          'supported': supported,
          'nativeMode': supported ? 'androidSilenceSkipping' : 'unavailable',
          if (failure != null) 'error': '$failure',
        };
        customEvent.add(<String, dynamic>{
          playbackEventType: skipSilenceDiagnosticEvent,
          ...diagnostics,
        });
        return diagnostics;
      case setSleepTimerAction:
        _sleepTimer?.cancel();
        _sleepTimer = null;
        _sleepAtEpisodeEnd = extras?['endOfEpisode'] == true;
        final seconds = extras?['seconds'] as int?;
        if (seconds != null && seconds > 0) {
          _sleepAtEpisodeEnd = false;
          _sleepTimer = Timer(Duration(seconds: seconds), _expireSleepTimer);
        }
        return null;
      default:
        return super.customAction(name, extras);
    }
  }

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
    if (event.processingState == ProcessingState.completed) {
      _emitCompletion(event.currentIndex);
    }
    playbackState.add(
      PlaybackState(
        controls: notificationControls(playing: _player.playing),
        systemActions: systemActions,
        androidCompactActionIndices: const <int>[0, 1, 2],
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

  void _onPositionDiscontinuity(PositionDiscontinuity discontinuity) {
    if (discontinuity.reason != PositionDiscontinuityReason.autoAdvance) return;
    _emitCompletion(discontinuity.previousEvent.currentIndex);
  }

  void _emitCompletion(int? index) {
    final items = queue.value;
    if (index == null ||
        index < 0 ||
        index >= items.length ||
        !_completedIndices.add(index)) {
      return;
    }
    customEvent.add(<String, dynamic>{
      playbackEventType: playbackCompletionEvent,
      'eventId': '$_queueGeneration:$index',
      episodeIdExtra: episodeIdForMediaItem(items[index]),
    });
    if (_sleepAtEpisodeEnd) unawaited(_expireSleepTimer());
  }

  Future<void> _expireSleepTimer() async {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepAtEpisodeEnd = false;
    await _player.pause();
    customEvent.add(const <String, dynamic>{
      playbackEventType: sleepTimerExpiredEvent,
    });
  }

  void _onPlayerError(PlayerException error) {
    final index = error.index ?? _player.currentIndex;
    final items = queue.value;
    final episodeId = index != null && index >= 0 && index < items.length
        ? episodeIdForMediaItem(items[index])
        : null;
    final willSkip = _player.hasNext;
    customEvent.add(<String, dynamic>{
      playbackEventType: playbackErrorEvent,
      episodeIdExtra: episodeId,
      'willSkip': willSkip,
    });
    unawaited(_recoverFromError(willSkip: willSkip));
  }

  Future<void> _recoverFromError({required bool willSkip}) async {
    try {
      if (willSkip) {
        await skipToNext();
      } else {
        await _player.pause();
      }
    } catch (_) {
      await _player.pause();
    }
  }

  Future<void> disposeHandler() async {
    _sleepTimer?.cancel();
    await _eventSubscription?.cancel();
    await _indexSubscription?.cancel();
    await _discontinuitySubscription?.cancel();
    await _errorSubscription?.cancel();
    await _player.dispose();
  }
}
