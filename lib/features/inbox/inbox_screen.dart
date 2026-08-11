import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../providers.dart';
import '../shared/artwork.dart';
import '../shared/episode_tile.dart';
import 'inbox_models.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  InboxFilter _filter = InboxFilter.all;
  InboxSort _sort = InboxSort.newest;

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);
    final app = ref.watch(appControllerProvider);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: app.refresh,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 4),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inbox',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Triage new episodes before they join your queue.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Inbox settings',
                      onPressed: _editGlobalSwipeSettings,
                      icon: const Icon(Icons.swipe_rounded),
                    ),
                    PopupMenuButton<InboxSort>(
                      tooltip: 'Sort Inbox',
                      initialValue: _sort,
                      onSelected: (sort) => setState(() => _sort = sort),
                      itemBuilder: (_) => InboxSort.values
                          .map(
                            (sort) => PopupMenuItem(
                              value: sort,
                              child: Text(sort.label),
                            ),
                          )
                          .toList(),
                      icon: const Icon(Icons.sort_rounded),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: InboxFilter.values
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
                      .toList(),
                ),
              ),
            ),
            StreamBuilder<List<EpisodeRecord>>(
              stream: database.watchInbox(filter: _filter, sort: _sort),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Couldn’t open the Inbox',
                      body: 'Pull down to try again.',
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final episodes = snapshot.data!;
                if (episodes.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.inbox_outlined,
                      title: _filter == InboxFilter.all
                          ? 'Inbox zero'
                          : 'No matching episodes',
                      body: _filter == InboxFilter.all
                          ? 'New episodes will appear after your next refresh.'
                          : 'Try another filter or refresh your subscriptions.',
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: episodes.length,
                  itemBuilder: (_, index) =>
                      _buildInboxEpisode(database, episodes[index]),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  Widget _buildInboxEpisode(AppDatabase database, EpisodeRecord episode) =>
      FutureBuilder<InboxSwipePreferences>(
        future: database.resolvedInboxSwipePreferences(episode.podcastId),
        initialData: const InboxSwipePreferences(),
        builder: (context, snapshot) {
          final preferences = snapshot.data ?? const InboxSwipePreferences();
          return Dismissible(
            key: ValueKey('inbox-${episode.id}'),
            background: _SwipeBackground(
              action: preferences.right,
              alignment: Alignment.centerLeft,
            ),
            secondaryBackground: _SwipeBackground(
              action: preferences.left,
              alignment: Alignment.centerRight,
            ),
            confirmDismiss: (direction) async {
              final action = direction == DismissDirection.startToEnd
                  ? preferences.right
                  : preferences.left;
              await _performAction(episode, action);
              return action == InboxSwipeAction.remove;
            },
            child: EpisodeTile(
              episode: episode,
              onLongPress: () => _showEpisodeActions(episode),
              onRemoveFromInbox: () => _performAction(
                episode,
                InboxSwipeAction.remove,
                markRemovedAsPlayed: false,
              ),
            ),
          );
        },
      );

  Future<void> _showEpisodeActions(EpisodeRecord episode) async {
    final choice = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow_rounded),
                title: const Text('Play'),
                onTap: () => Navigator.pop(context, 'play'),
              ),
              ...InboxSwipeAction.values.map(
                (action) => ListTile(
                  leading: Icon(action.icon),
                  title: Text(action.episodeLabel(episode)),
                  onTap: () => Navigator.pop(context, action),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: Text('Swipe settings for ${episode.podcastTitle}'),
                onTap: () => Navigator.pop(context, 'podcast-settings'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'play') {
      await ref.read(playerControllerProvider).playEpisode(episode);
    } else if (choice == 'podcast-settings') {
      await _editPodcastSwipeSettings(episode);
    } else if (choice is InboxSwipeAction) {
      await _performAction(episode, choice);
    }
  }

  Future<void> _performAction(
    EpisodeRecord episode,
    InboxSwipeAction action, {
    bool? markRemovedAsPlayed,
  }) async {
    final app = ref.read(appControllerProvider);
    final wasQueued = episode.queued;
    final wasCompleted = episode.completed;
    final wasDownloaded = episode.downloaded;
    var markedPlayedOnRemove = false;
    switch (action) {
      case InboxSwipeAction.queue:
        wasQueued
            ? await app.removeFromQueue(episode)
            : await app.addToQueue(episode);
      case InboxSwipeAction.remove:
        markedPlayedOnRemove = await app.removeFromInbox(
          episode,
          markAsPlayed: markRemovedAsPlayed,
        );
      case InboxSwipeAction.togglePlayed:
        await app.setCompleted(episode, !wasCompleted);
      case InboxSwipeAction.download:
        wasDownloaded
            ? await ref.read(downloadManagerProvider).delete(episode.id)
            : await ref.read(downloadManagerProvider).start(episode);
      case InboxSwipeAction.playNext:
        await app.addToQueue(episode, next: true);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          persist: false,
          content: Text(
            action == InboxSwipeAction.remove && markedPlayedOnRemove
                ? 'Removed from Inbox and marked played'
                : action.feedbackLabel(episode),
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              switch (action) {
                case InboxSwipeAction.queue:
                  wasQueued
                      ? await app.addToQueue(episode)
                      : await app.removeFromQueue(episode);
                case InboxSwipeAction.remove:
                  await app.restoreToInbox(
                    episode,
                    restoreAsUnplayed: markedPlayedOnRemove,
                  );
                case InboxSwipeAction.togglePlayed:
                  await app.setCompleted(episode, wasCompleted);
                case InboxSwipeAction.download:
                  wasDownloaded
                      ? await ref.read(downloadManagerProvider).start(episode)
                      : await ref
                            .read(downloadManagerProvider)
                            .delete(episode.id);
                case InboxSwipeAction.playNext:
                  wasQueued
                      ? await app.addToQueue(episode)
                      : await app.removeFromQueue(episode);
              }
            },
          ),
        ),
      );
  }

  Future<void> _editGlobalSwipeSettings() async {
    final database = ref.read(databaseProvider);
    final current = await database.inboxSwipePreferences();
    if (!mounted) return;
    var left = current.left;
    var right = current.right;
    var markRemovedAsPlayed = current.markRemovedAsPlayed;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Inbox settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionDropdown(
                label: 'Swipe left',
                value: left,
                onChanged: (value) => setDialogState(() => left = value),
              ),
              const SizedBox(height: 12),
              _ActionDropdown(
                label: 'Swipe right',
                value: right,
                onChanged: (value) => setDialogState(() => right = value),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark removed episodes as played'),
                subtitle: const Text(
                  'App-wide behavior whenever Remove from Inbox is used.',
                ),
                value: markRemovedAsPlayed,
                onChanged: (value) =>
                    setDialogState(() => markRemovedAsPlayed = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      await database.setInboxSwipePreferences(
        InboxSwipePreferences(
          left: left,
          right: right,
          markRemovedAsPlayed: markRemovedAsPlayed,
        ),
      );
      if (mounted) setState(() {});
    }
  }

  Future<void> _editPodcastSwipeSettings(EpisodeRecord episode) async {
    final database = ref.read(databaseProvider);
    final current = await database.podcastInboxOverride(episode.podcastId);
    if (!mounted) return;
    var left = current.left?.name ?? 'global';
    var right = current.right?.name ?? 'global';
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${episode.podcastTitle} swipes'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OverrideDropdown(
                label: 'Swipe left',
                value: left,
                onChanged: (value) => setDialogState(() => left = value),
              ),
              const SizedBox(height: 12),
              _OverrideDropdown(
                label: 'Swipe right',
                value: right,
                onChanged: (value) => setDialogState(() => right = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      await database.setPodcastInboxOverride(
        episode.podcastId,
        PodcastInboxOverride(
          left: left == 'global' ? null : InboxSwipeAction.parse(left),
          right: right == 'global' ? null : InboxSwipeAction.parse(right),
        ),
      );
      if (mounted) setState(() {});
    }
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.action, required this.alignment});

  final InboxSwipeAction action;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => Container(
    alignment: alignment,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(
      color: action.color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(action.icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          action.label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ActionDropdown extends StatelessWidget {
  const _ActionDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final InboxSwipeAction value;
  final ValueChanged<InboxSwipeAction> onChanged;

  @override
  Widget build(BuildContext context) =>
      DropdownButtonFormField<InboxSwipeAction>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: InboxSwipeAction.values
            .map(
              (action) =>
                  DropdownMenuItem(value: action, child: Text(action.label)),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      );
}

class _OverrideDropdown extends StatelessWidget {
  const _OverrideDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: [
      const DropdownMenuItem(
        value: 'global',
        child: Text('Use global default'),
      ),
      ...InboxSwipeAction.values.map(
        (action) =>
            DropdownMenuItem(value: action.name, child: Text(action.label)),
      ),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}

extension on InboxFilter {
  String get label => switch (this) {
    InboxFilter.all => 'All',
    InboxFilter.downloaded => 'Downloaded',
  };
}

extension on InboxSort {
  String get label => switch (this) {
    InboxSort.newest => 'Newest discovered',
    InboxSort.oldest => 'Oldest discovered',
    InboxSort.podcast => 'Podcast',
  };
}

extension on InboxSwipeAction {
  String get label => switch (this) {
    InboxSwipeAction.queue => 'Queue',
    InboxSwipeAction.remove => 'Remove',
    InboxSwipeAction.togglePlayed => 'Played / unplayed',
    InboxSwipeAction.download => 'Download',
    InboxSwipeAction.playNext => 'Play next',
  };

  IconData get icon => switch (this) {
    InboxSwipeAction.queue => Icons.queue_music_rounded,
    InboxSwipeAction.remove => Icons.inbox_outlined,
    InboxSwipeAction.togglePlayed => Icons.done_all_rounded,
    InboxSwipeAction.download => Icons.download_rounded,
    InboxSwipeAction.playNext => Icons.playlist_play_rounded,
  };

  Color get color => switch (this) {
    InboxSwipeAction.remove => const Color(0xFFB54747),
    InboxSwipeAction.togglePlayed => const Color(0xFF527A68),
    InboxSwipeAction.download => const Color(0xFF476C91),
    InboxSwipeAction.queue ||
    InboxSwipeAction.playNext => const Color(0xFF315F51),
  };

  String episodeLabel(EpisodeRecord episode) => switch (this) {
    InboxSwipeAction.queue =>
      episode.queued ? 'Remove from queue' : 'Add to queue',
    InboxSwipeAction.remove => 'Remove from Inbox',
    InboxSwipeAction.togglePlayed =>
      episode.completed ? 'Mark unplayed' : 'Mark played',
    InboxSwipeAction.download =>
      episode.downloaded ? 'Delete download' : 'Download',
    InboxSwipeAction.playNext => 'Play next',
  };

  String feedbackLabel(EpisodeRecord episode) => switch (this) {
    InboxSwipeAction.queue =>
      episode.queued ? 'Removed from queue' : 'Added to queue',
    InboxSwipeAction.remove => 'Removed from Inbox',
    InboxSwipeAction.togglePlayed =>
      episode.completed ? 'Marked unplayed' : 'Marked played',
    InboxSwipeAction.download =>
      episode.downloaded ? 'Download deleted' : 'Download requested',
    InboxSwipeAction.playNext => 'Moved to play next',
  };
}
