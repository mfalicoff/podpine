import 'dart:convert';

import 'package:drift/drift.dart';

import '../backend/podcast_backend.dart';
import '../database/app_database.dart';

class SyncEngine {
  const SyncEngine(this.database, this.backend, this.userId);

  final AppDatabase database;
  final PodcastBackend backend;
  final int userId;

  Future<void> refresh() async {
    await _flushPendingMutations();
    final results = await Future.wait([
      backend.getSubscriptions(userId),
      backend.getEpisodes(userId),
      backend.getQueue(userId),
    ]);
    final podcasts = results[0] as List<RemotePodcast>;
    final episodes = results[1] as List<RemoteEpisode>;
    final queue = results[2] as List<RemoteEpisode>;
    final now = DateTime.now().toUtc();
    final cachedChapters = await database.episodeChapterMetadata();
    final podcastIds = podcasts.map((podcast) => podcast.id).toSet();

    // Some queue responses omit podcast ids. The full episode snapshot is the
    // authoritative metadata source; the queue response supplies ordering.
    final episodesById = {for (final episode in episodes) episode.id: episode};
    for (final queued in queue) {
      episodesById.putIfAbsent(queued.id, () => queued);
    }

    final podcastRows = podcasts
        .map(
          (podcast) => PodcastRowsCompanion.insert(
            id: Value(podcast.id),
            title: podcast.title,
            author: Value(podcast.author),
            artworkUrl: Value(podcast.artworkUrl),
            description: Value(podcast.description),
            feedUrl: Value(podcast.feedUrl),
            episodeCount: Value(podcast.episodeCount),
          ),
        )
        .toList();

    // Pinepods queue data can contain an episode before the podcast snapshot
    // catches up. Insert a small placeholder to keep the foreign key valid.
    for (final episode in episodesById.values) {
      if (podcastIds.add(episode.podcastId)) {
        podcastRows.add(
          PodcastRowsCompanion.insert(
            id: Value(episode.podcastId),
            title: episode.podcastTitle.isEmpty
                ? 'Unknown podcast'
                : episode.podcastTitle,
          ),
        );
      }
    }

    final episodeRows = episodesById.values
        .map(
          (episode) => EpisodeRowsCompanion.insert(
            id: Value(episode.id),
            podcastId: episode.podcastId,
            podcastTitle: episode.podcastTitle,
            title: episode.title,
            description: Value(episode.description),
            artworkUrl: Value(episode.artworkUrl),
            audioUrl: Value(episode.audioUrl),
            publishedAt: episode.publishedAt,
            durationSeconds: Value(episode.durationSeconds),
            positionSeconds: Value(episode.positionSeconds),
            completed: Value(episode.completed),
            queued: Value(episode.queued),
            downloaded: Value(episode.downloaded),
            isYoutube: Value(episode.isYoutube),
            chaptersJson: Value(
              episode.chaptersJson == '[]'
                  ? cachedChapters[episode.id] ?? '[]'
                  : episode.chaptersJson,
            ),
            updatedAt: now,
          ),
        )
        .toList();

    final queueRows = queue.indexed.map((entry) {
      final (index, episode) = entry;
      return QueueRowsCompanion.insert(
        episodeId: Value(episode.id),
        sortKey: (episode.queuePosition ?? index).toDouble(),
        addedAt: now,
      );
    }).toList();

    await database.replaceRemoteSnapshot(
      podcasts: podcastRows,
      episodes: episodeRows,
      queue: queueRows,
    );
  }

  Future<void> _flushPendingMutations() async {
    for (final mutation in await database.pendingMutations()) {
      try {
        final payload = jsonDecode(mutation.payload) as Map<String, dynamic>;
        final episodeId = mutation.episodeId;
        if (episodeId == null) {
          await database.removeMutation(mutation.id);
          continue;
        }
        switch (mutation.type) {
          case 'position':
            await backend.updatePlayback(
              userId,
              episodeId,
              Duration(seconds: payload['seconds'] as int? ?? 0),
            );
            break;
          case 'completed':
            await backend.markCompleted(
              userId,
              episodeId,
              payload['value'] == true,
            );
            break;
          case 'queue_add':
            await backend.addToQueue(userId, episodeId);
            break;
          case 'queue_remove':
            await backend.removeFromQueue(userId, episodeId);
            break;
        }
        await database.removeMutation(mutation.id);
      } catch (_) {
        await database.noteMutationFailure(mutation.id, mutation.attempts);
        rethrow;
      }
    }
  }
}
