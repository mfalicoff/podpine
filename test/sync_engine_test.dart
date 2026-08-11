import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/backend/pinepods_backend.dart';
import 'package:podpine/core/backend/podcast_backend.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/core/sync/playback_sync.dart';
import 'package:podpine/core/sync/sync_engine.dart';

void main() {
  test(
    'pushes offline mutations before replacing the local snapshot',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final backend = _FakeBackend();

      await database.enqueueMutation(
        SyncMutationsCompanion.insert(
          id: 'mutation-1',
          type: 'position',
          episodeId: const Value(8),
          payload: const Value('{"seconds":22}'),
          createdAt: DateTime.utc(2026, 8, 10),
        ),
      );

      await SyncEngine(database, backend, 7).refresh();

      expect(backend.calls, [
        'position:7:8:22',
        'subscriptions',
        'episodes',
        'queue',
      ]);
      expect(await database.pendingMutations(), isEmpty);
      expect((await database.watchPodcasts().first).single.title, 'Test Cast');
      expect((await database.watchRecentEpisodes().first).single.id, 8);
    },
  );

  test('coalesces repeated position and played-state mutations', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final backend = _FakeBackend();
    final mutations = <SyncMutationsCompanion>[
      SyncMutationsCompanion.insert(
        id: 'position-old',
        type: 'position',
        episodeId: const Value(8),
        payload: const Value('{"seconds":5}'),
        createdAt: DateTime.utc(2026, 8, 10),
      ),
      SyncMutationsCompanion.insert(
        id: 'position-new',
        type: 'position',
        episodeId: const Value(8),
        payload: const Value('{"seconds":45}'),
        createdAt: DateTime.utc(2026, 8, 10, 0, 1),
      ),
      SyncMutationsCompanion.insert(
        id: 'played-old',
        type: 'completed',
        episodeId: const Value(8),
        payload: const Value('{"value":true}'),
        createdAt: DateTime.utc(2026, 8, 10, 0, 2),
      ),
      SyncMutationsCompanion.insert(
        id: 'played-new',
        type: 'completed',
        episodeId: const Value(8),
        payload: const Value('{"value":false}'),
        createdAt: DateTime.utc(2026, 8, 10, 0, 3),
      ),
    ];
    for (final mutation in mutations) {
      await database.enqueueMutation(mutation);
    }

    await SyncEngine(database, backend, 7).refresh();

    expect(backend.calls, [
      'position:7:8:45',
      'completed:7:8:false',
      'subscriptions',
      'episodes',
      'queue',
    ]);
    expect(await database.pendingMutations(), isEmpty);
  });

  test(
    'scalar backend preflight drops stale progress but keeps a seek',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final backend = _FakeBackend()..remotePosition = 90;
      final occurredAt = DateTime.utc(2026, 8, 11, 10);

      Future<void> enqueue({
        required String id,
        required int seconds,
        required PlaybackEventKind kind,
      }) => database.enqueueMutation(
        SyncMutationsCompanion.insert(
          id: id,
          type: 'position',
          episodeId: const Value(8),
          payload: Value(
            jsonEncode(
              PlaybackSyncEvent(
                episodeId: 8,
                positionSeconds: seconds,
                durationSeconds: 120,
                completed: false,
                kind: kind,
                occurredAt: occurredAt,
                deviceId: 'device-a',
                mediaIdentity: 'https://example.test/episode.mp3',
              ).toPayload(),
            ),
          ),
          createdAt: occurredAt,
        ),
      );

      await enqueue(
        id: 'stale-progress',
        seconds: 30,
        kind: PlaybackEventKind.progress,
      );
      await SyncEngine(database, backend, 7).flushPendingMutations();
      expect(backend.calls, ['episodes']);

      backend.calls.clear();
      await enqueue(
        id: 'intentional-seek',
        seconds: 10,
        kind: PlaybackEventKind.seek,
      );
      await SyncEngine(database, backend, 7).flushPendingMutations();
      expect(backend.calls, ['episodes', 'position:7:8:10']);
    },
  );

  test('queue operations retain their causal order in the outbox', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final backend = _FakeBackend();
    for (final mutation in [
      SyncMutationsCompanion.insert(
        id: 'queue-add',
        type: 'queue_add',
        episodeId: const Value(8),
        payload: const Value('{"order":[3,8,5]}'),
        createdAt: DateTime.utc(2026, 8, 10),
      ),
      SyncMutationsCompanion.insert(
        id: 'queue-reorder',
        type: 'queue_reorder',
        payload: const Value('{"order":[8,5,3]}'),
        createdAt: DateTime.utc(2026, 8, 10, 0, 1),
      ),
      SyncMutationsCompanion.insert(
        id: 'queue-clear',
        type: 'queue_clear',
        payload: const Value('{"episodeIds":[8,5,3]}'),
        createdAt: DateTime.utc(2026, 8, 10, 0, 2),
      ),
    ]) {
      await database.enqueueMutation(mutation);
    }

    expect(
      (await database.pendingMutations()).map((mutation) => mutation.type),
      ['queue_add', 'queue_reorder', 'queue_clear'],
    );
    await SyncEngine(database, backend, 7).refresh();
    expect(await database.pendingMutations(), isEmpty);
  });

  test(
    'transient failures are retried after bounded jittered backoff',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final backend = _FakeBackend()..positionFailures = 1;
      var now = DateTime.utc(2026, 8, 10);
      await database.enqueueMutation(
        SyncMutationsCompanion.insert(
          id: 'retry-position',
          type: 'position',
          episodeId: const Value(8),
          payload: const Value('{"seconds":22}'),
          createdAt: now,
        ),
      );
      final engine = SyncEngine(
        database,
        backend,
        7,
        clock: () => now,
        jitter: () => .5,
      );

      await expectLater(
        engine.refresh(),
        throwsA(isA<SyncDeferredException>()),
      );
      var pending = (await database.pendingMutations()).single;
      expect(pending.attempts, 1);
      expect(
        pending.nextAttemptAt?.toUtc(),
        now.add(const Duration(seconds: 1)),
      );
      expect(pending.lastError, contains('temporarily unavailable'));

      await expectLater(
        engine.refresh(),
        throwsA(isA<SyncDeferredException>()),
      );
      expect(backend.positionAttempts, 1);

      now = now.add(const Duration(seconds: 1));
      await engine.refresh();
      expect(backend.positionAttempts, 2);
      expect(await database.pendingMutations(), isEmpty);
    },
  );

  test('retry backoff never exceeds five minutes', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final backend = _FakeBackend()..positionFailures = 1;
    final now = DateTime.utc(2026, 8, 10);
    await database.enqueueMutation(
      SyncMutationsCompanion.insert(
        id: 'bounded-retry',
        type: 'position',
        episodeId: const Value(8),
        payload: const Value('{"seconds":22}'),
        createdAt: now,
        attempts: const Value(50),
      ),
    );

    await expectLater(
      SyncEngine(
        database,
        backend,
        7,
        clock: () => now,
        jitter: () => 1,
      ).refresh(),
      throwsA(isA<SyncDeferredException>()),
    );

    expect(
      (await database.pendingMutations()).single.nextAttemptAt?.toUtc(),
      now.add(SyncEngine.maxRetryDelay),
    );
  });

  test('authorization failures become inspectable terminal failures', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final backend = _FakeBackend()
      ..positionError = const PinepodsException(
        'API key rejected',
        statusCode: 401,
      );
    await database.enqueueMutation(
      SyncMutationsCompanion.insert(
        id: 'denied-position',
        type: 'position',
        episodeId: const Value(8),
        payload: const Value('{"seconds":22}'),
        createdAt: DateTime.utc(2026, 8, 10),
      ),
    );

    await SyncEngine(database, backend, 7).refresh();

    expect(await database.pendingMutations(), isEmpty);
    final failed = (await database.failedMutations()).single;
    expect(failed.state, 'failed');
    expect(failed.attempts, 1);
    expect(failed.lastError, contains('API key rejected'));
  });

  test('network restoration forces a pending outbox flush', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final changes = StreamController<List<ConnectivityResult>>.broadcast(
      sync: true,
    );
    final backend = _FakeBackend();
    final controller = AppController(
      database,
      const CredentialStore(FlutterSecureStorage()),
      connectivityChanges: changes.stream,
    );
    addTearDown(() async {
      controller.dispose();
      await changes.close();
      await database.close();
    });
    await controller.initialize();
    controller
      ..backend = backend
      ..userId = 7;
    await database.enqueueMutation(
      SyncMutationsCompanion.insert(
        id: 'restore-position',
        type: 'position',
        episodeId: const Value(8),
        payload: const Value('{"seconds":33}'),
        createdAt: DateTime.utc(2026, 8, 10),
      ),
    );
    await database.scheduleMutationRetry(
      id: 'restore-position',
      attempts: 0,
      attemptedAt: DateTime.utc(2026, 8, 10),
      nextAttemptAt: DateTime.utc(2100),
      error: 'offline',
    );

    changes.add([ConnectivityResult.none]);
    changes.add([ConnectivityResult.wifi]);
    await backend.positionObserved.future.timeout(const Duration(seconds: 1));
    await Future<void>.delayed(Duration.zero);

    expect(await database.pendingMutations(), isEmpty);
    expect(backend.calls, contains('position:7:8:33'));
  });
}

class _FakeBackend implements PodcastBackend, QueueControlBackend {
  final calls = <String>[];
  int positionFailures = 0;
  int positionAttempts = 0;
  Object? positionError;
  int remotePosition = 22;
  final positionObserved = Completer<void>();

  @override
  Future<int> verifyConnection() async => 7;

  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async {
    calls.add('subscriptions');
    return const [
      RemotePodcast(
        id: 2,
        title: 'Test Cast',
        author: 'Podpine',
        artworkUrl: '',
        description: '',
        feedUrl: 'https://example.test/feed.xml',
        episodeCount: 1,
      ),
    ];
  }

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async {
    calls.add('episodes');
    return [
      RemoteEpisode(
        id: 8,
        podcastId: 2,
        podcastTitle: 'Test Cast',
        title: 'Test episode',
        description: '',
        artworkUrl: '',
        audioUrl: 'https://example.test/episode.mp3',
        publishedAt: DateTime.utc(2026, 8, 10),
        durationSeconds: 120,
        positionSeconds: remotePosition,
        completed: false,
        queued: false,
        downloaded: false,
        isYoutube: false,
      ),
    ];
  }

  @override
  Future<List<RemoteEpisode>> getQueue(int userId) async {
    calls.add('queue');
    return const [];
  }

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
  ) async {
    positionAttempts++;
    if (!positionObserved.isCompleted) positionObserved.complete();
    final error = positionError;
    if (error != null) throw error;
    if (positionFailures > 0) {
      positionFailures--;
      throw StateError('Server temporarily unavailable');
    }
    calls.add('position:$userId:$episodeId:${position.inSeconds}');
  }

  @override
  Future<void> markCompleted(int userId, int episodeId, bool completed) async {
    calls.add('completed:$userId:$episodeId:$completed');
  }

  @override
  Future<void> addToQueue(int userId, int episodeId) async {
    calls.add('queue-add:$userId:$episodeId');
  }

  @override
  Future<void> removeFromQueue(int userId, int episodeId) async {}

  @override
  Future<void> reorderQueue(int userId, List<int> episodeIds) async {
    calls.add('queue-order:$userId:${episodeIds.join(',')}');
  }

  @override
  Future<void> clearQueue(int userId) async {
    calls.add('queue-clear:$userId');
  }
}
