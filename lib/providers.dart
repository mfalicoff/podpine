import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_controller.dart';
import 'core/app_preferences.dart';
import 'core/database/app_database.dart';
import 'core/downloads/download_manager.dart';
import 'core/storage/credential_store.dart';
import 'features/player/player_controller.dart';
import 'features/library/library_models.dart';

final audioHandlerProvider = Provider<AudioHandler>(
  (ref) => throw StateError('Audio service was not initialized.'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final credentialStoreProvider = Provider<CredentialStore>(
  (ref) => const CredentialStore(FlutterSecureStorage()),
);

final appPreferencesProvider = ChangeNotifierProvider<AppPreferences>((ref) {
  return AppPreferences();
});

final appControllerProvider = ChangeNotifierProvider<AppController>((ref) {
  final controller = AppController(
    ref.watch(databaseProvider),
    ref.watch(credentialStoreProvider),
  );
  controller.initialize();
  return controller;
});

final podcastsProvider = StreamProvider<List<PodcastRecord>>(
  (ref) => ref.watch(databaseProvider).watchPodcasts(),
);

final podcastUnplayedCountsProvider = StreamProvider<Map<int, int>>(
  (ref) => ref.watch(databaseProvider).watchPodcastUnplayedCounts(),
);

final libraryPreferencesProvider = StreamProvider<LibraryPreferences>(
  (ref) => ref.watch(databaseProvider).watchLibraryPreferences(),
);

final libraryFoldersProvider = StreamProvider<List<LibraryFolderRecord>>(
  (ref) => ref.watch(databaseProvider).watchLibraryFolders(),
);

final libraryFolderAssignmentsProvider = StreamProvider<Map<int, int>>(
  (ref) => ref.watch(databaseProvider).watchLibraryFolderAssignments(),
);

final episodesProvider = StreamProvider<List<EpisodeRecord>>(
  (ref) => ref.watch(databaseProvider).watchAllEpisodes(),
);

final downloadManagerProvider = ChangeNotifierProvider<DownloadManager>((ref) {
  final app = ref.watch(appControllerProvider);
  final manager = DownloadManager(
    ref.watch(databaseProvider),
    onDownloadedChanged: app.setDownloaded,
  );
  unawaited(manager.initialize());
  return manager;
});

final downloadJobsProvider = StreamProvider<List<DownloadJobRecord>>(
  (ref) => ref.watch(databaseProvider).watchDownloadJobs(),
);

final queueProvider = StreamProvider<List<EpisodeRecord>>(
  (ref) => ref.watch(databaseProvider).watchQueue(),
);

final inboxUnreadCountProvider = StreamProvider<int>(
  (ref) => ref.watch(databaseProvider).watchInboxUnreadCount(),
);

final playerControllerProvider = ChangeNotifierProvider<PlayerController>((
  ref,
) {
  final controller = PlayerController(
    ref.watch(databaseProvider),
    ref.watch(audioHandlerProvider),
    ref.read(appControllerProvider).recordPosition,
    ref.read(appControllerProvider).setCompleted,
    chapterLoader: ref.read(appControllerProvider).loadChapters,
    recordSeek: (episode, position) => ref
        .read(appControllerProvider)
        .recordPosition(episode, position, userInitiatedSeek: true),
  );
  final app = ref.read(appControllerProvider);
  int? activeEpisodeId() => controller.current?.id;
  app.activeEpisodeId = activeEpisodeId;
  ref.listen(queueProvider, (_, queue) {
    queue.whenData(controller.syncQueue);
  }, fireImmediately: true);
  ref.listen(downloadJobsProvider, (_, jobs) {
    jobs.whenData(controller.syncDownloadJobs);
  }, fireImmediately: true);
  ref.onDispose(() {
    if (identical(app.activeEpisodeId, activeEpisodeId)) {
      app.activeEpisodeId = null;
    }
    controller.dispose();
  });
  return controller;
});
