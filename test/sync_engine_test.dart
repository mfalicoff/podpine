import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/backend/podcast_backend.dart';
import 'package:podpine/core/database/app_database.dart';
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

      expect(backend.calls, ['position:7:8:22']);
      expect(await database.pendingMutations(), isEmpty);
      expect((await database.watchPodcasts().first).single.title, 'Test Cast');
      expect((await database.watchRecentEpisodes().first).single.id, 8);
    },
  );
}

class _FakeBackend implements PodcastBackend {
  final calls = <String>[];

  @override
  Future<int> verifyConnection() async => 7;

  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async => const [
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

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async => [
    RemoteEpisode(
      id: 8,
      podcastId: 2,
      podcastTitle: 'Test Cast',
      title: 'Test episode',
      description: '',
      artworkUrl: '',
      audioUrl: '',
      publishedAt: DateTime.utc(2026, 8, 10),
      durationSeconds: 120,
      positionSeconds: 22,
      completed: false,
      queued: false,
      downloaded: false,
      isYoutube: false,
    ),
  ];

  @override
  Future<List<RemoteEpisode>> getQueue(int userId) async => const [];

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
