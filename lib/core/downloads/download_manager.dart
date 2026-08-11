import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../database/app_database.dart';
import 'download_file_store.dart';
import 'download_models.dart';
import 'download_platform.dart';

typedef DownloadClientFactory = http.Client Function();

class DownloadManager extends ChangeNotifier {
  DownloadManager(
    this.database, {
    DownloadFileStore? files,
    StorageSpaceProbe? storage,
    DownloadNetworkProbe? network,
    ChargingStateProbe? charging,
    DownloadClientFactory? clientFactory,
    this.onDownloadedChanged,
    this.storageReserveBytes = 100 * 1024 * 1024,
    DateTime Function()? now,
  }) : files = files ?? const DeviceDownloadFileStore(),
       storage = storage ?? const DeviceStorageSpaceProbe(),
       network = network ?? const DeviceDownloadNetworkProbe(),
       charging = charging ?? const DeviceChargingStateProbe(),
       _now = now ?? DateTime.now,
       _clientFactory = clientFactory ?? http.Client.new;

  final AppDatabase database;
  final DownloadFileStore files;
  final StorageSpaceProbe storage;
  final DownloadNetworkProbe network;
  final ChargingStateProbe charging;
  final DownloadClientFactory _clientFactory;
  final DateTime Function() _now;
  final Future<void> Function(EpisodeRecord episode, bool downloaded)?
  onDownloadedChanged;
  final int storageReserveBytes;
  final Map<int, _ActiveDownload> _active = <int, _ActiveDownload>{};
  StreamSubscription<List<EpisodeRecord>>? _episodeSubscription;
  Timer? _policyTimer;
  DateTime? _policyDeadline;
  Future<void>? _evaluationInFlight;
  bool _evaluationRequested = false;

  bool _disposed = false;

  bool isActive(int episodeId) => _active.containsKey(episodeId);

  Future<void> initialize() async {
    for (final job in await database.downloadJobs()) {
      final episode = await database.episodeById(job.episodeId);
      if (episode == null) {
        await _deleteFiles(job);
        await database.deleteDownloadJob(job.episodeId);
        continue;
      }
      if (job.downloadState == DownloadState.completed) {
        final exists = await files.exists(job.filePath);
        final length = exists ? await files.length(job.filePath) : 0;
        final valid =
            exists &&
            length > 0 &&
            (job.totalBytes == null || length == job.totalBytes);
        if (!valid) {
          await _deleteFiles(job);
          await database.updateDownloadJob(
            job.episodeId,
            DownloadJobRowsCompanion(
              state: Value(DownloadState.failed.name),
              bytesDownloaded: const Value(0),
              error: const Value(
                'The downloaded file was missing or incomplete.',
              ),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
          await _setDownloaded(episode, false);
        } else if (!episode.downloaded) {
          await _setDownloaded(episode, true);
        }
        continue;
      }

      final partialExists = await files.exists(job.partialPath);
      final partialLength = partialExists
          ? await files.length(job.partialPath)
          : 0;
      await database.updateDownloadJob(
        job.episodeId,
        DownloadJobRowsCompanion(
          state: Value(
            job.downloadState == DownloadState.downloading ||
                    job.downloadState == DownloadState.queued
                ? DownloadState.paused.name
                : job.state,
          ),
          bytesDownloaded: Value(partialLength),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
    _episodeSubscription = database.watchAllEpisodes().listen(
      (_) => unawaited(evaluateRules()),
    );
    await evaluateRules();
  }

  Future<bool> requiresCellularConfirmation() async {
    final connections = await network.current();
    return connections.contains(ConnectivityResult.mobile) &&
        !connections.contains(ConnectivityResult.wifi) &&
        !connections.contains(ConnectivityResult.ethernet);
  }

  Future<void> start(
    EpisodeRecord episode, {
    bool allowCellular = false,
    bool automatic = false,
    int? storageFloorBytes,
  }) async {
    if (_disposed || _active.containsKey(episode.id)) return;
    if (!automatic && !allowCellular && await requiresCellularConfirmation()) {
      throw const CellularDownloadConfirmationRequired();
    }
    if (episode.audioUrl.trim().isEmpty) {
      throw const DownloadException(
        'This episode has no downloadable media URL.',
      );
    }
    final current = await database.downloadJob(episode.id);
    if (current?.downloadState == DownloadState.completed) return;

    if (current == null) {
      final directory = await files.downloadsDirectory();
      final extension = _fileExtension(episode.audioUrl);
      final filePath = '$directory/episode-${episode.id}$extension';
      await database.upsertDownloadJob(
        DownloadJobRowsCompanion.insert(
          episodeId: Value(episode.id),
          sourceUrl: episode.audioUrl,
          filePath: filePath,
          partialPath: '$filePath.part',
          state: DownloadState.queued.name,
          automatic: Value(automatic),
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    } else {
      await database.updateDownloadJob(
        episode.id,
        DownloadJobRowsCompanion(
          state: Value(DownloadState.queued.name),
          error: const Value(null),
          automatic: Value(automatic || current.automatic),
          nextAttemptAt: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
    await database.setDownloaded(episode.id, false);

    final active = _ActiveDownload(
      _clientFactory(),
      storageFloorBytes ?? storageReserveBytes,
    );
    _active[episode.id] = active;
    notifyListeners();
    unawaited(_run(episode.id, active));
  }

  Future<void> pause(int episodeId) async {
    final active = _active[episodeId];
    if (active == null) return;
    active.command = _DownloadCommand.pause;
    active.client.close();
    await database.updateDownloadJob(
      episodeId,
      DownloadJobRowsCompanion(
        state: Value(DownloadState.paused.name),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> resume(int episodeId) async {
    final episode = await database.episodeById(episodeId);
    if (episode == null) return;
    await start(episode);
  }

  Future<void> retry(int episodeId) => resume(episodeId);

  Future<void> cancel(int episodeId) => _remove(episodeId);

  Future<void> delete(int episodeId) => _remove(episodeId);

  Future<void> _remove(int episodeId) async {
    final active = _active[episodeId];
    if (active != null) {
      active.command = _DownloadCommand.cancel;
      active.client.close();
    }
    final job = await database.downloadJob(episodeId);
    if (job != null) await _deleteFiles(job);
    await database.deleteDownloadJob(episodeId);
    final episode = await database.episodeById(episodeId);
    if (episode != null) await _setDownloaded(episode, false);
    notifyListeners();
  }

  Future<void> _run(int episodeId, _ActiveDownload active) async {
    DownloadByteSink? sink;
    try {
      var job = await database.downloadJob(episodeId);
      if (job == null || active.command == _DownloadCommand.cancel) return;
      await database.updateDownloadJob(
        episodeId,
        DownloadJobRowsCompanion(
          state: Value(DownloadState.downloading.name),
          error: const Value(null),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      var offset = await files.exists(job.partialPath)
          ? await files.length(job.partialPath)
          : 0;
      var response = await _send(job, offset, active.client);

      if (response.statusCode == 401 || response.statusCode == 403) {
        await response.stream.drain<void>();
        final episode = await database.episodeById(episodeId);
        final refreshedUrl = episode?.audioUrl.trim() ?? '';
        if (refreshedUrl.isNotEmpty && refreshedUrl != job.sourceUrl) {
          await database.updateDownloadJob(
            episodeId,
            DownloadJobRowsCompanion(
              sourceUrl: Value(refreshedUrl),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
          job = (await database.downloadJob(episodeId))!;
          response = await _send(job, offset, active.client);
        }
      }

      if (response.statusCode == 416) {
        final serverLength = _unsatisfiedLength(
          response.headers['content-range'],
        );
        await response.stream.drain<void>();
        if (offset > 0 && serverLength == offset) {
          await _complete(job, offset);
          return;
        }
        await files.delete(job.partialPath);
        offset = 0;
        response = await _send(job, 0, active.client);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        await response.stream.drain<void>();
        final message = response.statusCode == 401 || response.statusCode == 403
            ? 'The media URL expired. Refresh the podcast and retry.'
            : 'Download failed with HTTP ${response.statusCode}.';
        throw DownloadException(message);
      }

      var append = offset > 0 && response.statusCode == 206;
      if (append && _rangeStart(response.headers['content-range']) != offset) {
        await response.stream.drain<void>();
        await files.delete(job.partialPath);
        offset = 0;
        response = await _send(job, 0, active.client);
        append = false;
      } else if (offset > 0 && response.statusCode == 200) {
        await files.delete(job.partialPath);
        offset = 0;
        append = false;
      }

      final contentLength = response.contentLength;
      final rangeTotal = _rangeTotal(response.headers['content-range']);
      final totalBytes = response.statusCode == 206
          ? rangeTotal ??
                (contentLength == null ? null : offset + contentLength)
          : contentLength;
      await _ensureStorage(
        totalBytes == null ? null : totalBytes - offset,
        active.storageFloorBytes,
      );
      await database.updateDownloadJob(
        episodeId,
        DownloadJobRowsCompanion(
          bytesDownloaded: Value(offset),
          totalBytes: Value(totalBytes),
          etag: Value(response.headers['etag'] ?? job.etag),
          lastModified: Value(
            response.headers['last-modified'] ?? job.lastModified,
          ),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

      sink = await files.open(job.partialPath, append: append);
      var downloaded = offset;
      var lastPersisted = offset;
      var lastPersistedAt = DateTime.now();
      await for (final chunk in response.stream) {
        if (active.command != _DownloadCommand.none) break;
        final bytes = Uint8List.fromList(chunk);
        sink.add(bytes);
        downloaded += bytes.length;
        final now = DateTime.now();
        if (downloaded - lastPersisted >= 256 * 1024 ||
            now.difference(lastPersistedAt) >=
                const Duration(milliseconds: 400)) {
          await database.updateDownloadJob(
            episodeId,
            DownloadJobRowsCompanion(
              bytesDownloaded: Value(downloaded),
              updatedAt: Value(now.toUtc()),
            ),
          );
          lastPersisted = downloaded;
          lastPersistedAt = now;
        }
      }
      await sink.flush();
      await sink.close();
      sink = null;

      if (active.command == _DownloadCommand.pause ||
          active.command == _DownloadCommand.cancel) {
        return;
      }
      if (totalBytes != null && downloaded != totalBytes) {
        throw const DownloadException(
          'The server ended the download before the media file was complete.',
        );
      }
      await _complete(job, downloaded, totalBytes: totalBytes);
    } catch (error) {
      if (active.command == _DownloadCommand.none &&
          await database.downloadJob(episodeId) != null) {
        final message = _storageError(error)
            ? const LowStorageException().message
            : error is DownloadException
            ? error.message
            : 'Download failed. Check your connection and retry.';
        final partial = await database.downloadJob(episodeId);
        final length =
            partial != null && await files.exists(partial.partialPath)
            ? await files.length(partial.partialPath)
            : 0;
        final attempts = partial?.automatic == true
            ? (partial?.attempts ?? 0) + 1
            : (partial?.attempts ?? 0);
        final nextAttemptAt = partial?.automatic == true
            ? _now().toUtc().add(_retryDelay(attempts))
            : null;
        await database.updateDownloadJob(
          episodeId,
          DownloadJobRowsCompanion(
            state: Value(DownloadState.failed.name),
            bytesDownloaded: Value(length),
            error: Value(message),
            attempts: Value(attempts),
            nextAttemptAt: Value(nextAttemptAt),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
        if (nextAttemptAt != null) _schedulePolicyAt(nextAttemptAt);
      }
    } finally {
      try {
        await sink?.close();
      } catch (_) {}
      active.client.close();
      if (identical(_active[episodeId], active)) _active.remove(episodeId);
      if (!_disposed) notifyListeners();
    }
  }

  Future<http.StreamedResponse> _send(
    DownloadJobRecord job,
    int offset,
    http.Client client,
  ) {
    final uri = Uri.tryParse(job.sourceUrl);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const DownloadException('The episode media URL is invalid.');
    }
    final request = http.Request('GET', uri)
      ..followRedirects = true
      ..maxRedirects = 8;
    if (offset > 0) {
      request.headers['Range'] = 'bytes=$offset-';
      final validator = job.etag ?? job.lastModified;
      if (validator != null && validator.isNotEmpty) {
        request.headers['If-Range'] = validator;
      }
    }
    return client.send(request);
  }

  Future<void> _complete(
    DownloadJobRecord job,
    int bytes, {
    int? totalBytes,
  }) async {
    if (!await files.exists(job.partialPath) || bytes <= 0) {
      throw const DownloadException('The downloaded media file was empty.');
    }
    final actualLength = await files.length(job.partialPath);
    final expected = totalBytes ?? job.totalBytes;
    if (actualLength != bytes ||
        (expected != null && actualLength != expected)) {
      throw const DownloadException(
        'The downloaded media file was incomplete.',
      );
    }
    await files.move(job.partialPath, job.filePath);
    await database.updateDownloadJob(
      job.episodeId,
      DownloadJobRowsCompanion(
        state: Value(DownloadState.completed.name),
        bytesDownloaded: Value(actualLength),
        totalBytes: Value(expected ?? actualLength),
        error: const Value(null),
        attempts: const Value(0),
        nextAttemptAt: const Value(null),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    final episode = await database.episodeById(job.episodeId);
    if (episode != null) await _setDownloaded(episode, true);
  }

  Future<void> _setDownloaded(EpisodeRecord episode, bool value) async {
    await database.setDownloaded(episode.id, value);
    final callback = onDownloadedChanged;
    if (callback != null) unawaited(callback(episode, value));
  }

  Future<void> _ensureStorage(int? remainingBytes, int floorBytes) async {
    final available = await storage.availableBytes();
    if (available == null) return;
    final required = floorBytes + (remainingBytes ?? 0);
    if (available < required) throw const LowStorageException();
  }

  Future<void> evaluateRules() async {
    if (_disposed) return;
    _evaluationRequested = true;
    final current = _evaluationInFlight;
    if (current != null) return current;
    final operation = _drainRuleEvaluations();
    _evaluationInFlight = operation;
    try {
      await operation;
    } finally {
      if (identical(_evaluationInFlight, operation)) {
        _evaluationInFlight = null;
      }
    }
  }

  Future<void> _drainRuleEvaluations() async {
    do {
      _evaluationRequested = false;
      await _evaluateRules();
    } while (_evaluationRequested && !_disposed);
  }

  Future<void> _evaluateRules() async {
    _policyTimer?.cancel();
    _policyTimer = null;
    _policyDeadline = null;
    final global =
        (await database.downloadPreferences())?.settings ??
        const DownloadRuleSettings();
    final overrides = await database.podcastDownloadOverrides();
    final episodes = await database.allEpisodes();
    final jobs = {
      for (final job in await database.downloadJobs()) job.episodeId: job,
    };
    final now = _now().toUtc();

    await _applyRetention(episodes, jobs, global, overrides, now);

    final connections = await network.current();
    final hasNetwork = connections.any(
      (result) => result != ConnectivityResult.none,
    );
    if (!hasNetwork) return;
    final hasUnmetered =
        connections.contains(ConnectivityResult.wifi) ||
        connections.contains(ConnectivityResult.ethernet);
    bool? isCharging;
    final podcastIds =
        episodes.map((episode) => episode.podcastId).toSet().toList()..sort();
    for (final podcastId in podcastIds) {
      final settings = overrides[podcastId]?.settings ?? global;
      if (!settings.automatic || (settings.wifiOnly && !hasUnmetered)) continue;
      if (settings.chargingOnly) {
        isCharging ??= await charging.isCharging();
        if (isCharging != true) continue;
      }
      final candidates =
          episodes
              .where(
                (episode) =>
                    episode.podcastId == podcastId &&
                    !episode.completed &&
                    episode.audioUrl.trim().isNotEmpty,
              )
              .toList()
            ..sort((left, right) {
              final published = right.publishedAt.compareTo(left.publishedAt);
              return published != 0 ? published : right.id.compareTo(left.id);
            });
      final selected = candidates.take(settings.episodeLimit).toList();
      for (final episode in candidates.skip(settings.episodeLimit)) {
        final job = jobs[episode.id];
        if (job?.automatic == true && !_active.containsKey(episode.id)) {
          await delete(episode.id);
        }
      }
      for (final episode in selected) {
        final job = jobs[episode.id];
        if (job?.downloadState == DownloadState.completed ||
            _active.containsKey(episode.id)) {
          continue;
        }
        if (job?.downloadState == DownloadState.failed &&
            job?.nextAttemptAt != null &&
            job!.nextAttemptAt!.isAfter(now)) {
          _schedulePolicyAt(job.nextAttemptAt!);
          continue;
        }
        await start(
          episode,
          allowCellular: true,
          automatic: true,
          storageFloorBytes: settings.storageFloorBytes,
        );
      }
    }
  }

  Future<void> _applyRetention(
    List<EpisodeRecord> episodes,
    Map<int, DownloadJobRecord> jobs,
    DownloadRuleSettings global,
    Map<int, PodcastDownloadOverrideRecord> overrides,
    DateTime now,
  ) async {
    final episodeById = {for (final episode in episodes) episode.id: episode};
    for (final job in jobs.values) {
      if (job.downloadState != DownloadState.completed) continue;
      final episode = episodeById[job.episodeId];
      if (episode == null) continue;
      if (!episode.completed) {
        if (job.playedAt != null) {
          await database.updateDownloadJob(
            job.episodeId,
            const DownloadJobRowsCompanion(playedAt: Value(null)),
          );
        }
        continue;
      }
      final settings = overrides[episode.podcastId]?.settings ?? global;
      switch (settings.retention) {
        case PlayedDownloadRetention.never:
          continue;
        case PlayedDownloadRetention.immediate:
          await delete(episode.id);
        case PlayedDownloadRetention.delayed:
          final playedAt = job.playedAt?.toUtc() ?? now;
          if (job.playedAt == null) {
            await database.updateDownloadJob(
              job.episodeId,
              DownloadJobRowsCompanion(playedAt: Value(playedAt)),
            );
          }
          final deleteAt = playedAt.add(
            Duration(hours: settings.retentionDelayHours),
          );
          if (!deleteAt.isAfter(now)) {
            await delete(episode.id);
          } else {
            _schedulePolicyAt(deleteAt);
          }
      }
    }
  }

  void _schedulePolicyAt(DateTime at) {
    if (_disposed) return;
    final delay = at.difference(_now().toUtc());
    final bounded = delay.isNegative ? Duration.zero : delay;
    final existing = _policyTimer;
    if (existing != null &&
        existing.isActive &&
        _policyDeadline != null &&
        !_policyDeadline!.isAfter(at)) {
      return;
    }
    existing?.cancel();
    _policyDeadline = at;
    _policyTimer = Timer(bounded, () {
      _policyTimer = null;
      _policyDeadline = null;
      unawaited(evaluateRules());
    });
  }

  static Duration _retryDelay(int attempts) {
    final exponent = attempts.clamp(1, 7) - 1;
    return Duration(minutes: 1 << exponent);
  }

  Future<void> _deleteFiles(DownloadJobRecord job) async {
    await files.delete(job.partialPath);
    await files.delete(job.filePath);
  }

  static int? _rangeStart(String? contentRange) {
    final match = RegExp(r'^bytes (\d+)-\d+/').firstMatch(contentRange ?? '');
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static int? _unsatisfiedLength(String? contentRange) {
    final match = RegExp(r'^bytes \*/(\d+)$').firstMatch(contentRange ?? '');
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static int? _rangeTotal(String? contentRange) {
    final match = RegExp(
      r'^bytes \d+-\d+/(\d+)$',
    ).firstMatch(contentRange ?? '');
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static String _fileExtension(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final match = RegExp(r'\.[A-Za-z0-9]{1,5}$').firstMatch(path);
    return match?.group(0)?.toLowerCase() ?? '.media';
  }

  static bool _storageError(Object error) {
    final text = '$error'.toLowerCase();
    return text.contains('no space left') ||
        text.contains('disk full') ||
        text.contains('enospc');
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_episodeSubscription?.cancel());
    _policyTimer?.cancel();
    _policyDeadline = null;
    for (final active in _active.values) {
      active.command = _DownloadCommand.pause;
      active.client.close();
    }
    _active.clear();
    super.dispose();
  }
}

enum _DownloadCommand { none, pause, cancel }

class _ActiveDownload {
  _ActiveDownload(this.client, this.storageFloorBytes);

  final http.Client client;
  final int storageFloorBytes;
  _DownloadCommand command = _DownloadCommand.none;
}
