import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/l10n.dart';
import '../../providers.dart';
import '../shared/artwork.dart';
import '../shared/episode_tile.dart';
import '../shared/multi_select.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  List<EpisodeRecord> _visibleItems = const <EpisodeRecord>[];
  bool _reorderPending = false;
  final _selection = MultiSelectionController();

  @override
  Widget build(BuildContext context) {
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
                    context.l10n.upNext,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    context.l10n.queueFollowsDevices,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...queue.when(
            data: (items) {
              if (!_reorderPending) _visibleItems = items;
              final visibleItems = _visibleItems;
              _selection.retain(visibleItems.map((episode) => episode.id));
              return visibleItems.isEmpty
                  ? [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.queue_music_rounded,
                          title: context.l10n.nothingQueued,
                          body: context.l10n.queueEmptyBody,
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
                                    .playEpisode(visibleItems.first),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: Text(context.l10n.playQueue),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _confirmClear,
                                tooltip: context.l10n.clearQueue,
                                icon: const Icon(Icons.clear_all_rounded),
                              ),
                              if (!_selection.isActive)
                                IconButton(
                                  onPressed: () => setState(_selection.begin),
                                  tooltip: context.l10n.selectEpisodes,
                                  icon: const Icon(Icons.checklist_rounded),
                                ),
                              const Spacer(),
                              Text(
                                context.l10n.episodeCount(visibleItems.length),
                                style: TextStyle(
                                  fontFamily: 'sans-serif',
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_selection.isActive)
                        SliverToBoxAdapter(
                          child: MultiSelectToolbar(
                            selectedCount: _selection.count,
                            totalCount: visibleItems.length,
                            onClose: () => setState(_selection.clear),
                            onSelectRange: (range) => setState(
                              () => _selection.selectRange(
                                visibleItems
                                    .map((episode) => episode.id)
                                    .toList(),
                                range,
                              ),
                            ),
                            actions: _episodeActions(visibleItems),
                          ),
                        ),
                      SliverReorderableList(
                        itemCount: visibleItems.length,
                        onReorderItem: _reorder,
                        itemBuilder: (_, index) => Material(
                          key: ValueKey(visibleItems[index].id),
                          type: MaterialType.transparency,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ReorderableDragStartListener(
                                index: index,
                                enabled: !_selection.isActive,
                                child: SizedBox(
                                  width: 44,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontFamily: 'sans-serif',
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Icon(
                                        Icons.drag_handle_rounded,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: EpisodeTile(
                                  episode: visibleItems[index],
                                  compact: true,
                                  selectionMode: _selection.isActive,
                                  selected: _selection.contains(
                                    visibleItems[index].id,
                                  ),
                                  onLongPress: () => setState(
                                    () => _selection.start(
                                      visibleItems[index].id,
                                    ),
                                  ),
                                  onSelected: () => setState(
                                    () => _selection.toggle(
                                      visibleItems[index].id,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
                  title: context.l10n.queueUnavailable,
                  body: context.l10n.queueUnavailableBody,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<MultiSelectAction> _episodeActions(List<EpisodeRecord> episodes) {
    const actions = [
      EpisodeBulkAction.markPlayed,
      EpisodeBulkAction.markUnplayed,
      EpisodeBulkAction.removeFromQueue,
      EpisodeBulkAction.deleteDownloads,
    ];
    return actions
        .map(
          (action) => MultiSelectAction(
            label: action.label(context),
            icon: action.icon,
            onSelected: () => _runAction(episodes, action),
          ),
        )
        .toList(growable: false);
  }

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

  Future<void> _reorder(int oldIndex, int newIndex) async {
    setState(() {
      final reordered = List<EpisodeRecord>.of(_visibleItems);
      final episode = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, episode);
      _visibleItems = reordered;
      _reorderPending = true;
    });
    try {
      await ref.read(appControllerProvider).reorderQueue(_visibleItems);
    } finally {
      if (mounted) setState(() => _reorderPending = false);
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.clearQueueQuestion),
        content: Text(context.l10n.clearQueueBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.clearQueue),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(appControllerProvider).clearQueue();
    }
  }
}
