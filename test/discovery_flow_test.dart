import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/backend/pinepods_backend.dart';
import 'package:podpine/core/backend/podcast_backend.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';

void main() {
  test(
    'subscribe and unsubscribe stay optimistic when Pinepods is offline',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final controller =
          AppController(database, const CredentialStore(FlutterSecureStorage()))
            ..backend = _OfflineBackend()
            ..userId = 42
            ..connected = true;
      const podcast = RemotePodcast(
        id: 0,
        title: 'Offline Cast',
        author: 'Podpine',
        artworkUrl: '',
        description: 'Cached details',
        feedUrl: 'https://example.test/offline.xml',
        episodeCount: 1,
      );

      await controller.subscribe(podcast);

      final optimistic = await database.podcastByFeedUrl(podcast.feedUrl);
      expect(optimistic, isNotNull);
      expect(optimistic!.id, isNegative);
      expect(
        (await database.pendingMutations()).single.type,
        'podcast_subscribe',
      );

      await database
          .into(database.episodeRows)
          .insert(
            EpisodeRowsCompanion.insert(
              id: const Value(-44),
              podcastId: optimistic.id,
              podcastTitle: optimistic.title,
              title: 'Cached episode',
              publishedAt: DateTime.utc(2026, 8, 10),
              updatedAt: DateTime.utc(2026, 8, 10),
            ),
          );
      await database.addToQueue(-44);

      await controller.unsubscribe(podcast);

      expect(await database.podcastByFeedUrl(podcast.feedUrl), isNull);
      expect(await database.watchRecentEpisodes().first, isEmpty);
      expect(await database.watchQueue().first, isEmpty);
      expect(
        (await database.pendingMutations()).map((mutation) => mutation.type),
        ['podcast_subscribe', 'podcast_unsubscribe'],
      );
      expect(await database.discoveryCache(podcast.feedUrl), isNotNull);
    },
  );
}

class _OfflineBackend implements PodcastBackend {
  const _OfflineBackend();

  Never _offline() => throw const PinepodsException('offline');

  @override
  Future<int> verifyConnection() async => _offline();

  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async => _offline();

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async => _offline();

  @override
  Future<List<RemoteEpisode>> getQueue(int userId) async => _offline();

  @override
  Future<List<RemotePodcast>> searchPodcasts(
    String query, {
    String provider = 'podcast_index',
  }) async => _offline();

  @override
  Future<RemotePodcast> getPodcastDetails(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async => _offline();

  @override
  Future<List<RemoteEpisode>> getPodcastEpisodes(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async => _offline();

  @override
  Future<int> subscribe(int userId, RemotePodcast podcast) async => _offline();

  @override
  Future<void> unsubscribe(int userId, RemotePodcast podcast) async =>
      _offline();

  @override
  Future<String> getChapters(int userId, int episodeId) async => _offline();

  @override
  Future<void> updatePlayback(
    int userId,
    int episodeId,
    Duration position,
  ) async => _offline();

  @override
  Future<void> markCompleted(int userId, int episodeId, bool completed) async =>
      _offline();

  @override
  Future<void> addToQueue(int userId, int episodeId) async => _offline();

  @override
  Future<void> removeFromQueue(int userId, int episodeId) async => _offline();
}
