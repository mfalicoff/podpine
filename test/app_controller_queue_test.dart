import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/backend/podcast_backend.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/core/sync/queue_sync.dart';
import 'package:podpine/core/sync/sync_engine.dart';

void main() {
  test('play next persists after the active episode and reconciles', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await _seed(database);
    final backend = _QueueBackend([1, 2]);
    final controller =
        AppController(database, const CredentialStore(FlutterSecureStorage()))
          ..backend = backend
          ..userId = 7
          ..activeEpisodeId = () => 1;

    await controller.addToQueue(_episode(3), next: true);

    expect(backend.calls, ['get', 'add:3', 'reorder:1,3,2']);
    expect(await database.queueEpisodeIds(), [1, 3, 2]);
    expect(await database.pendingMutations(), isEmpty);
  });

  test('failed play next remains recoverable in the outbox', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await _seed(database);
    final backend = _QueueBackend([1, 2])..failReorder = true;
    final controller =
        AppController(database, const CredentialStore(FlutterSecureStorage()))
          ..backend = backend
          ..userId = 7
          ..activeEpisodeId = () => 1;

    await controller.addToQueue(_episode(3), next: true);

    expect(await database.queueEpisodeIds(), [1, 3, 2]);
    final mutation = (await database.pendingMutations()).single;
    expect(mutation.type, 'queue_add');
    final payload = jsonDecode(mutation.payload) as Map<String, dynamic>;
    expect(payload['operationId'], mutation.id);
    expect(payload['baseRevision'], queueRevision([1, 2]));
    expect(payload['baseOrder'], [1, 2]);
    expect(payload['order'], [1, 3, 2]);

    backend.failReorder = false;
    await SyncEngine(
      database,
      backend,
      7,
    ).flushPendingMutations(ignoreBackoff: true);
    expect(backend.serverOrder, [1, 3, 2]);
    expect(await database.pendingMutations(), isEmpty);
  });

  test('every offline queue edit keeps a stable operation ID', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await _seed(database);
    final controller = AppController(
      database,
      const CredentialStore(FlutterSecureStorage()),
    );

    await controller.addToQueue(_episode(3));
    await controller.reorderQueue([_episode(3), _episode(1), _episode(2)]);
    await controller.removeFromQueue(_episode(2));
    await controller.clearQueue();

    final mutations = await database.pendingMutations();
    expect(mutations.map((mutation) => mutation.type), [
      'queue_add',
      'queue_reorder',
      'queue_remove',
      'queue_clear',
    ]);
    for (final mutation in mutations) {
      final payload = jsonDecode(mutation.payload) as Map<String, dynamic>;
      expect(payload['operationId'], mutation.id);
      expect(payload['baseRevision'], isNotEmpty);
      expect(payload['baseOrder'], isA<List<dynamic>>());
      expect(payload['order'], isA<List<dynamic>>());
    }
  });
}

Future<void> _seed(AppDatabase database) async {
  await database.into(database.podcastRows).insert(_podcast);
  for (final episode in [_episode(1), _episode(2), _episode(3)]) {
    await database.into(database.episodeRows).insert(episode);
  }
  await database.addToQueue(1);
  await database.addToQueue(2);
}

class _QueueBackend implements PodcastBackend, QueueControlBackend {
  _QueueBackend(this.serverOrder);

  List<int> serverOrder;
  final calls = <String>[];
  bool failReorder = false;

  @override
  Future<void> addToQueue(int userId, int episodeId) async {
    calls.add('add:$episodeId');
    serverOrder
      ..remove(episodeId)
      ..add(episodeId);
  }

  @override
  Future<void> reorderQueue(int userId, List<int> episodeIds) async {
    calls.add('reorder:${episodeIds.join(',')}');
    if (failReorder) throw StateError('offline');
    serverOrder = List<int>.of(episodeIds);
  }

  @override
  Future<List<RemoteEpisode>> getQueue(int userId) async {
    calls.add('get');
    return serverOrder.indexed
        .map((entry) => _remoteEpisode(entry.$2, entry.$1))
        .toList();
  }

  @override
  Future<void> clearQueue(int userId) async => serverOrder.clear();

  @override
  Future<void> removeFromQueue(int userId, int episodeId) async {
    serverOrder.remove(episodeId);
  }

  @override
  Future<int> verifyConnection() async => 7;

  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async => const [];

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async => const [];

  @override
  Future<List<RemotePodcast>> searchPodcasts(
    String query, {
    String provider = 'podcast_index',
  }) async => const [];

  @override
  Future<RemotePodcast> getPodcastDetails(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async => podcast;

  @override
  Future<List<RemoteEpisode>> getPodcastEpisodes(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async => const [];

  @override
  Future<int> subscribe(int userId, RemotePodcast podcast) async => podcast.id;

  @override
  Future<void> unsubscribe(int userId, RemotePodcast podcast) async {}

  @override
  Future<String> getChapters(int userId, int episodeId) async => '[]';

  @override
  Future<void> updatePlayback(
    int userId,
    int episodeId,
    Duration position,
  ) async {}

  @override
  Future<void> markCompleted(int userId, int episodeId, bool completed) async {}
}

const _podcast = PodcastRecord(
  id: 7,
  title: 'Test Cast',
  author: '',
  artworkUrl: '',
  description: '',
  feedUrl: '',
  episodeCount: 3,
  websiteUrl: '',
  categoriesJson: '[]',
  explicit: false,
  podcastIndexId: 0,
);

EpisodeRecord _episode(int id) => EpisodeRecord(
  id: id,
  podcastId: 7,
  podcastTitle: 'Test Cast',
  title: 'Episode $id',
  description: '',
  artworkUrl: '',
  audioUrl: 'https://example.test/$id.mp3',
  publishedAt: DateTime.utc(2026, 8, 10),
  durationSeconds: 60,
  positionSeconds: 0,
  completed: false,
  queued: id < 3,
  downloaded: false,
  isYoutube: false,
  chaptersJson: '[]',
  playbackIntent: 'progress',
  playbackMediaIdentity: 'https://example.test/$id.mp3',
  updatedAt: DateTime.utc(2026, 8, 10),
);

RemoteEpisode _remoteEpisode(int id, int position) => RemoteEpisode(
  id: id,
  podcastId: 7,
  podcastTitle: 'Test Cast',
  title: 'Episode $id',
  description: '',
  artworkUrl: '',
  audioUrl: 'https://example.test/$id.mp3',
  publishedAt: DateTime.utc(2026, 8, 10),
  durationSeconds: 60,
  positionSeconds: 0,
  completed: false,
  queued: true,
  downloaded: false,
  isYoutube: false,
  queuePosition: position,
);
