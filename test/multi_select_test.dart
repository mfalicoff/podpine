import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/features/home/home_screen.dart';
import 'package:podpine/features/shared/multi_select.dart';
import 'package:podpine/providers.dart';

void main() {
  test('selection expands above and below the most recent anchor', () {
    final selection = MultiSelectionController()..begin();
    expect(selection.isActive, isTrue);
    expect(selection.count, 0);
    selection.start(3);

    selection.selectRange([1, 2, 3, 4], SelectionRange.above);
    expect(selection.selectedIds, {1, 2, 3});

    selection
      ..clear()
      ..start(2)
      ..selectRange([1, 2, 3, 4], SelectionRange.below);
    expect(selection.selectedIds, {2, 3, 4});

    selection.retain([3, 4]);
    expect(selection.selectedIds, {3, 4});
  });

  testWidgets(
    'Home selection expands above an episode and marks the group played',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await database.into(database.podcastRows).insert(_podcast);
      final episodes = [_episode(-1), _episode(-2), _episode(-3)];
      for (final episode in episodes) {
        await database.into(database.episodeRows).insert(episode);
      }
      final app = AppController(
        database,
        const CredentialStore(FlutterSecureStorage()),
        playbackDeviceId: 'multi-select-test',
      )..initialized = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            appControllerProvider.overrideWith((ref) => app),
            episodesProvider.overrideWith((ref) => Stream.value(episodes)),
            downloadJobsProvider.overrideWith(
              (ref) => Stream.value(const <DownloadJobRecord>[]),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: HomeScreen())),
        ),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Select episodes'));
      await tester.pump();
      expect(find.text('0 of 3 selected'), findsOneWidget);

      await tester.tap(find.text('Episode -2'));
      await tester.pump();
      expect(find.text('1 of 3 selected'), findsOneWidget);

      await tester.tap(find.byTooltip('Expand selection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select all above'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 3 selected'), findsOneWidget);

      await tester.tap(find.byTooltip('Actions for selected items'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark played'));
      await tester.pumpAndSettle();

      expect((await database.episodeById(-1))!.completed, isTrue);
      expect((await database.episodeById(-2))!.completed, isTrue);
      expect((await database.episodeById(-3))!.completed, isFalse);
      expect(find.text('Mark played: 2 updated.'), findsOneWidget);
    },
  );
}

const _podcast = PodcastRecord(
  id: -7,
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
