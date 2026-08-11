import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../backend/pinepods_backend.dart';
import '../backend/podcast_backend.dart';
import '../database/app_database.dart';
import 'queue_sync.dart';

class SyncEngine {
  SyncEngine(
    this.database,
    this.backend,
    this.userId, {
    DateTime Function()? clock,
    double Function()? jitter,
  }) : _clock = clock ?? _utcNow,
       _jitter = jitter ?? Random().nextDouble;

  final AppDatabase database;
  final PodcastBackend backend;
  final int userId;
  final DateTime Function() _clock;
  final double Function() _jitter;

  static const maxRetryDelay = Duration(minutes: 5);

  Future<void> refresh({bool forceMutationRetry = false}) async {
    await flushPendingMutations(ignoreBackoff: forceMutationRetry);
    if ((await database.pendingMutations()).isNotEmpty) {
      throw const SyncDeferredException();
    }
    final results = await Future.wait([
      backend.getSubscriptions(userId),
      backend.getEpisodes(userId),
      backend.getQueue(userId),
    ]);
    final podcasts = results[0] as List<RemotePodcast>;
    final episodes = results[1] as List<RemoteEpisode>;
    final queue = results[2] as List<RemoteEpisode>;
    final queuedEpisodeIds = queue.map((episode) => episode.id).toSet();
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
            websiteUrl: Value(podcast.websiteUrl),
            categoriesJson: Value(jsonEncode(podcast.categories)),
            explicit: Value(podcast.explicit),
            podcastIndexId: Value(podcast.podcastIndexId),
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
            queued: Value(queuedEpisodeIds.contains(episode.id)),
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

  Future<void> flushPendingMutations({bool ignoreBackoff = false}) async {
    final now = _clock();
    for (final mutation in await database.readyMutations(
      now,
      ignoreBackoff: ignoreBackoff,
    )) {
      try {
        final payload = jsonDecode(mutation.payload) as Map<String, dynamic>;
        final episodeId = mutation.episodeId;
        switch (mutation.type) {
          case 'position':
            if (episodeId == null) {
              throw const FormatException('Position mutation has no episode.');
            }
            await backend.updatePlayback(
              userId,
              episodeId,
              Duration(seconds: payload['seconds'] as int? ?? 0),
            );
            break;
          case 'completed':
            if (episodeId == null) {
              throw const FormatException('Completed mutation has no episode.');
            }
            await backend.markCompleted(
              userId,
              episodeId,
              payload['value'] == true,
            );
            break;
          case 'queue_add':
          case 'queue_remove':
          case 'queue_reorder':
          case 'queue_clear':
            final result = await QueueSyncCoordinator(backend, userId).apply(
              QueueSyncOperation.fromPayload(
                id: mutation.id,
                type: mutation.type,
                episodeId: episodeId,
                payload: payload,
              ),
            );
            await database.replaceQueueOrder(result.order);
            await database.acknowledgeQueue(result.order);
            break;
          case 'downloaded':
            if (episodeId == null) {
              throw const FormatException('Download mutation has no episode.');
            }
            final downloadBackend = backend is EpisodeDownloadBackend
                ? backend as EpisodeDownloadBackend
                : null;
            if (downloadBackend == null) {
              throw UnsupportedError('Episode downloads are unavailable.');
            }
            await downloadBackend.setEpisodeDownloaded(
              userId,
              episodeId,
              payload['value'] == true,
            );
            break;
          case 'podcast_subscribe':
            final podcast = RemotePodcast.fromJson(payload);
            final remoteId = await backend.subscribe(userId, podcast);
            if (remoteId > 0) {
              await database.reconcilePodcastId(
                temporaryId: podcast.id,
                podcast: _podcastCompanion(podcast.copyWith(id: remoteId)),
              );
            }
            break;
          case 'podcast_unsubscribe':
            await backend.unsubscribe(userId, RemotePodcast.fromJson(payload));
            break;
          default:
            throw UnsupportedError(
              'Unknown outbox mutation type: ${mutation.type}',
            );
        }
        await database.removeMutation(mutation.id);
      } catch (error) {
        final attemptedAt = _clock();
        final message = _shortError(error);
        if (_isPermanent(error)) {
          await database.markMutationFailed(
            id: mutation.id,
            attempts: mutation.attempts,
            failedAt: attemptedAt,
            error: message,
          );
          continue;
        }
        await database.scheduleMutationRetry(
          id: mutation.id,
          attempts: mutation.attempts,
          attemptedAt: attemptedAt,
          nextAttemptAt: attemptedAt.add(_retryDelay(mutation.attempts)),
          error: message,
        );
        // Preserve outbox order after a transient failure. Later operations
        // may depend on this mutation having reached the server first.
        break;
      }
    }
  }

  Duration _retryDelay(int previousAttempts) {
    final exponent = previousAttempts.clamp(0, 20);
    final exponentialSeconds = min(1 << exponent, maxRetryDelay.inSeconds);
    final jitteredMilliseconds = (exponentialSeconds * 1000 * (.5 + _jitter()))
        .round();
    return Duration(
      milliseconds: min(jitteredMilliseconds, maxRetryDelay.inMilliseconds),
    );
  }

  static bool _isPermanent(Object error) {
    if (error is UnsupportedError ||
        error is FormatException ||
        error is TypeError) {
      return true;
    }
    if (error is! PinepodsException || error.statusCode == null) return false;
    final status = error.statusCode!;
    return status >= 400 &&
        status < 500 &&
        status != 408 &&
        status != 425 &&
        status != 429;
  }

  static String _shortError(Object error) {
    final message = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return message.length <= 500 ? message : '${message.substring(0, 497)}...';
  }

  static DateTime _utcNow() => DateTime.now().toUtc();

  static PodcastRowsCompanion _podcastCompanion(RemotePodcast podcast) =>
      PodcastRowsCompanion.insert(
        id: Value(podcast.id),
        title: podcast.title,
        author: Value(podcast.author),
        artworkUrl: Value(podcast.artworkUrl),
        description: Value(podcast.description),
        feedUrl: Value(podcast.feedUrl),
        episodeCount: Value(podcast.episodeCount),
        websiteUrl: Value(podcast.websiteUrl),
        categoriesJson: Value(jsonEncode(podcast.categories)),
        explicit: Value(podcast.explicit),
        podcastIndexId: Value(podcast.podcastIndexId),
      );
}

class SyncDeferredException implements Exception {
  const SyncDeferredException();

  @override
  String toString() => 'Outbox retry is scheduled for a later time.';
}
