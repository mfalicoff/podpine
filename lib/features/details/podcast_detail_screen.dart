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
import '../../core/l10n.dart';
import '../../providers.dart';
import '../shared/artwork.dart';
import '../shared/multi_select.dart';
import '../shared/linkified_text.dart';
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
              ? context.l10n.podcastOffline
              : context.l10n.savedOffline;
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
          title: Text(context.l10n.unsubscribeQuestion),
          content: Text(
            context.l10n.unsubscribeBody(
              MetadataSanitizer.plainText(bundle.podcast.title),
            ),
          ),
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
        title: Text(context.l10n.podcast),
        actions: [
          IconButton(
            tooltip: context.l10n.podcastDownloadSettings,
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
            tooltip: context.l10n.refreshDetails,
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
                    label: Text(
                      bundle.subscribed
                          ? context.l10n.subscribed
                          : context.l10n.subscribe,
                    ),
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
                      context.l10n.about,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    LinkifiedText(
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
                  _SafeLink(
                    label: context.l10n.website,
                    value: podcast.websiteUrl,
                  ),
                  _SafeLink(
                    label: context.l10n.feedUrl,
                    value: podcast.feedUrl,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.episodes,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (podcast.episodeCount > 0)
                        Text(context.l10n.totalCount(podcast.episodeCount)),
                      if (localEpisodes.isNotEmpty && !_selection.isActive)
                        IconButton(
                          tooltip: context.l10n.selectEpisodes,
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
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: EmptyState(
                        icon: Icons.podcasts_outlined,
                        title: context.l10n.noEpisodesAvailable,
                        body: context.l10n.feedUpdating,
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
              label: action.label(context),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(bulkActionMessage(context, action, result))),
    );
  }
}

class _PodcastHeader extends StatelessWidget {
  const _PodcastHeader({required this.podcast});
  final RemotePodcast podcast;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final artwork = Artwork(
        id: podcast.id == 0 ? podcast.podcastIndexId : podcast.id,
        title: podcast.title,
        url: podcast.artworkUrl,
        size: constraints.maxWidth < 520 ? 112 : 126,
        radius: 24,
      );
      final details = Column(
        crossAxisAlignment: constraints.maxWidth < 520
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            MetadataSanitizer.plainText(podcast.title).isEmpty
                ? context.l10n.untitledPodcast
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
                Chip(
                  label: Text(context.l10n.episodeCount(podcast.episodeCount)),
                ),
              if (podcast.explicit) Chip(label: Text(context.l10n.explicit)),
            ],
          ),
        ],
      );
      if (constraints.maxWidth < 520) {
        return Column(children: [artwork, const SizedBox(height: 16), details]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          artwork,
          const SizedBox(width: 18),
          Expanded(child: details),
        ],
      );
    },
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
    return Semantics(
      link: true,
      label: context.l10n.openLink(uri.toString()),
      child: ListTile(
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
      ),
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
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(episode.publishedAt.toLocal());
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
              ? context.l10n.untitledEpisode
              : MetadataSanitizer.plainText(episode.title),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            ?date,
            if (minutes > 0) context.l10n.minutesShort(minutes),
            if (local?.downloaded ?? episode.downloaded)
              context.l10n.downloaded,
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
    final chapters = _chapters(
      context,
      local?.chaptersJson ?? episode.chaptersJson,
    );
    final description = MetadataSanitizer.plainText(episode.description);
    final published = episode.publishedAt.year <= 1971
        ? context.l10n.publicationUnavailable
        : DateFormat.yMMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(episode.publishedAt.toLocal());
    final duration = _duration(episode.durationSeconds);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.episode)),
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
                ? context.l10n.untitledEpisode
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
                Chip(label: Text(context.l10n.played))
              else if ((local?.positionSeconds ?? episode.positionSeconds) > 0)
                Chip(label: Text(context.l10n.inProgress)),
              if (local?.queued ?? episode.queued)
                Chip(label: Text(context.l10n.queued)),
              if (local?.downloaded ?? episode.downloaded)
                Chip(label: Text(context.l10n.downloaded)),
            ],
          ),
          if (local != null && local.audioUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(playerControllerProvider).playEpisode(local),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                local.positionSeconds > 0
                    ? context.l10n.resume
                    : context.l10n.play,
              ),
            ),
          ],
          if (local != null) ...[
            const SizedBox(height: 10),
            _DownloadControls(episode: local, job: download),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 26),
            Text(
              context.l10n.showNotes,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 9),
            LinkifiedText(description),
          ],
          if (chapters.isNotEmpty) ...[
            const SizedBox(height: 26),
            Text(
              context.l10n.chapters(chapters.length),
              style: Theme.of(context).textTheme.titleLarge,
            ),
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

  static List<(double, String)> _chapters(BuildContext context, String value) {
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
            return (seconds, title.isEmpty ? context.l10n.chapter : title);
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
        context.l10n.download,
        () => startDownloadWithCellularConfirmation(context, ref, episode),
      ),
      DownloadState.queued || DownloadState.downloading => (
        Icons.pause_rounded,
        context.l10n.pauseDownload,
        () => ref.read(downloadManagerProvider).pause(episode.id),
      ),
      DownloadState.paused => (
        Icons.download_rounded,
        context.l10n.resumeDownload,
        () => startDownloadWithCellularConfirmation(context, ref, episode),
      ),
      DownloadState.failed => (
        Icons.refresh_rounded,
        context.l10n.retryDownload,
        () => startDownloadWithCellularConfirmation(context, ref, episode),
      ),
      DownloadState.completed => (
        Icons.delete_outline_rounded,
        context.l10n.deleteDownload,
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
              child: Text(context.l10n.cancel),
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
