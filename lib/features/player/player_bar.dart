import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers.dart';
import '../shared/artwork.dart';
import 'player_controller.dart';

class PlayerBar extends ConsumerWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final episode = player.current;
    if (episode == null) return const SizedBox.shrink();
    final progress = player.duration.inMilliseconds == 0
        ? 0.0
        : player.position.inMilliseconds / player.duration.inMilliseconds;
    return Material(
      color: const Color(0xFFFDFCF8),
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: PodpineTheme.cream,
          builder: (_) => const _FullPlayer(),
        ),
        child: Column(
          children: [
            if (player.error != null) _PlaybackError(player: player),
            LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 2,
              backgroundColor: Colors.black12,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  Artwork(
                    id: episode.podcastId,
                    title: episode.podcastTitle,
                    url: episode.artworkUrl,
                    size: 44,
                    radius: 10,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          episode.podcastTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'sans-serif',
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => player.skip(-15),
                    icon: const Icon(Icons.replay_10_rounded),
                  ),
                  IconButton.filled(
                    onPressed: player.loading ? null : player.toggle,
                    icon: player.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            player.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                  ),
                  IconButton(
                    onPressed: () => player.skip(30),
                    icon: const Icon(Icons.forward_30_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaybackError extends StatelessWidget {
  const _PlaybackError({required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: Theme.of(context).colorScheme.errorContainer,
    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
    child: Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            player.error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontSize: 12,
            ),
          ),
        ),
        if (player.errorCanRetry)
          TextButton(onPressed: player.retry, child: const Text('Retry')),
        IconButton(
          tooltip: 'Dismiss playback error',
          onPressed: player.dismissError,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    ),
  );
}

class _FullPlayer extends ConsumerWidget {
  const _FullPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final episode = player.current;
    if (episode == null) return const SizedBox.shrink();
    final max = player.duration.inMilliseconds
        .toDouble()
        .clamp(1, double.infinity)
        .toDouble();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 26),
            Artwork(
              id: episode.podcastId,
              title: episode.podcastTitle,
              url: episode.artworkUrl,
              size: 230,
              radius: 28,
            ),
            const SizedBox(height: 24),
            Text(
              episode.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 7),
            Text(
              episode.podcastTitle,
              style: const TextStyle(
                fontFamily: 'sans-serif',
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Slider(
              value: player.position.inMilliseconds
                  .toDouble()
                  .clamp(0, max)
                  .toDouble(),
              max: max,
              onChanged: (value) =>
                  player.seek(Duration(milliseconds: value.round())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _time(player.position),
                    style: const TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                  Text(
                    '-${_time(player.duration - player.position)}',
                    style: const TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _showSpeed(context, player),
                  child: Text('${player.speed}×'),
                ),
                IconButton(
                  iconSize: 32,
                  onPressed: () => player.skip(-15),
                  icon: const Icon(Icons.replay_10_rounded),
                ),
                IconButton.filled(
                  iconSize: 40,
                  padding: const EdgeInsets.all(16),
                  onPressed: player.toggle,
                  icon: Icon(
                    player.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                ),
                IconButton(
                  iconSize: 32,
                  onPressed: () => player.skip(30),
                  icon: const Icon(Icons.forward_30_rounded),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bedtime_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _time(Duration value) {
    final duration = value.isNegative ? Duration.zero : value;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static Future<void> _showSpeed(BuildContext context, dynamic player) =>
      showDialog<void>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Playback speed'),
          children: [
            for (final speed in [0.8, 1.0, 1.2, 1.5, 1.8, 2.0])
              SimpleDialogOption(
                onPressed: () {
                  player.setSpeed(speed);
                  Navigator.pop(context);
                },
                child: Text('$speed×'),
              ),
          ],
        ),
      );
}
