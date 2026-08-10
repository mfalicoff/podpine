import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'core/backend/pinepods_backend.dart';
import 'core/backend/podcast_backend.dart';
import 'core/database/app_database.dart';
import 'core/storage/credential_store.dart';
import 'core/sync/sync_engine.dart';

class AppController extends ChangeNotifier {
  AppController(this.database, this.credentials);

  final AppDatabase database;
  final CredentialStore credentials;

  bool initialized = false;
  bool connected = false;
  bool demoMode = false;
  bool busy = false;
  String? error;
  String? serverUrl;
  int? userId;
  DateTime? lastSyncedAt;
  PodcastBackend? backend;
  String? _apiKey;
  static const _uuid = Uuid();

  Future<void> initialize() async {
    try {
      final stored = await credentials.read();
      if (stored != null) {
        serverUrl = stored.serverUrl;
        userId = stored.userId;
        _apiKey = stored.apiKey;
        backend = PinepodsBackend(
          serverUrl: stored.serverUrl,
          apiKey: stored.apiKey,
        );
        connected = true;
        await _resolveUserIdentity();
        await refresh(silent: true);
      }
    } catch (_) {
      // Cached content remains available even when secure storage or the
      // self-hosted server is temporarily unavailable.
    } finally {
      initialized = true;
      notifyListeners();
    }
  }

  Future<void> connect(String rawServerUrl, String apiKey) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final normalized = _normalizeUrl(rawServerUrl);
      final candidate = PinepodsBackend(
        serverUrl: normalized,
        apiKey: apiKey.trim(),
      );
      final verifiedUserId = await candidate.verifyConnection();
      await credentials.write(
        StoredSession(
          serverUrl: normalized,
          apiKey: apiKey.trim(),
          userId: verifiedUserId,
        ),
      );
      backend = candidate;
      _apiKey = apiKey.trim();
      serverUrl = normalized;
      userId = verifiedUserId;
      connected = true;
      demoMode = false;
      await refresh(silent: true);
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> enterDemo() async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await database.seedDemo();
      demoMode = true;
      connected = true;
      serverUrl = 'Demo library';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refresh({bool silent = false}) async {
    if (backend == null || userId == null) return;
    if (!silent) {
      busy = true;
      error = null;
      notifyListeners();
    }
    try {
      await SyncEngine(database, backend!, userId!).refresh();
      lastSyncedAt = DateTime.now();
    } catch (exception) {
      if (exception is PinepodsException && exception.statusCode == 403) {
        try {
          await _resolveUserIdentity();
          await SyncEngine(database, backend!, userId!).refresh();
          lastSyncedAt = DateTime.now();
          error = null;
          return;
        } catch (_) {
          // Fall through to the cached-library state below.
        }
      }
      error = 'Offline — showing saved library';
      if (!silent) rethrow;
    } finally {
      if (!silent) busy = false;
      notifyListeners();
    }
  }

  Future<void> setCompleted(EpisodeRecord episode, bool completed) async {
    await database.setCompleted(episode.id, completed);
    if (backend != null && userId != null && episode.id > 0) {
      try {
        await backend!.markCompleted(userId!, episode.id, completed);
      } catch (_) {
        await _enqueueMutation('completed', episode.id, {'value': completed});
        error =
            'Saved offline. The change will sync when the server is available.';
        notifyListeners();
      }
    }
  }

  Future<void> recordPosition(EpisodeRecord episode, Duration position) async {
    await database.setPosition(episode.id, position);
    if (backend != null && userId != null && episode.id > 0) {
      try {
        await backend!.updatePlayback(userId!, episode.id, position);
      } catch (_) {
        await _enqueueMutation('position', episode.id, {
          'seconds': position.inSeconds,
        });
      }
    }
  }

  Future<String> loadChapters(EpisodeRecord episode) async {
    if (episode.chaptersJson != '[]' ||
        backend == null ||
        userId == null ||
        episode.id <= 0) {
      return episode.chaptersJson;
    }
    try {
      final chapters = await backend!.getChapters(userId!, episode.id);
      if (chapters != '[]') {
        await database.setEpisodeChapters(episode.id, chapters);
      }
      return chapters;
    } catch (_) {
      return episode.chaptersJson;
    }
  }

  Future<void> addToQueue(EpisodeRecord episode, {bool next = false}) async {
    await database.addToQueue(episode.id, next: next);
    if (backend != null && userId != null && episode.id > 0) {
      try {
        await backend!.addToQueue(userId!, episode.id);
      } catch (_) {
        await _enqueueMutation('queue_add', episode.id, const {});
        error = 'Queue changed offline.';
        notifyListeners();
      }
    }
  }

  Future<void> removeFromQueue(EpisodeRecord episode) async {
    await database.removeFromQueue(episode.id);
    if (backend != null && userId != null && episode.id > 0) {
      try {
        await backend!.removeFromQueue(userId!, episode.id);
      } catch (_) {
        await _enqueueMutation('queue_remove', episode.id, const {});
        error = 'Queue changed offline.';
        notifyListeners();
      }
    }
  }

  Future<void> disconnect() async {
    await credentials.clear();
    await database.clearAll();
    connected = false;
    demoMode = false;
    serverUrl = null;
    userId = null;
    backend = null;
    _apiKey = null;
    lastSyncedAt = null;
    notifyListeners();
  }

  Future<void> _resolveUserIdentity() async {
    final currentBackend = backend;
    if (currentBackend == null) return;
    final resolvedUserId = await currentBackend.verifyConnection();
    if (resolvedUserId == userId) return;
    userId = resolvedUserId;
    if (serverUrl != null && _apiKey != null) {
      await credentials.write(
        StoredSession(
          serverUrl: serverUrl!,
          apiKey: _apiKey!,
          userId: resolvedUserId,
        ),
      );
    }
  }

  Future<void> _enqueueMutation(
    String type,
    int episodeId,
    Map<String, Object?> payload,
  ) => database.enqueueMutation(
    SyncMutationsCompanion.insert(
      id: _uuid.v4(),
      type: type,
      episodeId: Value(episodeId),
      payload: Value(jsonEncode(payload)),
      createdAt: DateTime.now().toUtc(),
    ),
  );

  static String _normalizeUrl(String input) {
    var value = input.trim();
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority) {
      throw const PinepodsException('Enter a valid Pinepods server URL.');
    }
    return value.replaceFirst(RegExp(r'/+$'), '');
  }
}
