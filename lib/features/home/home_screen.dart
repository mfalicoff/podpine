import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_controller.dart';
import '../../core/database/app_database.dart';
import '../../core/theme.dart';
import '../../providers.dart';
import '../developer/background_sync_status_screen.dart';
import '../shared/artwork.dart';
import '../shared/episode_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _EpisodeFilter _filter = _EpisodeFilter.all;

  @override
  Widget build(BuildContext context) {
    final episodes = ref.watch(episodesProvider);
    final app = ref.watch(appControllerProvider);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => app.refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(app: app)),
            ...episodes.when(
              data: (items) => _content(context, ref, items),
              loading: () => [
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (_, _) => const [
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Library unavailable',
                    body: 'Pull down to try loading it again.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    List<EpisodeRecord> episodes,
  ) {
    if (episodes.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.podcasts_rounded,
            title: 'Your library is ready',
            body: 'Use Discover to add your first subscription.',
          ),
        ),
      ];
    }
    final inProgress = episodes
        .where((e) => !e.completed && e.positionSeconds > 0)
        .firstOrNull;
    final filtered = episodes.where(_filter.matches).toList();
    return [
      if (inProgress != null) ...[
        const SliverToBoxAdapter(child: SectionHeading('Continue listening')),
        SliverToBoxAdapter(child: _ContinueCard(episode: inProgress)),
      ],
      SliverToBoxAdapter(
        child: SectionHeading(
          'All episodes',
          trailing: TextButton.icon(
            onPressed: () => ref.read(appControllerProvider).refresh(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: _EpisodeFilter.values
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter.label),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
      if (filtered.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: 'No matching episodes',
              body: 'Choose another filter or refresh your subscriptions.',
            ),
          ),
        )
      else
        SliverList.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) =>
              EpisodeTile(episode: filtered[index]),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 28)),
    ];
  }
}

enum _EpisodeFilter {
  all('All'),
  unplayed('Unplayed'),
  played('Played'),
  downloaded('Downloaded'),
  queued('Queued');

  const _EpisodeFilter(this.label);

  final String label;

  bool matches(EpisodeRecord episode) => switch (this) {
    _EpisodeFilter.all => true,
    _EpisodeFilter.unplayed => !episode.completed,
    _EpisodeFilter.played => episode.completed,
    _EpisodeFilter.downloaded => episode.downloaded,
    _EpisodeFilter.queued => episode.queued,
  };
}

class _Header extends StatelessWidget {
  const _Header({required this.app});
  final AppController app;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 14, 0),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PODPINE',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                  color: PodpineTheme.fern,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Good listening.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (app.error != null) ...[
                const SizedBox(height: 4),
                Text(
                  app.error!,
                  style: const TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
              ],
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const CircleAvatar(
            backgroundColor: Color(0xFFDDE7E0),
            child: Icon(Icons.person_outline_rounded, color: PodpineTheme.pine),
          ),
          onSelected: (value) {
            if (value == 'background-sync') {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BackgroundSyncStatusScreen(),
                ),
              );
            } else if (value == 'disconnect') {
              app.disconnect();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              enabled: false,
              child: Text(app.serverUrl ?? 'Pinepods'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'background-sync',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.developer_mode_rounded),
                title: Text('Background sync status'),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'disconnect',
              child: Text(app.demoMode ? 'Leave demo' : 'Disconnect server'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({required this.episode});
  final EpisodeRecord episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = episode.durationSeconds == 0
        ? 0.0
        : episode.positionSeconds / episode.durationSeconds;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: PodpineTheme.pine,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Artwork(
              id: episode.podcastId,
              title: episode.podcastTitle,
              url: episode.artworkUrl,
              size: 86,
              radius: 18,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.podcastTitle.toUpperCase(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 10,
                      letterSpacing: 1,
                      color: Colors.white60,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    episode.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    minHeight: 3,
                    color: const Color(0xFFF3C969),
                    backgroundColor: Colors.white24,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF3C969),
                foregroundColor: PodpineTheme.pine,
              ),
              onPressed: () =>
                  ref.read(playerControllerProvider).playEpisode(episode),
              icon: const Icon(Icons.play_arrow_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
