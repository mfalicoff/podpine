import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'core/backend/pinepods_backend.dart';
import 'core/backend/podcast_backend.dart';
import 'core/database/app_database.dart';
import 'core/storage/credential_store.dart';
import 'core/sync/queue_sync.dart';
import 'core/sync/playback_sync.dart';
import 'core/sync/sync_engine.dart';

class AppController extends ChangeNotifier {
  AppController(
    this.database,
    this.credentials, {
    Stream<List<ConnectivityResult>>? connectivityChanges,
    String? playbackDeviceId,
  }) : _connectivityChanges =
           connectivityChanges ?? Connectivity().onConnectivityChanged,
       _deviceIdCandidate = playbackDeviceId ?? _uuid.v4();

  final AppDatabase database;
  final CredentialStore credentials;
  final Stream<List<ConnectivityResult>> _connectivityChanges;
  final String _deviceIdCandidate;

  bool initialized = false;
  bool connected = false;
  bool demoMode = false;
  bool busy = false;
  String? error;
  String? serverUrl;
  int? userId;
  DateTime? lastSyncedAt;
  PodcastBackend? backend;
  int? Function()? activeEpisodeId;
  String? _apiKey;
  Future<void>? _refreshInFlight;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool? _wasOffline;
  Future<String>? _deviceIdFuture;
  static const _uuid = Uuid();

  Future<void> initialize() async {
    _listenForConnectivityRestoration();
    try {
      final stored = await credentials.read();
      if (stored != null) {
        serverUrl = stored.serverUrl;
        userId = stored.userId;
        _apiKey = stored.apiKey;
        backend = PinepodsBackend(
          serverUrl: stored.serverUrl,
          apiKey: stored.apiKey,
        );
        connected = true;
        await _resolveUserIdentity();
        await refresh(silent: true);
      }
    } catch (_) {
      // Cached content remains available even when secure storage or the
      // self-hosted server is temporarily unavailable.
    } finally {
      initialized = true;
      notifyListeners();
    }
  }

  Future<void> connect(String rawServerUrl, String apiKey) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final normalized = _normalizeUrl(rawServerUrl);
      final candidate = PinepodsBackend(
        serverUrl: normalized,
        apiKey: apiKey.trim(),
      );
      final verifiedUserId = await candidate.verifyConnection();
      await credentials.write(
        StoredSession(
          serverUrl: normalized,
          apiKey: apiKey.trim(),
          userId: verifiedUserId,
        ),
      );
      backend = candidate;
      _apiKey = apiKey.trim();
      serverUrl = normalized;
      userId = verifiedUserId;
      connected = true;
      demoMode = false;
      await refresh(silent: true);
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> enterDemo() async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await database.seedDemo();
      demoMode = true;
      connected = true;
      serverUrl = 'Demo library';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refresh({
    bool silent = false,
    bool forceMutationRetry = false,
  }) async {
    final current = _refreshInFlight;
    if (current != null) {
      await current;
      return;
    }
    final operation = _performRefresh(
      silent: silent,
      forceMutationRetry: forceMutationRetry,
    );
    _refreshInFlight = operation;
    try {
      await operation;
    } finally {
      if (identical(_refreshInFlight, operation)) _refreshInFlight = null;
    }
  }

  Future<void> _performRefresh({
    required bool silent,
    required bool forceMutationRetry,
  }) async {
    if (backend == null || userId == null) return;
    if (!silent) {
      busy = true;
      error = null;
      notifyListeners();
    }
    try {
      await SyncEngine(
        database,
        backend!,
        userId!,
      ).refresh(forceMutationRetry: forceMutationRetry);
      lastSyncedAt = DateTime.now();
    } catch (exception) {
      if (exception is PinepodsException && exception.statusCode == 403) {
        try {
          await _resolveUserIdentity();
          await SyncEngine(
            database,
            backend!,
            userId!,
          ).refresh(forceMutationRetry: forceMutationRetry);
          lastSyncedAt = DateTime.now();
          error = null;
          return;
        } catch (_) {
          // Fall through to the cached-library state below.
        }
      }
      error = 'Offline — showing saved library';
      if (!silent) rethrow;
    } finally {
      if (!silent) busy = false;
      notifyListeners();
    }
  }

  Future<List<RemotePodcast>> searchCachedPodcasts(String query) async {
    final rows = await database.searchDiscoveryCache(query);
    return rows
        .map((row) {
          try {
            return RemotePodcast.fromJson(
              (jsonDecode(row.podcastJson) as Map).cast<String, Object?>(),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<RemotePodcast>()
        .toList(growable: false);
  }

  Future<List<RemotePodcast>> searchPodcasts(
    String query, {
    String provider = 'podcast_index',
  }) async {
    final currentBackend = backend;
    if (currentBackend == null || userId == null) {
      return searchCachedPodcasts(query);
    }
    final results = await currentBackend.searchPodcasts(
      query,
      provider: provider,
    );
    await Future.wait(results.map(_cachePodcast));
    error = null;
    notifyListeners();
    return results;
  }

  Future<PodcastDetailBundle> cachedPodcastDetails(RemotePodcast seed) async {
    var podcast = seed;
    var cachedEpisodes = const <RemoteEpisode>[];
    final cached = await database.discoveryCache(seed.feedUrl);
    if (cached != null) {
      try {
        podcast = RemotePodcast.fromJson(
          (jsonDecode(cached.podcastJson) as Map).cast<String, Object?>(),
        );
        cachedEpisodes = (jsonDecode(cached.episodesJson) as List)
            .whereType<Map>()
            .map((json) => RemoteEpisode.fromJson(json.cast<String, Object?>()))
            .toList(growable: false);
      } catch (_) {
        podcast = seed;
        cachedEpisodes = const [];
      }
    }
    final localPodcast = await database.podcastByFeedUrl(seed.feedUrl);
    if (localPodcast == null) {
      return PodcastDetailBundle(
        podcast: podcast,
        episodes: cachedEpisodes,
        subscribed: false,
      );
    }
    final records = await database.podcastEpisodes(localPodcast.id);
    final localById = {for (final episode in records) episode.id: episode};
    return PodcastDetailBundle(
      podcast: _remotePodcast(localPodcast, fallback: podcast),
      episodes: _mergeSavedEpisodes(cachedEpisodes, records),
      subscribed: true,
      localEpisodes: localById,
    );
  }

  Future<PodcastDetailBundle> refreshPodcastDetails(RemotePodcast seed) async {
    final currentBackend = backend;
    final currentUserId = userId;
    if (currentBackend == null || currentUserId == null) {
      return cachedPodcastDetails(seed);
    }
    final localPodcast = await database.podcastByFeedUrl(seed.feedUrl);
    final subscribed = localPodcast != null;
    final requestPodcast = localPodcast == null
        ? seed
        : _remotePodcast(localPodcast, fallback: seed);
    final details = await currentBackend.getPodcastDetails(
      currentUserId,
      requestPodcast,
      subscribed: subscribed,
    );
    final episodes = await currentBackend.getPodcastEpisodes(
      currentUserId,
      details,
      subscribed: subscribed,
    );
    await _cachePodcast(details, episodes: episodes);
    if (localPodcast != null) {
      final existingEpisodes = await database.podcastEpisodes(localPodcast.id);
      final existingById = {
        for (final episode in existingEpisodes) episode.id: episode,
      };
      await database.upsertPodcast(
        _podcastCompanion(details.copyWith(id: localPodcast.id)),
      );
      await database.upsertEpisodes(
        episodes.map(
          (episode) => _episodeCompanion(
            episode,
            podcastId: localPodcast.id,
            podcastTitle: details.title,
            existing: existingById[episode.id],
          ),
        ),
      );
    }
    final refreshedLocalEpisodes = localPodcast == null
        ? const <EpisodeRecord>[]
        : await database.podcastEpisodes(localPodcast.id);
    return PodcastDetailBundle(
      podcast: details.copyWith(id: localPodcast?.id ?? details.id),
      episodes: localPodcast == null
          ? episodes
          : _mergeSavedEpisodes(episodes, refreshedLocalEpisodes),
      subscribed: subscribed,
      localEpisodes: {
        for (final episode in refreshedLocalEpisodes) episode.id: episode,
      },
    );
  }

  Future<bool> isSubscribed(String feedUrl) async =>
      await database.podcastByFeedUrl(feedUrl) != null;

  Future<void> subscribe(RemotePodcast podcast) async {
    final currentBackend = backend;
    final currentUserId = userId;
    if (currentBackend == null || currentUserId == null) {
      throw const PinepodsException('Connect a Pinepods account to subscribe.');
    }
    final temporary = podcast.copyWith(
      id: _temporaryPodcastId(podcast.feedUrl),
    );
    await _cachePodcast(temporary);
    await database.upsertPodcast(_podcastCompanion(temporary));
    notifyListeners();
    try {
      final remoteId = await currentBackend.subscribe(currentUserId, podcast);
      if (remoteId > 0) {
        await database.reconcilePodcastId(
          temporaryId: temporary.id,
          podcast: _podcastCompanion(podcast.copyWith(id: remoteId)),
        );
      }
      error = null;
      unawaited(refresh(silent: true));
    } catch (_) {
      await _enqueueMutation('podcast_subscribe', null, temporary.toJson());
      error = 'Subscription saved offline and will sync automatically.';
    }
    notifyListeners();
  }

  Future<void> unsubscribe(RemotePodcast podcast) async {
    final local = await database.podcastByFeedUrl(podcast.feedUrl);
    final saved = local == null
        ? podcast
        : _remotePodcast(local, fallback: podcast);
    await _cachePodcast(saved);
    await database.removePodcastByFeedUrl(saved.feedUrl);
    notifyListeners();
    if (backend == null || userId == null) {
      await _enqueueMutation('podcast_unsubscribe', null, saved.toJson());
      error = 'Unsubscription saved offline and will sync automatically.';
      notifyListeners();
      return;
    }
    try {
      await backend!.unsubscribe(userId!, saved);
      error = null;
      unawaited(refresh(silent: true));
    } catch (_) {
      await _enqueueMutation('podcast_unsubscribe', null, saved.toJson());
      error = 'Unsubscription saved offline and will sync automatically.';
    }
    notifyListeners();
  }

  Future<void> setCompleted(EpisodeRecord episode, bool completed) async {
    final occurredAt = DateTime.now().toUtc();
    final deviceId = await _playbackDeviceId();
    final event = PlaybackSyncEvent(
      episodeId: episode.id,
      positionSeconds: completed && episode.durationSeconds > 0
          ? episode.durationSeconds
          : episode.positionSeconds,
      durationSeconds: episode.durationSeconds,
      completed: completed,
      kind: completed
          ? PlaybackEventKind.completed
          : PlaybackEventKind.uncompleted,
      occurredAt: occurredAt,
      deviceId: deviceId,
      mediaIdentity: episode.audioUrl.trim(),
    );
    await database.setCompleted(
      episode.id,
      completed,
      playbackUpdatedAt: occurredAt,
      deviceId: deviceId,
      mediaIdentity: event.mediaIdentity,
    );
    if (backend != null && userId != null && episode.id > 0) {
      try {
        await _sendPlaybackEvent(event);
      } catch (_) {
        await _enqueueMutation('completed', episode.id, {
          ...event.toPayload(),
          'value': completed,
        });
        error =
            'Saved offline. The change will sync when the server is available.';
        notifyListeners();
      }
    }
  }

  Future<void> recordPosition(
    EpisodeRecord episode,
    Duration position, {
    bool userInitiatedSeek = false,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[PodpinePlayback][persistence] recordPosition id=${episode.id} '
        'position=${position.inSeconds}s seek=$userInitiatedSeek',
      );
    }
    final occurredAt = DateTime.now().toUtc();
    final deviceId = await _playbackDeviceId();
    final event = PlaybackSyncEvent(
      episodeId: episode.id,
      positionSeconds: position.inSeconds,
      durationSeconds: episode.durationSeconds,
      completed: false,
      kind: userInitiatedSeek
          ? PlaybackEventKind.seek
          : PlaybackEventKind.progress,
      occurredAt: occurredAt,
      deviceId: deviceId,
      mediaIdentity: episode.audioUrl.trim(),
    );
    await database.setPosition(
      episode.id,
      position,
      playbackUpdatedAt: occurredAt,
      deviceId: deviceId,
      userInitiatedSeek: userInitiatedSeek,
      mediaIdentity: event.mediaIdentity,
    );
    if (backend != null && userId != null && episode.id > 0) {
      try {
        await _sendPlaybackEvent(event);
        await database.acknowledgePlaybackEvent(event);
      } catch (_) {
        await _enqueueMutation('position', episode.id, event.toPayload());
      }
    }
  }

  Future<String> loadChapters(EpisodeRecord episode) async {
    if (episode.chaptersJson != '[]' ||
        backend == null ||
        userId == null ||
        episode.id <= 0) {
      return episode.chaptersJson;
    }
    try {
      final chapters = await backend!.getChapters(userId!, episode.id);
      if (chapters != '[]') {
        await database.setEpisodeChapters(episode.id, chapters);
      }
      return chapters;
    } catch (_) {
      return episode.chaptersJson;
    }
  }

  Future<void> addToQueue(EpisodeRecord episode, {bool next = false}) async {
    final baseOrder = await database.queueEpisodeIds();
    final afterEpisodeId = next ? activeEpisodeId?.call() : null;
    await database.addToQueue(episode.id, afterEpisodeId: afterEpisodeId);
    final order = await database.queueEpisodeIds();
    if (episode.id <= 0) return;
    await _submitQueueOperation(
      type: 'queue_add',
      episodeId: episode.id,
      baseOrder: baseOrder,
      desiredOrder: order,
      offlineMessage: 'Queue changed offline.',
    );
  }

  Future<void> removeFromQueue(EpisodeRecord episode) async {
    final baseOrder = await database.queueEpisodeIds();
    await database.removeFromQueue(episode.id);
    if (episode.id <= 0) return;
    await _submitQueueOperation(
      type: 'queue_remove',
      episodeId: episode.id,
      baseOrder: baseOrder,
      desiredOrder: await database.queueEpisodeIds(),
      offlineMessage: 'Queue changed offline.',
    );
  }

  Future<void> reorderQueue(List<EpisodeRecord> episodes) async {
    final baseOrder = await database.queueEpisodeIds();
    final order = episodes.map((episode) => episode.id).toList(growable: false);
    await database.reorderQueue(order);
    final desiredOrder = await database.queueEpisodeIds();
    if (!desiredOrder.any((id) => id > 0)) return;
    await _submitQueueOperation(
      type: 'queue_reorder',
      baseOrder: baseOrder,
      desiredOrder: desiredOrder,
      offlineMessage: 'Queue order saved offline.',
    );
  }

  Future<void> clearQueue() async {
    final removedIds = await database.queueEpisodeIds();
    if (removedIds.isEmpty) return;
    await database.clearQueue();
    if (!removedIds.any((id) => id > 0)) return;
    await _submitQueueOperation(
      type: 'queue_clear',
      baseOrder: removedIds,
      desiredOrder: const [],
      offlineMessage: 'Queue clear saved offline.',
    );
  }

  Future<void> _submitQueueOperation({
    required String type,
    required List<int> baseOrder,
    required List<int> desiredOrder,
    required String offlineMessage,
    int? episodeId,
  }) async {
    final baseRevision =
        await database.acknowledgedQueueRevision() ?? queueRevision(baseOrder);
    final operationId = await _enqueueMutation(type, episodeId, {
      'baseRevision': baseRevision,
      'baseOrder': baseOrder,
      'order': desiredOrder,
    });
    final currentBackend = backend;
    final currentUserId = userId;
    if (currentBackend == null || currentUserId == null) return;

    await SyncEngine(
      database,
      currentBackend,
      currentUserId,
    ).flushPendingMutations(ignoreBackoff: true);
    if (await database.mutationById(operationId) != null) {
      error = offlineMessage;
    } else {
      error = null;
    }
    notifyListeners();
  }

  Future<bool> removeFromInbox(
    EpisodeRecord episode, {
    bool? markAsPlayed,
  }) async {
    final shouldMarkAsPlayed =
        markAsPlayed ??
        (await database.inboxSwipePreferences()).markRemovedAsPlayed;
    await database.removeFromInbox(episode.id);
    if (episode.completed || !shouldMarkAsPlayed) return false;
    await setCompleted(episode, true);
    return true;
  }

  Future<void> restoreToInbox(
    EpisodeRecord episode, {
    bool restoreAsUnplayed = false,
  }) async {
    await database.restoreToInbox(episode.id);
    if (restoreAsUnplayed) await setCompleted(episode, false);
  }

  Future<void> setDownloaded(EpisodeRecord episode, bool downloaded) async {
    await database.setDownloaded(episode.id, downloaded);
    final currentBackend = backend;
    final downloadBackend = currentBackend is EpisodeDownloadBackend
        ? currentBackend as EpisodeDownloadBackend
        : null;
    if (downloadBackend != null && userId != null && episode.id > 0) {
      try {
        await downloadBackend.setEpisodeDownloaded(
          userId!,
          episode.id,
          downloaded,
        );
        return;
      } catch (_) {
        // The durable mutation below preserves the optimistic local change.
      }
    }
    if (episode.id > 0) {
      await _enqueueMutation('downloaded', episode.id, {'value': downloaded});
      error = downloaded
          ? 'Download requested offline.'
          : 'Download removal saved offline.';
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await credentials.clear();
    await database.clearAll();
    connected = false;
    demoMode = false;
    serverUrl = null;
    userId = null;
    backend = null;
    _apiKey = null;
    lastSyncedAt = null;
    notifyListeners();
  }

  void _listenForConnectivityRestoration() {
    if (_connectivitySubscription != null) return;
    _connectivitySubscription = _connectivityChanges.listen((results) {
      final offline =
          results.isEmpty ||
          results.every((result) => result == ConnectivityResult.none);
      final restored = _wasOffline == true && !offline;
      _wasOffline = offline;
      if (restored && backend != null && userId != null) {
        unawaited(refresh(silent: true, forceMutationRetry: true));
      }
    });
  }

  @override
  void dispose() {
    unawaited(_connectivitySubscription?.cancel());
    super.dispose();
  }

  Future<void> _resolveUserIdentity() async {
    final currentBackend = backend;
    if (currentBackend == null) return;
    final resolvedUserId = await currentBackend.verifyConnection();
    if (resolvedUserId == userId) return;
    userId = resolvedUserId;
    if (serverUrl != null && _apiKey != null) {
      await credentials.write(
        StoredSession(
          serverUrl: serverUrl!,
          apiKey: _apiKey!,
          userId: resolvedUserId,
        ),
      );
    }
  }

  Future<String> _enqueueMutation(
    String type,
    int? episodeId,
    Map<String, Object?> payload,
  ) async {
    final id = _uuid.v4();
    final encodedPayload = Map<String, Object?>.of(payload);
    if (type.startsWith('queue_')) encodedPayload['operationId'] = id;
    await database.enqueueMutation(
      SyncMutationsCompanion.insert(
        id: id,
        type: type,
        episodeId: Value(episodeId),
        payload: Value(jsonEncode(encodedPayload)),
        createdAt: DateTime.now().toUtc(),
      ),
    );
    return id;
  }

  Future<String> _playbackDeviceId() =>
      _deviceIdFuture ??= database.ensureSyncDeviceId(_deviceIdCandidate);

  Future<void> _sendPlaybackEvent(PlaybackSyncEvent event) {
    final currentBackend = backend!;
    final currentUserId = userId!;
    if (currentBackend is PlaybackEventBackend) {
      return (currentBackend as PlaybackEventBackend).updatePlaybackEvent(
        currentUserId,
        event,
      );
    }
    return switch (event.kind) {
      PlaybackEventKind.completed ||
      PlaybackEventKind.uncompleted => currentBackend.markCompleted(
        currentUserId,
        event.episodeId,
        event.completed,
      ),
      PlaybackEventKind.progress ||
      PlaybackEventKind.seek => currentBackend.updatePlayback(
        currentUserId,
        event.episodeId,
        Duration(seconds: event.positionSeconds),
      ),
    };
  }

  Future<void> _cachePodcast(
    RemotePodcast podcast, {
    List<RemoteEpisode>? episodes,
  }) => database.cacheDiscovery(
    feedUrl: podcast.feedUrl,
    title: podcast.title,
    podcastJson: jsonEncode(podcast.toJson()),
    episodesJson: episodes == null
        ? null
        : jsonEncode(episodes.map((episode) => episode.toJson()).toList()),
  );

  static PodcastRowsCompanion _podcastCompanion(RemotePodcast podcast) =>
      PodcastRowsCompanion.insert(
        id: Value(podcast.id),
        title: podcast.title,
        author: Value(podcast.author),
        artworkUrl: Value(podcast.artworkUrl),
        description: Value(podcast.description),
        feedUrl: Value(podcast.feedUrl),
        episodeCount: Value(podcast.episodeCount),
        websiteUrl: Value(podcast.websiteUrl),
        categoriesJson: Value(jsonEncode(podcast.categories)),
        explicit: Value(podcast.explicit),
        podcastIndexId: Value(podcast.podcastIndexId),
      );

  static RemotePodcast _remotePodcast(
    PodcastRecord record, {
    RemotePodcast? fallback,
  }) => RemotePodcast(
    id: record.id,
    title: record.title,
    author: record.author.isEmpty ? fallback?.author ?? '' : record.author,
    artworkUrl: record.artworkUrl.isEmpty
        ? fallback?.artworkUrl ?? ''
        : record.artworkUrl,
    description: record.description.isEmpty
        ? fallback?.description ?? ''
        : record.description,
    feedUrl: record.feedUrl.isEmpty ? fallback?.feedUrl ?? '' : record.feedUrl,
    episodeCount: record.episodeCount == 0
        ? fallback?.episodeCount ?? 0
        : record.episodeCount,
    websiteUrl: record.websiteUrl.isEmpty
        ? fallback?.websiteUrl ?? ''
        : record.websiteUrl,
    categories: _decodeCategories(record.categoriesJson).isEmpty
        ? fallback?.categories ?? const []
        : _decodeCategories(record.categoriesJson),
    explicit: record.explicit || (fallback?.explicit ?? false),
    podcastIndexId: record.podcastIndexId == 0
        ? fallback?.podcastIndexId ?? 0
        : record.podcastIndexId,
  );

  static EpisodeRowsCompanion _episodeCompanion(
    RemoteEpisode episode, {
    required int podcastId,
    required String podcastTitle,
    EpisodeRecord? existing,
  }) => EpisodeRowsCompanion.insert(
    id: Value(episode.id),
    podcastId: podcastId,
    podcastTitle: episode.podcastTitle.trim().isEmpty
        ? existing?.podcastTitle ?? podcastTitle
        : episode.podcastTitle,
    title: episode.title.trim().isEmpty
        ? existing?.title ?? 'Untitled episode'
        : episode.title,
    description: Value(
      episode.description.trim().isEmpty
          ? existing?.description ?? ''
          : episode.description,
    ),
    artworkUrl: Value(
      episode.artworkUrl.trim().isEmpty
          ? existing?.artworkUrl ?? ''
          : episode.artworkUrl,
    ),
    audioUrl: Value(
      episode.audioUrl.trim().isEmpty
          ? existing?.audioUrl ?? ''
          : episode.audioUrl,
    ),
    publishedAt: episode.publishedAt.year <= 1971
        ? existing?.publishedAt ?? episode.publishedAt
        : episode.publishedAt,
    durationSeconds: Value(
      episode.durationSeconds == 0
          ? existing?.durationSeconds ?? 0
          : episode.durationSeconds,
    ),
    positionSeconds: Value(
      existing?.positionSeconds ?? episode.positionSeconds,
    ),
    completed: Value(existing?.completed ?? episode.completed),
    queued: Value(existing?.queued ?? episode.queued),
    downloaded: Value(existing?.downloaded ?? false),
    isYoutube: Value(existing?.isYoutube ?? episode.isYoutube),
    chaptersJson: Value(
      episode.chaptersJson == '[]'
          ? existing?.chaptersJson ?? '[]'
          : episode.chaptersJson,
    ),
    updatedAt: DateTime.now().toUtc(),
  );

  static RemoteEpisode _remoteEpisode(
    EpisodeRecord episode, {
    RemoteEpisode? fallback,
  }) => RemoteEpisode(
    id: episode.id,
    podcastId: episode.podcastId,
    podcastTitle: episode.podcastTitle.isEmpty
        ? fallback?.podcastTitle ?? ''
        : episode.podcastTitle,
    title: episode.title.isEmpty
        ? fallback?.title ?? 'Untitled episode'
        : episode.title,
    description: episode.description.isEmpty
        ? fallback?.description ?? ''
        : episode.description,
    artworkUrl: episode.artworkUrl.isEmpty
        ? fallback?.artworkUrl ?? ''
        : episode.artworkUrl,
    audioUrl: episode.audioUrl.isEmpty
        ? fallback?.audioUrl ?? ''
        : episode.audioUrl,
    publishedAt: episode.publishedAt.year <= 1971
        ? fallback?.publishedAt ?? episode.publishedAt
        : episode.publishedAt,
    durationSeconds: episode.durationSeconds == 0
        ? fallback?.durationSeconds ?? 0
        : episode.durationSeconds,
    positionSeconds: episode.positionSeconds,
    completed: episode.completed,
    queued: episode.queued,
    downloaded: episode.downloaded,
    isYoutube: episode.isYoutube || (fallback?.isYoutube ?? false),
    chaptersJson: episode.chaptersJson == '[]'
        ? fallback?.chaptersJson ?? '[]'
        : episode.chaptersJson,
  );

  static List<RemoteEpisode> _mergeSavedEpisodes(
    List<RemoteEpisode> cached,
    List<EpisodeRecord> local,
  ) {
    final cachedById = {for (final episode in cached) episode.id: episode};
    final localIds = local.map((episode) => episode.id).toSet();
    final merged = [
      for (final episode in local)
        _remoteEpisode(episode, fallback: cachedById[episode.id]),
      for (final episode in cached)
        if (!localIds.contains(episode.id)) episode,
    ];
    merged.sort((left, right) => right.publishedAt.compareTo(left.publishedAt));
    return merged;
  }

  static List<String> _decodeCategories(String json) {
    try {
      return (jsonDecode(json) as List)
          .map((category) => '$category')
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static int _temporaryPodcastId(String feedUrl) {
    var hash = 0x811c9dc5;
    for (final unit in feedUrl.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return -(hash == 0 ? 1 : hash);
  }

  static String _normalizeUrl(String input) {
    var value = input.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority) {
      throw const PinepodsException('Enter a valid Pinepods server URL.');
    }
    return value.replaceFirst(RegExp(r'/+$'), '');
  }
}

class PodcastDetailBundle {
  const PodcastDetailBundle({
    required this.podcast,
    required this.episodes,
    required this.subscribed,
    this.localEpisodes = const {},
  });

  final RemotePodcast podcast;
  final List<RemoteEpisode> episodes;
  final bool subscribed;
  final Map<int, EpisodeRecord> localEpisodes;
}
