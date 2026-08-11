import 'dart:convert';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../backend/pinepods_backend.dart';
import '../backend/podcast_backend.dart';
import '../database/app_database.dart';
import '../storage/credential_store.dart';
import 'sync_engine.dart';

const backgroundSyncIdentifier = 'app.podpine.podpine.backgroundRefresh';
const backgroundSyncTaskName = 'podpineBackgroundRefresh';
const backgroundSyncFrequency = Duration(hours: 6);
const backgroundSyncInitialDelay = Duration(minutes: 15);

bool get backgroundSyncSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

String get backgroundSyncScheduler => switch (defaultTargetPlatform) {
  TargetPlatform.android => 'Android WorkManager',
  TargetPlatform.iOS => 'iOS BGAppRefreshTask',
  _ => 'Unavailable on this platform',
};

String get backgroundSyncPolicy => switch (defaultTargetPlatform) {
  TargetPlatform.android =>
    'Opportunistic every 6 hours; connected network, battery not low, and '
        'storage not low.',
  TargetPlatform.iOS =>
    'System-managed timing; connected network requested and iOS controls '
        'execution based on usage, power, and its short refresh budget.',
  _ => 'Background execution is not scheduled on this platform.',
};

Future<void> initializeBackgroundSync() async {
  final diagnostics = BackgroundSyncDiagnostics();
  if (!backgroundSyncSupported) {
    await _recordDiagnostics(
      () => diagnostics.recordScheduling(
        scheduler: backgroundSyncScheduler,
        policy: backgroundSyncPolicy,
        scheduled: false,
        detail: 'Background refresh is unavailable on this platform.',
      ),
    );
    return;
  }

  try {
    await Workmanager().initialize(backgroundSyncCallbackDispatcher);
    await Workmanager().registerPeriodicTask(
      backgroundSyncIdentifier,
      backgroundSyncTaskName,
      frequency: backgroundSyncFrequency,
      initialDelay: backgroundSyncInitialDelay,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresStorageNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
      tag: backgroundSyncTaskName,
    );
    await _recordDiagnostics(
      () => diagnostics.recordScheduling(
        scheduler: backgroundSyncScheduler,
        policy: backgroundSyncPolicy,
        scheduled: true,
        detail: 'The OS accepted the opportunistic refresh request.',
      ),
    );
  } catch (error) {
    await _recordDiagnostics(
      () => diagnostics.recordScheduling(
        scheduler: backgroundSyncScheduler,
        policy: backgroundSyncPolicy,
        scheduled: false,
        detail: 'Scheduling failed: ${_shortError(error)}',
      ),
    );
  }
}

@pragma('vm:entry-point')
void backgroundSyncCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    if (taskName != backgroundSyncTaskName &&
        taskName != backgroundSyncIdentifier &&
        taskName != Workmanager.iOSBackgroundTask) {
      return true;
    }
    return runBackgroundSync(taskName: taskName);
  });
}

@visibleForTesting
Future<bool> runBackgroundSync({
  required String taskName,
  Future<List<ConnectivityResult>> Function()? checkConnectivity,
  Future<StoredSession?> Function()? readSession,
  AppDatabase Function()? openDatabase,
  PodcastBackend Function(StoredSession session)? createBackend,
  BackgroundSyncDiagnosticSink? diagnostics,
}) async {
  final status = diagnostics ?? BackgroundSyncDiagnostics();
  final startedAt = DateTime.now().toUtc();
  await _recordDiagnostics(
    () => status.recordStarted(taskName: taskName, startedAt: startedAt),
  );

  AppDatabase? database;
  try {
    final connectivity =
        await (checkConnectivity ?? () => Connectivity().checkConnectivity())();
    if (connectivity.isEmpty ||
        connectivity.every((result) => result == ConnectivityResult.none)) {
      await _recordDiagnostics(
        () => status.recordFinished(
          outcome: BackgroundSyncOutcome.skippedOffline,
          detail: 'No connected network was available.',
          startedAt: startedAt,
        ),
      );
      return true;
    }

    final session =
        await (readSession ??
            () => const CredentialStore(FlutterSecureStorage()).read())();
    if (session == null) {
      await _recordDiagnostics(
        () => status.recordFinished(
          outcome: BackgroundSyncOutcome.skippedNoSession,
          detail: 'No connected Pinepods session was available.',
          startedAt: startedAt,
        ),
      );
      return true;
    }

    database = (openDatabase ?? AppDatabase.new)();
    final pendingBefore = (await database.pendingMutations()).length;
    final backend =
        (createBackend ??
        (stored) => PinepodsBackend(
          serverUrl: stored.serverUrl,
          apiKey: stored.apiKey,
        ))(session);

    await SyncEngine(database, backend, session.userId).refresh();
    final pendingAfter = (await database.pendingMutations()).length;
    await _recordDiagnostics(
      () => status.recordFinished(
        outcome: BackgroundSyncOutcome.succeeded,
        detail:
            'Subscriptions, episodes, queue, and mutation outbox refreshed.',
        startedAt: startedAt,
        pendingBefore: pendingBefore,
        pendingAfter: pendingAfter,
      ),
    );
    return true;
  } catch (error) {
    await _recordDiagnostics(
      () => status.recordFinished(
        outcome: BackgroundSyncOutcome.failed,
        detail: _shortError(error),
        startedAt: startedAt,
      ),
    );
    return false;
  } finally {
    await database?.close();
  }
}

enum BackgroundSyncOutcome {
  neverRun,
  running,
  succeeded,
  skippedOffline,
  skippedNoSession,
  failed,
}

@immutable
class BackgroundSyncSnapshot {
  const BackgroundSyncSnapshot({
    this.scheduler = 'Not initialized',
    this.policy = 'Not initialized',
    this.scheduled = false,
    this.schedulingDetail = 'The scheduler has not been initialized yet.',
    this.scheduledAt,
    this.lastTaskName,
    this.lastStartedAt,
    this.lastCompletedAt,
    this.outcome = BackgroundSyncOutcome.neverRun,
    this.detail = 'No background refresh has run yet.',
    this.pendingBefore,
    this.pendingAfter,
    this.durationMilliseconds,
  });

  final String scheduler;
  final String policy;
  final bool scheduled;
  final String schedulingDetail;
  final DateTime? scheduledAt;
  final String? lastTaskName;
  final DateTime? lastStartedAt;
  final DateTime? lastCompletedAt;
  final BackgroundSyncOutcome outcome;
  final String detail;
  final int? pendingBefore;
  final int? pendingAfter;
  final int? durationMilliseconds;

  BackgroundSyncSnapshot copyWith({
    String? scheduler,
    String? policy,
    bool? scheduled,
    String? schedulingDetail,
    DateTime? scheduledAt,
    String? lastTaskName,
    DateTime? lastStartedAt,
    DateTime? lastCompletedAt,
    BackgroundSyncOutcome? outcome,
    String? detail,
    int? pendingBefore,
    int? pendingAfter,
    int? durationMilliseconds,
    bool clearPendingCounts = false,
  }) => BackgroundSyncSnapshot(
    scheduler: scheduler ?? this.scheduler,
    policy: policy ?? this.policy,
    scheduled: scheduled ?? this.scheduled,
    schedulingDetail: schedulingDetail ?? this.schedulingDetail,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    lastTaskName: lastTaskName ?? this.lastTaskName,
    lastStartedAt: lastStartedAt ?? this.lastStartedAt,
    lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    outcome: outcome ?? this.outcome,
    detail: detail ?? this.detail,
    pendingBefore: clearPendingCounts
        ? null
        : pendingBefore ?? this.pendingBefore,
    pendingAfter: clearPendingCounts ? null : pendingAfter ?? this.pendingAfter,
    durationMilliseconds: durationMilliseconds ?? this.durationMilliseconds,
  );

  Map<String, Object?> toJson() => {
    'scheduler': scheduler,
    'policy': policy,
    'scheduled': scheduled,
    'schedulingDetail': schedulingDetail,
    'scheduledAt': scheduledAt?.toIso8601String(),
    'lastTaskName': lastTaskName,
    'lastStartedAt': lastStartedAt?.toIso8601String(),
    'lastCompletedAt': lastCompletedAt?.toIso8601String(),
    'outcome': outcome.name,
    'detail': detail,
    'pendingBefore': pendingBefore,
    'pendingAfter': pendingAfter,
    'durationMilliseconds': durationMilliseconds,
  };

  factory BackgroundSyncSnapshot.fromJson(Map<String, Object?> json) {
    final outcomeName = json['outcome'] as String?;
    return BackgroundSyncSnapshot(
      scheduler: json['scheduler'] as String? ?? 'Not initialized',
      policy: json['policy'] as String? ?? 'Not initialized',
      scheduled: json['scheduled'] as bool? ?? false,
      schedulingDetail:
          json['schedulingDetail'] as String? ??
          'Scheduling state unavailable.',
      scheduledAt: _date(json['scheduledAt']),
      lastTaskName: json['lastTaskName'] as String?,
      lastStartedAt: _date(json['lastStartedAt']),
      lastCompletedAt: _date(json['lastCompletedAt']),
      outcome: BackgroundSyncOutcome.values.firstWhere(
        (value) => value.name == outcomeName,
        orElse: () => BackgroundSyncOutcome.neverRun,
      ),
      detail: json['detail'] as String? ?? 'No run details are available.',
      pendingBefore: json['pendingBefore'] as int?,
      pendingAfter: json['pendingAfter'] as int?,
      durationMilliseconds: json['durationMilliseconds'] as int?,
    );
  }

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toUtc() : null;
}

abstract interface class BackgroundSyncDiagnosticSink {
  Future<void> recordStarted({
    required String taskName,
    required DateTime startedAt,
  });

  Future<void> recordFinished({
    required BackgroundSyncOutcome outcome,
    required String detail,
    required DateTime startedAt,
    int? pendingBefore,
    int? pendingAfter,
  });
}

class BackgroundSyncDiagnostics implements BackgroundSyncDiagnosticSink {
  BackgroundSyncDiagnostics([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'podpine.backgroundSync.diagnostics.v1';
  final SharedPreferencesAsync _preferences;

  Future<BackgroundSyncSnapshot> read() async {
    final encoded = await _preferences.getString(_key);
    if (encoded == null) return const BackgroundSyncSnapshot();
    try {
      return BackgroundSyncSnapshot.fromJson(
        (jsonDecode(encoded) as Map).cast<String, Object?>(),
      );
    } catch (_) {
      return const BackgroundSyncSnapshot(
        schedulingDetail: 'Stored diagnostics could not be decoded.',
      );
    }
  }

  Future<void> recordScheduling({
    required String scheduler,
    required String policy,
    required bool scheduled,
    required String detail,
  }) async {
    final current = await read();
    await _write(
      current.copyWith(
        scheduler: scheduler,
        policy: policy,
        scheduled: scheduled,
        schedulingDetail: detail,
        scheduledAt: DateTime.now().toUtc(),
      ),
    );
  }

  @override
  Future<void> recordStarted({
    required String taskName,
    required DateTime startedAt,
  }) async {
    final current = await read();
    await _write(
      current.copyWith(
        lastTaskName: taskName,
        lastStartedAt: startedAt,
        outcome: BackgroundSyncOutcome.running,
        detail: 'Background refresh is running.',
      ),
    );
  }

  @override
  Future<void> recordFinished({
    required BackgroundSyncOutcome outcome,
    required String detail,
    required DateTime startedAt,
    int? pendingBefore,
    int? pendingAfter,
  }) async {
    final completedAt = DateTime.now().toUtc();
    final current = await read();
    await _write(
      current.copyWith(
        lastCompletedAt: completedAt,
        outcome: outcome,
        detail: detail,
        pendingBefore: pendingBefore,
        pendingAfter: pendingAfter,
        clearPendingCounts: pendingBefore == null,
        durationMilliseconds: completedAt.difference(startedAt).inMilliseconds,
      ),
    );
  }

  Future<void> _write(BackgroundSyncSnapshot snapshot) =>
      _preferences.setString(_key, jsonEncode(snapshot.toJson()));
}

String _shortError(Object error) {
  final message = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  return message.length <= 240 ? message : '${message.substring(0, 237)}...';
}

Future<void> _recordDiagnostics(Future<void> Function() action) async {
  try {
    await action();
  } catch (_) {
    // Diagnostics are best effort and must never prevent the sync itself.
  }
}
