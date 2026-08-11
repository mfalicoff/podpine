import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/database/app_database.dart';

void main() {
  test('v1 database upgrades to v10 without losing user data', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute('''
          CREATE TABLE podcast_rows (
            id INTEGER NOT NULL PRIMARY KEY,
            title TEXT NOT NULL,
            author TEXT NOT NULL DEFAULT '',
            artwork_url TEXT NOT NULL DEFAULT '',
            description TEXT NOT NULL DEFAULT '',
            feed_url TEXT NOT NULL DEFAULT '',
            episode_count INTEGER NOT NULL DEFAULT 0
          )
        ''');
        database.execute('''
          CREATE TABLE episode_rows (
            id INTEGER NOT NULL PRIMARY KEY,
            podcast_id INTEGER NOT NULL REFERENCES podcast_rows(id),
            podcast_title TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            artwork_url TEXT NOT NULL DEFAULT '',
            audio_url TEXT NOT NULL DEFAULT '',
            published_at INTEGER NOT NULL,
            duration_seconds INTEGER NOT NULL DEFAULT 0,
            position_seconds INTEGER NOT NULL DEFAULT 0,
            completed INTEGER NOT NULL DEFAULT 0,
            queued INTEGER NOT NULL DEFAULT 0,
            downloaded INTEGER NOT NULL DEFAULT 0,
            is_youtube INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          CREATE TABLE queue_rows (
            episode_id INTEGER NOT NULL PRIMARY KEY
              REFERENCES episode_rows(id),
            sort_key REAL NOT NULL,
            added_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          CREATE TABLE sync_mutations (
            id TEXT NOT NULL PRIMARY KEY,
            type TEXT NOT NULL,
            episode_id INTEGER,
            payload TEXT NOT NULL DEFAULT '{}',
            created_at INTEGER NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0
          )
        ''');

        database.execute('''
          INSERT INTO podcast_rows (
            id, title, author, feed_url, episode_count
          ) VALUES (
            41, 'Existing podcast', 'Existing author',
            'https://fixtures.invalid/feed.xml', 9
          )
        ''');
        database.execute('''
          INSERT INTO episode_rows (
            id, podcast_id, podcast_title, title, audio_url, published_at,
            duration_seconds, position_seconds, queued, downloaded, updated_at
          ) VALUES (
            73, 41, 'Existing podcast', 'Saved episode',
            'https://fixtures.invalid/audio.mp3', 1720000000,
            3600, 937, 1, 1, 1720000123
          )
        ''');
        database.execute('''
          INSERT INTO queue_rows (episode_id, sort_key, added_at)
          VALUES (73, 4.5, 1720000200)
        ''');
        database.execute('''
          INSERT INTO sync_mutations (
            id, type, episode_id, payload, created_at, attempts
          ) VALUES (
            'existing-mutation', 'position', 73,
            '{"positionSeconds":937}', 1720000300, 2
          )
        ''');
        database.userVersion = 1;
      },
    );
    final database = AppDatabase(executor);
    addTearDown(database.close);

    // Opening the first typed query runs every migration from v1 through v10.
    final episode = await database.episodeById(73);
    final podcast = await database.podcastById(41);
    final queue = await database.watchQueue().first;
    final mutation = await database.mutationById('existing-mutation');
    final inbox = await database
        .customSelect(
          'SELECT discovered_at, removed_at FROM inbox_rows WHERE episode_id = 73',
        )
        .getSingle();
    final schemaVersion = await database
        .customSelect('PRAGMA user_version')
        .getSingle();

    expect(schemaVersion.data['user_version'], 10);
    expect(podcast?.title, 'Existing podcast');
    expect(podcast?.author, 'Existing author');
    expect(podcast?.feedUrl, 'https://fixtures.invalid/feed.xml');
    expect(podcast?.websiteUrl, isEmpty);
    expect(episode?.title, 'Saved episode');
    expect(episode?.positionSeconds, 937);
    expect(episode?.downloaded, isTrue);
    expect(episode?.chaptersJson, '[]');
    expect(episode?.playbackIntent, 'progress');
    expect(queue.map((item) => item.id), [73]);
    expect(mutation?.attempts, 2);
    expect(mutation?.state, 'pending');
    expect(mutation?.lastError, isNull);
    expect(inbox.data['discovered_at'], 1720000123);
    expect(inbox.data['removed_at'], isNotNull);
    expect(await database.downloadPreferences(), isNull);
    expect(await database.podcastDownloadOverrides(), isEmpty);
  });
}
