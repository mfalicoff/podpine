import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/backend/podcast_backend.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/sync/queue_sync.dart';
import 'package:podpine/core/sync/sync_engine.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);

  test('duplicate operation delivery is idempotent', () async {
    final backend = _SharedQueueBackend([1, 2]);
    final operation = QueueSyncOperation(
      id: 'device-a:add:3',
      type: 'queue_add',
      episodeId: 3,
      baseRevision: queueRevision([1, 2]),
      baseOrder: const [1, 2],
      desiredOrder: const [1, 2, 3],
    );
    final coordinator = QueueSyncCoordinator(backend, 7);

    await coordinator.apply(operation);
    final writesAfterFirstDelivery = backend.writes;
    await coordinator.apply(operation);

    expect(backend.order, [1, 2, 3]);
    expect(backend.writes, writesAfterFirstDelivery);
  });

  test(
    'a stale clear preserves episodes added after its base revision',
    () async {
      final backend = _SharedQueueBackend([1, 2, 3]);
      final result = await QueueSyncCoordinator(backend, 7).apply(
        QueueSyncOperation(
          id: 'device-a:clear',
          type: 'queue_clear',
          baseRevision: queueRevision([1, 2]),
          baseOrder: const [1, 2],
          desiredOrder: const [],
        ),
      );

      expect(result.conflicted, isTrue);
      expect(result.order, [3]);
      expect(backend.order, [3]);
    },
  );

  for (final reconnectOrder in [
    ['a', 'b'],
    ['b', 'a'],
  ]) {
    test(
      'two offline devices converge when reconnecting ${reconnectOrder.join(' then ')}',
      () async {
        final backend = _SharedQueueBackend([1, 2]);
        final deviceA = AppDatabase(NativeDatabase.memory());
        final deviceB = AppDatabase(NativeDatabase.memory());
        addTearDown(deviceA.close);
        addTearDown(deviceB.close);
        await _seedDevice(deviceA);
        await _seedDevice(deviceB);

        await deviceA.addToQueue(3);
        await _enqueue(
          deviceA,
          id: 'device-a:add:3',
          type: 'queue_add',
          episodeId: 3,
          baseOrder: const [1, 2],
          desiredOrder: const [1, 2, 3],
        );
        await deviceB.addToQueue(4, afterEpisodeId: 1);
        await _enqueue(
          deviceB,
          id: 'device-b:add:4-next',
          type: 'queue_add',
          episodeId: 4,
          baseOrder: const [1, 2],
          desiredOrder: const [1, 4, 2],
        );

        final engines = {
          'a': SyncEngine(deviceA, backend, 7),
          'b': SyncEngine(deviceB, backend, 7),
        };
        for (final device in reconnectOrder) {
          await engines[device]!.flushPendingMutations(ignoreBackoff: true);
        }

        expect(backend.order, [1, 2, 3, 4]);
        expect(await deviceA.pendingMutations(), isEmpty);
        expect(await deviceB.pendingMutations(), isEmpty);

        await engines['a']!.refresh();
        await engines['b']!.refresh();
        expect(await deviceA.queueEpisodeIds(), backend.order);
        expect(await deviceB.queueEpisodeIds(), backend.order);
        expect(
          await deviceA.acknowledgedQueueRevision(),
          queueRevision(backend.order),
        );
        expect(
          await deviceB.acknowledgedQueueRevision(),
          queueRevision(backend.order),
        );
      },
    );
  }

  test('concurrent removals and moves merge identically in either order', () {
    final left = mergeConcurrentQueueOrders(
      base: const [1, 2, 3],
      local: const [3, 1],
      remote: const [1, 3, 4, 2],
    );
    final right = mergeConcurrentQueueOrders(
      base: const [1, 2, 3],
      local: const [1, 3, 4, 2],
      remote: const [3, 1],
    );

    expect(left, right);
    expect(left, [1, 3, 4]);
  });
}

Future<void> _seedDevice(AppDatabase database) async {
  await database.into(database.podcastRows).insert(_podcast);
  for (var id = 1; id <= 4; id++) {
    await database.into(database.episodeRows).insert(_episode(id));
  }
  await database.addToQueue(1);
  await database.addToQueue(2);
  await database.acknowledgeQueue(const [1, 2]);
}

Future<void> _enqueue(
  AppDatabase database, {
  required String id,
  required String type,
  required List<int> baseOrder,
  required List<int> desiredOrder,
  int? episodeId,
}) => database.enqueueMutation(
  SyncMutationsCompanion.insert(
    id: id,
    type: type,
    episodeId: Value(episodeId),
    payload: Value(
      jsonEncode({
        'operationId': id,
        'baseRevision': queueRevision(baseOrder),
        'baseOrder': baseOrder,
        'order': desiredOrder,
      }),
    ),
    createdAt: DateTime.utc(2026, 8, 11),
  ),
);

class _SharedQueueBackend implements PodcastBackend, QueueControlBackend {
  _SharedQueueBackend(List<int> order) : order = List.of(order);

  List<int> order;
  int writes = 0;

  @override
  Future<void> addToQueue(int userId, int episodeId) async {
    writes++;
    if (!order.contains(episodeId)) order.add(episodeId);
  }

  @override
  Future<void> removeFromQueue(int userId, int episodeId) async {
    writes++;
    order.remove(episodeId);
  }

  @override
  Future<void> reorderQueue(int userId, List<int> episodeIds) async {
    writes++;
    order = List.of(episodeIds);
  }

  @override
  Future<void> clearQueue(int userId) async {
    writes++;
    order.clear();
  }

  @override
  Future<List<RemoteEpisode>> getQueue(int userId) async => order.indexed
      .map((entry) => _remoteEpisode(entry.$2, queuePosition: entry.$1))
      .toList();

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async => [
    for (var id = 1; id <= 4; id++) _remoteEpisode(id),
  ];

  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async => const [
    RemotePodcast(
      id: 7,
      title: 'Test Cast',
      author: '',
      artworkUrl: '',
      description: '',
      feedUrl: 'https://example.test/feed.xml',
      episodeCount: 4,
    ),
  ];

  @override
  Future<int> verifyConnection() async => 7;

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
  feedUrl: 'https://example.test/feed.xml',
  episodeCount: 4,
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
  publishedAt: DateTime.utc(2026, 8, 11),
  durationSeconds: 60,
  positionSeconds: 0,
  completed: false,
  queued: id <= 2,
  downloaded: false,
  isYoutube: false,
  chaptersJson: '[]',
  updatedAt: DateTime.utc(2026, 8, 11),
);

RemoteEpisode _remoteEpisode(int id, {int? queuePosition}) => RemoteEpisode(
  id: id,
  podcastId: 7,
  podcastTitle: 'Test Cast',
  title: 'Episode $id',
  description: '',
  artworkUrl: '',
  audioUrl: 'https://example.test/$id.mp3',
  publishedAt: DateTime.utc(2026, 8, 11),
  durationSeconds: 60,
  positionSeconds: 0,
  completed: false,
  queued: queuePosition != null,
  downloaded: false,
  isYoutube: false,
  queuePosition: queuePosition,
);
