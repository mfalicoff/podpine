import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../core/backend/podcast_backend.dart';
import '../../core/database/app_database.dart';
import '../details/podcast_detail_screen.dart';
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
                            'Use Discover to find and subscribe to a podcast.',
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
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PodcastDetailScreen(
                                        podcast: _remotePodcast(podcast),
                                      ),
                                    ),
                                  ),
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

  static RemotePodcast _remotePodcast(PodcastRecord podcast) {
    List<String> categories;
    try {
      categories = (jsonDecode(podcast.categoriesJson) as List)
          .map((value) => '$value')
          .toList(growable: false);
    } catch (_) {
      categories = const [];
    }
    return RemotePodcast(
      id: podcast.id,
      title: podcast.title,
      author: podcast.author,
      artworkUrl: podcast.artworkUrl,
      description: podcast.description,
      feedUrl: podcast.feedUrl,
      episodeCount: podcast.episodeCount,
      websiteUrl: podcast.websiteUrl,
      categories: categories,
      explicit: podcast.explicit,
      podcastIndexId: podcast.podcastIndexId,
    );
  }
}
