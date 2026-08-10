import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../shared/artwork.dart';
import '../shared/episode_tile.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueProvider);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Up next',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'This queue follows you across devices.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          ...queue.when(
            data: (items) => items.isEmpty
                ? const [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.queue_music_rounded,
                        title: 'Nothing queued',
                        body: 'Open an episode menu and choose Add to queue.',
                      ),
                    ),
                  ]
                : [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                        child: Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () => ref
                                  .read(playerControllerProvider)
                                  .playEpisode(items.first),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Play queue'),
                            ),
                            const Spacer(),
                            Text(
                              '${items.length} episode${items.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontFamily: 'sans-serif',
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) => Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 34,
                            child: Text(
                              '${index + 1}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'sans-serif',
                                color: Colors.black38,
                              ),
                            ),
                          ),
                          Expanded(
                            child: EpisodeTile(
                              episode: items[index],
                              compact: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
            loading: () => const [
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (_, _) => const [
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Couldn’t open the queue',
                  body: 'Try again in a moment.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
