import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/backend/podcast_backend.dart';
import '../../core/downloads/download_models.dart';
import '../../core/downloads/download_actions.dart';
import '../../providers.dart';
import '../details/podcast_detail_screen.dart';
import 'artwork.dart';

class EpisodeTile extends ConsumerWidget {
  const EpisodeTile({
    super.key,
    required this.episode,
    this.compact = false,
    this.onLongPress,
    this.onRemoveFromInbox,
    this.selectionMode = false,
    this.selected = false,
    this.onSelected,
  });
  final EpisodeRecord episode;
  final bool compact;
  final VoidCallback? onLongPress;
  final Future<void> Function()? onRemoveFromInbox;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(downloadJobsProvider).valueOrNull ?? const [];
    final download = _jobFor(jobs, episode.id);
    final progress = episode.durationSeconds > 0
        ? (episode.positionSeconds / episode.durationSeconds).clamp(0.0, 1.0)
        : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onLongPress: onLongPress,
        onTap: selectionMode
            ? onSelected
            : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EpisodeDetailScreen(
                    episode: RemoteEpisode(
                      id: episode.id,
                      podcastId: episode.podcastId,
                      podcastTitle: episode.podcastTitle,
                      title: episode.title,
                      description: episode.description,
                      artworkUrl: episode.artworkUrl,
                      audioUrl: episode.audioUrl,
                      publishedAt: episode.publishedAt,
                      durationSeconds: episode.durationSeconds,
                      positionSeconds: episode.positionSeconds,
                      completed: episode.completed,
                      queued: episode.queued,
                      downloaded: episode.downloaded,
                      isYoutube: episode.isYoutube,
                      chaptersJson: episode.chaptersJson,
                    ),
                    localEpisode: episode,
                  ),
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectionMode) ...[
                Checkbox(value: selected, onChanged: (_) => onSelected?.call()),
                const SizedBox(width: 4),
              ],
              Artwork(
                id: episode.podcastId,
                title: episode.podcastTitle,
                url: episode.artworkUrl,
                size: compact ? 52 : 62,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.podcastTitle.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      episode.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          _metadata(episode),
                          style: const TextStyle(
                            fontFamily: 'sans-serif',
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                        if (download?.downloadState ==
                                DownloadState.completed ||
                            episode.downloaded) ...[
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.download_done_rounded,
                            size: 14,
                            color: Colors.black45,
                          ),
                        ],
                      ],
                    ),
                    if (progress > 0 && !episode.completed) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: Colors.black12,
                        ),
                      ),
                    ],
                    if (download != null &&
                        download.downloadState != DownloadState.completed) ...[
                      const SizedBox(height: 7),
                      LinearProgressIndicator(
                        value: download.progress,
                        minHeight: 3,
                        backgroundColor: Colors.black12,
                      ),
                      if (download.error != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          download.error!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'sans-serif',
                            fontSize: 10,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              if (!selectionMode)
                PopupMenuButton<String>(
                  tooltip: 'Episode actions',
                  onSelected: (value) => _handleAction(context, ref, value),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'complete',
                      child: Text(
                        episode.completed ? 'Mark unplayed' : 'Mark played',
                      ),
                    ),
                    PopupMenuItem(
                      value: 'queue',
                      child: Text(
                        episode.queued ? 'Remove from queue' : 'Add to queue',
                      ),
                    ),
                    if (!episode.queued)
                      const PopupMenuItem(
                        value: 'next',
                        child: Text('Play next'),
                      ),
                    ..._downloadMenuItems(download),
                    if (onRemoveFromInbox != null) ...[
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'remove-inbox',
                        child: Text('Remove from Inbox (keep unplayed)'),
                      ),
                    ],
                  ],
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final app = ref.read(appControllerProvider);
    try {
      switch (value) {
        case 'complete':
          await app.setCompleted(episode, !episode.completed);
        case 'queue':
          episode.queued
              ? await app.removeFromQueue(episode)
              : await app.addToQueue(episode);
        case 'next':
          await app.addToQueue(episode, next: true);
        case 'download':
          await startDownloadWithCellularConfirmation(context, ref, episode);
        case 'pause-download':
          await ref.read(downloadManagerProvider).pause(episode.id);
        case 'resume-download':
          await startDownloadWithCellularConfirmation(context, ref, episode);
        case 'retry-download':
          await startDownloadWithCellularConfirmation(context, ref, episode);
        case 'cancel-download':
          await ref.read(downloadManagerProvider).cancel(episode.id);
        case 'delete-download':
          await ref.read(downloadManagerProvider).delete(episode.id);
        case 'remove-inbox':
          await onRemoveFromInbox?.call();
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  static DownloadJobRecord? _jobFor(
    List<DownloadJobRecord> jobs,
    int episodeId,
  ) {
    for (final job in jobs) {
      if (job.episodeId == episodeId) return job;
    }
    return null;
  }

  static List<PopupMenuEntry<String>> _downloadMenuItems(
    DownloadJobRecord? job,
  ) {
    final state = job?.downloadState;
    return switch (state) {
      null => const [PopupMenuItem(value: 'download', child: Text('Download'))],
      DownloadState.queued || DownloadState.downloading => const [
        PopupMenuDivider(),
        PopupMenuItem(value: 'pause-download', child: Text('Pause download')),
        PopupMenuItem(value: 'cancel-download', child: Text('Cancel download')),
      ],
      DownloadState.paused => const [
        PopupMenuDivider(),
        PopupMenuItem(value: 'resume-download', child: Text('Resume download')),
        PopupMenuItem(value: 'cancel-download', child: Text('Cancel download')),
      ],
      DownloadState.failed => const [
        PopupMenuDivider(),
        PopupMenuItem(value: 'retry-download', child: Text('Retry download')),
        PopupMenuItem(value: 'cancel-download', child: Text('Cancel download')),
      ],
      DownloadState.completed => const [
        PopupMenuDivider(),
        PopupMenuItem(value: 'delete-download', child: Text('Delete download')),
      ],
    };
  }

  static String _metadata(EpisodeRecord episode) {
    final published = DateFormat.MMMd().format(episode.publishedAt.toLocal());
    final minutes = (episode.durationSeconds / 60).round();
    return minutes > 0 ? '$published  ·  $minutes min' : published;
  }
}
