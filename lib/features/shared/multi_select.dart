import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/l10n.dart';
import '../../providers.dart';

class MultiSelectionController {
  final Set<int> _selectedIds = <int>{};
  int? _anchorId;
  bool _active = false;

  Set<int> get selectedIds => Set<int>.unmodifiable(_selectedIds);
  int get count => _selectedIds.length;
  bool get isActive => _active;

  bool contains(int id) => _selectedIds.contains(id);

  void begin() => _active = true;

  void start(int id) {
    _active = true;
    _selectedIds
      ..clear()
      ..add(id);
    _anchorId = id;
  }

  void toggle(int id) {
    if (!_selectedIds.remove(id)) {
      _selectedIds.add(id);
    }
    _anchorId = id;
    if (_selectedIds.isEmpty) _anchorId = null;
  }

  void clear() {
    _selectedIds.clear();
    _anchorId = null;
    _active = false;
  }

  void retain(Iterable<int> availableIds) {
    final available = availableIds.toSet();
    _selectedIds.removeWhere((id) => !available.contains(id));
    if (_anchorId != null && !available.contains(_anchorId)) {
      _anchorId = _selectedIds.firstOrNull;
    }
  }

  void selectRange(List<int> orderedIds, SelectionRange range) {
    if (orderedIds.isEmpty) return;
    final anchorIndex = _anchorId == null ? -1 : orderedIds.indexOf(_anchorId!);
    final ids = switch (range) {
      SelectionRange.all => orderedIds,
      SelectionRange.above =>
        anchorIndex < 0
            ? const <int>[]
            : orderedIds.sublist(0, anchorIndex + 1),
      SelectionRange.below =>
        anchorIndex < 0 ? const <int>[] : orderedIds.sublist(anchorIndex),
    };
    _selectedIds.addAll(ids);
  }

  List<T> selectedItems<T>(Iterable<T> items, int Function(T item) idOf) =>
      items.where((item) => _selectedIds.contains(idOf(item))).toList();
}

enum SelectionRange { all, above, below }

class MultiSelectAction {
  const MultiSelectAction({
    required this.label,
    required this.icon,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onSelected;
}

class MultiSelectToolbar extends StatelessWidget {
  const MultiSelectToolbar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onClose,
    required this.onSelectRange,
    required this.actions,
  });

  final int selectedCount;
  final int totalCount;
  final VoidCallback onClose;
  final ValueChanged<SelectionRange> onSelectRange;
  final List<MultiSelectAction> actions;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: context.l10n.exitSelection,
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Text(
              context.l10n.selectedCount(selectedCount, totalCount),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          PopupMenuButton<SelectionRange>(
            tooltip: context.l10n.expandSelection,
            onSelected: onSelectRange,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: SelectionRange.all,
                child: Text(context.l10n.selectAll),
              ),
              PopupMenuItem(
                value: SelectionRange.above,
                enabled: selectedCount > 0,
                child: Text(context.l10n.selectAllAbove),
              ),
              PopupMenuItem(
                value: SelectionRange.below,
                enabled: selectedCount > 0,
                child: Text(context.l10n.selectAllBelow),
              ),
            ],
            icon: const Icon(Icons.select_all_rounded),
          ),
          PopupMenuButton<MultiSelectAction>(
            tooltip: context.l10n.selectedActions,
            enabled: selectedCount > 0 && actions.isNotEmpty,
            onSelected: (action) => action.onSelected(),
            itemBuilder: (_) => actions
                .map(
                  (action) => PopupMenuItem(
                    value: action,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(action.icon),
                      title: Text(action.label),
                    ),
                  ),
                )
                .toList(growable: false),
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    ),
  );
}

enum EpisodeBulkAction {
  markPlayed(Icons.check_circle_outline_rounded),
  markUnplayed(Icons.radio_button_unchecked_rounded),
  addToQueue(Icons.playlist_add_rounded),
  removeFromQueue(Icons.playlist_remove_rounded),
  deleteDownloads(Icons.delete_outline_rounded),
  removeFromInbox(Icons.inbox_outlined);

  const EpisodeBulkAction(this.icon);

  final IconData icon;

  String label(BuildContext context) => switch (this) {
    EpisodeBulkAction.markPlayed => context.l10n.markPlayed,
    EpisodeBulkAction.markUnplayed => context.l10n.markUnplayed,
    EpisodeBulkAction.addToQueue => context.l10n.addToQueue,
    EpisodeBulkAction.removeFromQueue => context.l10n.removeFromQueue,
    EpisodeBulkAction.deleteDownloads => context.l10n.deleteFromDevice,
    EpisodeBulkAction.removeFromInbox => context.l10n.removeFromInbox,
  };
}

class BulkActionResult {
  const BulkActionResult({required this.succeeded, required this.failed});

  final int succeeded;
  final int failed;
}

Future<BulkActionResult> performEpisodeBulkAction(
  WidgetRef ref,
  Iterable<EpisodeRecord> episodes,
  EpisodeBulkAction action,
) async {
  final app = ref.read(appControllerProvider);
  var succeeded = 0;
  var failed = 0;
  for (final episode in episodes) {
    try {
      switch (action) {
        case EpisodeBulkAction.markPlayed:
          await app.setCompleted(episode, true);
        case EpisodeBulkAction.markUnplayed:
          await app.setCompleted(episode, false);
        case EpisodeBulkAction.addToQueue:
          if (!episode.queued) await app.addToQueue(episode);
        case EpisodeBulkAction.removeFromQueue:
          if (episode.queued) await app.removeFromQueue(episode);
        case EpisodeBulkAction.deleteDownloads:
          await ref.read(downloadManagerProvider).delete(episode.id);
        case EpisodeBulkAction.removeFromInbox:
          await app.removeFromInbox(episode);
      }
      succeeded++;
    } catch (_) {
      failed++;
    }
  }
  return BulkActionResult(succeeded: succeeded, failed: failed);
}

String bulkActionMessage(
  BuildContext context,
  EpisodeBulkAction action,
  BulkActionResult result,
) {
  final failure = result.failed == 0
      ? ''
      : context.l10n.bulkFailures(result.failed);
  return context.l10n.bulkActionResult(
    action.label(context),
    result.succeeded,
    failure,
  );
}
