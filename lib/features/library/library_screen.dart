import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../shared/artwork.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcasts = ref.watch(podcastsProvider);
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
                    'Library',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Your subscriptions, saved on this device.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          ...podcasts.when(
            data: (items) => items.isEmpty
                ? const [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.library_music_outlined,
                        title: 'No subscriptions yet',
                        body:
                            'Add a podcast in Pinepods, then refresh your library.',
                      ),
                    ),
                  ]
                : [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.crossAxisExtent;
                          final columns = width >= 900
                              ? 5
                              : width >= 600
                              ? 4
                              : 2;
                          return SliverGrid.builder(
                            itemCount: items.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisExtent: 218,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                            itemBuilder: (context, index) {
                              final podcast = items[index];
                              return Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (_, size) => Artwork(
                                            id: podcast.id,
                                            title: podcast.title,
                                            url: podcast.artworkUrl,
                                            size: size.maxWidth,
                                            radius: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 11),
                                      Text(
                                        podcast.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        podcast.author.isEmpty
                                            ? '${podcast.episodeCount} episodes'
                                            : podcast.author,
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
                              );
                            },
                          );
                        },
                      ),
                    ),
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
                  title: 'Couldn’t open the library',
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
