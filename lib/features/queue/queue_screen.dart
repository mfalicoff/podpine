import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
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
            data: (items) {
              if (!_reorderPending) _visibleItems = items;
              final visibleItems = _visibleItems;
              _selection.retain(visibleItems.map((episode) => episode.id));
              return visibleItems.isEmpty
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
                                    .playEpisode(visibleItems.first),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Play queue'),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _confirmClear,
                                tooltip: 'Clear queue',
                                icon: const Icon(Icons.clear_all_rounded),
                              ),
                              if (!_selection.isActive)
                                IconButton(
                                  onPressed: () => setState(_selection.begin),
                                  tooltip: 'Select episodes',
                                  icon: const Icon(Icons.checklist_rounded),
                                ),
                              const Spacer(),
                              Text(
                                '${visibleItems.length} episode${visibleItems.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  fontFamily: 'sans-serif',
                                  color: Colors.black45,
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
                                        style: const TextStyle(
                                          fontFamily: 'sans-serif',
                                          color: Colors.black38,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.drag_handle_rounded,
                                        size: 18,
                                        color: Colors.black38,
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
            label: action.label,
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(bulkActionMessage(action, result))));
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
        title: const Text('Clear queue?'),
        content: const Text(
          'This removes every queued episode on all connected devices. '
          'Anything already playing will keep playing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear queue'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(appControllerProvider).clearQueue();
    }
  }
}
