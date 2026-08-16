import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';

import '../../core/metadata_sanitizer.dart';
import '../../core/l10n.dart';
import '../../providers.dart';
import '../shared/artwork.dart';
import '../shared/linkified_text.dart';
import 'playback_options.dart';
import 'player_controller.dart';

class PlayerBar extends ConsumerWidget {
  const PlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final episode = player.current;
    if (episode == null) return const SizedBox.shrink();
    final progress = player.duration.inMilliseconds == 0
        ? 0.0
        : player.position.inMilliseconds / player.duration.inMilliseconds;
    return Semantics(
      container: true,
      button: true,
      explicitChildNodes: true,
      label: context.l10n.openPlayer(episode.title),
      child: Material(
        color: Theme.of(context).navigationBarTheme.backgroundColor,
        child: InkWell(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            requestFocus: true,
            sheetAnimationStyle: MediaQuery.of(context).disableAnimations
                ? AnimationStyle.noAnimation
                : null,
            builder: (_) => const _FullPlayer(),
          ),
          child: Column(
            children: [
              if (player.error != null) _PlaybackError(player: player),
              LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 2,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  children: [
                    Artwork(
                      id: episode.podcastId,
                      title: episode.podcastTitle,
                      url: episode.artworkUrl,
                      size: 44,
                      radius: 10,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            episode.podcastTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _OrderedPlaybackControl(
                      order: 1,
                      label: context.l10n.skipBack,
                      child: IconButton(
                        tooltip: context.l10n.skipBack,
                        onPressed: () => player.skip(-15),
                        icon: const Icon(Icons.replay_10_rounded),
                      ),
                    ),
                    _OrderedPlaybackControl(
                      order: 2,
                      label: player.isPlaying
                          ? context.l10n.pause
                          : context.l10n.play,
                      child: IconButton.filled(
                        tooltip: player.isPlaying
                            ? context.l10n.pause
                            : context.l10n.play,
                        onPressed: player.loading ? null : player.toggle,
                        icon: player.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                player.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                      ),
                    ),
                    _OrderedPlaybackControl(
                      order: 3,
                      label: context.l10n.skipForward,
                      child: IconButton(
                        tooltip: context.l10n.skipForward,
                        onPressed: () => player.skip(30),
                        icon: const Icon(Icons.forward_30_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderedPlaybackControl extends StatelessWidget {
  const _OrderedPlaybackControl({
    required this.order,
    required this.label,
    required this.child,
  });

  final double order;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    sortKey: OrdinalSortKey(order),
    label: label,
    button: true,
    excludeSemantics: true,
    child: FocusTraversalOrder(order: NumericFocusOrder(order), child: child),
  );
}

class _PlaybackError extends StatelessWidget {
  const _PlaybackError({required this.player});

  final PlayerController player;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: Theme.of(context).colorScheme.errorContainer,
    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
    child: Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            player.error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontSize: 12,
            ),
          ),
        ),
        if (player.errorCanRetry)
          TextButton(onPressed: player.retry, child: Text(context.l10n.retry)),
        IconButton(
          tooltip: context.l10n.dismissPlaybackError,
          onPressed: player.dismissError,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    ),
  );
}

class _FullPlayer extends ConsumerWidget {
  const _FullPlayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerControllerProvider);
    final episode = player.current;
    if (episode == null) return const SizedBox.shrink();
    final max = player.duration.inMilliseconds
        .toDouble()
        .clamp(1, double.infinity)
        .toDouble();
    final showNotes = MetadataSanitizer.plainText(episode.description);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: .65),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 26),
            Artwork(
              id: episode.podcastId,
              title: episode.podcastTitle,
              url: episode.artworkUrl,
              size: (MediaQuery.sizeOf(context).width - 56).clamp(120, 230),
              radius: 28,
            ),
            const SizedBox(height: 24),
            Text(
              episode.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 7),
            Text(
              episode.podcastTitle,
              style: TextStyle(
                fontFamily: 'sans-serif',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (player.currentChapter case final chapter?) ...[
              const SizedBox(height: 8),
              Text(
                chapter.title,
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _SettingChip(
                  icon: Icons.speed_rounded,
                  label:
                      '${player.speed.toStringAsFixed(player.speed % 1 == 0 ? 1 : 2)}×${player.hasPodcastSpeedOverride ? ' · podcast' : ''}',
                ),
                _SettingChip(
                  icon: Icons.graphic_eq_rounded,
                  label:
                      '${player.skipSilence.label}${player.hasPodcastSkipSilenceOverride ? ' · podcast' : ''}',
                ),
                if (player.sleepAtEpisodeEnd)
                  _SettingChip(
                    icon: Icons.bedtime_outlined,
                    label: context.l10n.endOfEpisode,
                  )
                else if (player.sleepTimerRemaining case final remaining?)
                  _SettingChip(
                    icon: Icons.bedtime_outlined,
                    label: context.l10n.minutesShort(remaining.inMinutes + 1),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Slider(
              value: player.position.inMilliseconds
                  .toDouble()
                  .clamp(0, max)
                  .toDouble(),
              max: max,
              onChanged: (value) =>
                  player.seek(Duration(milliseconds: value.round())),
              semanticFormatterCallback: (value) =>
                  '${context.l10n.playbackPosition} ${_time(Duration(milliseconds: value.round()))}',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _time(player.position),
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '-${_time(player.duration - player.position)}',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: context.l10n.skipBack,
                  iconSize: 32,
                  onPressed: () => player.skip(-15),
                  icon: const Icon(Icons.replay_10_rounded),
                ),
                IconButton.filled(
                  tooltip: player.isPlaying
                      ? context.l10n.pause
                      : context.l10n.play,
                  iconSize: 40,
                  padding: const EdgeInsets.all(16),
                  onPressed: player.toggle,
                  icon: Icon(
                    player.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.skipForward,
                  iconSize: 32,
                  onPressed: () => player.skip(30),
                  icon: const Icon(Icons.forward_30_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _showSpeed(context, player),
                  icon: const Icon(Icons.speed_rounded),
                  label: Text(context.l10n.speed),
                ),
                TextButton.icon(
                  onPressed: () => _showSkipSilence(context, player),
                  icon: const Icon(Icons.graphic_eq_rounded),
                  label: Text(context.l10n.silence),
                ),
                if (player.chapters.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _showChapters(context, player),
                    icon: const Icon(Icons.list_rounded),
                    label: Text(context.l10n.chapters(player.chapters.length)),
                  ),
                TextButton.icon(
                  onPressed: () => _showSleepTimer(context, player),
                  icon: const Icon(Icons.bedtime_outlined),
                  label: Text(context.l10n.timer),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.showNotes,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 9),
                  if (showNotes.isEmpty)
                    Text(
                      context.l10n.noShowNotes,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    LinkifiedText(showNotes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _time(Duration value) {
    final duration = value.isNegative ? Duration.zero : value;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static Future<void> _showSpeed(
    BuildContext context,
    PlayerController player,
  ) {
    var selected = player.speed;
    var forPodcast = player.hasPodcastSpeedOverride;
    return showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.playbackSpeed),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${selected.toStringAsFixed(2)}×',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Slider(
                value: selected,
                min: 0.5,
                max: 3,
                divisions: 50,
                label: '${selected.toStringAsFixed(2)}×',
                onChanged: (value) => setState(() => selected = value),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: forPodcast,
                title: Text(
                  context.l10n.onlyForPodcast(
                    player.current?.podcastTitle ?? '',
                  ),
                ),
                subtitle: Text(context.l10n.globalDefaultExplanation),
                onChanged: (value) =>
                    setState(() => forPodcast = value ?? false),
              ),
            ],
          ),
          actions: [
            if (player.hasPodcastSpeedOverride)
              TextButton(
                onPressed: () async {
                  await player.clearPodcastSpeedOverride();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(context.l10n.useGlobal),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                await player.setSpeed(selected, forPodcast: forPodcast);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(context.l10n.apply),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showSkipSilence(
    BuildContext context,
    PlayerController player,
  ) {
    var selected = player.skipSilence;
    var forPodcast = player.hasPodcastSkipSilenceOverride;
    return showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.skipSilence),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioGroup<SkipSilenceStrength>(
                groupValue: selected,
                onChanged: (value) =>
                    setState(() => selected = value ?? selected),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final strength in SkipSilenceStrength.values)
                      RadioListTile<SkipSilenceStrength>(
                        contentPadding: EdgeInsets.zero,
                        value: strength,
                        title: Text(strength.label),
                        subtitle: strength == SkipSilenceStrength.conservative
                            ? Text(context.l10n.recommendedNaturalSpeech)
                            : null,
                      ),
                  ],
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: forPodcast,
                title: Text(
                  context.l10n.onlyForPodcast(
                    player.current?.podcastTitle ?? '',
                  ),
                ),
                onChanged: (value) =>
                    setState(() => forPodcast = value ?? false),
              ),
              Text(
                player.skipSilenceDiagnostics,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            if (player.hasPodcastSkipSilenceOverride)
              TextButton(
                onPressed: () async {
                  await player.clearPodcastSkipSilenceOverride();
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(context.l10n.useGlobal),
              ),
            FilledButton(
              onPressed: () async {
                await player.setSkipSilence(selected, forPodcast: forPodcast);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(context.l10n.apply),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showSleepTimer(
    BuildContext context,
    PlayerController player,
  ) => showDialog<void>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(context.l10n.sleepTimer),
      children: [
        for (final minutes in <int>[10, 15, 30, 45, 60])
          SimpleDialogOption(
            onPressed: () async {
              await player.setSleepTimer(Duration(minutes: minutes));
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(context.l10n.minutes(minutes)),
          ),
        SimpleDialogOption(
          onPressed: () async {
            await player.setSleepTimer(null, endOfEpisode: true);
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(context.l10n.endOfEpisode),
        ),
        if (player.sleepTimerEndsAt != null || player.sleepAtEpisodeEnd)
          SimpleDialogOption(
            onPressed: () async {
              await player.setSleepTimer(null);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(context.l10n.cancelTimer),
          ),
      ],
    ),
  );

  static Future<void> _showChapters(
    BuildContext context,
    PlayerController player,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    sheetAnimationStyle: MediaQuery.of(context).disableAnimations
        ? AnimationStyle.noAnimation
        : null,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
            child: Text(
              context.l10n.chapters(player.chapters.length),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          for (final chapter in player.chapters)
            ListTile(
              selected: chapter.start == player.currentChapter?.start,
              leading: Text(_time(chapter.start)),
              title: Text(chapter.title),
              onTap: () async {
                await player.seek(chapter.start);
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );
}

class _SettingChip extends StatelessWidget {
  const _SettingChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );
}
