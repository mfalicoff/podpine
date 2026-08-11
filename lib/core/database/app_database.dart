import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/player/playback_options.dart';
import '../../features/inbox/inbox_models.dart';
import '../sync/queue_sync.dart';
import '../sync/playback_sync.dart';

part 'app_database.g.dart';

@DataClassName('PodcastRecord')
class PodcastRows extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get author => text().withDefault(const Constant(''))();
  TextColumn get artworkUrl => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get feedUrl => text().withDefault(const Constant(''))();
  IntColumn get episodeCount => integer().withDefault(const Constant(0))();
  TextColumn get websiteUrl => text().withDefault(const Constant(''))();
  TextColumn get categoriesJson => text().withDefault(const Constant('[]'))();
  BoolColumn get explicit => boolean().withDefault(const Constant(false))();
  IntColumn get podcastIndexId => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DiscoveryCacheRecord')
class DiscoveryCacheRows extends Table {
  TextColumn get feedUrl => text()();
  TextColumn get title => text()();
  TextColumn get podcastJson => text()();
  TextColumn get episodesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {feedUrl};
}

@DataClassName('EpisodeRecord')
class EpisodeRows extends Table {
  IntColumn get id => integer()();
  IntColumn get podcastId => integer().references(PodcastRows, #id)();
  TextColumn get podcastTitle => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get artworkUrl => text().withDefault(const Constant(''))();
  TextColumn get audioUrl => text().withDefault(const Constant(''))();
  DateTimeColumn get publishedAt => dateTime()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get positionSeconds => integer().withDefault(const Constant(0))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get queued => boolean().withDefault(const Constant(false))();
  BoolColumn get downloaded => boolean().withDefault(const Constant(false))();
  BoolColumn get isYoutube => boolean().withDefault(const Constant(false))();
  TextColumn get chaptersJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get playbackUpdatedAt => dateTime().nullable()();
  TextColumn get playbackDeviceId => text().nullable()();
  TextColumn get playbackIntent =>
      text().withDefault(const Constant('progress'))();
  TextColumn get playbackMediaIdentity =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DownloadJobRecord')
class DownloadJobRows extends Table {
  IntColumn get episodeId => integer().references(EpisodeRows, #id)();
  TextColumn get sourceUrl => text()();
  TextColumn get filePath => text()();
  TextColumn get partialPath => text()();
  TextColumn get state => text()();
  IntColumn get bytesDownloaded => integer().withDefault(const Constant(0))();
  IntColumn get totalBytes => integer().nullable()();
  TextColumn get etag => text().nullable()();
  TextColumn get lastModified => text().nullable()();
  TextColumn get error => text().nullable()();
  BoolColumn get automatic => boolean().withDefault(const Constant(false))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get playedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {episodeId};
}

@DataClassName('DownloadPreferenceRecord')
class DownloadPreferenceRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  BoolColumn get automatic => boolean().withDefault(const Constant(false))();
  IntColumn get episodeLimit => integer().withDefault(const Constant(3))();
  BoolColumn get wifiOnly => boolean().withDefault(const Constant(true))();
  BoolColumn get chargingOnly => boolean().withDefault(const Constant(false))();
  IntColumn get storageFloorBytes =>
      integer().withDefault(const Constant(500 * 1024 * 1024))();
  TextColumn get retention => text().withDefault(const Constant('never'))();
  IntColumn get retentionDelayHours =>
      integer().withDefault(const Constant(24))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PodcastDownloadOverrideRecord')
class PodcastDownloadOverrideRows extends Table {
  IntColumn get podcastId => integer().references(PodcastRows, #id)();
  BoolColumn get automatic => boolean()();
  IntColumn get episodeLimit => integer()();
  BoolColumn get wifiOnly => boolean()();
  BoolColumn get chargingOnly => boolean()();
  IntColumn get storageFloorBytes => integer()();
  TextColumn get retention => text()();
  IntColumn get retentionDelayHours => integer()();

  @override
  Set<Column<Object>> get primaryKey => {podcastId};
}

@DataClassName('QueueRecord')
class QueueRows extends Table {
  IntColumn get episodeId => integer().references(EpisodeRows, #id)();
  RealColumn get sortKey => real()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {episodeId};
}

@DataClassName('InboxRecord')
class InboxRows extends Table {
  IntColumn get episodeId => integer().references(EpisodeRows, #id)();
  DateTimeColumn get discoveredAt => dateTime()();
  DateTimeColumn get removedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {episodeId};
}

@DataClassName('InboxPreferencesRecord')
class InboxPreferenceRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get leftAction => text().withDefault(const Constant('remove'))();
  TextColumn get rightAction => text().withDefault(const Constant('queue'))();
  BoolColumn get markRemovedAsPlayed =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PodcastInboxOverrideRecord')
class PodcastInboxOverrideRows extends Table {
  IntColumn get podcastId => integer().references(PodcastRows, #id)();
  TextColumn get leftAction => text().nullable()();
  TextColumn get rightAction => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {podcastId};
}

@DataClassName('PendingMutation')
class SyncMutations extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get episodeId => integer().nullable()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get state => text().withDefault(const Constant('pending'))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get failedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('QueueSyncStateRecord')
class QueueSyncStateRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get revision => text()();
  TextColumn get orderJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SyncDeviceRecord')
class SyncDeviceRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PlaybackPreferencesRecord')
class PlaybackPreferenceRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  RealColumn get speed => real().withDefault(const Constant(1))();
  TextColumn get skipSilence => text().withDefault(const Constant('off'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PodcastPlaybackOverrideRecord')
class PodcastPlaybackOverrideRows extends Table {
  IntColumn get podcastId => integer().references(PodcastRows, #id)();
  RealColumn get speed => real().nullable()();
  TextColumn get skipSilence => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {podcastId};
}

@DriftDatabase(
  tables: [
    PodcastRows,
    DiscoveryCacheRows,
    EpisodeRows,
    DownloadJobRows,
    DownloadPreferenceRows,
    PodcastDownloadOverrideRows,
    QueueRows,
    InboxRows,
    InboxPreferenceRows,
    PodcastInboxOverrideRows,
    SyncMutations,
    QueueSyncStateRows,
    SyncDeviceRows,
    PlaybackPreferenceRows,
    PodcastPlaybackOverrideRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'podpine',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(episodeRows, episodeRows.chaptersJson);
        await migrator.createTable(playbackPreferenceRows);
        await migrator.createTable(podcastPlaybackOverrideRows);
      }
      if (from < 3) {
        await migrator.addColumn(podcastRows, podcastRows.websiteUrl);
        await migrator.addColumn(podcastRows, podcastRows.categoriesJson);
        await migrator.addColumn(podcastRows, podcastRows.explicit);
        await migrator.addColumn(podcastRows, podcastRows.podcastIndexId);
        await migrator.createTable(discoveryCacheRows);
      }
      if (from < 4) {
        await migrator.createTable(inboxRows);
        await migrator.createTable(inboxPreferenceRows);
        await migrator.createTable(podcastInboxOverrideRows);
        final now = DateTime.now().toUtc();
        final existingEpisodes = await select(episodeRows).get();
        await batch(
          (batch) => batch.insertAll(
            inboxRows,
            existingEpisodes
                .map(
                  (episode) => InboxRowsCompanion.insert(
                    episodeId: Value(episode.id),
                    discoveredAt: episode.updatedAt,
                    removedAt: Value(now),
                  ),
                )
                .toList(),
          ),
        );
      }
      if (from < 5) {
        await migrator.createTable(downloadJobRows);
      }
      if (from < 6) {
        await migrator.addColumn(syncMutations, syncMutations.state);
        await migrator.addColumn(syncMutations, syncMutations.nextAttemptAt);
        await migrator.addColumn(syncMutations, syncMutations.lastAttemptAt);
        await migrator.addColumn(syncMutations, syncMutations.lastError);
        await migrator.addColumn(syncMutations, syncMutations.failedAt);
      }
      if (from < 7) {
        await migrator.createTable(queueSyncStateRows);
      }
      if (from < 8) {
        await migrator.addColumn(episodeRows, episodeRows.playbackUpdatedAt);
        await migrator.addColumn(episodeRows, episodeRows.playbackDeviceId);
        await migrator.addColumn(episodeRows, episodeRows.playbackIntent);
        await migrator.addColumn(
          episodeRows,
          episodeRows.playbackMediaIdentity,
        );
        await migrator.createTable(syncDeviceRows);
      }
      if (from < 9) {
        await migrator.addColumn(
          inboxPreferenceRows,
          inboxPreferenceRows.markRemovedAsPlayed,
        );
      }
      if (from < 10) {
        await migrator.addColumn(downloadJobRows, downloadJobRows.automatic);
        await migrator.addColumn(downloadJobRows, downloadJobRows.attempts);
        await migrator.addColumn(
          downloadJobRows,
          downloadJobRows.nextAttemptAt,
        );
        await migrator.addColumn(downloadJobRows, downloadJobRows.playedAt);
        await migrator.createTable(downloadPreferenceRows);
        await migrator.createTable(podcastDownloadOverrideRows);
      }
    },
  );

  Stream<List<PodcastRecord>> watchPodcasts() => (select(
    podcastRows,
  )..orderBy([(p) => OrderingTerm.asc(p.title)])).watch();

  Stream<List<EpisodeRecord>> watchRecentEpisodes() =>
      (select(episodeRows)
            ..orderBy([(e) => OrderingTerm.desc(e.publishedAt)])
            ..limit(100))
          .watch();

  Stream<List<EpisodeRecord>> watchAllEpisodes() => (select(
    episodeRows,
  )..orderBy([(episode) => OrderingTerm.desc(episode.publishedAt)])).watch();

  Future<List<EpisodeRecord>> allEpisodes() => (select(
    episodeRows,
  )..orderBy([(episode) => OrderingTerm.desc(episode.publishedAt)])).get();

  Future<EpisodeRecord?> episodeById(int episodeId) => (select(
    episodeRows,
  )..where((row) => row.id.equals(episodeId))).getSingleOrNull();

  Stream<List<DownloadJobRecord>> watchDownloadJobs() => (select(
    downloadJobRows,
  )..orderBy([(job) => OrderingTerm.desc(job.updatedAt)])).watch();

  Future<List<DownloadJobRecord>> downloadJobs() =>
      select(downloadJobRows).get();

  Future<DownloadJobRecord?> downloadJob(int episodeId) => (select(
    downloadJobRows,
  )..where((job) => job.episodeId.equals(episodeId))).getSingleOrNull();

  Future<void> upsertDownloadJob(DownloadJobRowsCompanion job) =>
      into(downloadJobRows).insertOnConflictUpdate(job);

  Future<void> updateDownloadJob(int episodeId, DownloadJobRowsCompanion job) =>
      (update(
        downloadJobRows,
      )..where((row) => row.episodeId.equals(episodeId))).write(job);

  Future<void> deleteDownloadJob(int episodeId) => (delete(
    downloadJobRows,
  )..where((row) => row.episodeId.equals(episodeId))).go();

  Stream<DownloadPreferenceRecord?> watchDownloadPreferences() => (select(
    downloadPreferenceRows,
  )..where((row) => row.id.equals(0))).watchSingleOrNull();

  Future<DownloadPreferenceRecord?> downloadPreferences() => (select(
    downloadPreferenceRows,
  )..where((row) => row.id.equals(0))).getSingleOrNull();

  Future<void> setDownloadPreferences(DownloadPreferenceRowsCompanion value) =>
      into(downloadPreferenceRows).insertOnConflictUpdate(value);

  Stream<PodcastDownloadOverrideRecord?> watchPodcastDownloadOverride(
    int podcastId,
  ) => (select(
    podcastDownloadOverrideRows,
  )..where((row) => row.podcastId.equals(podcastId))).watchSingleOrNull();

  Future<PodcastDownloadOverrideRecord?> podcastDownloadOverride(
    int podcastId,
  ) => (select(
    podcastDownloadOverrideRows,
  )..where((row) => row.podcastId.equals(podcastId))).getSingleOrNull();

  Future<Map<int, PodcastDownloadOverrideRecord>>
  podcastDownloadOverrides() async {
    final rows = await select(podcastDownloadOverrideRows).get();
    return {for (final row in rows) row.podcastId: row};
  }

  Future<void> setPodcastDownloadOverride(
    PodcastDownloadOverrideRowsCompanion value,
  ) => into(podcastDownloadOverrideRows).insertOnConflictUpdate(value);

  Future<void> clearPodcastDownloadOverride(int podcastId) => (delete(
    podcastDownloadOverrideRows,
  )..where((row) => row.podcastId.equals(podcastId))).go();

  Future<Map<int, String>> completedDownloadPaths(
    Iterable<int> episodeIds,
  ) async {
    final ids = episodeIds.toSet();
    if (ids.isEmpty) return const <int, String>{};
    final rows =
        await (select(downloadJobRows)..where(
              (job) => job.episodeId.isIn(ids) & job.state.equals('completed'),
            ))
            .get();
    return {for (final row in rows) row.episodeId: row.filePath};
  }

  Stream<List<EpisodeRecord>> watchPodcastEpisodes(int podcastId) =>
      (select(episodeRows)
            ..where((episode) => episode.podcastId.equals(podcastId))
            ..orderBy([(episode) => OrderingTerm.desc(episode.publishedAt)]))
          .watch();

  Future<PodcastRecord?> podcastById(int podcastId) => (select(
    podcastRows,
  )..where((row) => row.id.equals(podcastId))).getSingleOrNull();

  Future<PodcastRecord?> podcastByFeedUrl(String feedUrl) => (select(
    podcastRows,
  )..where((row) => row.feedUrl.equals(feedUrl))).getSingleOrNull();

  Future<List<EpisodeRecord>> podcastEpisodes(int podcastId) =>
      (select(episodeRows)
            ..where((episode) => episode.podcastId.equals(podcastId))
            ..orderBy([(episode) => OrderingTerm.desc(episode.publishedAt)]))
          .get();

  Future<DiscoveryCacheRecord?> discoveryCache(String feedUrl) => (select(
    discoveryCacheRows,
  )..where((row) => row.feedUrl.equals(feedUrl))).getSingleOrNull();

  Future<List<DiscoveryCacheRecord>> searchDiscoveryCache(String query) {
    final pattern = '%${query.trim().toLowerCase()}%';
    return (select(discoveryCacheRows)
          ..where(
            (row) =>
                row.title.lower().like(pattern) |
                row.podcastJson.lower().like(pattern),
          )
          ..orderBy([(row) => OrderingTerm.desc(row.cachedAt)]))
        .get();
  }

  Future<void> cacheDiscovery({
    required String feedUrl,
    required String title,
    required String podcastJson,
    String? episodesJson,
  }) async {
    final existing = await discoveryCache(feedUrl);
    await into(discoveryCacheRows).insertOnConflictUpdate(
      DiscoveryCacheRowsCompanion.insert(
        feedUrl: feedUrl,
        title: title,
        podcastJson: podcastJson,
        episodesJson: Value(episodesJson ?? existing?.episodesJson ?? '[]'),
        cachedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> upsertPodcast(PodcastRowsCompanion podcast) =>
      into(podcastRows).insertOnConflictUpdate(podcast);

  Future<void> upsertEpisodes(Iterable<EpisodeRowsCompanion> episodes) async {
    final rows = episodes.toList(growable: false);
    if (rows.isEmpty) return;
    await batch((batch) => batch.insertAllOnConflictUpdate(episodeRows, rows));
  }

  Future<void> reconcilePodcastId({
    required int temporaryId,
    required PodcastRowsCompanion podcast,
  }) async {
    await transaction(() async {
      await into(podcastRows).insertOnConflictUpdate(podcast);
      if (temporaryId != podcast.id.value) {
        await (delete(
          podcastRows,
        )..where((row) => row.id.equals(temporaryId))).go();
      }
    });
  }

  Future<void> removePodcastByFeedUrl(String feedUrl) async {
    final podcasts = await (select(
      podcastRows,
    )..where((row) => row.feedUrl.equals(feedUrl))).get();
    for (final podcast in podcasts) {
      await removePodcastSafely(podcast.id);
    }
  }

  Future<void> removePodcastSafely(int podcastId) async {
    await transaction(() async {
      final episodeIds =
          await (selectOnly(episodeRows)
                ..addColumns([episodeRows.id])
                ..where(episodeRows.podcastId.equals(podcastId)))
              .map((row) => row.read(episodeRows.id)!)
              .get();
      if (episodeIds.isNotEmpty) {
        await (delete(
          downloadJobRows,
        )..where((row) => row.episodeId.isIn(episodeIds))).go();
        await (delete(
          queueRows,
        )..where((row) => row.episodeId.isIn(episodeIds))).go();
        await (delete(
          inboxRows,
        )..where((row) => row.episodeId.isIn(episodeIds))).go();
      }
      await (delete(
        podcastInboxOverrideRows,
      )..where((row) => row.podcastId.equals(podcastId))).go();
      await (delete(
        podcastPlaybackOverrideRows,
      )..where((row) => row.podcastId.equals(podcastId))).go();
      await (delete(
        podcastDownloadOverrideRows,
      )..where((row) => row.podcastId.equals(podcastId))).go();
      await (delete(
        episodeRows,
      )..where((row) => row.podcastId.equals(podcastId))).go();
      await (delete(
        podcastRows,
      )..where((row) => row.id.equals(podcastId))).go();
    });
  }

  Stream<List<EpisodeRecord>> watchQueue() {
    final query = select(episodeRows).join([
      innerJoin(queueRows, queueRows.episodeId.equalsExp(episodeRows.id)),
    ])..orderBy([OrderingTerm.asc(queueRows.sortKey)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(episodeRows)).toList(),
    );
  }

  Stream<List<EpisodeRecord>> watchInbox({
    InboxFilter filter = InboxFilter.all,
    InboxSort sort = InboxSort.newest,
  }) {
    final query =
        select(episodeRows).join([
          innerJoin(inboxRows, inboxRows.episodeId.equalsExp(episodeRows.id)),
        ])..where(
          inboxRows.removedAt.isNull() &
              episodeRows.completed.equals(false) &
              episodeRows.queued.equals(false),
        );
    switch (filter) {
      case InboxFilter.all:
        break;
      case InboxFilter.downloaded:
        query.where(episodeRows.downloaded.equals(true));
    }
    query.orderBy(switch (sort) {
      InboxSort.newest => [
        OrderingTerm.desc(inboxRows.discoveredAt),
        OrderingTerm.desc(episodeRows.publishedAt),
      ],
      InboxSort.oldest => [
        OrderingTerm.asc(inboxRows.discoveredAt),
        OrderingTerm.asc(episodeRows.publishedAt),
      ],
      InboxSort.podcast => [
        OrderingTerm.asc(episodeRows.podcastTitle),
        OrderingTerm.desc(episodeRows.publishedAt),
      ],
    });
    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(episodeRows)).toList(),
    );
  }

  Stream<int> watchInboxUnreadCount() {
    final count = episodeRows.id.count();
    final query =
        selectOnly(episodeRows).join([
            innerJoin(inboxRows, inboxRows.episodeId.equalsExp(episodeRows.id)),
          ])
          ..addColumns([count])
          ..where(
            inboxRows.removedAt.isNull() &
                episodeRows.completed.equals(false) &
                episodeRows.queued.equals(false),
          );
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  Future<void> removeFromInbox(int episodeId) =>
      (update(inboxRows)..where((row) => row.episodeId.equals(episodeId)))
          .write(InboxRowsCompanion(removedAt: Value(DateTime.now().toUtc())));

  Future<void> restoreToInbox(int episodeId) =>
      (update(inboxRows)..where((row) => row.episodeId.equals(episodeId)))
          .write(const InboxRowsCompanion(removedAt: Value(null)));

  Future<InboxSwipePreferences> inboxSwipePreferences() async {
    final row = await select(inboxPreferenceRows).getSingleOrNull();
    return InboxSwipePreferences(
      left: InboxSwipeAction.parse(row?.leftAction),
      right: row == null
          ? InboxSwipeAction.queue
          : InboxSwipeAction.parse(row.rightAction),
      markRemovedAsPlayed: row?.markRemovedAsPlayed ?? true,
    );
  }

  Future<void> setInboxSwipePreferences(InboxSwipePreferences preferences) =>
      into(inboxPreferenceRows).insertOnConflictUpdate(
        InboxPreferenceRowsCompanion.insert(
          id: const Value(0),
          leftAction: Value(preferences.left.name),
          rightAction: Value(preferences.right.name),
          markRemovedAsPlayed: Value(preferences.markRemovedAsPlayed),
        ),
      );

  Future<PodcastInboxOverride> podcastInboxOverride(int podcastId) async {
    final row = await (select(
      podcastInboxOverrideRows,
    )..where((entry) => entry.podcastId.equals(podcastId))).getSingleOrNull();
    return PodcastInboxOverride(
      left: row?.leftAction == null
          ? null
          : InboxSwipeAction.parse(row!.leftAction),
      right: row?.rightAction == null
          ? null
          : InboxSwipeAction.parse(row!.rightAction),
    );
  }

  Future<InboxSwipePreferences> resolvedInboxSwipePreferences(
    int podcastId,
  ) async => (await podcastInboxOverride(
    podcastId,
  )).resolve(await inboxSwipePreferences());

  Future<void> setPodcastInboxOverride(
    int podcastId,
    PodcastInboxOverride override,
  ) async {
    if (override.isEmpty) {
      await (delete(
        podcastInboxOverrideRows,
      )..where((row) => row.podcastId.equals(podcastId))).go();
      return;
    }
    await into(podcastInboxOverrideRows).insertOnConflictUpdate(
      PodcastInboxOverrideRowsCompanion.insert(
        podcastId: Value(podcastId),
        leftAction: Value(override.left?.name),
        rightAction: Value(override.right?.name),
      ),
    );
  }

  Future<List<PendingMutation>> pendingMutations() =>
      (select(syncMutations)
            ..where((row) => row.state.equals('pending'))
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .get();

  Future<PendingMutation?> mutationById(String id) => (select(
    syncMutations,
  )..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<List<PendingMutation>> readyMutations(
    DateTime now, {
    bool ignoreBackoff = false,
  }) =>
      (select(syncMutations)
            ..where(
              (row) =>
                  row.state.equals('pending') &
                  (ignoreBackoff
                      ? const Constant(true)
                      : row.nextAttemptAt.isNull() |
                            row.nextAttemptAt.isSmallerOrEqualValue(now)),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .get();

  Future<List<PendingMutation>> failedMutations() =>
      (select(syncMutations)
            ..where((row) => row.state.equals('failed'))
            ..orderBy([(row) => OrderingTerm.desc(row.failedAt)]))
          .get();

  Stream<List<PendingMutation>> watchOutboxMutations() => (select(
    syncMutations,
  )..orderBy([(row) => OrderingTerm.asc(row.createdAt)])).watch();

  Future<void> enqueueMutation(SyncMutationsCompanion mutation) async {
    final type = mutation.type.value;
    final episodeId = mutation.episodeId.value;
    await transaction(() async {
      Expression<bool> sameEpisode(SyncMutations row) => episodeId == null
          ? row.episodeId.isNull()
          : row.episodeId.equals(episodeId);

      if ({'position', 'completed', 'downloaded'}.contains(type)) {
        await (delete(
          syncMutations,
        )..where((row) => row.type.equals(type) & sameEpisode(row))).go();
      }
      await into(syncMutations).insert(mutation);
    });
  }

  Future<void> removeMutation(String id) =>
      (delete(syncMutations)..where((row) => row.id.equals(id))).go();

  Future<void> scheduleMutationRetry({
    required String id,
    required int attempts,
    required DateTime attemptedAt,
    required DateTime nextAttemptAt,
    required String error,
  }) => (update(syncMutations)..where((row) => row.id.equals(id))).write(
    SyncMutationsCompanion(
      attempts: Value(attempts + 1),
      nextAttemptAt: Value(nextAttemptAt),
      lastAttemptAt: Value(attemptedAt),
      lastError: Value(error),
    ),
  );

  Future<void> markMutationFailed({
    required String id,
    required int attempts,
    required DateTime failedAt,
    required String error,
  }) => (update(syncMutations)..where((row) => row.id.equals(id))).write(
    SyncMutationsCompanion(
      attempts: Value(attempts + 1),
      state: const Value('failed'),
      nextAttemptAt: const Value(null),
      lastAttemptAt: Value(failedAt),
      lastError: Value(error),
      failedAt: Value(failedAt),
    ),
  );

  Future<String?> acknowledgedQueueRevision() async =>
      (await select(queueSyncStateRows).getSingleOrNull())?.revision;

  Future<String> ensureSyncDeviceId(String candidate) async {
    final existing = await select(syncDeviceRows).getSingleOrNull();
    if (existing != null) return existing.deviceId;
    await into(syncDeviceRows).insert(
      SyncDeviceRowsCompanion.insert(
        id: const Value(0),
        deviceId: candidate,
        createdAt: DateTime.now().toUtc(),
      ),
      mode: InsertMode.insertOrIgnore,
    );
    return (await select(syncDeviceRows).getSingle()).deviceId;
  }

  Future<List<int>> acknowledgedQueueOrder() async {
    final row = await select(queueSyncStateRows).getSingleOrNull();
    if (row == null) return const [];
    final decoded = jsonDecode(row.orderJson);
    return (decoded as List? ?? const [])
        .map((id) => id is int ? id : int.tryParse('$id'))
        .whereType<int>()
        .toList(growable: false);
  }

  Future<void> acknowledgeQueue(List<int> orderedEpisodeIds) =>
      into(queueSyncStateRows).insertOnConflictUpdate(
        QueueSyncStateRowsCompanion.insert(
          id: const Value(0),
          revision: queueRevision(orderedEpisodeIds),
          orderJson: Value(jsonEncode(orderedEpisodeIds)),
          updatedAt: DateTime.now().toUtc(),
        ),
      );

  Future<PlaybackPreferences> playbackPreferences() async {
    final row = await select(playbackPreferenceRows).getSingleOrNull();
    return PlaybackPreferences(
      speed: row?.speed ?? 1,
      skipSilence: SkipSilenceStrength.parse(row?.skipSilence),
    );
  }

  Future<void> setGlobalPlaybackPreferences(PlaybackPreferences preferences) =>
      into(playbackPreferenceRows).insertOnConflictUpdate(
        PlaybackPreferenceRowsCompanion.insert(
          id: const Value(0),
          speed: Value(preferences.speed),
          skipSilence: Value(preferences.skipSilence.name),
        ),
      );

  Future<Map<int, PodcastPlaybackOverride>> podcastPlaybackOverrides() async {
    final rows = await select(podcastPlaybackOverrideRows).get();
    return <int, PodcastPlaybackOverride>{
      for (final row in rows)
        row.podcastId: PodcastPlaybackOverride(
          speed: row.speed,
          skipSilence: row.skipSilence == null
              ? null
              : SkipSilenceStrength.parse(row.skipSilence),
        ),
    };
  }

  Future<Map<int, String>> episodeChapterMetadata() async {
    final query = selectOnly(episodeRows)
      ..addColumns([episodeRows.id, episodeRows.chaptersJson]);
    return <int, String>{
      for (final row in await query.get())
        row.read(episodeRows.id)!: row.read(episodeRows.chaptersJson) ?? '[]',
    };
  }

  Future<void> setEpisodeChapters(int episodeId, String chaptersJson) =>
      (update(episodeRows)..where((row) => row.id.equals(episodeId))).write(
        EpisodeRowsCompanion(chaptersJson: Value(chaptersJson)),
      );

  Future<void> setPodcastPlaybackOverride(
    int podcastId,
    PodcastPlaybackOverride override,
  ) async {
    if (override.isEmpty) {
      await (delete(
        podcastPlaybackOverrideRows,
      )..where((row) => row.podcastId.equals(podcastId))).go();
      return;
    }
    await into(podcastPlaybackOverrideRows).insertOnConflictUpdate(
      PodcastPlaybackOverrideRowsCompanion.insert(
        podcastId: Value(podcastId),
        speed: Value(override.speed),
        skipSilence: Value(override.skipSilence?.name),
      ),
    );
  }

  Future<void> replaceRemoteSnapshot({
    required List<PodcastRowsCompanion> podcasts,
    required List<EpisodeRowsCompanion> episodes,
    required List<QueueRowsCompanion> queue,
  }) async {
    await transaction(() async {
      final knownInboxEpisodeIds =
          (await (selectOnly(
                inboxRows,
              )..addColumns([inboxRows.episodeId])).get())
              .map((row) => row.read(inboxRows.episodeId)!)
              .toSet();
      final remotePodcastIds = podcasts
          .map((podcast) => podcast.id.value)
          .toSet();
      final stalePodcasts =
          await (select(podcastRows)..where(
                (row) =>
                    row.id.isBiggerThanValue(0) &
                    row.id.isNotIn(remotePodcastIds),
              ))
              .get();
      for (final podcast in stalePodcasts) {
        final staleEpisodeIds =
            await (selectOnly(episodeRows)
                  ..addColumns([episodeRows.id])
                  ..where(episodeRows.podcastId.equals(podcast.id)))
                .map((row) => row.read(episodeRows.id)!)
                .get();
        if (staleEpisodeIds.isNotEmpty) {
          await (delete(
            downloadJobRows,
          )..where((row) => row.episodeId.isIn(staleEpisodeIds))).go();
          await (delete(
            queueRows,
          )..where((row) => row.episodeId.isIn(staleEpisodeIds))).go();
          await (delete(
            inboxRows,
          )..where((row) => row.episodeId.isIn(staleEpisodeIds))).go();
        }
        await (delete(
          episodeRows,
        )..where((row) => row.podcastId.equals(podcast.id))).go();
        await (delete(
          podcastPlaybackOverrideRows,
        )..where((row) => row.podcastId.equals(podcast.id))).go();
        await (delete(
          podcastInboxOverrideRows,
        )..where((row) => row.podcastId.equals(podcast.id))).go();
        await (delete(
          podcastDownloadOverrideRows,
        )..where((row) => row.podcastId.equals(podcast.id))).go();
        await (delete(
          podcastRows,
        )..where((row) => row.id.equals(podcast.id))).go();
      }
      await batch((batch) {
        batch.insertAllOnConflictUpdate(podcastRows, podcasts);
        batch.insertAllOnConflictUpdate(episodeRows, episodes);
      });
      await update(
        episodeRows,
      ).write(const EpisodeRowsCompanion(downloaded: Value(false)));
      final completedIds =
          await (selectOnly(downloadJobRows)
                ..addColumns([downloadJobRows.episodeId])
                ..where(downloadJobRows.state.equals('completed')))
              .map((row) => row.read(downloadJobRows.episodeId)!)
              .get();
      if (completedIds.isNotEmpty) {
        await (update(episodeRows)..where((row) => row.id.isIn(completedIds)))
            .write(const EpisodeRowsCompanion(downloaded: Value(true)));
      }
      final discoveredAt = DateTime.now().toUtc();
      final newInboxRows = episodes
          .where((episode) => !knownInboxEpisodeIds.contains(episode.id.value))
          .map(
            (episode) => InboxRowsCompanion.insert(
              episodeId: Value(episode.id.value),
              discoveredAt: discoveredAt,
            ),
          )
          .toList();
      if (newInboxRows.isNotEmpty) {
        await batch((batch) => batch.insertAll(inboxRows, newInboxRows));
      }
      await delete(queueRows).go();
      await batch((batch) => batch.insertAll(queueRows, queue));
      final acknowledgedOrder = queue.toList()
        ..sort(
          (left, right) => left.sortKey.value.compareTo(right.sortKey.value),
        );
      await acknowledgeQueue(
        acknowledgedOrder.map((row) => row.episodeId.value).toList(),
      );
    });
  }

  Future<void> setCompleted(
    int episodeId,
    bool value, {
    DateTime? playbackUpdatedAt,
    String? deviceId,
    String? mediaIdentity,
  }) => (update(episodeRows)..where((e) => e.id.equals(episodeId))).write(
    EpisodeRowsCompanion(
      completed: Value(value),
      positionSeconds: value ? const Value(0) : const Value.absent(),
      playbackUpdatedAt: playbackUpdatedAt == null
          ? const Value.absent()
          : Value(playbackUpdatedAt),
      playbackDeviceId: deviceId == null
          ? const Value.absent()
          : Value(deviceId),
      playbackIntent: playbackUpdatedAt == null
          ? const Value.absent()
          : Value(
              value
                  ? PlaybackEventKind.completed.name
                  : PlaybackEventKind.uncompleted.name,
            ),
      playbackMediaIdentity: mediaIdentity == null
          ? const Value.absent()
          : Value(mediaIdentity),
      updatedAt: Value(DateTime.now().toUtc()),
    ),
  );

  Future<void> setPosition(
    int episodeId,
    Duration position, {
    DateTime? playbackUpdatedAt,
    String? deviceId,
    bool userInitiatedSeek = false,
    String? mediaIdentity,
  }) => (update(episodeRows)..where((e) => e.id.equals(episodeId))).write(
    EpisodeRowsCompanion(
      positionSeconds: Value(position.inSeconds),
      playbackUpdatedAt: playbackUpdatedAt == null
          ? const Value.absent()
          : Value(playbackUpdatedAt),
      playbackDeviceId: deviceId == null
          ? const Value.absent()
          : Value(deviceId),
      playbackIntent: playbackUpdatedAt == null
          ? const Value.absent()
          : Value(
              userInitiatedSeek
                  ? PlaybackEventKind.seek.name
                  : PlaybackEventKind.progress.name,
            ),
      playbackMediaIdentity: mediaIdentity == null
          ? const Value.absent()
          : Value(mediaIdentity),
      updatedAt: Value(DateTime.now().toUtc()),
    ),
  );

  Future<void> setDownloaded(int episodeId, bool value) =>
      (update(episodeRows)..where((e) => e.id.equals(episodeId))).write(
        EpisodeRowsCompanion(
          downloaded: Value(value),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> acknowledgePlaybackEvent(PlaybackSyncEvent event) async {
    if (event.kind != PlaybackEventKind.seek) return;
    await (update(episodeRows)..where(
          (row) =>
              row.id.equals(event.episodeId) &
              row.playbackUpdatedAt.equals(event.occurredAt),
        ))
        .write(const EpisodeRowsCompanion(playbackIntent: Value('progress')));
  }

  Future<List<int>> queueEpisodeIds() async =>
      (await (select(
            queueRows,
          )..orderBy([(row) => OrderingTerm.asc(row.sortKey)])).get())
          .map((row) => row.episodeId)
          .toList(growable: false);

  Future<void> addToQueue(int episodeId, {int? afterEpisodeId}) async {
    final orderedIds = (await queueEpisodeIds())
        .where((id) => id != episodeId)
        .toList();
    final afterIndex = afterEpisodeId == null
        ? -1
        : orderedIds.indexOf(afterEpisodeId);
    orderedIds.insert(
      afterEpisodeId == null
          ? orderedIds.length
          : afterIndex < 0
          ? 0
          : afterIndex + 1,
      episodeId,
    );
    await transaction(() async {
      await into(queueRows).insertOnConflictUpdate(
        QueueRowsCompanion.insert(
          episodeId: Value(episodeId),
          sortKey: orderedIds.indexOf(episodeId).toDouble(),
          addedAt: DateTime.now().toUtc(),
        ),
      );
      await _writeQueueOrder(orderedIds);
      await (update(episodeRows)..where((e) => e.id.equals(episodeId))).write(
        const EpisodeRowsCompanion(queued: Value(true)),
      );
    });
  }

  Future<void> removeFromQueue(int episodeId) async {
    await (delete(queueRows)..where((q) => q.episodeId.equals(episodeId))).go();
    await (update(episodeRows)..where((e) => e.id.equals(episodeId))).write(
      const EpisodeRowsCompanion(queued: Value(false)),
    );
  }

  Future<void> reorderQueue(List<int> orderedEpisodeIds) async {
    final currentIds = await queueEpisodeIds();
    final currentSet = currentIds.toSet();
    final normalized =
        orderedEpisodeIds
            .where(currentSet.contains)
            .toSet()
            .toList(growable: true)
          ..addAll(currentIds.where((id) => !orderedEpisodeIds.contains(id)));
    await transaction(() => _writeQueueOrder(normalized));
  }

  Future<void> replaceQueueOrder(List<int> orderedEpisodeIds) async {
    final knownIds = orderedEpisodeIds.isEmpty
        ? <int>{}
        : (await (selectOnly(episodeRows)
                    ..addColumns([episodeRows.id])
                    ..where(episodeRows.id.isIn(orderedEpisodeIds)))
                  .get())
              .map((row) => row.read(episodeRows.id)!)
              .toSet();
    final normalized = orderedEpisodeIds.where(knownIds.contains).toList();
    final now = DateTime.now().toUtc();
    await transaction(() async {
      await update(
        episodeRows,
      ).write(const EpisodeRowsCompanion(queued: Value(false)));
      if (normalized.isNotEmpty) {
        await (update(episodeRows)..where((row) => row.id.isIn(normalized)))
            .write(const EpisodeRowsCompanion(queued: Value(true)));
      }
      await delete(queueRows).go();
      await batch(
        (batch) => batch.insertAll(
          queueRows,
          normalized.indexed
              .map(
                (entry) => QueueRowsCompanion.insert(
                  episodeId: Value(entry.$2),
                  sortKey: entry.$1.toDouble(),
                  addedAt: now,
                ),
              )
              .toList(),
        ),
      );
    });
  }

  Future<void> clearQueue() async {
    await transaction(() async {
      await delete(queueRows).go();
      await (update(episodeRows)..where((row) => row.queued.equals(true)))
          .write(const EpisodeRowsCompanion(queued: Value(false)));
    });
  }

  Future<void> _writeQueueOrder(List<int> orderedEpisodeIds) async {
    for (final entry in orderedEpisodeIds.indexed) {
      await (update(queueRows)..where((row) => row.episodeId.equals(entry.$2)))
          .write(QueueRowsCompanion(sortKey: Value(entry.$1.toDouble())));
    }
  }

  Future<void> seedDemo() async {
    if (await podcastRows.count().getSingle() > 0) return;
    final now = DateTime.now().toUtc();
    const podcasts = [
      PodcastRowsCompanion(
        id: Value(-1),
        title: Value('Field Notes'),
        author: Value('Mara Chen'),
        description: Value('Small stories about technology and the outdoors.'),
        episodeCount: Value(42),
      ),
      PodcastRowsCompanion(
        id: Value(-2),
        title: Value('Signal & Noise'),
        author: Value('Lumen Studio'),
        description: Value('Calm conversations with people who make things.'),
        episodeCount: Value(87),
      ),
      PodcastRowsCompanion(
        id: Value(-3),
        title: Value('After Hours'),
        author: Value('Northline Audio'),
        description: Value('The surprising work that happens after dark.'),
        episodeCount: Value(31),
      ),
    ];
    final episodes = [
      EpisodeRowsCompanion.insert(
        id: const Value(-101),
        podcastId: -1,
        podcastTitle: 'Field Notes',
        title: 'The quiet architecture of a trail',
        description: const Value(
          'Why the best paths feel inevitable, and the people who shape them.',
        ),
        publishedAt: now.subtract(const Duration(hours: 4)),
        durationSeconds: const Value(2820),
        positionSeconds: const Value(754),
        updatedAt: now,
      ),
      EpisodeRowsCompanion.insert(
        id: const Value(-102),
        podcastId: -2,
        podcastTitle: 'Signal & Noise',
        title: 'Designing for the moments between',
        description: const Value(
          'A product designer on pauses, transitions, and patient software.',
        ),
        publishedAt: now.subtract(const Duration(days: 1)),
        durationSeconds: const Value(3300),
        updatedAt: now,
      ),
      EpisodeRowsCompanion.insert(
        id: const Value(-103),
        podcastId: -3,
        podcastTitle: 'After Hours',
        title: 'The last print run',
        description: const Value(
          'Inside a newspaper press as the city goes to sleep.',
        ),
        publishedAt: now.subtract(const Duration(days: 2)),
        durationSeconds: const Value(2160),
        updatedAt: now,
      ),
      EpisodeRowsCompanion.insert(
        id: const Value(-104),
        podcastId: -1,
        podcastTitle: 'Field Notes',
        title: 'A map made of memory',
        description: const Value('What we notice when the GPS is turned off.'),
        publishedAt: now.subtract(const Duration(days: 4)),
        durationSeconds: const Value(2580),
        completed: const Value(true),
        updatedAt: now,
      ),
    ];
    await batch((batch) {
      batch.insertAll(podcastRows, podcasts);
      batch.insertAll(episodeRows, episodes);
      batch.insertAll(
        inboxRows,
        episodes.map(
          (episode) => InboxRowsCompanion.insert(
            episodeId: episode.id,
            discoveredAt: now,
          ),
        ),
      );
    });
    await addToQueue(-101);
    await addToQueue(-103);
  }

  Future<void> clearAll() async {
    await transaction(() async {
      await delete(queueRows).go();
      await delete(downloadJobRows).go();
      await delete(inboxRows).go();
      await delete(syncMutations).go();
      await delete(discoveryCacheRows).go();
      await delete(podcastInboxOverrideRows).go();
      await delete(inboxPreferenceRows).go();
      await delete(podcastPlaybackOverrideRows).go();
      await delete(podcastDownloadOverrideRows).go();
      await delete(downloadPreferenceRows).go();
      await delete(episodeRows).go();
      await delete(podcastRows).go();
    });
  }
}
