import 'dart:async';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/downloads/download_file_store.dart';
import 'package:podpine/core/downloads/download_manager.dart';
import 'package:podpine/core/downloads/download_models.dart';
import 'package:podpine/core/downloads/download_platform.dart';

void main() {
  late AppDatabase database;
  late _MemoryFileStore files;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    files = _MemoryFileStore();
    await database.upsertPodcast(
      const PodcastRowsCompanion(id: Value(7), title: Value('Test Cast')),
    );
    await database.into(database.episodeRows).insert(_episode());
  });

  tearDown(() => database.close());

  test('completes a download and exposes the validated local path', () async {
    final manager = DownloadManager(
      database,
      files: files,
      storage: const _StorageProbe(1024 * 1024),
      storageReserveBytes: 0,
      clientFactory: () => _Client((request) async {
        expect(request.url.toString(), 'https://media.test/episode.mp3');
        return _response([1, 2, 3, 4]);
      }),
    );
    addTearDown(manager.dispose);

    await manager.start((await database.episodeById(11))!);
    final job = await _waitForState(database, 11, DownloadState.completed);

    expect(files.data(job.filePath), [1, 2, 3, 4]);
    expect(await files.exists(job.partialPath), isFalse);
    expect((await database.episodeById(11))!.downloaded, isTrue);
    expect(await database.completedDownloadPaths([11]), {11: job.filePath});
  });

  test('resumes a partial file with Range and If-Range validation', () async {
    await _insertJob(
      database,
      state: DownloadState.paused,
      bytes: 2,
      total: 4,
      etag: 'etag-one',
    );
    files.put('/downloads/episode-11.mp3.part', [1, 2]);
    final manager = DownloadManager(
      database,
      files: files,
      storage: const _StorageProbe(1024),
      storageReserveBytes: 0,
      clientFactory: () => _Client((request) async {
        expect(request.headers['Range'], 'bytes=2-');
        expect(request.headers['If-Range'], 'etag-one');
        return _response(
          [3, 4],
          status: 206,
          headers: {'content-range': 'bytes 2-3/4'},
        );
      }),
    );
    addTearDown(manager.dispose);

    await manager.resume(11);
    final job = await _waitForState(database, 11, DownloadState.completed);

    expect(files.data(job.filePath), [1, 2, 3, 4]);
    expect(job.bytesDownloaded, 4);
  });

  test(
    'turns interrupted jobs into resumable paused jobs on restart',
    () async {
      await _insertJob(
        database,
        state: DownloadState.downloading,
        bytes: 99,
        total: 120,
      );
      files.put('/downloads/episode-11.mp3.part', [1, 2, 3]);
      final manager = DownloadManager(database, files: files);
      addTearDown(manager.dispose);

      await manager.initialize();
      final job = await database.downloadJob(11);

      expect(job!.downloadState, DownloadState.paused);
      expect(job.bytesDownloaded, 3);
    },
  );

  test(
    'pauses an active transfer and keeps its partial file resumable',
    () async {
      final client = _PausableClient();
      final manager = DownloadManager(
        database,
        files: files,
        storage: const _StorageProbe(1024),
        storageReserveBytes: 0,
        clientFactory: () => client,
      );
      addTearDown(manager.dispose);

      await manager.start((await database.episodeById(11))!);
      await _waitForState(database, 11, DownloadState.downloading);
      await client.firstChunkWritten;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await manager.pause(11);
      await _waitUntil(() => !manager.isActive(11));

      final job = await database.downloadJob(11);
      expect(job!.downloadState, DownloadState.paused);
      expect(await files.exists(job.partialPath), isTrue);
      expect(await files.length(job.partialPath), greaterThan(0));
    },
  );

  test('cleans an invalid completed file safely during recovery', () async {
    await database.setDownloaded(11, true);
    await _insertJob(
      database,
      state: DownloadState.completed,
      bytes: 4,
      total: 4,
    );
    files.put('/downloads/episode-11.mp3', [1, 2]);
    final manager = DownloadManager(database, files: files);
    addTearDown(manager.dispose);

    await manager.initialize();
    final job = await database.downloadJob(11);

    expect(job!.downloadState, DownloadState.failed);
    expect(await files.exists(job.filePath), isFalse);
    expect((await database.episodeById(11))!.downloaded, isFalse);
  });

  test(
    'retries an expired URL after the database supplies a fresh URL',
    () async {
      await _insertJob(
        database,
        state: DownloadState.failed,
        sourceUrl: 'https://media.test/expired.mp3',
      );
      var requests = 0;
      final manager = DownloadManager(
        database,
        files: files,
        storage: const _StorageProbe(1024),
        storageReserveBytes: 0,
        clientFactory: () => _Client((request) async {
          requests++;
          if (requests == 1) {
            expect(request.url.path, '/expired.mp3');
            return _response(const [], status: 403);
          }
          expect(request.url.path, '/episode.mp3');
          return _response([8, 9]);
        }),
      );
      addTearDown(manager.dispose);

      await manager.retry(11);
      await _waitForState(database, 11, DownloadState.completed);

      expect(requests, 2);
    },
  );

  test(
    'reports low storage without leaving a corrupt completed file',
    () async {
      final manager = DownloadManager(
        database,
        files: files,
        storage: const _StorageProbe(2),
        storageReserveBytes: 0,
        clientFactory: () => _Client((_) async => _response([1, 2, 3, 4])),
      );
      addTearDown(manager.dispose);

      await manager.start((await database.episodeById(11))!);
      final job = await _waitForState(database, 11, DownloadState.failed);

      expect(job.error, contains('Not enough free storage'));
      expect(await files.exists(job.filePath), isFalse);
      expect((await database.episodeById(11))!.downloaded, isFalse);
    },
  );

  test(
    'reports storage totals and groups completed media by podcast',
    () async {
      await database.upsertPodcast(
        const PodcastRowsCompanion(id: Value(8), title: Value('Another Cast')),
      );
      await database
          .into(database.episodeRows)
          .insert(
            EpisodeRowsCompanion.insert(
              id: const Value(12),
              podcastId: 8,
              podcastTitle: 'Another Cast',
              title: 'Second episode',
              publishedAt: DateTime.utc(2026, 8, 9),
              updatedAt: DateTime.utc(2026, 8, 9),
            ),
          );
      await _insertJob(
        database,
        state: DownloadState.completed,
        bytes: 4,
        total: 4,
        updatedAt: DateTime.utc(2026, 8, 10),
      );
      await _insertJob(
        database,
        episodeId: 12,
        state: DownloadState.completed,
        bytes: 6,
        total: 6,
        updatedAt: DateTime.utc(2026, 8, 11),
      );
      final manager = DownloadManager(
        database,
        files: files,
        storage: const _StorageProbe(200),
        storageReserveBytes: 0,
      );
      addTearDown(manager.dispose);

      final snapshot = await manager.refreshStorageSnapshot();

      expect(snapshot.totalBytes, 10);
      expect(snapshot.items.map((item) => item.episode.id), [12, 11]);
      expect(snapshot.podcasts, hasLength(2));
      expect(
        snapshot.podcasts.map((usage) => usage.title),
        containsAll(['Test Cast', 'Another Cast']),
      );
      expect(snapshot.availableBytes, 200);
      expect(snapshot.isLowStorage, isTrue);
    },
  );

  test(
    'bulk cleanup filters completed media and protects partial downloads',
    () async {
      await database
          .into(database.episodeRows)
          .insert(
            EpisodeRowsCompanion.insert(
              id: const Value(12),
              podcastId: 7,
              podcastTitle: 'Test Cast',
              title: 'Unplayed episode',
              publishedAt: DateTime.utc(2026, 6, 1),
              updatedAt: DateTime.utc(2026, 6, 1),
            ),
          );
      await database
          .into(database.episodeRows)
          .insert(
            EpisodeRowsCompanion.insert(
              id: const Value(13),
              podcastId: 7,
              podcastTitle: 'Test Cast',
              title: 'Partial episode',
              publishedAt: DateTime.utc(2026, 5, 1),
              updatedAt: DateTime.utc(2026, 5, 1),
            ),
          );
      await database.setCompleted(11, true);
      await _insertJob(
        database,
        state: DownloadState.completed,
        bytes: 4,
        total: 4,
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      await _insertJob(
        database,
        episodeId: 12,
        state: DownloadState.completed,
        bytes: 6,
        total: 6,
        updatedAt: DateTime.utc(2026, 6, 1),
      );
      await _insertJob(
        database,
        episodeId: 13,
        state: DownloadState.paused,
        bytes: 2,
        total: 8,
        updatedAt: DateTime.utc(2026, 5, 1),
      );
      files.put('/downloads/episode-11.mp3', [1, 2, 3, 4]);
      files.put('/downloads/episode-12.mp3', [1, 2, 3, 4, 5, 6]);
      files.put('/downloads/episode-13.mp3.part', [1, 2]);
      final manager = DownloadManager(
        database,
        files: files,
        storageReserveBytes: 0,
      );
      addTearDown(manager.dispose);

      final result = await manager.cleanupDownloads(
        DownloadCleanupFilter(
          podcastId: 7,
          played: true,
          downloadedBefore: DateTime.utc(2026, 7, 1),
        ),
      );

      expect(result.deletedCount, 1);
      expect(result.reclaimedBytes, 4);
      expect(await database.downloadJob(11), isNull);
      expect(await database.downloadJob(12), isNotNull);
      expect(await database.downloadJob(13), isNotNull);
      expect(await files.exists('/downloads/episode-13.mp3.part'), isTrue);
    },
  );

  test(
    'manual downloads fail preflight before creating partial state',
    () async {
      final manager = DownloadManager(
        database,
        files: files,
        storage: const _StorageProbe(99),
        storageReserveBytes: 100,
      );
      addTearDown(manager.dispose);

      await expectLater(
        manager.start((await database.episodeById(11))!),
        throwsA(isA<LowStorageException>()),
      );

      expect(await database.downloadJob(11), isNull);
      expect(manager.isLowStorage, isTrue);
    },
  );

  test(
    'cancel removes partial state and delete removes completed media',
    () async {
      await _insertJob(
        database,
        state: DownloadState.paused,
        bytes: 2,
        total: 4,
      );
      files.put('/downloads/episode-11.mp3.part', [1, 2]);
      final manager = DownloadManager(database, files: files);
      addTearDown(manager.dispose);

      await manager.cancel(11);
      expect(await database.downloadJob(11), isNull);
      expect(await files.exists('/downloads/episode-11.mp3.part'), isFalse);

      await _insertJob(
        database,
        state: DownloadState.completed,
        bytes: 4,
        total: 4,
      );
      files.put('/downloads/episode-11.mp3', [1, 2, 3, 4]);
      await database.setDownloaded(11, true);
      await manager.delete(11);

      expect(await database.downloadJob(11), isNull);
      expect(await files.exists('/downloads/episode-11.mp3'), isFalse);
      expect((await database.episodeById(11))!.downloaded, isFalse);
    },
  );
}

EpisodeRowsCompanion _episode() => EpisodeRowsCompanion.insert(
  id: const Value(11),
  podcastId: 7,
  podcastTitle: 'Test Cast',
  title: 'Episode',
  audioUrl: const Value('https://media.test/episode.mp3'),
  publishedAt: DateTime.utc(2026, 8, 10),
  updatedAt: DateTime.utc(2026, 8, 10),
);

Future<void> _insertJob(
  AppDatabase database, {
  int episodeId = 11,
  required DownloadState state,
  int bytes = 0,
  int? total,
  String? etag,
  String sourceUrl = 'https://media.test/episode.mp3',
  DateTime? updatedAt,
}) => database.upsertDownloadJob(
  DownloadJobRowsCompanion.insert(
    episodeId: Value(episodeId),
    sourceUrl: sourceUrl,
    filePath: '/downloads/episode-$episodeId.mp3',
    partialPath: '/downloads/episode-$episodeId.mp3.part',
    state: state.name,
    bytesDownloaded: Value(bytes),
    totalBytes: Value(total),
    etag: Value(etag),
    createdAt: DateTime.utc(2026, 8, 10),
    updatedAt: updatedAt ?? DateTime.utc(2026, 8, 10),
  ),
);

Future<DownloadJobRecord> _waitForState(
  AppDatabase database,
  int episodeId,
  DownloadState state,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (DateTime.now().isBefore(deadline)) {
    final job = await database.downloadJob(episodeId);
    if (job?.downloadState == state) return job!;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError('Download $episodeId did not reach ${state.name}.');
}

Future<void> _waitUntil(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (DateTime.now().isBefore(deadline)) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError('Condition was not reached.');
}

http.StreamedResponse _response(
  List<int> bytes, {
  int status = 200,
  Map<String, String> headers = const {},
}) => http.StreamedResponse(
  Stream.value(bytes),
  status,
  contentLength: bytes.length,
  headers: headers,
);

class _Client extends http.BaseClient {
  _Client(this.handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      handler(request);
}

class _PausableClient extends http.BaseClient {
  final StreamController<List<int>> _stream = StreamController<List<int>>();
  final Completer<void> _firstChunk = Completer<void>();

  Future<void> get firstChunkWritten => _firstChunk.future;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    scheduleMicrotask(() {
      _stream.add([1, 2]);
      _firstChunk.complete();
    });
    return http.StreamedResponse(_stream.stream, 200, contentLength: 4);
  }

  @override
  void close() {
    if (!_stream.isClosed) unawaited(_stream.close());
  }
}

class _StorageProbe implements StorageSpaceProbe {
  const _StorageProbe(this.bytes);

  final int? bytes;

  @override
  Future<int?> availableBytes() async => bytes;
}

class _MemoryFileStore implements DownloadFileStore {
  final Map<String, List<int>> _files = <String, List<int>>{};

  void put(String path, List<int> bytes) => _files[path] = List.of(bytes);

  List<int>? data(String path) => _files[path];

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
