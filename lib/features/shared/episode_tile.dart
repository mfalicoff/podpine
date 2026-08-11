import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/backend/podcast_backend.dart';
import '../../providers.dart';
import '../details/podcast_detail_screen.dart';
import 'artwork.dart';

class EpisodeTile extends ConsumerWidget {
  const EpisodeTile({super.key, required this.episode, this.compact = false});
  final EpisodeRecord episode;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = episode.durationSeconds > 0
        ? (episode.positionSeconds / episode.durationSeconds).clamp(0.0, 1.0)
        : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
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
                        if (episode.downloaded) ...[
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
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Episode actions',
                onSelected: (value) => _handleAction(ref, value),
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
                ],
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(WidgetRef ref, String value) async {
    final app = ref.read(appControllerProvider);
    switch (value) {
      case 'complete':
        await app.setCompleted(episode, !episode.completed);
      case 'queue':
        episode.queued
            ? await app.removeFromQueue(episode)
            : await app.addToQueue(episode);
      case 'next':
        await app.addToQueue(episode, next: true);
    }
  }

  static String _metadata(EpisodeRecord episode) {
    final published = DateFormat.MMMd().format(episode.publishedAt.toLocal());
    final minutes = (episode.durationSeconds / 60).round();
    return minutes > 0 ? '$published  ·  $minutes min' : published;
  }
}
