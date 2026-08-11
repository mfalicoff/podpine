import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/features/queue/queue_screen.dart';
import 'package:podpine/providers.dart';

void main() {
  testWidgets('dragged queue rows retain a Material ancestor', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await database.into(database.podcastRows).insert(_podcast);
    for (final episode in [_episode(-1), _episode(-2)]) {
      await database.into(database.episodeRows).insert(episode);
      await database.addToQueue(episode.id);
    }
    final app = AppController(
      database,
      const CredentialStore(FlutterSecureStorage()),
    )..initialized = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          appControllerProvider.overrideWith((ref) => app),
        ],
        child: const MaterialApp(home: Scaffold(body: QueueScreen())),
      ),
    );
    await tester.pump();

    final handle = find.byIcon(Icons.drag_handle_rounded).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();

    expect(tester.takeException(), isNull);

    await gesture.up();
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });
}

const _podcast = PodcastRecord(
  id: -7,
  title: 'Test Cast',
  author: '',
  artworkUrl: '',
  description: '',
  feedUrl: '',
  episodeCount: 2,
  websiteUrl: '',
  categoriesJson: '[]',
  explicit: false,
  podcastIndexId: 0,
);

EpisodeRecord _episode(int id) => EpisodeRecord(
  id: id,
  podcastId: -7,
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
  playbackIntent: 'progress',
  playbackMediaIdentity: 'https://example.test/$id.mp3',
  updatedAt: DateTime.utc(2026, 8, 10),
);
