import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/features/details/podcast_detail_screen.dart';
import 'package:podpine/features/home/home_screen.dart';
import 'package:podpine/providers.dart';

void main() {
  testWidgets('all episodes can be filtered by playback and download state', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final app = AppController(
      database,
      const CredentialStore(FlutterSecureStorage()),
    )..initialized = true;
    addTearDown(database.close);
    final episodes = [
      _episode(1, 'Unplayed episode'),
      _episode(2, 'Played episode', completed: true),
      _episode(3, 'Downloaded episode', downloaded: true),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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

    expect(find.text('Unplayed episode'), findsOneWidget);
    expect(find.text('Played episode'), findsOneWidget);
    expect(find.text('Downloaded episode'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Played'));
    await tester.pump();
    expect(find.text('Played episode'), findsOneWidget);
    expect(find.text('Unplayed episode'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Downloaded'));
    await tester.pump();
    expect(find.text('Downloaded episode'), findsOneWidget);
    expect(find.text('Played episode'), findsNothing);
  });

  testWidgets('continue listening opens the episode view', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final app = AppController(
      database,
      const CredentialStore(FlutterSecureStorage()),
    )..initialized = true;
    addTearDown(database.close);
    final episode = _episode(4, 'Continue this episode', positionSeconds: 30);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appControllerProvider.overrideWith((ref) => app),
          episodesProvider.overrideWith((ref) => Stream.value([episode])),
          downloadJobsProvider.overrideWith(
            (ref) => Stream.value(const <DownloadJobRecord>[]),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: HomeScreen())),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Continue this episode').first);
    await tester.pumpAndSettle();

    expect(find.byType(EpisodeDetailScreen), findsOneWidget);
    expect(find.text('Episode'), findsOneWidget);
  });
}

EpisodeRecord _episode(
  int id,
  String title, {
  bool completed = false,
  bool downloaded = false,
  int positionSeconds = 0,
}) => EpisodeRecord(
  id: id,
  podcastId: 7,
  podcastTitle: 'Test Cast',
  title: title,
  description: '',
  artworkUrl: '',
  audioUrl: 'https://media.test/$id.mp3',
  publishedAt: DateTime.utc(2026, 8, 10).add(Duration(hours: id)),
  durationSeconds: 120,
  positionSeconds: positionSeconds,
  completed: completed,
  queued: false,
  downloaded: downloaded,
  isYoutube: false,
  chaptersJson: '[]',
  playbackIntent: 'progress',
  playbackMediaIdentity: 'https://media.test/$id.mp3',
  updatedAt: DateTime.utc(2026, 8, 10),
);
