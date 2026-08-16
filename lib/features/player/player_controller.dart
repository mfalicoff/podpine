import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/database/app_database.dart';
import 'playback_options.dart';
import 'podpine_audio_handler.dart';

/// UI-facing playback state. The platform-capable [AudioHandler] owns audio;
/// this controller maps its streams and commands onto Podpine's episode model.
class PlayerController extends ChangeNotifier with WidgetsBindingObserver {
  PlayerController(
    this.database,
    this._handler,
    this._recordPosition,
    this._setCompleted, {
    Future<String> Function(EpisodeRecord episode)? chapterLoader,
    this.recordSeek,
  }) : _loadChapters = chapterLoader {
    WidgetsBinding.instance.addObserver(this);
    _playbackSubscription = _handler.playbackState.listen(_onPlaybackState);
    _mediaItemSubscription = _handler.mediaItem.listen(_onMediaItem);
    _customEventSubscription = _handler.customEvent.listen(_onCustomEvent);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _settingsReady = _loadSettings();
  }

  final AppDatabase database;
  final AudioHandler _handler;
  final Future<void> Function(EpisodeRecord episode, Duration position)
  _recordPosition;
  final Future<void> Function(EpisodeRecord episode, bool completed)
  _setCompleted;
  final Future<void> Function(EpisodeRecord episode, Duration position)?
  recordSeek;
  final Future<String> Function(EpisodeRecord episode)? _loadChapters;
  final Map<int, EpisodeRecord> _episodesById = <int, EpisodeRecord>{};
  final Set<String> _handledCompletionEvents = <String>{};
  final Set<int> _completedEpisodeIds = <int>{};

  StreamSubscription<PlaybackState>? _playbackSubscription;
  StreamSubscription<MediaItem?>? _mediaItemSubscription;
  StreamSubscription<dynamic>? _customEventSubscription;
  Timer? _timer;
  late final Future<void> _settingsReady;
  PlaybackState _playbackState = PlaybackState();
  List<int> _playbackQueueIds = const <int>[];
  List<String> _playbackQueueAudioUrls = const <String>[];
  Map<int, String> _completedDownloadPaths = const <int, String>{};

  EpisodeRecord? current;
  Duration position = Duration.zero;
  bool isPlaying = false;
  bool loading = false;
  bool _demoPlayback = false;
  bool _selectingEpisode = false;
  bool _downloadSourceRefreshPending = false;
  int _lastPersistedSecond = -1;
  double speed = 1;
  PlaybackPreferences globalPreferences = const PlaybackPreferences();
  final Map<int, PodcastPlaybackOverride> _podcastOverrides =
      <int, PodcastPlaybackOverride>{};
  SkipSilenceStrength skipSilence = SkipSilenceStrength.off;
  String skipSilenceDiagnostics = 'Silence skipping is off.';
  DateTime? sleepTimerEndsAt;
  bool sleepAtEpisodeEnd = false;
  String? error;
  bool errorCanRetry = false;

  Duration get duration => Duration(seconds: current?.durationSeconds ?? 0);

  List<PodcastChapter> get chapters {
    final episode = current;
    if (episode == null) return const <PodcastChapter>[];
    return ChapterParser.parse(
      episode.chaptersJson,
      description: episode.description,
    );
  }

  PodcastChapter? get currentChapter {
    PodcastChapter? active;
    for (final chapter in chapters) {
      if (chapter.start > position) break;
      active = chapter;
    }
    return active;
  }

  Duration? get sleepTimerRemaining {
    final end = sleepTimerEndsAt;
    if (end == null) return null;
    final remaining = end.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get hasPodcastSpeedOverride =>
      current != null && _podcastOverrides[current!.podcastId]?.speed != null;

  bool get hasPodcastSkipSilenceOverride =>
      current != null &&
      _podcastOverrides[current!.podcastId]?.skipSilence != null;

  Future<void> playEpisode(EpisodeRecord episode) async {
    if (current?.id == episode.id) return toggle();

    await _settingsReady;
    await _persist();
    final storedEpisode = await database.episodeById(episode.id);
    _playbackTrace(
      'playEpisode id=${episode.id} uiPosition=${episode.positionSeconds}s '
      'databasePosition=${storedEpisode?.positionSeconds}s '
      'currentId=${current?.id}',
    );
    _completedEpisodeIds.remove(episode.id);
    current = episode;
    unawaited(_hydrateChapters(episode));
    final resumePosition = Duration(seconds: episode.positionSeconds);
    position = resumePosition;
    _lastPersistedSecond = -1;
    loading = true;
    error = null;
    errorCanRetry = false;
    _selectEffectiveSettings(episode.podcastId);
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
      final queue = await _mediaItems(playableQueue);
      final activeIndex = playableQueue.indexWhere(
        (item) => item.id == episode.id,
      );
      _playbackTrace(
        'selectQueue id=${episode.id} index=$activeIndex '
        'resume=${resumePosition.inSeconds}s queueSize=${queue.length}',
      );

      await _handler.updateQueue(queue);
      _playbackQueueIds = playableQueue
          .map((episode) => episode.id)
          .toList(growable: false);
      _playbackQueueAudioUrls = _audioUrls(queue);
      await _handler.skipToQueueItem(activeIndex);
      // `updateQueue` deliberately avoids preloading network media. Prepare
      // the selected source before seeking: on Android, an idle ExoPlayer can
      // report an accepted seek and then reset it when `play()` loads media.
      await _handler.prepare();
      // Queue selection briefly reports its initial position (zero) through
      // the playback-state stream. Keep the persisted resume point captured
      // above so that transient state cannot change the requested seek.
      await _handler.seek(resumePosition);
      _playbackTrace(
        'seekSent id=${episode.id} requested=${resumePosition.inSeconds}s '
        'controllerPosition=${position.inSeconds}s',
      );
      await _handler.setSpeed(speed);
      await _applySkipSilence();
      isPlaying = true;
      unawaited(_playGuarded());
    } catch (_) {
      isPlaying = false;
      error = 'This episode could not be played.';
      errorCanRetry = true;
    } finally {
      _selectingEpisode = false;
      loading = false;
      if (_downloadSourceRefreshPending) {
        _refreshPlaybackSourcesWhenReady();
      }
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
    final episode = current;
    final seekRecorder = recordSeek;
    if (episode != null && seekRecorder != null) {
      _lastPersistedSecond = position.inSeconds;
      await seekRecorder(episode, position);
    } else {
      await _persist();
    }
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

  Future<void> setSpeed(double value, {bool forPodcast = false}) async {
    await _settingsReady;
    final normalized = (value.clamp(0.5, 3.0) * 20).round() / 20;
    final episode = current;
    if (forPodcast && episode != null) {
      final existing =
          _podcastOverrides[episode.podcastId] ??
          const PodcastPlaybackOverride();
      final updated = PodcastPlaybackOverride(
        speed: normalized,
        skipSilence: existing.skipSilence,
      );
      _podcastOverrides[episode.podcastId] = updated;
      await database.setPodcastPlaybackOverride(episode.podcastId, updated);
    } else {
      globalPreferences = PlaybackPreferences(
        speed: normalized,
        skipSilence: globalPreferences.skipSilence,
      );
      await database.setGlobalPlaybackPreferences(globalPreferences);
    }
    speed = normalized;
    if (!_demoPlayback) await _handler.setSpeed(normalized);
    notifyListeners();
  }

  Future<void> clearPodcastSpeedOverride() async {
    await _settingsReady;
    final episode = current;
    if (episode == null) return;
    final existing =
        _podcastOverrides[episode.podcastId] ?? const PodcastPlaybackOverride();
    final updated = PodcastPlaybackOverride(skipSilence: existing.skipSilence);
    await _savePodcastOverride(episode.podcastId, updated);
    speed = globalPreferences.speed;
    if (!_demoPlayback) await _handler.setSpeed(speed);
    notifyListeners();
  }

  Future<void> setSkipSilence(
    SkipSilenceStrength value, {
    bool forPodcast = false,
  }) async {
    await _settingsReady;
    final episode = current;
    if (forPodcast && episode != null) {
      final existing =
          _podcastOverrides[episode.podcastId] ??
          const PodcastPlaybackOverride();
      final updated = PodcastPlaybackOverride(
        speed: existing.speed,
        skipSilence: value,
      );
      await _savePodcastOverride(episode.podcastId, updated);
    } else {
      globalPreferences = PlaybackPreferences(
        speed: globalPreferences.speed,
        skipSilence: value,
      );
      await database.setGlobalPlaybackPreferences(globalPreferences);
    }
    skipSilence = value;
    await _applySkipSilence();
    notifyListeners();
  }

  Future<void> clearPodcastSkipSilenceOverride() async {
    await _settingsReady;
    final episode = current;
    if (episode == null) return;
    final existing =
        _podcastOverrides[episode.podcastId] ?? const PodcastPlaybackOverride();
    await _savePodcastOverride(
      episode.podcastId,
      PodcastPlaybackOverride(speed: existing.speed),
    );
    skipSilence = globalPreferences.skipSilence;
    await _applySkipSilence();
    notifyListeners();
  }

  Future<void> setSleepTimer(
    Duration? duration, {
    bool endOfEpisode = false,
  }) async {
    await _settingsReady;
    sleepTimerEndsAt = duration == null ? null : DateTime.now().add(duration);
    sleepAtEpisodeEnd = endOfEpisode;
    await _handler.customAction(setSleepTimerAction, <String, dynamic>{
      if (duration != null) 'seconds': duration.inSeconds,
      'endOfEpisode': endOfEpisode,
    });
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
    if (_selectingEpisode) {
      _playbackTrace(
        'selectionState id=${current?.id} '
        'processing=${state.processingState.name} '
        'position=${state.position.inMilliseconds}ms '
        'playing=${state.playing}',
      );
    }
    if (!_selectingEpisode) speed = state.speed;
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
    unawaited(_hydrateChapters(episode));
    position = _playbackState.position;
    _lastPersistedSecond = -1;
    _selectEffectiveSettings(episode.podcastId);
    unawaited(_applyEffectiveSettings());
    if (previousEpisode != null) {
      unawaited(_recordPosition(previousEpisode, previousPosition));
    }
    notifyListeners();
  }

  Future<void> syncQueue(List<EpisodeRecord> storedQueue) async {
    final active = current;
    if (active == null || _demoPlayback || _selectingEpisode || loading) return;
    await _syncPlaybackQueue(storedQueue, active);
  }

  void syncDownloadJobs(List<DownloadJobRecord> jobs) {
    final completedPaths = <int, String>{
      for (final job in jobs)
        if (job.state == 'completed') job.episodeId: job.filePath,
    };
    final hasNewCompletedSource = completedPaths.entries.any(
      (entry) => _completedDownloadPaths[entry.key] != entry.value,
    );
    _completedDownloadPaths = completedPaths;
    if (!hasNewCompletedSource) return;

    _refreshPlaybackSourcesWhenReady();
  }

  void _refreshPlaybackSourcesWhenReady() {
    final active = current;
    if (active == null || _demoPlayback) return;
    if (_selectingEpisode) {
      _downloadSourceRefreshPending = true;
      return;
    }
    _downloadSourceRefreshPending = false;
    unawaited(_refreshPlaybackSources(active.id));
  }

  Future<void> _refreshPlaybackSources(int activeEpisodeId) async {
    final active = current;
    if (active == null || active.id != activeEpisodeId) return;
    final storedQueue = await database.watchQueue().first;
    final refreshedActive = await database.episodeById(activeEpisodeId);
    if (current?.id != activeEpisodeId) return;
    await _syncPlaybackQueue(storedQueue, refreshedActive ?? active);
  }

  Future<void> _syncPlaybackQueue(
    List<EpisodeRecord> storedQueue,
    EpisodeRecord active,
  ) async {
    final playableQueue = storedQueue
        .where((episode) => episode.audioUrl.trim().isNotEmpty)
        .toList();
    if (!playableQueue.any((episode) => episode.id == active.id)) {
      playableQueue.insert(0, active);
    }
    final ids = playableQueue
        .map((episode) => episode.id)
        .toList(growable: false);
    final queue = await _mediaItems(playableQueue);
    final audioUrls = _audioUrls(queue);
    _episodesById
      ..clear()
      ..addEntries(
        playableQueue.map((episode) => MapEntry(episode.id, episode)),
      );
    if (listEquals(ids, _playbackQueueIds) &&
        listEquals(audioUrls, _playbackQueueAudioUrls)) {
      return;
    }
    try {
      await _handler.updateQueue(queue);
      _playbackQueueIds = ids;
      _playbackQueueAudioUrls = audioUrls;
    } catch (_) {
      // Playback continues on its existing queue. A later database emission
      // retries the update without replacing the active episode in the UI.
    }
  }

  Future<List<MediaItem>> _mediaItems(List<EpisodeRecord> episodes) async {
    final paths = await database.completedDownloadPaths(
      episodes.map((episode) => episode.id),
    );
    return episodes
        .map(
          (episode) =>
              mediaItemForEpisode(episode, localPath: paths[episode.id]),
        )
        .toList(growable: false);
  }

  List<String> _audioUrls(List<MediaItem> items) => items
      .map((item) => item.extras?[audioUrlExtra] as String? ?? '')
      .toList(growable: false);

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
      return;
    }
    if (type == sleepTimerExpiredEvent) {
      sleepTimerEndsAt = null;
      sleepAtEpisodeEnd = false;
      isPlaying = false;
      notifyListeners();
      return;
    }
    if (type == skipSilenceDiagnosticEvent) {
      _updateSkipSilenceDiagnostics(event);
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    globalPreferences = await database.playbackPreferences();
    _podcastOverrides
      ..clear()
      ..addAll(await database.podcastPlaybackOverrides());
    if (current == null) {
      speed = globalPreferences.speed;
      skipSilence = globalPreferences.skipSilence;
    }
    notifyListeners();
  }

  Future<void> _hydrateChapters(EpisodeRecord episode) async {
    final loader = _loadChapters;
    if (loader == null || episode.chaptersJson != '[]') return;
    final metadata = await loader(episode);
    if (metadata == '[]' || current?.id != episode.id) return;
    final hydrated = episode.copyWith(chaptersJson: metadata);
    current = hydrated;
    _episodesById[episode.id] = hydrated;
    notifyListeners();
  }

  void _selectEffectiveSettings(int podcastId) {
    final override = _podcastOverrides[podcastId];
    speed = override?.speed ?? globalPreferences.speed;
    skipSilence = override?.skipSilence ?? globalPreferences.skipSilence;
  }

  Future<void> _applyEffectiveSettings() async {
    if (_demoPlayback) return;
    await _handler.setSpeed(speed);
    await _applySkipSilence();
  }

  Future<void> _applySkipSilence() async {
    if (_demoPlayback) {
      skipSilenceDiagnostics = skipSilence == SkipSilenceStrength.off
          ? 'Silence skipping is off.'
          : '${skipSilence.label} silence skipping is selected (demo playback).';
      return;
    }
    final result = await _handler.customAction(
      setSkipSilenceAction,
      <String, dynamic>{'strength': skipSilence.name},
    );
    if (result is Map) _updateSkipSilenceDiagnostics(result);
  }

  void _updateSkipSilenceDiagnostics(Map event) {
    if (event['supported'] == false && skipSilence != SkipSilenceStrength.off) {
      skipSilenceDiagnostics =
          '${skipSilence.label} selected; native silence skipping is unavailable on this platform.';
    } else if (event['error'] != null) {
      skipSilenceDiagnostics =
          'Silence skipping could not be enabled: ${event['error']}';
    } else if (skipSilence == SkipSilenceStrength.off) {
      skipSilenceDiagnostics = 'Silence skipping is off.';
    } else {
      skipSilenceDiagnostics =
          '${skipSilence.label} mode uses the platform speech-safe silence detector.';
    }
  }

  Future<void> _savePodcastOverride(
    int podcastId,
    PodcastPlaybackOverride value,
  ) async {
    if (value.isEmpty) {
      _podcastOverrides.remove(podcastId);
    } else {
      _podcastOverrides[podcastId] = value;
    }
    await database.setPodcastPlaybackOverride(podcastId, value);
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
    final remaining = sleepTimerRemaining;
    if (remaining == Duration.zero && sleepTimerEndsAt != null) {
      sleepTimerEndsAt = null;
      sleepAtEpisodeEnd = false;
      if (_demoPlayback) isPlaying = false;
    }
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

void _playbackTrace(String message) {
  if (kDebugMode) debugPrint('[PodpinePlayback][controller] $message');
}
