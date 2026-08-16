import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_controller.dart';
import '../../core/backend/podcast_backend.dart';
import '../../core/database/app_database.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../providers.dart';
import '../details/podcast_detail_screen.dart';
import '../developer/background_sync_status_screen.dart';
import '../shared/artwork.dart';
import '../shared/episode_tile.dart';
import '../shared/multi_select.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _EpisodeFilter _filter = _EpisodeFilter.all;
  final _selection = MultiSelectionController();

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
              error: (_, _) => [
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: context.l10n.libraryUnavailable,
                    body: context.l10n.pullToRetry,
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
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.podcasts_rounded,
            title: context.l10n.libraryReady,
            body: context.l10n.discoverFirstSubscription,
          ),
        ),
      ];
    }
    final inProgress = episodes
        .where((e) => !e.completed && e.positionSeconds > 0)
        .firstOrNull;
    final filtered = episodes.where(_filter.matches).toList();
    _selection.retain(filtered.map((episode) => episode.id));
    return [
      if (inProgress != null) ...[
        SliverToBoxAdapter(
          child: SectionHeading(context.l10n.continueListening),
        ),
        SliverToBoxAdapter(child: _ContinueCard(episode: inProgress)),
      ],
      SliverToBoxAdapter(
        child: SectionHeading(
          context.l10n.allEpisodes,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_selection.isActive)
                IconButton(
                  tooltip: context.l10n.selectEpisodes,
                  onPressed: () => setState(_selection.begin),
                  icon: const Icon(Icons.checklist_rounded),
                ),
              TextButton.icon(
                onPressed: () => ref.read(appControllerProvider).refresh(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(context.l10n.refresh),
              ),
            ],
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
                      label: Text(filter.label(context)),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
      if (_selection.isActive)
        SliverToBoxAdapter(
          child: MultiSelectToolbar(
            selectedCount: _selection.count,
            totalCount: filtered.length,
            onClose: () => setState(_selection.clear),
            onSelectRange: (range) => setState(
              () => _selection.selectRange(
                filtered.map((episode) => episode.id).toList(),
                range,
              ),
            ),
            actions: _episodeActions(context, filtered),
          ),
        ),
      if (filtered.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: context.l10n.noMatchingEpisodes,
              body: context.l10n.chooseAnotherFilter,
            ),
          ),
        )
      else
        SliverList.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final episode = filtered[index];
            return EpisodeTile(
              episode: episode,
              selectionMode: _selection.isActive,
              selected: _selection.contains(episode.id),
              onLongPress: () => setState(() => _selection.start(episode.id)),
              onSelected: () => setState(() => _selection.toggle(episode.id)),
            );
          },
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 28)),
    ];
  }

  List<MultiSelectAction> _episodeActions(
    BuildContext context,
    List<EpisodeRecord> episodes,
  ) => EpisodeBulkAction.values
      .where((action) => action != EpisodeBulkAction.removeFromInbox)
      .map(
        (action) => MultiSelectAction(
          label: action.label(context),
          icon: action.icon,
          onSelected: () => _runAction(episodes, action),
        ),
      )
      .toList(growable: false);

  Future<void> _runAction(
    List<EpisodeRecord> episodes,
    EpisodeBulkAction action,
  ) async {
    final selected = _selection.selectedItems(
      episodes,
      (episode) => episode.id,
    );
    final result = await performEpisodeBulkAction(ref, selected, action);
    if (!mounted) return;
    setState(_selection.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(bulkActionMessage(context, action, result))),
    );
  }
}

enum _EpisodeFilter {
  all,
  unplayed,
  played,
  downloaded,
  queued;

  String label(BuildContext context) => switch (this) {
    _EpisodeFilter.all => context.l10n.filterAll,
    _EpisodeFilter.unplayed => context.l10n.filterUnplayed,
    _EpisodeFilter.played => context.l10n.filterPlayed,
    _EpisodeFilter.downloaded => context.l10n.filterDownloaded,
    _EpisodeFilter.queued => context.l10n.filterQueued,
  };

  bool matches(EpisodeRecord episode) => switch (this) {
    _EpisodeFilter.all => true,
    _EpisodeFilter.unplayed => !episode.completed,
    _EpisodeFilter.played => episode.completed,
    _EpisodeFilter.downloaded => episode.downloaded,
    _EpisodeFilter.queued => episode.queued,
  };
}

class _Header extends ConsumerWidget {
  const _Header({required this.app});
  final AppController app;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 14, 0),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.appName.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.l10n.goodListening,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (app.error != null) ...[
                const SizedBox(height: 4),
                Text(
                  app.error!,
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.error,
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
            } else if (value == 'theme') {
              _showThemeDialog(context, ref);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              enabled: false,
              child: Text(app.serverUrl ?? 'Pinepods'),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'theme',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.contrast_rounded),
                title: Text(context.l10n.theme),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'background-sync',
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: const Icon(Icons.developer_mode_rounded),
                title: Text(context.l10n.backgroundSyncStatus),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'disconnect',
              child: Text(
                app.demoMode
                    ? context.l10n.leaveDemo
                    : context.l10n.disconnectServer,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _showThemeDialog(BuildContext context, WidgetRef ref) async {
    final preferences = ref.read(appPreferencesProvider);
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(dialogContext.l10n.themeDialogTitle),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: preferences.themeMode,
            onChanged: (value) => Navigator.pop(dialogContext, value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: mode,
                    title: Text(switch (mode) {
                      ThemeMode.system => dialogContext.l10n.themeSystem,
                      ThemeMode.light => dialogContext.l10n.themeLight,
                      ThemeMode.dark => dialogContext.l10n.themeDark,
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null) await preferences.setThemeMode(selected);
  }
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
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
                tooltip: context.l10n.play,
                icon: const Icon(Icons.play_arrow_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
