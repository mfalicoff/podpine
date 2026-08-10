import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/database/app_database.dart';

class PlayerController extends ChangeNotifier {
  PlayerController(this.database, this._recordPosition) {
    _stateSubscription = _audio.playerStateStream.listen((state) {
      if (!_demoPlayback) isPlaying = state.playing;
      notifyListeners();
    });
    _positionSubscription = _audio.positionStream.listen((value) {
      if (_demoPlayback) return;
      position = value;
      notifyListeners();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final AppDatabase database;
  final Future<void> Function(EpisodeRecord episode, Duration position)
  _recordPosition;
  final AudioPlayer _audio = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  Timer? _timer;

  EpisodeRecord? current;
  Duration position = Duration.zero;
  bool isPlaying = false;
  bool loading = false;
  bool _demoPlayback = false;
  int _lastPersistedSecond = -1;
  double speed = 1;
  String? error;

  Duration get duration => Duration(seconds: current?.durationSeconds ?? 0);

  Future<void> playEpisode(EpisodeRecord episode) async {
    if (current?.id == episode.id) {
      return toggle();
    }
    await _persist();
    current = episode;
    position = Duration(seconds: episode.positionSeconds);
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (episode.audioUrl.isEmpty) {
        _demoPlayback = true;
        isPlaying = true;
      } else {
        _demoPlayback = false;
        await _audio.setUrl(episode.audioUrl);
        await _audio.seek(position);
        await _audio.setSpeed(speed);
        await _audio.play();
      }
    } catch (_) {
      isPlaying = false;
      error = 'This episode could not be played.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (current == null) return;
    if (_demoPlayback) {
      isPlaying = !isPlaying;
      if (!isPlaying) await _persist();
    } else if (_audio.playing) {
      await _audio.pause();
      await _persist();
    } else {
      await _audio.play();
    }
    notifyListeners();
  }

  Future<void> seek(Duration target) async {
    final bounded = target < Duration.zero
        ? Duration.zero
        : target > duration
        ? duration
        : target;
    position = bounded;
    if (!_demoPlayback) await _audio.seek(bounded);
    await _persist();
    notifyListeners();
  }

  Future<void> skip(int seconds) => seek(position + Duration(seconds: seconds));

  Future<void> setSpeed(double value) async {
    speed = value;
    if (!_demoPlayback) await _audio.setSpeed(value);
    notifyListeners();
  }

  void _tick() {
    if (_demoPlayback && isPlaying && current != null) {
      position += Duration(milliseconds: (1000 * speed).round());
      if (position >= duration) {
        position = duration;
        isPlaying = false;
        database.setCompleted(current!.id, true);
      }
      notifyListeners();
    }
    if (isPlaying && position.inSeconds > 0 && position.inSeconds % 15 == 0) {
      _persist();
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
    _persist();
    _timer?.cancel();
    _stateSubscription?.cancel();
    _positionSubscription?.cancel();
    _audio.dispose();
    super.dispose();
  }
}
