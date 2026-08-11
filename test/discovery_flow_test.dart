import 'dart:convert';

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
    'saved podcast details merge cached and downloaded episodes offline',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database.upsertPodcast(
        const PodcastRowsCompanion(
          id: Value(7),
          title: Value('Offline Cast'),
          feedUrl: Value('https://example.test/offline.xml'),
        ),
      );
      await database.cacheDiscovery(
        feedUrl: 'https://example.test/offline.xml',
        title: 'Offline Cast',
        podcastJson: jsonEncode(_DetailsBackend.podcast.toJson()),
        episodesJson: jsonEncode([_DetailsBackend.newEpisode.toJson()]),
      );
      await database
          .into(database.episodeRows)
          .insert(
            EpisodeRowsCompanion.insert(
              id: const Value(11),
              podcastId: 7,
              podcastTitle: 'Offline Cast',
              title: 'Downloaded archive episode',
              audioUrl: const Value('https://media.test/archive.mp3'),
              publishedAt: DateTime.utc(2026, 8, 1),
              downloaded: const Value(true),
              updatedAt: DateTime.utc(2026, 8, 10),
            ),
          );
      final controller = AppController(
        database,
        const CredentialStore(FlutterSecureStorage()),
      );

      final details = await controller.cachedPodcastDetails(
        const RemotePodcast(
          id: 7,
          title: 'Offline Cast',
          author: '',
          artworkUrl: '',
          description: '',
          feedUrl: 'https://example.test/offline.xml',
          episodeCount: 0,
        ),
      );

      expect(details.podcast.description, 'Rich saved description');
      expect(details.episodes.map((episode) => episode.id), [12, 11]);
      expect(
        details.episodes.singleWhere((episode) => episode.id == 11).downloaded,
        isTrue,
      );
      expect(details.localEpisodes.keys, [11]);
    },
  );

  test(
    'detail refresh persists episodes and retains omitted downloads',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database.upsertPodcast(
        const PodcastRowsCompanion(
          id: Value(7),
          title: Value('Offline Cast'),
          feedUrl: Value('https://example.test/offline.xml'),
        ),
      );
      await database
          .into(database.episodeRows)
          .insert(
            EpisodeRowsCompanion.insert(
              id: const Value(11),
              podcastId: 7,
              podcastTitle: 'Offline Cast',
              title: 'Downloaded archive episode',
              audioUrl: const Value('https://media.test/archive.mp3'),
              publishedAt: DateTime.utc(2026, 8, 1),
              positionSeconds: const Value(45),
              downloaded: const Value(true),
              updatedAt: DateTime.utc(2026, 8, 10),
            ),
          );
      final controller =
          AppController(database, const CredentialStore(FlutterSecureStorage()))
            ..backend = const _DetailsBackend()
            ..userId = 42;

      final refreshed = await controller.refreshPodcastDetails(
        _DetailsBackend.podcast,
      );

      expect(refreshed.episodes.map((episode) => episode.id), [12, 11]);
      expect(refreshed.localEpisodes.keys, containsAll([11, 12]));
      expect(
        (await database.podcastById(7))!.description,
        'Rich saved description',
      );
      expect((await database.episodeById(12))!.description, 'Saved show notes');
      expect((await database.episodeById(11))!.downloaded, isTrue);
      expect((await database.episodeById(11))!.positionSeconds, 45);

      controller
        ..backend = null
        ..userId = null;
      final offline = await controller.cachedPodcastDetails(
        _DetailsBackend.podcast,
      );
      expect(offline.podcast.description, 'Rich saved description');
      expect(offline.episodes.map((episode) => episode.id), [12, 11]);
    },
  );

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

class _DetailsBackend extends _OfflineBackend {
  const _DetailsBackend();

  static const podcast = RemotePodcast(
    id: 7,
    title: 'Offline Cast',
    author: 'Podpine',
    artworkUrl: 'https://images.test/offline.jpg',
    description: 'Rich saved description',
    feedUrl: 'https://example.test/offline.xml',
    episodeCount: 2,
    websiteUrl: 'https://example.test/offline',
    categories: ['Technology'],
  );

  static final newEpisode = RemoteEpisode(
    id: 12,
    podcastId: 7,
    podcastTitle: 'Offline Cast',
    title: 'Newest episode',
    description: 'Saved show notes',
    artworkUrl: 'https://images.test/episode.jpg',
    audioUrl: 'https://media.test/new.mp3',
    publishedAt: DateTime.utc(2026, 8, 11),
    durationSeconds: 1800,
    positionSeconds: 0,
    completed: false,
    queued: false,
    downloaded: false,
    isYoutube: false,
  );

  @override
  Future<RemotePodcast> getPodcastDetails(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async {
    expect(subscribed, isTrue);
    return _DetailsBackend.podcast;
  }

  @override
  Future<List<RemoteEpisode>> getPodcastEpisodes(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async {
    expect(subscribed, isTrue);
    return [newEpisode];
  }
}
