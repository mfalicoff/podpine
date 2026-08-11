import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/backend/podcast_backend.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/core/sync/background_sync.dart';

void main() {
  test('background refresh skips cleanly without connectivity', () async {
    final diagnostics = _Diagnostics();
    var openedDatabase = false;

    final result = await runBackgroundSync(
      taskName: backgroundSyncTaskName,
      checkConnectivity: () async => [ConnectivityResult.none],
      openDatabase: () {
        openedDatabase = true;
        return AppDatabase(NativeDatabase.memory());
      },
      diagnostics: diagnostics,
    );

    expect(result, isTrue);
    expect(openedDatabase, isFalse);
    expect(diagnostics.outcome, BackgroundSyncOutcome.skippedOffline);
  });

  test(
    'background refresh flushes the outbox and records diagnostics',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      final backend = _FakeBackend();
      final diagnostics = _Diagnostics();
      await database.enqueueMutation(
        SyncMutationsCompanion.insert(
          id: 'background-position',
          type: 'position',
          episodeId: const Value(42),
          payload: const Value('{"seconds":19}'),
          createdAt: DateTime.utc(2026, 8, 11),
        ),
      );

      final result = await runBackgroundSync(
        taskName: backgroundSyncTaskName,
        checkConnectivity: () async => [ConnectivityResult.wifi],
        readSession: () async => const StoredSession(
          serverUrl: 'https://pinepods.example',
          apiKey: 'secret',
          userId: 7,
        ),
        openDatabase: () => database,
        createBackend: (_) => backend,
        diagnostics: diagnostics,
      );

      expect(result, isTrue);
      expect(backend.calls, [
        'position:7:42:19',
        'subscriptions',
        'episodes',
        'queue',
      ]);
      expect(diagnostics.outcome, BackgroundSyncOutcome.succeeded);
      expect(diagnostics.pendingBefore, 1);
      expect(diagnostics.pendingAfter, 0);
    },
  );

  test('background diagnostic snapshots round-trip defensively', () {
    final startedAt = DateTime.utc(2026, 8, 11, 1, 2, 3);
    final snapshot = BackgroundSyncSnapshot(
      scheduler: 'Android WorkManager',
      policy: 'Connected network',
      scheduled: true,
      scheduledAt: startedAt,
      lastStartedAt: startedAt,
      outcome: BackgroundSyncOutcome.succeeded,
      detail: 'Refreshed',
      pendingBefore: 2,
      pendingAfter: 0,
      durationMilliseconds: 123,
    );

    final restored = BackgroundSyncSnapshot.fromJson(snapshot.toJson());

    expect(restored.scheduler, snapshot.scheduler);
    expect(restored.scheduledAt, startedAt);
    expect(restored.outcome, BackgroundSyncOutcome.succeeded);
    expect(restored.pendingBefore, 2);
    expect(restored.pendingAfter, 0);
    expect(restored.durationMilliseconds, 123);
  });
}

class _Diagnostics implements BackgroundSyncDiagnosticSink {
  BackgroundSyncOutcome? outcome;
  int? pendingBefore;
  int? pendingAfter;

  @override
  Future<void> recordStarted({
    required String taskName,
    required DateTime startedAt,
  }) async {}

  @override
  Future<void> recordFinished({
    required BackgroundSyncOutcome outcome,
    required String detail,
    required DateTime startedAt,
    int? pendingBefore,
    int? pendingAfter,
  }) async {
    this.outcome = outcome;
    this.pendingBefore = pendingBefore;
    this.pendingAfter = pendingAfter;
  }
}

class _FakeBackend implements PodcastBackend {
  final calls = <String>[];

  @override
  Future<int> verifyConnection() async => 7;

  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async {
    calls.add('subscriptions');
    return const [];
  }

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async {
    calls.add('episodes');
    return const [];
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
    calls.add('position:$userId:$episodeId:${position.inSeconds}');
  }

  @override
  Future<void> markCompleted(int userId, int episodeId, bool completed) async {}

  @override
  Future<void> addToQueue(int userId, int episodeId) async {}

  @override
  Future<void> removeFromQueue(int userId, int episodeId) async {}
}
