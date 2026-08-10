import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';

import '../../core/database/app_database.dart';
import 'podpine_audio_handler.dart';

/// UI-facing playback state. The platform-capable [AudioHandler] owns audio;
/// this controller maps its streams and commands onto Podpine's episode model.
class PlayerController extends ChangeNotifier with WidgetsBindingObserver {
  PlayerController(
    this.database,
    this._handler,
    this._recordPosition,
    this._setCompleted,
  ) {
    WidgetsBinding.instance.addObserver(this);
    _playbackSubscription = _handler.playbackState.listen(_onPlaybackState);
    _mediaItemSubscription = _handler.mediaItem.listen(_onMediaItem);
    _customEventSubscription = _handler.customEvent.listen(_onCustomEvent);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final AppDatabase database;
  final AudioHandler _handler;
  final Future<void> Function(EpisodeRecord episode, Duration position)
  _recordPosition;
  final Future<void> Function(EpisodeRecord episode, bool completed)
  _setCompleted;
  final Map<int, EpisodeRecord> _episodesById = <int, EpisodeRecord>{};
  final Set<String> _handledCompletionEvents = <String>{};
  final Set<int> _completedEpisodeIds = <int>{};

  StreamSubscription<PlaybackState>? _playbackSubscription;
  StreamSubscription<MediaItem?>? _mediaItemSubscription;
  StreamSubscription<dynamic>? _customEventSubscription;
  Timer? _timer;
  PlaybackState _playbackState = PlaybackState();

  EpisodeRecord? current;
  Duration position = Duration.zero;
  bool isPlaying = false;
  bool loading = false;
  bool _demoPlayback = false;
  bool _selectingEpisode = false;
  int _lastPersistedSecond = -1;
  double speed = 1;
  String? error;
  bool errorCanRetry = false;

  Duration get duration => Duration(seconds: current?.durationSeconds ?? 0);

  Future<void> playEpisode(EpisodeRecord episode) async {
    if (current?.id == episode.id) return toggle();

    await _persist();
    _completedEpisodeIds.remove(episode.id);
    current = episode;
    position = Duration(seconds: episode.positionSeconds);
    _lastPersistedSecond = -1;
    loading = true;
    error = null;
    errorCanRetry = false;
    notifyListeners();

    if (episode.audioUrl.trim().isEmpty) {
      _demoPlayback = true;
      await _handler.stop();
      isPlaying = true;
      loading = false;
      notifyListeners();
      return;
    }

    _demoPlayback = false;
    _selectingEpisode = true;
    try {
      final storedQueue = await database.watchQueue().first;
      final playableQueue = storedQueue
          .where((item) => item.audioUrl.trim().isNotEmpty)
          .toList();
      if (!playableQueue.any((item) => item.id == episode.id)) {
        playableQueue.insert(0, episode);
      }

      _episodesById
        ..clear()
        ..addEntries(playableQueue.map((item) => MapEntry(item.id, item)));
      final queue = playableQueue.map(mediaItemForEpisode).toList();
      final activeIndex = playableQueue.indexWhere(
        (item) => item.id == episode.id,
      );

      await _handler.updateQueue(queue);
      await _handler.skipToQueueItem(activeIndex);
      await _handler.seek(position);
      await _handler.setSpeed(speed);
      isPlaying = true;
      unawaited(_playGuarded());
    } catch (_) {
      isPlaying = false;
      error = 'This episode could not be played.';
      errorCanRetry = true;
    } finally {
      _selectingEpisode = false;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (current == null) return;
    if (_demoPlayback) {
      isPlaying = !isPlaying;
      if (!isPlaying) await _persist();
    } else if (isPlaying) {
      isPlaying = false;
      await _handler.pause();
      await _persist();
    } else {
      error = null;
      errorCanRetry = false;
      isPlaying = true;
      unawaited(_playGuarded());
    }
    notifyListeners();
  }

  Future<void> _playGuarded() async {
    try {
      await _handler.play();
    } catch (_) {
      if (error == null) {
        isPlaying = false;
        error = 'This episode could not be played. Try again.';
        errorCanRetry = true;
        notifyListeners();
      }
    }
  }

  Future<void> seek(Duration target) async {
    final end = duration;
    final bounded = target < Duration.zero
        ? Duration.zero
        : end > Duration.zero && target > end
        ? end
        : target;
    position = bounded;
    if (!_demoPlayback) await _handler.seek(bounded);
    await _persist();
    notifyListeners();
  }

  Future<void> skip(int seconds) => seek(position + Duration(seconds: seconds));

  Future<void> previous() async {
    await _persist();
    await _handler.skipToPrevious();
  }

  Future<void> next() async {
    await _persist();
    await _handler.skipToNext();
  }

  Future<void> setSpeed(double value) async {
    speed = value;
    if (!_demoPlayback) await _handler.setSpeed(value);
    notifyListeners();
  }

  void _onPlaybackState(PlaybackState state) {
    final wasPlaying = isPlaying;
    _playbackState = state;
    if (_demoPlayback) return;
    isPlaying =
        state.playing &&
        state.processingState != AudioProcessingState.completed;
    loading =
        state.processingState == AudioProcessingState.loading ||
        state.processingState == AudioProcessingState.buffering;
    position = state.position;
    speed = state.speed;
    if (state.processingState == AudioProcessingState.error) {
      error ??= 'This episode could not be played. Try again.';
      errorCanRetry = true;
    }
    if (wasPlaying && !isPlaying) unawaited(_persist());
    notifyListeners();
  }

  void _onMediaItem(MediaItem? item) {
    if (item == null || _demoPlayback || _selectingEpisode) return;
    final episodeId = episodeIdForMediaItem(item);
    final episode = episodeId == null ? null : _episodesById[episodeId];
    if (episode == null || episode.id == current?.id) return;

    final previousEpisode = current;
    final previousPosition = position;
    current = episode;
    position = _playbackState.position;
    _lastPersistedSecond = -1;
    if (previousEpisode != null) {
      unawaited(_recordPosition(previousEpisode, previousPosition));
    }
    notifyListeners();
  }

  void _onCustomEvent(dynamic event) {
    if (event is! Map) return;
    final type = event[playbackEventType];
    final rawEpisodeId = event[episodeIdExtra];
    final episodeId = rawEpisodeId is int
        ? rawEpisodeId
        : int.tryParse('$rawEpisodeId');
    if (type == playbackCompletionEvent && episodeId != null) {
      final eventId = '${event['eventId']}';
      if (!_handledCompletionEvents.add(eventId)) return;
      final episode = _episodesById[episodeId];
      if (episode == null) return;
      _completedEpisodeIds.add(episodeId);
      unawaited(_completeEpisode(episode));
      return;
    }
    if (type == playbackErrorEvent) {
      final episode = episodeId == null ? null : _episodesById[episodeId];
      final title = episode?.title ?? 'this episode';
      final willSkip = event['willSkip'] == true;
      error = willSkip
          ? 'Couldn’t play “$title”. Skipped to the next episode.'
          : 'Couldn’t play “$title”. Check your connection and try again.';
      errorCanRetry = !willSkip;
      notifyListeners();
    }
  }

  Future<void> _completeEpisode(EpisodeRecord episode) async {
    final completedPosition = episode.durationSeconds > 0
        ? Duration(seconds: episode.durationSeconds)
        : position;
    if (current?.id != episode.id ||
        _lastPersistedSecond != completedPosition.inSeconds) {
      if (current?.id == episode.id) {
        _lastPersistedSecond = completedPosition.inSeconds;
      }
      await _recordPosition(episode, completedPosition);
    }
    await _setCompleted(episode, true);
  }

  void dismissError() {
    error = null;
    errorCanRetry = false;
    notifyListeners();
  }

  Future<void> retry() async {
    if (current == null || _demoPlayback) return;
    loading = true;
    error = null;
    errorCanRetry = false;
    notifyListeners();
    try {
      await _handler.seek(position);
      loading = false;
      isPlaying = true;
      notifyListeners();
      unawaited(_playGuarded());
    } catch (_) {
      isPlaying = false;
      error = 'This episode could not be played. Try again.';
      errorCanRetry = true;
      loading = false;
      notifyListeners();
    }
  }

  void _tick() {
    if (_demoPlayback && isPlaying && current != null) {
      position += Duration(milliseconds: (1000 * speed).round());
      if (duration > Duration.zero && position >= duration) {
        position = duration;
        isPlaying = false;
        final completed = current!;
        if (_completedEpisodeIds.add(completed.id)) {
          unawaited(_completeEpisode(completed));
        }
      }
      notifyListeners();
    } else if (!_demoPlayback && isPlaying) {
      position = _playbackState.position;
      notifyListeners();
    }

    if (isPlaying && position.inSeconds > 0 && position.inSeconds % 15 == 0) {
      unawaited(_persist());
    }
  }

  Future<void> _persist() async {
    final episode = current;
    if (episode == null ||
        _completedEpisodeIds.contains(episode.id) ||
        position.inSeconds == _lastPersistedSecond) {
      return;
    }
    _lastPersistedSecond = position.inSeconds;
    await _recordPosition(episode, position);
  }

  Future<void> flushPosition() => _persist();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(flushPosition());
      case AppLifecycleState.resumed:
        if (!_demoPlayback && current != null) {
          position = _playbackState.position;
          notifyListeners();
        }
    }
  }

  @override
  void dispose() {
    unawaited(_persist());
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    unawaited(_playbackSubscription?.cancel());
    unawaited(_mediaItemSubscription?.cancel());
    unawaited(_customEventSubscription?.cancel());
    super.dispose();
  }
}
