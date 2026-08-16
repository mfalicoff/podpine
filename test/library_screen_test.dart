import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/downloads/download_manager.dart';
import 'package:podpine/features/library/library_models.dart';
import 'package:podpine/features/library/library_screen.dart';
import 'package:podpine/providers.dart';

void main() {
  test(
    'library preferences, folders, assignments, and counts persist',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      await _seedLibrary(database);

      final folderId = await database.createLibraryFolder('Favorites');
      await database.movePodcastToLibraryFolder(7, folderId);
      await database.setLibraryArtworkSize(LibraryArtworkSize.small);

      expect(
        (await database.watchLibraryPreferences().first).artworkSize,
        LibraryArtworkSize.small,
      );
      expect(
        (await database.watchLibraryFolders().first).single.name,
        'Favorites',
      );
      expect(await database.watchLibraryFolderAssignments().first, {
        7: folderId,
      });
      expect(await database.watchPodcastUnplayedCounts().first, {7: 2, 8: 1});

      await database.setCompleted(71, true);
      expect(await database.watchPodcastUnplayedCounts().first, {7: 1, 8: 1});

      await database.deleteLibraryFolder(folderId);
      expect(await database.watchLibraryFolderAssignments().first, isEmpty);
    },
  );

  testWidgets('library can resize artwork, create folders, and move podcasts', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final database = AppDatabase(NativeDatabase.memory());
    final downloads = DownloadManager(database);
    addTearDown(database.close);
    await _seedLibrary(database);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          downloadManagerProvider.overrideWith((ref) => downloads),
        ],
        child: const MaterialApp(home: Scaffold(body: LibraryScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('2 unplayed episodes'), findsOneWidget);
    semantics.dispose();
    expect(_firstGridColumns(tester), 4);

    await tester.tap(find.byTooltip('Customize library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Large'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Favorites');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Favorites'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(_firstGridColumns(tester), 2);

    await tester.tap(find.byTooltip('Organize Test Cast'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsOneWidget);
    final folder = await database
        .select(database.libraryFolderRows)
        .getSingle();
    final assignment = await database
        .select(database.libraryFolderMembershipRows)
        .getSingle();
    expect(assignment.podcastId, 7);
    expect(assignment.folderId, folder.id);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

int _firstGridColumns(WidgetTester tester) {
  final grid = tester.widget<SliverGrid>(find.byType(SliverGrid).first);
  return (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
      .crossAxisCount;
}

Future<void> _seedLibrary(AppDatabase database) async {
  await database.upsertPodcast(
    const PodcastRowsCompanion(
      id: Value(7),
      title: Value('Test Cast'),
      author: Value('Test Studio'),
      episodeCount: Value(2),
    ),
  );
  await database.upsertPodcast(
    const PodcastRowsCompanion(
      id: Value(8),
      title: Value('Another Cast'),
      author: Value('Another Studio'),
      episodeCount: Value(1),
    ),
  );
  await database.upsertEpisodes([
    _episode(71, 7, 'Test Cast', 'First episode'),
    _episode(72, 7, 'Test Cast', 'Second episode'),
    _episode(81, 8, 'Another Cast', 'Third episode'),
  ]);
}

EpisodeRowsCompanion _episode(
  int id,
  int podcastId,
  String podcastTitle,
  String title,
) => EpisodeRowsCompanion.insert(
  id: Value(id),
  podcastId: podcastId,
  podcastTitle: podcastTitle,
  title: title,
  publishedAt: DateTime.utc(2026, 8, 10),
  updatedAt: DateTime.utc(2026, 8, 10),
);
