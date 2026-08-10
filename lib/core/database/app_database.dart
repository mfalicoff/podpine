import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/player/playback_options.dart';

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

  @override
  Set<Column<Object>> get primaryKey => {id};
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
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('QueueRecord')
class QueueRows extends Table {
  IntColumn get episodeId => integer().references(EpisodeRows, #id)();
  RealColumn get sortKey => real()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {episodeId};
}

@DataClassName('PendingMutation')
class SyncMutations extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get episodeId => integer().nullable()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();

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
    EpisodeRows,
    QueueRows,
    SyncMutations,
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(episodeRows, episodeRows.chaptersJson);
        await migrator.createTable(playbackPreferenceRows);
        await migrator.createTable(podcastPlaybackOverrideRows);
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

  Stream<List<EpisodeRecord>> watchQueue() {
    final query = select(episodeRows).join([
      innerJoin(queueRows, queueRows.episodeId.equalsExp(episodeRows.id)),
    ])..orderBy([OrderingTerm.asc(queueRows.sortKey)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(episodeRows)).toList(),
    );
  }

  Future<List<PendingMutation>> pendingMutations() => (select(
    syncMutations,
  )..orderBy([(row) => OrderingTerm.asc(row.createdAt)])).get();

  Future<void> enqueueMutation(SyncMutationsCompanion mutation) =>
      into(syncMutations).insert(mutation);

  Future<void> removeMutation(String id) =>
      (delete(syncMutations)..where((row) => row.id.equals(id))).go();

  Future<void> noteMutationFailure(String id, int attempts) =>
      (update(syncMutations)..where((row) => row.id.equals(id))).write(
        SyncMutationsCompanion(attempts: Value(attempts + 1)),
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
      await batch((batch) {
        batch.insertAllOnConflictUpdate(podcastRows, podcasts);
        batch.insertAllOnConflictUpdate(episodeRows, episodes);
      });
      await delete(queueRows).go();
      await batch((batch) => batch.insertAll(queueRows, queue));
    });
  }

  Future<void> setCompleted(int episodeId, bool value) =>
      (update(episodeRows)..where((e) => e.id.equals(episodeId))).write(
        EpisodeRowsCompanion(
          completed: Value(value),
          positionSeconds: value ? const Value(0) : const Value.absent(),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> setPosition(int episodeId, Duration position) =>
      (update(episodeRows)..where((e) => e.id.equals(episodeId))).write(
        EpisodeRowsCompanion(
          positionSeconds: Value(position.inSeconds),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  Future<void> addToQueue(int episodeId, {bool next = false}) async {
    final current = await select(queueRows).get();
    final sortKey = current.isEmpty
        ? 0.0
        : next
        ? current.map((e) => e.sortKey).reduce((a, b) => a < b ? a : b) - 1
        : current.map((e) => e.sortKey).reduce((a, b) => a > b ? a : b) + 1;
    await into(queueRows).insertOnConflictUpdate(
      QueueRowsCompanion.insert(
        episodeId: Value(episodeId),
        sortKey: sortKey,
        addedAt: DateTime.now().toUtc(),
      ),
    );
    await (update(episodeRows)..where((e) => e.id.equals(episodeId))).write(
      const EpisodeRowsCompanion(queued: Value(true)),
    );
  }

  Future<void> removeFromQueue(int episodeId) async {
    await (delete(queueRows)..where((q) => q.episodeId.equals(episodeId))).go();
    await (update(episodeRows)..where((e) => e.id.equals(episodeId))).write(
      const EpisodeRowsCompanion(queued: Value(false)),
    );
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
    });
    await addToQueue(-101);
    await addToQueue(-103);
  }

  Future<void> clearAll() async {
    await transaction(() async {
      await delete(queueRows).go();
      await delete(syncMutations).go();
      await delete(podcastPlaybackOverrideRows).go();
      await delete(episodeRows).go();
      await delete(podcastRows).go();
    });
  }
}
