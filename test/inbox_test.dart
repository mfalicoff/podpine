import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/features/inbox/inbox_models.dart';

void main() {
  test(
    'Inbox discovery, tombstones, and preferences persist across restarts',
    () async {
      final directory = await Directory.systemTemp.createTemp('podpine-inbox-');
      final file = File('${directory.path}/podpine.sqlite');
      addTearDown(() => directory.delete(recursive: true));

      var database = AppDatabase(NativeDatabase(file));
      await database.replaceRemoteSnapshot(
        podcasts: [_podcast()],
        episodes: [_episode(1, publishedAt: DateTime.utc(2026, 8, 10))],
        queue: const [],
      );

      expect((await database.watchInbox().first).map((e) => e.id), [1]);
      expect(await database.watchInboxUnreadCount().first, 1);
      await database.removeFromInbox(1);
      await database.close();

      database = AppDatabase(NativeDatabase(file));
      addTearDown(database.close);
      expect(await database.watchInbox().first, isEmpty);
      expect((await database.watchRecentEpisodes().first).single.id, 1);

      await database.replaceRemoteSnapshot(
        podcasts: [_podcast()],
        episodes: [
          _episode(1, publishedAt: DateTime.utc(2026, 8, 10)),
          _episode(2, publishedAt: DateTime.utc(2026, 8, 11)),
        ],
        queue: const [],
      );
      expect((await database.watchInbox().first).map((e) => e.id), [2]);

      await database.restoreToInbox(1);
      await database.setCompleted(1, true);
      await database.addToQueue(2);
      await database.setDownloaded(2, true);

      expect(
        (await database
                .watchInbox(
                  filter: InboxFilter.unplayed,
                  sort: InboxSort.oldest,
                )
                .first)
            .map((e) => e.id),
        [2],
      );
      expect(
        (await database.watchInbox(filter: InboxFilter.queued).first).single.id,
        2,
      );
      expect(
        (await database.watchInbox(filter: InboxFilter.downloaded).first)
            .single
            .id,
        2,
      );
      expect(
        (await database.watchInbox(sort: InboxSort.oldest).first).map(
          (e) => e.id,
        ),
        [1, 2],
      );
      expect(await database.watchInboxUnreadCount().first, 1);

      await database.setInboxSwipePreferences(
        const InboxSwipePreferences(
          left: InboxSwipeAction.download,
          right: InboxSwipeAction.playNext,
        ),
      );
      await database.setPodcastInboxOverride(
        7,
        const PodcastInboxOverride(left: InboxSwipeAction.remove),
      );
      final preferences = await database.resolvedInboxSwipePreferences(7);
      expect(preferences.left, InboxSwipeAction.remove);
      expect(preferences.right, InboxSwipeAction.playNext);
    },
  );
}

PodcastRowsCompanion _podcast() =>
    const PodcastRowsCompanion(id: Value(7), title: Value('Inbox Cast'));

EpisodeRowsCompanion _episode(int id, {required DateTime publishedAt}) =>
    EpisodeRowsCompanion.insert(
      id: Value(id),
      podcastId: 7,
      podcastTitle: 'Inbox Cast',
      title: 'Episode $id',
      publishedAt: publishedAt,
      updatedAt: publishedAt,
    );
