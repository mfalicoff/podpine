import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_controller.dart';
import '../../core/backend/podcast_backend.dart';
import '../../core/database/app_database.dart';
import '../../core/downloads/download_models.dart';
import '../../core/downloads/download_actions.dart';
import '../../core/metadata_sanitizer.dart';
import '../../providers.dart';
import '../shared/artwork.dart';
import '../shared/multi_select.dart';
import '../downloads/download_settings_screen.dart';

class PodcastDetailScreen extends ConsumerStatefulWidget {
  const PodcastDetailScreen({super.key, required this.podcast});

  final RemotePodcast podcast;

  @override
  ConsumerState<PodcastDetailScreen> createState() =>
      _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends ConsumerState<PodcastDetailScreen> {
  PodcastDetailBundle? _bundle;
  bool _refreshing = false;
  bool _changingSubscription = false;
  String? _error;
  final _selection = MultiSelectionController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final app = ref.read(appControllerProvider);
    final cached = await app.cachedPodcastDetails(widget.podcast);
    if (!mounted) return;
    setState(() => _bundle = cached);
    await _refresh();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      final refreshed = await ref
          .read(appControllerProvider)
          .refreshPodcastDetails(_bundle?.podcast ?? widget.podcast);
      if (mounted) setState(() => _bundle = refreshed);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = _bundle == null || _bundle!.episodes.isEmpty
              ? 'Podcast details are unavailable while offline.'
              : 'Offline — showing saved details.';
        });
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _toggleSubscription() async {
    final bundle = _bundle;
    if (bundle == null || _changingSubscription) return;
    if (bundle.subscribed) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsubscribe?'),
          content: Text(
            'Remove ${MetadataSanitizer.plainText(bundle.podcast.title)} and its locally cached episodes from your library?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Unsubscribe'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() => _changingSubscription = true);
    try {
      final app = ref.read(appControllerProvider);
      bundle.subscribed
          ? await app.unsubscribe(bundle.podcast)
          : await app.subscribe(bundle.podcast);
      final updated = await app.cachedPodcastDetails(bundle.podcast);
      if (mounted) setState(() => _bundle = updated);
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(exception.toString())));
      }
    } finally {
      if (mounted) setState(() => _changingSubscription = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bundle = _bundle;
    final podcast = bundle?.podcast ?? widget.podcast;
    final localEpisodes =
        bundle?.episodes
            .map((episode) => bundle.localEpisodes[episode.id])
            .whereType<EpisodeRecord>()
            .toList(growable: false) ??
        const <EpisodeRecord>[];
    _selection.retain(localEpisodes.map((episode) => episode.id));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podcast'),
        actions: [
          IconButton(
            tooltip: 'Podcast download settings',
            onPressed: podcast.id == 0
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DownloadSettingsScreen(
                        podcastId: podcast.id,
                        podcastTitle: podcast.title,
                      ),
                    ),
                  ),
            icon: const Icon(Icons.download_for_offline_outlined),
          ),
          IconButton(
            tooltip: 'Refresh details',
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: bundle == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                children: [
                  _PodcastHeader(podcast: podcast),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _changingSubscription
                        ? null
                        : _toggleSubscription,
                    icon: _changingSubscription
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            bundle.subscribed
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                          ),
                    label: Text(bundle.subscribed ? 'Subscribed' : 'Subscribe'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _Notice(message: _error!),
                  ],
                  const SizedBox(height: 24),
                  if (MetadataSanitizer.plainText(
                    podcast.description,
                  ).isNotEmpty) ...[
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      MetadataSanitizer.plainText(podcast.description),
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (podcast.categories.isNotEmpty)
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: podcast.categories
                          .map(
                            (category) => Chip(
                              label: Text(
                                MetadataSanitizer.plainText(category),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  if (podcast.categories.isNotEmpty) const SizedBox(height: 14),
                  _SafeLink(label: 'Website', value: podcast.websiteUrl),
                  _SafeLink(label: 'Feed URL', value: podcast.feedUrl),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Episodes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (podcast.episodeCount > 0)
                        Text('${podcast.episodeCount} total'),
                      if (localEpisodes.isNotEmpty && !_selection.isActive)
                        IconButton(
                          tooltip: 'Select episodes',
                          onPressed: () => setState(_selection.begin),
                          icon: const Icon(Icons.checklist_rounded),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_selection.isActive) ...[
                    MultiSelectToolbar(
                      selectedCount: _selection.count,
                      totalCount: localEpisodes.length,
                      onClose: () => setState(_selection.clear),
                      onSelectRange: (range) => setState(
                        () => _selection.selectRange(
                          localEpisodes.map((episode) => episode.id).toList(),
                          range,
                        ),
                      ),
                      actions: _episodeActions(localEpisodes),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (bundle.episodes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: EmptyState(
                        icon: Icons.podcasts_outlined,
                        title: 'No episodes available',
                        body:
                            'This feed may still be updating. Pull down to try again.',
                      ),
                    )
                  else
                    ...bundle.episodes.map(
                      (episode) => _EpisodeCard(
                        episode: episode,
                        local: bundle.localEpisodes[episode.id],
                        selectionMode:
                            _selection.isActive &&
                            bundle.localEpisodes[episode.id] != null,
                        selected: _selection.contains(episode.id),
                        onLongPress: bundle.localEpisodes[episode.id] == null
                            ? null
                            : () =>
                                  setState(() => _selection.start(episode.id)),
                        onSelected: bundle.localEpisodes[episode.id] == null
                            ? null
                            : () =>
                                  setState(() => _selection.toggle(episode.id)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  List<MultiSelectAction> _episodeActions(List<EpisodeRecord> episodes) =>
      EpisodeBulkAction.values
          .where((action) => action != EpisodeBulkAction.removeFromInbox)
          .map(
            (action) => MultiSelectAction(
              label: action.label,
              icon: action.icon,
              onSelected: () => _runBulkAction(episodes, action),
            ),
          )
          .toList(growable: false);

  Future<void> _runBulkAction(
    List<EpisodeRecord> episodes,
    EpisodeBulkAction action,
  ) async {
    final selected = _selection.selectedItems(
      episodes,
      (episode) => episode.id,
    );
    final result = await performEpisodeBulkAction(ref, selected, action);
    final updated = await ref
        .read(appControllerProvider)
        .cachedPodcastDetails(_bundle?.podcast ?? widget.podcast);
    if (!mounted) return;
    setState(() {
      _bundle = updated;
      _selection.clear();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(bulkActionMessage(action, result))));
  }
}

class _PodcastHeader extends StatelessWidget {
  const _PodcastHeader({required this.podcast});
  final RemotePodcast podcast;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Artwork(
        id: podcast.id == 0 ? podcast.podcastIndexId : podcast.id,
        title: podcast.title,
        url: podcast.artworkUrl,
        size: 126,
        radius: 24,
      ),
      const SizedBox(width: 18),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MetadataSanitizer.plainText(podcast.title).isEmpty
                  ? 'Untitled podcast'
                  : MetadataSanitizer.plainText(podcast.title),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (MetadataSanitizer.plainText(podcast.author).isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(MetadataSanitizer.plainText(podcast.author)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if (podcast.episodeCount > 0)
                  Chip(label: Text('${podcast.episodeCount} episodes')),
                if (podcast.explicit) const Chip(label: Text('Explicit')),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _SafeLink extends StatelessWidget {
  const _SafeLink({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final uri = MetadataSanitizer.safeHttpUri(value);
    if (uri == null) return const SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const Icon(Icons.open_in_new_rounded),
      title: Text(label),
      subtitle: Text(
        uri.toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => launchUrl(uri, mode: LaunchMode.externalApplication),
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({
    required this.episode,
    this.local,
    this.selectionMode = false,
    this.selected = false,
    this.onLongPress,
    this.onSelected,
  });
  final RemoteEpisode episode;
  final EpisodeRecord? local;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final date = episode.publishedAt.year <= 1971
        ? null
        : DateFormat.yMMMd().format(episode.publishedAt.toLocal());
    final minutes = (episode.durationSeconds / 60).round();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        selected: selected,
        selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
        contentPadding: const EdgeInsets.all(12),
        leading: selectionMode
            ? Checkbox(value: selected, onChanged: (_) => onSelected?.call())
            : Artwork(
                id: episode.id,
                title: episode.title,
                url: episode.artworkUrl,
                size: 58,
              ),
        title: Text(
          MetadataSanitizer.plainText(episode.title).isEmpty
              ? 'Untitled episode'
              : MetadataSanitizer.plainText(episode.title),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            ?date,
            if (minutes > 0) '$minutes min',
            if (local?.downloaded ?? episode.downloaded) 'Downloaded',
          ].join(' · '),
        ),
        trailing: selectionMode
            ? null
            : const Icon(Icons.chevron_right_rounded),
        onLongPress: onLongPress,
        onTap: selectionMode
            ? onSelected
            : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EpisodeDetailScreen(
                    episode: episode,
                    localEpisode: local,
                  ),
                ),
              ),
      ),
    );
  }
}

class EpisodeDetailScreen extends ConsumerWidget {
  const EpisodeDetailScreen({
    super.key,
    required this.episode,
    this.localEpisode,
  });

  final RemoteEpisode episode;
  final EpisodeRecord? localEpisode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = localEpisode;
    final jobs = ref.watch(downloadJobsProvider).valueOrNull ?? const [];
    DownloadJobRecord? download;
    for (final job in jobs) {
      if (job.episodeId == episode.id) {
        download = job;
        break;
      }
    }
    final chapters = _chapters(local?.chaptersJson ?? episode.chaptersJson);
    final description = MetadataSanitizer.plainText(episode.description);
    final published = episode.publishedAt.year <= 1971
        ? 'Publication date unavailable'
        : DateFormat.yMMMMd().format(episode.publishedAt.toLocal());
    final duration = _duration(episode.durationSeconds);
    return Scaffold(
      appBar: AppBar(title: const Text('Episode')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Center(
            child: Artwork(
              id: episode.id,
              title: episode.title,
              url: episode.artworkUrl,
              size: 210,
              radius: 28,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            MetadataSanitizer.plainText(episode.title).isEmpty
                ? 'Untitled episode'
                : MetadataSanitizer.plainText(episode.title),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (MetadataSanitizer.plainText(episode.podcastTitle).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(MetadataSanitizer.plainText(episode.podcastTitle)),
          ],
          const SizedBox(height: 10),
          Text([published, if (duration.isNotEmpty) duration].join(' · ')),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (local?.completed ?? episode.completed)
                const Chip(label: Text('Played'))
              else if ((local?.positionSeconds ?? episode.positionSeconds) > 0)
                const Chip(label: Text('In progress')),
              if (local?.queued ?? episode.queued)
                const Chip(label: Text('Queued')),
              if (local?.downloaded ?? episode.downloaded)
                const Chip(label: Text('Downloaded')),
            ],
          ),
          if (local != null && local.audioUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(playerControllerProvider).playEpisode(local),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(local.positionSeconds > 0 ? 'Resume' : 'Play'),
            ),
          ],
          if (local != null) ...[
            const SizedBox(height: 10),
            _DownloadControls(episode: local, job: download),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 26),
            Text('Show notes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 9),
            SelectableText(description),
          ],
          if (chapters.isNotEmpty) ...[
            const SizedBox(height: 26),
            Text('Chapters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 7),
            ...chapters.map(
              (chapter) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bookmark_outline_rounded),
                title: Text(chapter.$2),
                subtitle: Text(_duration(chapter.$1.round())),
                onTap: local == null
                    ? null
                    : () async {
                        await ref
                            .read(playerControllerProvider)
                            .playEpisode(local);
                        await ref
                            .read(playerControllerProvider)
                            .seek(Duration(seconds: chapter.$1.round()));
                      },
              ),
            ),
          ],
        ],
      ),
    );
  }

  static List<(double, String)> _chapters(String value) {
    try {
      return (jsonDecode(value) as List)
          .whereType<Map>()
          .map((chapter) {
            final start = chapter['startTime'];
            final seconds = start is num
                ? start.toDouble()
                : double.tryParse('$start') ?? 0;
            final title = MetadataSanitizer.plainText(
              '${chapter['title'] ?? ''}',
            );
            return (seconds, title.isEmpty ? 'Chapter' : title);
          })
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static String _duration(int seconds) {
    if (seconds <= 0) return '';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final remaining = duration.inSeconds.remainder(60);
    return hours > 0
        ? '$hours:${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}'
        : '$minutes:${remaining.toString().padLeft(2, '0')}';
  }
}

class _DownloadControls extends ConsumerWidget {
  const _DownloadControls({required this.episode, required this.job});

  final EpisodeRecord episode;
  final DownloadJobRecord? job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = job?.downloadState;
    final (icon, label, action) = switch (state) {
      null => (
        Icons.download_rounded,
        'Download',
        () => startDownloadWithCellularConfirmation(context, ref, episode),
      ),
      DownloadState.queued || DownloadState.downloading => (
        Icons.pause_rounded,
        'Pause download',
        () => ref.read(downloadManagerProvider).pause(episode.id),
      ),
      DownloadState.paused => (
        Icons.download_rounded,
        'Resume download',
        () => startDownloadWithCellularConfirmation(context, ref, episode),
      ),
      DownloadState.failed => (
        Icons.refresh_rounded,
        'Retry download',
        () => startDownloadWithCellularConfirmation(context, ref, episode),
      ),
      DownloadState.completed => (
        Icons.delete_outline_rounded,
        'Delete download',
        () => ref.read(downloadManagerProvider).delete(episode.id),
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            try {
              await action();
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error.toString())));
              }
            }
          },
          icon: Icon(icon),
          label: Text(label),
        ),
        if (job != null && state != DownloadState.completed) ...[
          const SizedBox(height: 7),
          LinearProgressIndicator(value: job!.progress),
          if (job!.error != null) ...[
            const SizedBox(height: 6),
            Text(
              job!.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  ref.read(downloadManagerProvider).cancel(episode.id),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_outlined, size: 19),
        const SizedBox(width: 9),
        Expanded(child: Text(message)),
      ],
    ),
  );
}
