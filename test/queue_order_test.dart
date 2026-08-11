import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/database/app_database.dart';

void main() {
  test(
    'play next, drag reorder, and clear keep a canonical local order',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database.into(database.podcastRows).insert(_podcast);
      for (final episode in [_episode(1), _episode(2), _episode(3)]) {
        await database.into(database.episodeRows).insert(episode);
        await database.addToQueue(episode.id);
      }

      await database.addToQueue(3, afterEpisodeId: 1);
      expect(await database.queueEpisodeIds(), [1, 3, 2]);

      await database.reorderQueue([2, 1, 3]);
      expect(await database.queueEpisodeIds(), [2, 1, 3]);

      await database.clearQueue();
      expect(await database.queueEpisodeIds(), isEmpty);
      expect(
        (await database.watchRecentEpisodes().first).where((row) => row.queued),
        isEmpty,
      );
    },
  );
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
  queued: false,
  downloaded: false,
  isYoutube: false,
  chaptersJson: '[]',
  updatedAt: DateTime.utc(2026, 8, 10),
);
