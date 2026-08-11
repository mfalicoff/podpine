import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/downloads/download_models.dart';
import '../../providers.dart';

class DownloadStorageScreen extends ConsumerStatefulWidget {
  const DownloadStorageScreen({super.key});

  @override
  ConsumerState<DownloadStorageScreen> createState() =>
      _DownloadStorageScreenState();
}

class _DownloadStorageScreenState extends ConsumerState<DownloadStorageScreen> {
  int? _podcastId;
  _PlayedFilter _played = _PlayedFilter.any;
  int? _olderThanDays;
  bool _cleaning = false;

  DownloadCleanupFilter _filter() => DownloadCleanupFilter(
    podcastId: _podcastId,
    played: _played.value,
    downloadedBefore: _olderThanDays == null
        ? null
        : DateTime.now().toUtc().subtract(Duration(days: _olderThanDays!)),
  );

  Future<void> _cleanup(DownloadStorageSnapshot snapshot) async {
    if (_cleaning) return;
    final matching = snapshot.items.where(_filter().matches).toList();
    if (matching.isEmpty) return;
    final bytes = matching.fold(0, (sum, item) => sum + item.sizeBytes);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete ${matching.length} ${matching.length == 1 ? 'download' : 'downloads'}?',
        ),
        content: Text(
          'This will free about ${formatBytes(bytes)}. Active and partial downloads are always protected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cleaning = true);
    final result = await ref
        .read(downloadManagerProvider)
        .cleanupDownloads(_filter());
    if (!mounted) return;
    setState(() => _cleaning = false);
    final skipped = result.skippedUnsafeCount == 0
        ? ''
        : ' ${result.skippedUnsafeCount} active or partial downloads were protected.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted ${result.deletedCount} and freed ${formatBytes(result.reclaimedBytes)}.$skipped',
        ),
      ),
    );
  }

  Future<void> _deleteOne(DownloadStorageItem item) async {
    await ref.read(downloadManagerProvider).delete(item.episode.id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Deleted “${item.episode.title}”.')));
  }

  @override
  Widget build(BuildContext context) {
    final manager = ref.watch(downloadManagerProvider);
    final snapshot = manager.storageSnapshot;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download storage'),
        actions: [
          IconButton(
            tooltip: 'Refresh storage',
            onPressed: manager.refreshStorageSnapshot,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: snapshot == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
              children: [
                _StorageSummary(snapshot: snapshot),
                if (snapshot.isLowStorage) ...[
                  const SizedBox(height: 12),
                  const _LowStorageWarning(),
                ],
                const SizedBox(height: 24),
                Text(
                  'By podcast',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (snapshot.podcasts.isEmpty)
                  const Text('No downloaded episodes are using storage.')
                else
                  ...snapshot.podcasts.map(
                    (podcast) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.podcasts_rounded),
                      title: Text(podcast.title),
                      subtitle: Text(
                        '${podcast.episodeCount} ${podcast.episodeCount == 1 ? 'episode' : 'episodes'}',
                      ),
                      trailing: Text(formatBytes(podcast.sizeBytes)),
                    ),
                  ),
                const Divider(height: 36),
                Text(
                  'Bulk cleanup',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  initialValue: _podcastId,
                  decoration: const InputDecoration(labelText: 'Podcast'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All podcasts'),
                    ),
                    ...snapshot.podcasts.map(
                      (podcast) => DropdownMenuItem(
                        value: podcast.podcastId,
                        child: Text(
                          podcast.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _podcastId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<_PlayedFilter>(
                  initialValue: _played,
                  decoration: const InputDecoration(labelText: 'Played state'),
                  items: _PlayedFilter.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _played = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _olderThanDays,
                  decoration: const InputDecoration(labelText: 'Download age'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Any age')),
                    DropdownMenuItem(
                      value: 7,
                      child: Text('Older than 7 days'),
                    ),
                    DropdownMenuItem(
                      value: 30,
                      child: Text('Older than 30 days'),
                    ),
                    DropdownMenuItem(
                      value: 90,
                      child: Text('Older than 90 days'),
                    ),
                    DropdownMenuItem(
                      value: 365,
                      child: Text('Older than 1 year'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _olderThanDays = value),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final matches = snapshot.items
                        .where(_filter().matches)
                        .length;
                    return FilledButton.icon(
                      onPressed: matches == 0 || _cleaning
                          ? null
                          : () => _cleanup(snapshot),
                      icon: _cleaning
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_sweep_outlined),
                      label: Text('Delete $matches matching downloads'),
                    );
                  },
                ),
                const Divider(height: 42),
                Text(
                  'Downloaded episodes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (snapshot.items.isEmpty)
                  const Text('Downloaded episodes will appear here.')
                else
                  ...snapshot.items.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.episode.title),
                      subtitle: Text(
                        '${item.episode.podcastTitle} · ${formatBytes(item.sizeBytes)} · ${DateFormat.yMMMd().format(item.downloadedAt.toLocal())}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Delete download',
                        onPressed: () => _deleteOne(item),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _StorageSummary extends StatelessWidget {
  const _StorageSummary({required this.snapshot});

  final DownloadStorageSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.storage_rounded, size: 34),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatBytes(snapshot.totalBytes),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${snapshot.items.length} downloaded ${snapshot.items.length == 1 ? 'episode' : 'episodes'}',
                ),
                if (snapshot.availableBytes != null)
                  Text(
                    '${formatBytes(snapshot.availableBytes!)} free on device',
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _LowStorageWarning extends StatelessWidget {
  const _LowStorageWarning();

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: Theme.of(context).colorScheme.errorContainer,
    child: const ListTile(
      leading: Icon(Icons.warning_amber_rounded),
      title: Text('Device storage is low'),
      subtitle: Text(
        'Free space is below your download reserve. Clean up media before starting another download.',
      ),
    ),
  );
}

enum _PlayedFilter {
  any('Played or unplayed', null),
  played('Played only', true),
  unplayed('Unplayed only', false);

  const _PlayedFilter(this.label, this.value);

  final String label;
  final bool? value;
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final digits = value >= 10 ? 0 : 1;
  return '${value.toStringAsFixed(digits)} ${units[unit]}';
}
