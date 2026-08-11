import 'dart:async';
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
    DownloadClientFactory? clientFactory,
    this.onDownloadedChanged,
    this.storageReserveBytes = 100 * 1024 * 1024,
  }) : files = files ?? const DeviceDownloadFileStore(),
       storage = storage ?? const DeviceStorageSpaceProbe(),
       _clientFactory = clientFactory ?? http.Client.new;

  final AppDatabase database;
  final DownloadFileStore files;
  final StorageSpaceProbe storage;
  final DownloadClientFactory _clientFactory;
  final Future<void> Function(EpisodeRecord episode, bool downloaded)?
  onDownloadedChanged;
  final int storageReserveBytes;
  final Map<int, _ActiveDownload> _active = <int, _ActiveDownload>{};

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
  }

  Future<void> start(EpisodeRecord episode) async {
    if (_disposed || _active.containsKey(episode.id)) return;
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
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }
    await database.setDownloaded(episode.id, false);

    final active = _ActiveDownload(_clientFactory());
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
      await _ensureStorage(totalBytes == null ? null : totalBytes - offset);
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
        await database.updateDownloadJob(
          episodeId,
          DownloadJobRowsCompanion(
            state: Value(DownloadState.failed.name),
            bytesDownloaded: Value(length),
            error: Value(message),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
        );
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

  Future<void> _ensureStorage(int? remainingBytes) async {
    final available = await storage.availableBytes();
    if (available == null) return;
    final required = storageReserveBytes + (remainingBytes ?? 0);
    if (available < required) throw const LowStorageException();
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
  _ActiveDownload(this.client);

  final http.Client client;
  _DownloadCommand command = _DownloadCommand.none;
}
