import 'package:drift/drift.dart';

import '../database/app_database.dart';

enum PlayedDownloadRetention {
  never,
  immediate,
  delayed;

  static PlayedDownloadRetention parse(String value) => values.firstWhere(
    (retention) => retention.name == value,
    orElse: () => PlayedDownloadRetention.never,
  );
}

class DownloadRuleSettings {
  const DownloadRuleSettings({
    this.automatic = false,
    this.episodeLimit = 3,
    this.wifiOnly = true,
    this.chargingOnly = false,
    this.storageFloorBytes = 500 * 1024 * 1024,
    this.retention = PlayedDownloadRetention.never,
    this.retentionDelayHours = 24,
  });

  final bool automatic;
  final int episodeLimit;
  final bool wifiOnly;
  final bool chargingOnly;
  final int storageFloorBytes;
  final PlayedDownloadRetention retention;
  final int retentionDelayHours;

  DownloadRuleSettings copyWith({
    bool? automatic,
    int? episodeLimit,
    bool? wifiOnly,
    bool? chargingOnly,
    int? storageFloorBytes,
    PlayedDownloadRetention? retention,
    int? retentionDelayHours,
  }) => DownloadRuleSettings(
    automatic: automatic ?? this.automatic,
    episodeLimit: episodeLimit ?? this.episodeLimit,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    chargingOnly: chargingOnly ?? this.chargingOnly,
    storageFloorBytes: storageFloorBytes ?? this.storageFloorBytes,
    retention: retention ?? this.retention,
    retentionDelayHours: retentionDelayHours ?? this.retentionDelayHours,
  );

  DownloadPreferenceRowsCompanion toGlobalCompanion() =>
      DownloadPreferenceRowsCompanion.insert(
        id: const Value(0),
        automatic: Value(automatic),
        episodeLimit: Value(episodeLimit.clamp(1, 100)),
        wifiOnly: Value(wifiOnly),
        chargingOnly: Value(chargingOnly),
        storageFloorBytes: Value(
          storageFloorBytes.clamp(0, 1024 * 1024 * 1024 * 1024),
        ),
        retention: Value(retention.name),
        retentionDelayHours: Value(retentionDelayHours.clamp(1, 24 * 365)),
      );

  PodcastDownloadOverrideRowsCompanion toPodcastCompanion(int podcastId) =>
      PodcastDownloadOverrideRowsCompanion.insert(
        podcastId: Value(podcastId),
        automatic: automatic,
        episodeLimit: episodeLimit.clamp(1, 100),
        wifiOnly: wifiOnly,
        chargingOnly: chargingOnly,
        storageFloorBytes: storageFloorBytes.clamp(
          0,
          1024 * 1024 * 1024 * 1024,
        ),
        retention: retention.name,
        retentionDelayHours: retentionDelayHours.clamp(1, 24 * 365),
      );
}

extension DownloadPreferenceSettings on DownloadPreferenceRecord {
  DownloadRuleSettings get settings => DownloadRuleSettings(
    automatic: automatic,
    episodeLimit: episodeLimit,
    wifiOnly: wifiOnly,
    chargingOnly: chargingOnly,
    storageFloorBytes: storageFloorBytes,
    retention: PlayedDownloadRetention.parse(retention),
    retentionDelayHours: retentionDelayHours,
  );
}

extension PodcastDownloadOverrideSettings on PodcastDownloadOverrideRecord {
  DownloadRuleSettings get settings => DownloadRuleSettings(
    automatic: automatic,
    episodeLimit: episodeLimit,
    wifiOnly: wifiOnly,
    chargingOnly: chargingOnly,
    storageFloorBytes: storageFloorBytes,
    retention: PlayedDownloadRetention.parse(retention),
    retentionDelayHours: retentionDelayHours,
  );
}

enum DownloadState {
  queued,
  downloading,
  paused,
  completed,
  failed;

  static DownloadState parse(String value) => values.firstWhere(
    (state) => state.name == value,
    orElse: () => DownloadState.failed,
  );
}

extension DownloadJobRecordState on DownloadJobRecord {
  DownloadState get downloadState => DownloadState.parse(state);

  double? get progress => totalBytes == null || totalBytes! <= 0
      ? null
      : (bytesDownloaded / totalBytes!).clamp(0, 1);
}

class DownloadException implements Exception {
  const DownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LowStorageException extends DownloadException {
  const LowStorageException()
    : super('Not enough free storage to download this episode.');
}

class CellularDownloadConfirmationRequired extends DownloadException {
  const CellularDownloadConfirmationRequired()
    : super('Confirm this download to use your cellular connection.');
}

class DownloadStorageItem {
  const DownloadStorageItem({required this.episode, required this.job});

  final EpisodeRecord episode;
  final DownloadJobRecord job;

  int get sizeBytes => job.totalBytes ?? job.bytesDownloaded;
  DateTime get downloadedAt => job.updatedAt;
}

class PodcastStorageUsage {
  const PodcastStorageUsage({
    required this.podcastId,
    required this.title,
    required this.episodeCount,
    required this.sizeBytes,
  });

  final int podcastId;
  final String title;
  final int episodeCount;
  final int sizeBytes;
}

class DownloadStorageSnapshot {
  const DownloadStorageSnapshot({
    required this.items,
    required this.podcasts,
    required this.totalBytes,
    required this.storageFloorBytes,
    this.availableBytes,
  });

  final List<DownloadStorageItem> items;
  final List<PodcastStorageUsage> podcasts;
  final int totalBytes;
  final int? availableBytes;
  final int storageFloorBytes;

  bool get isLowStorage =>
      availableBytes != null && availableBytes! < storageFloorBytes;
}

class DownloadCleanupFilter {
  const DownloadCleanupFilter({
    this.podcastId,
    this.played,
    this.downloadedBefore,
  });

  final int? podcastId;
  final bool? played;
  final DateTime? downloadedBefore;

  bool matches(DownloadStorageItem item) {
    if (podcastId != null && item.episode.podcastId != podcastId) return false;
    if (played != null && item.episode.completed != played) return false;
    if (downloadedBefore != null &&
        !item.downloadedAt.isBefore(downloadedBefore!)) {
      return false;
    }
    return true;
  }
}

class DownloadCleanupResult {
  const DownloadCleanupResult({
    required this.deletedCount,
    required this.reclaimedBytes,
    required this.skippedUnsafeCount,
  });

  final int deletedCount;
  final int reclaimedBytes;
  final int skippedUnsafeCount;
}
