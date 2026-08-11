import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  });

  tearDown(() => database.close());

  test(
    'global rules deterministically download the newest episode limit',
    () async {
      await database.upsertEpisodes([
        _episode(11, DateTime.utc(2026, 8, 11)),
        _episode(12, DateTime.utc(2026, 8, 12)),
        _episode(13, DateTime.utc(2026, 8, 13)),
      ]);
      await database.setDownloadPreferences(
        const DownloadRuleSettings(
          automatic: true,
          episodeLimit: 2,
          wifiOnly: true,
          storageFloorBytes: 0,
        ).toGlobalCompanion(),
      );
      expect(
        (await database.downloadPreferences())?.settings.automatic,
        isTrue,
      );
      final requested = <int>[];
      final manager = _manager(
        database,
        files,
        clientFactory: () => _Client((request) async {
          requested.add(_episodeId(request.url));
          return _response([1, 2, 3]);
        }),
      );
      addTearDown(manager.dispose);

      await manager.initialize();
      await manager.evaluateRules();
      await _waitForState(database, 12, DownloadState.completed);
      await _waitForState(database, 13, DownloadState.completed);

      expect(requested.toSet(), {12, 13});
      expect(await database.downloadJob(11), isNull);

      await database.upsertEpisodes([_episode(14, DateTime.utc(2026, 8, 14))]);
      await manager.evaluateRules();
      await _waitForState(database, 14, DownloadState.completed);

      expect(await database.downloadJob(12), isNull);
      expect(requested.toSet(), {12, 13, 14});
    },
  );

  test('podcast rules override disabled global automatic downloads', () async {
    await database.upsertEpisodes([_episode(11, DateTime.utc(2026, 8, 11))]);
    await database.setDownloadPreferences(
      const DownloadRuleSettings(automatic: false).toGlobalCompanion(),
    );
    await database.setPodcastDownloadOverride(
      const DownloadRuleSettings(
        automatic: true,
        episodeLimit: 1,
        storageFloorBytes: 0,
      ).toPodcastCompanion(7),
    );
    final manager = _manager(database, files);
    addTearDown(manager.dispose);

    await manager.initialize();

    expect(
      (await _waitForState(database, 11, DownloadState.completed)).automatic,
      isTrue,
    );
  });

  test('automatic rules wait when charging-only condition is unmet', () async {
    await database.upsertEpisodes([_episode(11, DateTime.utc(2026, 8, 11))]);
    await database.setDownloadPreferences(
      const DownloadRuleSettings(
        automatic: true,
        chargingOnly: true,
        storageFloorBytes: 0,
      ).toGlobalCompanion(),
    );
    var requests = 0;
    final manager = _manager(
      database,
      files,
      charging: const _ChargingProbe(false),
      clientFactory: () => _Client((_) async {
        requests++;
        return _response([1]);
      }),
    );
    addTearDown(manager.dispose);

    await manager.initialize();

    expect(requests, 0);
    expect(await database.downloadJob(11), isNull);
  });

  test('manual cellular downloads require explicit confirmation', () async {
    await database.upsertEpisodes([_episode(11, DateTime.utc(2026, 8, 11))]);
    final manager = _manager(
      database,
      files,
      network: const _NetworkProbe([ConnectivityResult.mobile]),
    );
    addTearDown(manager.dispose);
    final episode = (await database.episodeById(11))!;

    await expectLater(
      manager.start(episode),
      throwsA(isA<CellularDownloadConfirmationRequired>()),
    );
    expect(await database.downloadJob(11), isNull);

    await manager.start(episode, allowCellular: true);
    await _waitForState(database, 11, DownloadState.completed);
  });

  test('available-storage floor blocks an automatic download', () async {
    await database.upsertEpisodes([_episode(11, DateTime.utc(2026, 8, 11))]);
    await database.setDownloadPreferences(
      const DownloadRuleSettings(
        automatic: true,
        storageFloorBytes: 100,
      ).toGlobalCompanion(),
    );
    final manager = _manager(
      database,
      files,
      storage: const _StorageProbe(102),
      clientFactory: () => _Client((_) async => _response([1, 2, 3, 4])),
    );
    addTearDown(manager.dispose);

    await manager.initialize();
    final job = await _waitForState(database, 11, DownloadState.failed);

    expect(job.error, contains('Not enough free storage'));
    expect(await files.exists(job.filePath), isFalse);
  });

  test(
    'played downloads are deleted immediately by retention policy',
    () async {
      await database.upsertEpisodes([
        _episode(
          11,
          DateTime.utc(2026, 8, 11),
          completed: true,
          downloaded: true,
        ),
      ]);
      await database.setDownloadPreferences(
        const DownloadRuleSettings(
          retention: PlayedDownloadRetention.immediate,
        ).toGlobalCompanion(),
      );
      await _insertCompletedJob(database, 11);
      files.put('/downloads/episode-11.mp3', [1, 2, 3]);
      final manager = _manager(database, files);
      addTearDown(manager.dispose);

      await manager.initialize();

      expect(await database.downloadJob(11), isNull);
      expect(await files.exists('/downloads/episode-11.mp3'), isFalse);
      expect((await database.episodeById(11))!.downloaded, isFalse);
    },
  );

  test(
    'delayed retention keeps a stable played timestamp across refreshes',
    () async {
      var now = DateTime.utc(2026, 8, 11, 12);
      await database.upsertEpisodes([
        _episode(11, now, completed: true, downloaded: true),
      ]);
      await database.setDownloadPreferences(
        const DownloadRuleSettings(
          retention: PlayedDownloadRetention.delayed,
          retentionDelayHours: 24,
        ).toGlobalCompanion(),
      );
      await _insertCompletedJob(database, 11);
      files.put('/downloads/episode-11.mp3', [1, 2, 3]);
      final manager = _manager(database, files, now: () => now);
      addTearDown(manager.dispose);

      await manager.initialize();
      final playedAt = (await database.downloadJob(11))!.playedAt;
      expect(playedAt, isNotNull);

      now = now.add(const Duration(hours: 20));
      await database.upsertEpisodes([
        _episode(11, now, completed: true, downloaded: true),
      ]);
      await manager.evaluateRules();
      expect(await database.downloadJob(11), isNotNull);
      expect((await database.downloadJob(11))!.playedAt, playedAt);

      now = now.add(const Duration(hours: 5));
      await manager.evaluateRules();
      expect(await database.downloadJob(11), isNull);
    },
  );

  test(
    'failed automatic jobs resume the same partial file after backoff',
    () async {
      var now = DateTime.utc(2026, 8, 11, 12);
      await database.upsertEpisodes([_episode(11, now)]);
      await database.setDownloadPreferences(
        const DownloadRuleSettings(
          automatic: true,
          storageFloorBytes: 0,
        ).toGlobalCompanion(),
      );
      var requests = 0;
      final manager = _manager(
        database,
        files,
        now: () => now,
        clientFactory: () => _Client((request) async {
          requests++;
          if (requests == 1) {
            return http.StreamedResponse(
              Stream.value([1, 2]),
              200,
              contentLength: 4,
            );
          }
          expect(request.headers['Range'], 'bytes=2-');
          return _response(
            [3, 4],
            status: 206,
            headers: {'content-range': 'bytes 2-3/4'},
          );
        }),
      );
      addTearDown(manager.dispose);

      await manager.initialize();
      final failed = await _waitForState(database, 11, DownloadState.failed);
      expect(failed.attempts, 1);
      expect(files.data(failed.partialPath), [1, 2]);

      now = now.add(const Duration(minutes: 2));
      await manager.evaluateRules();
      final completed = await _waitForState(
        database,
        11,
        DownloadState.completed,
      );

      expect(requests, 2);
      expect(files.data(completed.filePath), [1, 2, 3, 4]);
      expect(await files.exists(completed.partialPath), isFalse);
    },
  );
}

DownloadManager _manager(
  AppDatabase database,
  _MemoryFileStore files, {
  StorageSpaceProbe storage = const _StorageProbe(1024 * 1024),
  DownloadNetworkProbe network = const _NetworkProbe([ConnectivityResult.wifi]),
  ChargingStateProbe charging = const _ChargingProbe(true),
  DownloadClientFactory? clientFactory,
  DateTime Function()? now,
}) => DownloadManager(
  database,
  files: files,
  storage: storage,
  network: network,
  charging: charging,
  storageReserveBytes: 0,
  clientFactory:
      clientFactory ?? () => _Client((_) async => _response([1, 2, 3])),
  now: now,
);

EpisodeRowsCompanion _episode(
  int id,
  DateTime publishedAt, {
  bool completed = false,
  bool downloaded = false,
}) => EpisodeRowsCompanion.insert(
  id: Value(id),
  podcastId: 7,
  podcastTitle: 'Test Cast',
  title: 'Episode $id',
  audioUrl: Value('https://media.test/episode-$id.mp3'),
  publishedAt: publishedAt,
  completed: Value(completed),
  downloaded: Value(downloaded),
  updatedAt: publishedAt,
);

Future<void> _insertCompletedJob(AppDatabase database, int episodeId) =>
    database.upsertDownloadJob(
      DownloadJobRowsCompanion.insert(
        episodeId: Value(episodeId),
        sourceUrl: 'https://media.test/episode-$episodeId.mp3',
        filePath: '/downloads/episode-$episodeId.mp3',
        partialPath: '/downloads/episode-$episodeId.mp3.part',
        state: DownloadState.completed.name,
        bytesDownloaded: const Value(3),
        totalBytes: const Value(3),
        createdAt: DateTime.utc(2026, 8, 11),
        updatedAt: DateTime.utc(2026, 8, 11),
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
  throw StateError(
    'Download $episodeId did not reach ${state.name}. Jobs: '
    '${await database.downloadJobs()}',
  );
}

int _episodeId(Uri uri) =>
    int.parse(RegExp(r'episode-(\d+)').firstMatch(uri.path)!.group(1)!);

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

class _StorageProbe implements StorageSpaceProbe {
  const _StorageProbe(this.bytes);

  final int? bytes;

  @override
  Future<int?> availableBytes() async => bytes;
}

class _NetworkProbe implements DownloadNetworkProbe {
  const _NetworkProbe(this.results);

  final List<ConnectivityResult> results;

  @override
  Future<List<ConnectivityResult>> current() async => results;
}

class _ChargingProbe implements ChargingStateProbe {
  const _ChargingProbe(this.value);

  final bool? value;

  @override
  Future<bool?> isCharging() async => value;
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
