import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/downloads/download_file_store.dart';
import 'package:podpine/core/downloads/download_manager.dart';
import 'package:podpine/core/downloads/download_models.dart';
import 'package:podpine/core/downloads/download_platform.dart';
import 'package:podpine/features/downloads/download_storage_screen.dart';
import 'package:podpine/providers.dart';

void main() {
  testWidgets('shows grouped storage, episode metadata, and cleanup filters', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final files = _MemoryFileStore();
    addTearDown(database.close);
    await database.upsertPodcast(
      const PodcastRowsCompanion(id: Value(7), title: Value('Test Cast')),
    );
    await database.upsertPodcast(
      const PodcastRowsCompanion(id: Value(8), title: Value('Another Cast')),
    );
    await database.upsertEpisodes([
      _episode(11, 7, 'Test Cast', 'First episode'),
      _episode(12, 8, 'Another Cast', 'Second episode'),
    ]);
    await _completedJob(database, 11, 4, DateTime.utc(2026, 8, 10));
    await _completedJob(database, 12, 6, DateTime.utc(2026, 8, 11));
    files.put('/downloads/episode-11.mp3', [1, 2, 3, 4]);
    files.put('/downloads/episode-12.mp3', [1, 2, 3, 4, 5, 6]);
    final manager = DownloadManager(
      database,
      files: files,
      storage: const _StorageProbe(100),
      storageReserveBytes: 0,
    );
    await manager.refreshStorageSnapshot();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [downloadManagerProvider.overrideWith((ref) => manager)],
        child: const MaterialApp(home: DownloadStorageScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('10 B'), findsOneWidget);
    expect(find.text('Device storage is low'), findsOneWidget);
    expect(find.text('By podcast'), findsOneWidget);
    expect(find.text('Test Cast'), findsWidgets);
    expect(find.text('Another Cast'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Bulk cleanup'), 300);
    expect(find.text('All podcasts'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Played or unplayed'), 150);
    expect(find.text('Played or unplayed'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Any age'), 150);
    expect(find.text('Any age'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Delete 2 matching downloads'),
      150,
    );
    expect(find.text('Delete 2 matching downloads'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Downloaded episodes'), 300);
    await tester.scrollUntilVisible(find.text('First episode'), 200);
    expect(find.text('First episode'), findsOneWidget);
    expect(find.text('Second episode'), findsOneWidget);
    expect(find.textContaining('Aug 10, 2026'), findsOneWidget);
  });
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
  publishedAt: DateTime.utc(2026, 8, 1),
  downloaded: const Value(true),
  updatedAt: DateTime.utc(2026, 8, 1),
);

Future<void> _completedJob(
  AppDatabase database,
  int episodeId,
  int bytes,
  DateTime downloadedAt,
) => database.upsertDownloadJob(
  DownloadJobRowsCompanion.insert(
    episodeId: Value(episodeId),
    sourceUrl: 'https://media.test/episode-$episodeId.mp3',
    filePath: '/downloads/episode-$episodeId.mp3',
    partialPath: '/downloads/episode-$episodeId.mp3.part',
    state: DownloadState.completed.name,
    bytesDownloaded: Value(bytes),
    totalBytes: Value(bytes),
    createdAt: downloadedAt,
    updatedAt: downloadedAt,
  ),
);

class _StorageProbe implements StorageSpaceProbe {
  const _StorageProbe(this.bytes);

  final int bytes;

  @override
  Future<int?> availableBytes() async => bytes;
}

class _MemoryFileStore implements DownloadFileStore {
  final Map<String, List<int>> _files = <String, List<int>>{};

  void put(String path, List<int> bytes) => _files[path] = List.of(bytes);

  @override
  Future<String> downloadsDirectory() async => '/downloads';

  @override
  Future<void> delete(String path) async => _files.remove(path);

  @override
  Future<bool> exists(String path) async => _files.containsKey(path);

  @override
  Future<int> length(String path) async => _files[path]!.length;

  @override
  Future<void> move(String from, String to) async {
    _files[to] = _files.remove(from)!;
  }

  @override
  Future<DownloadByteSink> open(String path, {required bool append}) async {
    if (!append) _files[path] = <int>[];
    return _MemorySink(_files.putIfAbsent(path, () => <int>[]));
  }
}

class _MemorySink implements DownloadByteSink {
  _MemorySink(this.bytes);

  final List<int> bytes;

  @override
  void add(Uint8List bytes) => this.bytes.addAll(bytes);

  @override
  Future<void> close() async {}

  @override
  Future<void> flush() async {}
}
