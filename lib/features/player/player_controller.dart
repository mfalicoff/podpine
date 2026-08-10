import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart';
import 'podpine_audio_handler.dart';

/// UI-facing playback state. The platform-capable [AudioHandler] owns audio;
/// this controller maps its streams and commands onto Podpine's episode model.
class PlayerController extends ChangeNotifier {
  PlayerController(this.database, this._handler, this._recordPosition) {
    _playbackSubscription = _handler.playbackState.listen(_onPlaybackState);
    _mediaItemSubscription = _handler.mediaItem.listen(_onMediaItem);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final AppDatabase database;
  final AudioHandler _handler;
  final Future<void> Function(EpisodeRecord episode, Duration position)
  _recordPosition;
  final Map<int, EpisodeRecord> _episodesById = <int, EpisodeRecord>{};

  StreamSubscription<PlaybackState>? _playbackSubscription;
  StreamSubscription<MediaItem?>? _mediaItemSubscription;
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

  Duration get duration => Duration(seconds: current?.durationSeconds ?? 0);

  Future<void> playEpisode(EpisodeRecord episode) async {
    if (current?.id == episode.id) return toggle();

    await _persist();
    current = episode;
    position = Duration(seconds: episode.positionSeconds);
    _lastPersistedSecond = -1;
    loading = true;
    error = null;
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
      unawaited(_handler.play());
    } catch (_) {
      isPlaying = false;
      error = 'This episode could not be played.';
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
      isPlaying = true;
      unawaited(_handler.play());
    }
    notifyListeners();
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

  Future<void> previous() => _handler.skipToPrevious();

  Future<void> next() => _handler.skipToNext();

  Future<void> setSpeed(double value) async {
    speed = value;
    if (!_demoPlayback) await _handler.setSpeed(value);
    notifyListeners();
  }

  void _onPlaybackState(PlaybackState state) {
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
      error = 'This episode could not be played.';
    }
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

  void _tick() {
    if (_demoPlayback && isPlaying && current != null) {
      position += Duration(milliseconds: (1000 * speed).round());
      if (duration > Duration.zero && position >= duration) {
        position = duration;
        isPlaying = false;
        unawaited(database.setCompleted(current!.id, true));
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
    if (episode == null || position.inSeconds == _lastPersistedSecond) return;
    _lastPersistedSecond = position.inSeconds;
    await _recordPosition(episode, position);
  }

  @override
  void dispose() {
    unawaited(_persist());
    _timer?.cancel();
    unawaited(_playbackSubscription?.cancel());
    unawaited(_mediaItemSubscription?.cancel());
    super.dispose();
  }
}
