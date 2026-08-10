import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../shared/artwork.dart';
import '../shared/episode_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final episodes = ref.watch(episodesProvider).valueOrNull ?? [];
    final filtered = query.trim().isEmpty
        ? const <dynamic>[]
        : episodes.where((episode) {
            final needle = query.toLowerCase();
            return episode.title.toLowerCase().contains(needle) ||
                episode.podcastTitle.toLowerCase().contains(needle);
          }).toList();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              'Search',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: false,
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                hintText: 'Search your saved library',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: query.trim().isEmpty
                ? const EmptyState(
                    icon: Icons.travel_explore_rounded,
                    title: 'Find something worth hearing',
                    body:
                        'Search episodes and podcasts already saved on this device.',
                  )
                : filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No saved matches',
                    body:
                        'Discovery search against Pinepods is next on the implementation roadmap.',
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, index) =>
                        EpisodeTile(episode: filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
