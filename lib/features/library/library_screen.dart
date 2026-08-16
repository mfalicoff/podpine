import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backend/podcast_backend.dart';
import '../../core/database/app_database.dart';
import '../../core/l10n.dart';
import '../../providers.dart';
import '../details/podcast_detail_screen.dart';
import '../downloads/download_settings_screen.dart';
import '../downloads/download_storage_screen.dart';
import '../shared/artwork.dart';
import '../shared/multi_select.dart';
import 'library_models.dart';

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
    final preferences =
        ref.watch(libraryPreferencesProvider).valueOrNull ??
        const LibraryPreferences();
    final folders =
        ref.watch(libraryFoldersProvider).valueOrNull ??
        const <LibraryFolderRecord>[];
    final folderAssignments =
        ref.watch(libraryFolderAssignmentsProvider).valueOrNull ??
        const <int, int>{};
    final unplayedCounts =
        ref.watch(podcastUnplayedCountsProvider).valueOrNull ??
        const <int, int>{};

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
                      if (!_selection.isActive) ...[
                        IconButton(
                          tooltip: 'Customize library',
                          onPressed: _openLibrarySettings,
                          icon: const Icon(Icons.tune_rounded),
                        ),
                        IconButton(
                          tooltip: context.l10n.selectPodcasts,
                          onPressed: () => setState(_selection.begin),
                          icon: const Icon(Icons.checklist_rounded),
                        ),
                      ],
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
            data: (items) => _libraryContent(
              items,
              preferences: preferences,
              folders: folders,
              folderAssignments: folderAssignments,
              unplayedCounts: unplayedCounts,
            ),
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

  List<Widget> _libraryContent(
    List<PodcastRecord> items, {
    required LibraryPreferences preferences,
    required List<LibraryFolderRecord> folders,
    required Map<int, int> folderAssignments,
    required Map<int, int> unplayedCounts,
  }) {
    _selection.retain(items.map((podcast) => podcast.id));
    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.library_music_outlined,
            title: context.l10n.noSubscriptions,
            body: context.l10n.noSubscriptionsBody,
          ),
        ),
      ];
    }

    final validFolderIds = folders.map((folder) => folder.id).toSet();
    final groups = <_LibraryGroup>[
      for (final folder in folders)
        _LibraryGroup(
          title: folder.name,
          podcasts: items
              .where((podcast) => folderAssignments[podcast.id] == folder.id)
              .toList(growable: false),
        ),
      _LibraryGroup(
        title: folders.isEmpty ? null : 'Unfiled',
        podcasts: items
            .where(
              (podcast) =>
                  !validFolderIds.contains(folderAssignments[podcast.id]),
            )
            .toList(growable: false),
      ),
    ].where((group) => group.podcasts.isNotEmpty).toList(growable: false);

    return [
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
      for (final group in groups) ...[
        if (group.title != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.folder_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.title!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    '${group.podcasts.length}',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              const spacing = 14.0;
              final columns = _columnCount(
                constraints.crossAxisExtent,
                preferences.artworkSize,
              );
              final cardWidth =
                  (constraints.crossAxisExtent - spacing * (columns - 1)) /
                  columns;
              return SliverGrid.builder(
                itemCount: group.podcasts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: cardWidth + 72,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemBuilder: (context, index) {
                  final podcast = group.podcasts[index];
                  return _PodcastCard(
                    podcast: podcast,
                    unplayedCount: unplayedCounts[podcast.id] ?? 0,
                    selected: _selection.contains(podcast.id),
                    selectionMode: _selection.isActive,
                    onLongPress: () =>
                        setState(() => _selection.start(podcast.id)),
                    onTap: _selection.isActive
                        ? () => setState(() => _selection.toggle(podcast.id))
                        : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PodcastDetailScreen(
                                podcast: _remotePodcast(podcast),
                              ),
                            ),
                          ),
                    onOrganize: () => _movePodcast(podcast, folders),
                    onToggleSelection: () =>
                        setState(() => _selection.toggle(podcast.id)),
                  );
                },
              );
            },
          ),
        ),
      ],
    ];
  }

  static int _columnCount(double width, LibraryArtworkSize artworkSize) =>
      switch (artworkSize) {
        LibraryArtworkSize.small =>
          width >= 900
              ? 7
              : width >= 600
              ? 5
              : 3,
        LibraryArtworkSize.medium =>
          width >= 900
              ? 5
              : width >= 600
              ? 4
              : 2,
        LibraryArtworkSize.large =>
          width >= 900
              ? 4
              : width >= 600
              ? 2
              : 1,
      };

  void _openLibrarySettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _LibrarySettingsSheet(),
    );
  }

  Future<void> _movePodcast(
    PodcastRecord podcast,
    List<LibraryFolderRecord> folders,
  ) async {
    final currentFolder = ref
        .read(libraryFolderAssignmentsProvider)
        .valueOrNull?[podcast.id];
    final choice = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move ${podcast.title}'),
        contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        content: SizedBox(
          width: 360,
          height: ((folders.length + 1) * 56.0 + (folders.isEmpty ? 72 : 0))
              .clamp(120, 360)
              .toDouble(),
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: const Text('Unfiled'),
                trailing: currentFolder == null
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, -1),
              ),
              for (final folder in folders)
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(folder.name),
                  trailing: currentFolder == folder.id
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.pop(context, folder.id),
                ),
              if (folders.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(
                    'Create folders from Customize library first.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (choice == null) return;
    await ref
        .read(databaseProvider)
        .movePodcastToLibraryFolder(podcast.id, choice == -1 ? null : choice);
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

class _PodcastCard extends StatelessWidget {
  const _PodcastCard({
    required this.podcast,
    required this.unplayedCount,
    required this.selected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onOrganize,
    required this.onToggleSelection,
  });

  final PodcastRecord podcast;
  final int unplayedCount;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onOrganize;
  final VoidCallback onToggleSelection;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: selected ? Theme.of(context).colorScheme.secondaryContainer : null,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onLongPress: onLongPress,
      onTap: onTap,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  podcast.author.isEmpty
                      ? context.l10n.episodeCount(podcast.episodeCount)
                      : podcast.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (unplayedCount > 0)
            Positioned(
              top: 8,
              left: 8,
              child: Semantics(
                container: true,
                excludeSemantics: true,
                label:
                    '$unplayedCount unplayed ${unplayedCount == 1 ? 'episode' : 'episodes'}',
                child: Badge(
                  largeSize: 22,
                  label: Text(unplayedCount > 99 ? '99+' : '$unplayedCount'),
                ),
              ),
            ),
          if (selectionMode)
            Positioned(
              top: 4,
              right: 4,
              child: Checkbox(
                value: selected,
                onChanged: (_) => onToggleSelection(),
              ),
            )
          else
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.white.withValues(alpha: .9),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Organize ${podcast.title}',
                  visualDensity: VisualDensity.compact,
                  iconSize: 19,
                  onPressed: onOrganize,
                  icon: const Icon(Icons.drive_file_move_outline),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _LibrarySettingsSheet extends ConsumerWidget {
  const _LibrarySettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences =
        ref.watch(libraryPreferencesProvider).valueOrNull ??
        const LibraryPreferences();
    final folders =
        ref.watch(libraryFoldersProvider).valueOrNull ??
        const <LibraryFolderRecord>[];
    final database = ref.read(databaseProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Customize library',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Artwork size',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<LibraryArtworkSize>(
                segments: [
                  for (final size in LibraryArtworkSize.values)
                    ButtonSegment(value: size, label: Text(size.label)),
                ],
                selected: {preferences.artworkSize},
                onSelectionChanged: (selection) =>
                    database.setLibraryArtworkSize(selection.single),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Folders',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _createFolder(context, database),
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('New folder'),
                ),
              ],
            ),
            if (folders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Create a folder, then use the folder button on a podcast to move it.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              for (final folder in folders)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(folder.name),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Rename ${folder.name}',
                        onPressed: () =>
                            _renameFolder(context, database, folder),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete ${folder.name}',
                        onPressed: () =>
                            _deleteFolder(context, database, folder),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  static Future<void> _createFolder(
    BuildContext context,
    AppDatabase database,
  ) async {
    final name = await _folderNameDialog(context, title: 'New folder');
    if (name == null) return;
    try {
      await database.createLibraryFolder(name);
    } on ArgumentError catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${error.message}')));
    }
  }

  static Future<void> _renameFolder(
    BuildContext context,
    AppDatabase database,
    LibraryFolderRecord folder,
  ) async {
    final name = await _folderNameDialog(
      context,
      title: 'Rename folder',
      initialValue: folder.name,
    );
    if (name == null) return;
    try {
      await database.renameLibraryFolder(folder.id, name);
    } on ArgumentError catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${error.message}')));
    }
  }

  static Future<void> _deleteFolder(
    BuildContext context,
    AppDatabase database,
    LibraryFolderRecord folder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${folder.name}?'),
        content: const Text(
          'Podcasts in this folder will move back to Unfiled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await database.deleteLibraryFolder(folder.id);
  }

  static Future<String?> _folderNameDialog(
    BuildContext context, {
    required String title,
    String initialValue = '',
  }) async {
    var value = initialValue;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextFormField(
          initialValue: initialValue,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Folder name'),
          onChanged: (updated) => value = updated,
          onFieldSubmitted: (submitted) {
            if (submitted.trim().isNotEmpty) {
              Navigator.pop(context, submitted.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final normalized = value.trim();
              if (normalized.isNotEmpty) Navigator.pop(context, normalized);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _LibraryGroup {
  const _LibraryGroup({required this.title, required this.podcasts});

  final String? title;
  final List<PodcastRecord> podcasts;
}
