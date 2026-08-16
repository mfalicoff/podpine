import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../core/backend/podcast_backend.dart';
import '../../core/database/app_database.dart';
import '../../core/l10n.dart';
import '../details/podcast_detail_screen.dart';
import '../downloads/download_settings_screen.dart';
import '../downloads/download_storage_screen.dart';
import '../shared/artwork.dart';
import '../shared/multi_select.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _selection = MultiSelectionController();

  @override
  Widget build(BuildContext context) {
    final podcasts = ref.watch(podcastsProvider);
    final downloads = ref.watch(downloadManagerProvider);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.library,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      if (!_selection.isActive)
                        IconButton(
                          tooltip: context.l10n.selectPodcasts,
                          onPressed: () => setState(_selection.begin),
                          icon: const Icon(Icons.checklist_rounded),
                        ),
                      IconButton(
                        tooltip: context.l10n.automaticDownloadSettings,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DownloadSettingsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.download_for_offline_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    context.l10n.subscriptionsSaved,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (downloads.isLowStorage) ...[
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber_rounded),
                        title: Text(context.l10n.lowStorage),
                        subtitle: Text(context.l10n.lowStorageBody),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const DownloadStorageScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ...podcasts.when(
            data: (items) {
              _selection.retain(items.map((podcast) => podcast.id));
              return items.isEmpty
                  ? [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.library_music_outlined,
                          title: context.l10n.noSubscriptions,
                          body: context.l10n.noSubscriptionsBody,
                        ),
                      ),
                    ]
                  : [
                      if (_selection.isActive)
                        SliverToBoxAdapter(
                          child: MultiSelectToolbar(
                            selectedCount: _selection.count,
                            totalCount: items.length,
                            onClose: () => setState(_selection.clear),
                            onSelectRange: (range) => setState(
                              () => _selection.selectRange(
                                items.map((podcast) => podcast.id).toList(),
                                range,
                              ),
                            ),
                            actions: [
                              MultiSelectAction(
                                label: context.l10n.unsubscribe,
                                icon: Icons.unsubscribe_rounded,
                                onSelected: () => _unsubscribeSelected(items),
                              ),
                            ],
                          ),
                        ),
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
                                  color: _selection.contains(podcast.id)
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.secondaryContainer
                                      : null,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onLongPress: () => setState(
                                      () => _selection.start(podcast.id),
                                    ),
                                    onTap: _selection.isActive
                                        ? () => setState(
                                            () => _selection.toggle(podcast.id),
                                          )
                                        : () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PodcastDetailScreen(
                                                    podcast: _remotePodcast(
                                                      podcast,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                    child: Stack(
                                      children: [
                                        Padding(
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
                                                    ? context.l10n.episodeCount(
                                                        podcast.episodeCount,
                                                      )
                                                    : podcast.author,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'sans-serif',
                                                  fontSize: 11,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_selection.isActive)
                                          Positioned(
                                            top: 6,
                                            right: 6,
                                            child: Checkbox(
                                              value: _selection.contains(
                                                podcast.id,
                                              ),
                                              onChanged: (_) => setState(
                                                () => _selection.toggle(
                                                  podcast.id,
                                                ),
                                              ),
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
                    ];
            },
            loading: () => const [
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (_, _) => [
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: context.l10n.libraryUnavailable,
                  body: context.l10n.libraryUnavailableBody,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _unsubscribeSelected(List<PodcastRecord> podcasts) async {
    final selected = _selection.selectedItems(
      podcasts,
      (podcast) => podcast.id,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.unsubscribeSelectedQuestion(selected.length)),
        content: Text(context.l10n.unsubscribeSelectedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.unsubscribe),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    var succeeded = 0;
    var failed = 0;
    for (final podcast in selected) {
      try {
        await ref
            .read(appControllerProvider)
            .unsubscribe(_remotePodcast(podcast));
        succeeded++;
      } catch (_) {
        failed++;
      }
    }
    if (!mounted) return;
    setState(_selection.clear);
    final failures = failed == 0 ? '' : context.l10n.bulkFailures(failed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.unsubscribedResult(succeeded, failures)),
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
