import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_controller.dart';
import 'core/database/app_database.dart';
import 'core/storage/credential_store.dart';
import 'features/player/player_controller.dart';

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

final episodesProvider = StreamProvider<List<EpisodeRecord>>(
  (ref) => ref.watch(databaseProvider).watchRecentEpisodes(),
);

final queueProvider = StreamProvider<List<EpisodeRecord>>(
  (ref) => ref.watch(databaseProvider).watchQueue(),
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
  );
  ref.onDispose(controller.dispose);
  return controller;
});
