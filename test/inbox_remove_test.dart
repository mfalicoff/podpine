import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/backend/podcast_backend.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/features/inbox/inbox_models.dart';
import 'package:podpine/features/inbox/inbox_screen.dart';
import 'package:podpine/providers.dart';

void main() {
  test(
    'removing from Inbox marks played by default and Undo reverses both',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final episode = await _seedInbox(database);
      final backend = _InboxBackend();
      final controller =
          AppController(database, const CredentialStore(FlutterSecureStorage()))
            ..backend = backend
            ..userId = 7;

      expect(
        (await database.inboxSwipePreferences()).markRemovedAsPlayed,
        isTrue,
      );

      final markedPlayed = await controller.removeFromInbox(episode);

      expect(markedPlayed, isTrue);
      expect((await database.episodeById(episode.id))!.completed, isTrue);
      expect(await database.watchInbox().first, isEmpty);
      expect(backend.completedCalls, [(episode.id, true)]);

      await controller.restoreToInbox(episode, restoreAsUnplayed: markedPlayed);

      expect((await database.episodeById(episode.id))!.completed, isFalse);
      expect((await database.watchInbox().first).single.id, episode.id);
      expect(backend.completedCalls, [(episode.id, true), (episode.id, false)]);
    },
  );

  test('removing from Inbox leaves playback unchanged when disabled', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final episode = await _seedInbox(database);
    await database.setInboxSwipePreferences(
      const InboxSwipePreferences(markRemovedAsPlayed: false),
    );
    final backend = _InboxBackend();
    final controller =
        AppController(database, const CredentialStore(FlutterSecureStorage()))
          ..backend = backend
          ..userId = 7;

    final markedPlayed = await controller.removeFromInbox(episode);

    expect(markedPlayed, isFalse);
    expect((await database.episodeById(episode.id))!.completed, isFalse);
    expect(await database.watchInbox().first, isEmpty);
    expect(backend.completedCalls, isEmpty);
  });

  test('removing from Inbox can explicitly keep an episode unplayed', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final episode = await _seedInbox(database);
    final backend = _InboxBackend();
    final controller =
        AppController(database, const CredentialStore(FlutterSecureStorage()))
          ..backend = backend
          ..userId = 7;

    final markedPlayed = await controller.removeFromInbox(
      episode,
      markAsPlayed: false,
    );

    expect(markedPlayed, isFalse);
    expect((await database.episodeById(episode.id))!.completed, isFalse);
    expect(await database.watchInbox().first, isEmpty);
    expect(backend.completedCalls, isEmpty);
  });

  testWidgets('Inbox settings persists remove-as-played preference', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final controller = AppController(
      database,
      const CredentialStore(FlutterSecureStorage()),
    )..initialized = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          appControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: Scaffold(body: InboxScreen())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Inbox settings'));
    await tester.pumpAndSettle();

    expect(find.text('Mark removed episodes as played'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.tap(find.byType(Switch));
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(
      (await database.inboxSwipePreferences()).markRemovedAsPlayed,
      isFalse,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('three-dot removal keeps the episode unplayed and Undo expires', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final episode = await _seedInbox(database);
    final controller = AppController(
      database,
      const CredentialStore(FlutterSecureStorage()),
    )..initialized = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          appControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: Scaffold(body: InboxScreen())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Episode actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from Inbox (keep unplayed)'));
    await tester.pumpAndSettle();

    expect((await database.episodeById(episode.id))!.completed, isFalse);
    expect(
      (await database.select(database.inboxRows).getSingle()).removedAt,
      isA<DateTime>(),
    );
    expect(find.text('Undo'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Undo'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

Future<EpisodeRecord> _seedInbox(AppDatabase database) async {
  await database
      .into(database.podcastRows)
      .insert(
        const PodcastRowsCompanion(id: Value(7), title: Value('Inbox Cast')),
      );
  await database
      .into(database.episodeRows)
      .insert(
        EpisodeRowsCompanion.insert(
          id: const Value(35),
          podcastId: 7,
          podcastTitle: 'Inbox Cast',
          title: 'Inbox episode',
          audioUrl: const Value('https://media.test/35.mp3'),
          durationSeconds: const Value(120),
          publishedAt: DateTime.utc(2026, 8, 11),
          updatedAt: DateTime.utc(2026, 8, 11),
        ),
      );
  await database
      .into(database.inboxRows)
      .insert(
        InboxRowsCompanion.insert(
          episodeId: const Value(35),
          discoveredAt: DateTime.utc(2026, 8, 11),
        ),
      );
  return (await database.episodeById(35))!;
}

class _InboxBackend implements PodcastBackend {
  final completedCalls = <(int, bool)>[];

  @override
  Future<void> markCompleted(int userId, int episodeId, bool completed) async =>
      completedCalls.add((episodeId, completed));

  @override
  Future<void> addToQueue(int userId, int episodeId) async {}

  @override
  Future<String> getChapters(int userId, int episodeId) async => '[]';

  @override
  Future<List<RemoteEpisode>> getEpisodes(int userId) async => const [];

  @override
  Future<List<RemoteEpisode>> getPodcastEpisodes(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async => const [];

  @override
  Future<RemotePodcast> getPodcastDetails(
    int userId,
    RemotePodcast podcast, {
    required bool subscribed,
  }) async => podcast;

  @override
  Future<List<RemoteEpisode>> getQueue(int userId) async => const [];

  @override
  Future<List<RemotePodcast>> getSubscriptions(int userId) async => const [];

  @override
  Future<void> removeFromQueue(int userId, int episodeId) async {}

  @override
  Future<List<RemotePodcast>> searchPodcasts(
    String query, {
    String provider = 'podcast_index',
  }) async => const [];

  @override
  Future<int> subscribe(int userId, RemotePodcast podcast) async => podcast.id;

  @override
  Future<void> unsubscribe(int userId, RemotePodcast podcast) async {}

  @override
  Future<void> updatePlayback(
    int userId,
    int episodeId,
    Duration position,
  ) async {}

  @override
  Future<int> verifyConnection() async => 7;
}
