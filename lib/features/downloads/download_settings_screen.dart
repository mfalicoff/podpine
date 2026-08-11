import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/downloads/download_models.dart';
import '../../providers.dart';

class DownloadSettingsScreen extends ConsumerStatefulWidget {
  const DownloadSettingsScreen({super.key, this.podcastId, this.podcastTitle});

  final int? podcastId;
  final String? podcastTitle;

  @override
  ConsumerState<DownloadSettingsScreen> createState() =>
      _DownloadSettingsScreenState();
}

class _DownloadSettingsScreenState
    extends ConsumerState<DownloadSettingsScreen> {
  DownloadRuleSettings? _settings;
  bool _usePodcastOverride = false;
  bool _saving = false;

  bool get _isPodcast => widget.podcastId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final database = ref.read(databaseProvider);
    final global =
        (await database.downloadPreferences())?.settings ??
        const DownloadRuleSettings();
    final podcastId = widget.podcastId;
    final override = podcastId == null
        ? null
        : await database.podcastDownloadOverride(podcastId);
    if (!mounted) return;
    setState(() {
      _usePodcastOverride = override != null;
      _settings = override?.settings ?? global;
    });
  }

  Future<void> _save() async {
    final settings = _settings;
    if (settings == null || _saving) return;
    setState(() => _saving = true);
    try {
      final database = ref.read(databaseProvider);
      final podcastId = widget.podcastId;
      if (podcastId == null) {
        await database.setDownloadPreferences(settings.toGlobalCompanion());
      } else if (_usePodcastOverride) {
        await database.setPodcastDownloadOverride(
          settings.toPodcastCompanion(podcastId),
        );
      } else {
        await database.clearPodcastDownloadOverride(podcastId);
      }
      await ref.read(downloadManagerProvider).evaluateRules();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _update(DownloadRuleSettings value) => setState(() => _settings = value);

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isPodcast ? 'Podcast downloads' : 'Automatic downloads'),
        actions: [
          TextButton(
            onPressed: settings == null || _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
              children: [
                if (_isPodcast) ...[
                  Text(
                    widget.podcastTitle ?? 'This podcast',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use custom rules'),
                    subtitle: const Text(
                      'Turn this off to inherit the global download rules.',
                    ),
                    value: _usePodcastOverride,
                    onChanged: (value) =>
                        setState(() => _usePodcastOverride = value),
                  ),
                  const Divider(height: 30),
                ],
                IgnorePointer(
                  ignoring: _isPodcast && !_usePodcastOverride,
                  child: Opacity(
                    opacity: _isPodcast && !_usePodcastOverride ? 0.5 : 1,
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Download new episodes automatically',
                          ),
                          subtitle: const Text(
                            'Keeps the newest unplayed episodes available offline.',
                          ),
                          value: settings.automatic,
                          onChanged: (value) =>
                              _update(settings.copyWith(automatic: value)),
                        ),
                        _RuleDropdown<int>(
                          title: 'Episode limit',
                          value: settings.episodeLimit,
                          values: const [1, 2, 3, 5, 10, 20],
                          label: (value) => '$value',
                          onChanged: (value) =>
                              _update(settings.copyWith(episodeLimit: value)),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Wi-Fi only'),
                          subtitle: const Text(
                            'Automatic downloads wait for Wi-Fi or Ethernet.',
                          ),
                          value: settings.wifiOnly,
                          onChanged: (value) =>
                              _update(settings.copyWith(wifiOnly: value)),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Only while charging'),
                          value: settings.chargingOnly,
                          onChanged: (value) =>
                              _update(settings.copyWith(chargingOnly: value)),
                        ),
                        _RuleDropdown<int>(
                          title: 'Keep free storage',
                          value: settings.storageFloorBytes ~/ (1024 * 1024),
                          values: const [0, 100, 250, 500, 1024, 2048, 5120],
                          label: (value) => value >= 1024
                              ? '${value ~/ 1024} GB'
                              : '$value MB',
                          onChanged: (value) => _update(
                            settings.copyWith(
                              storageFloorBytes: value * 1024 * 1024,
                            ),
                          ),
                        ),
                        _RuleDropdown<PlayedDownloadRetention>(
                          title: 'Delete played downloads',
                          value: settings.retention,
                          values: PlayedDownloadRetention.values,
                          label: (value) => switch (value) {
                            PlayedDownloadRetention.never => 'Never',
                            PlayedDownloadRetention.immediate => 'Immediately',
                            PlayedDownloadRetention.delayed => 'After a delay',
                          },
                          onChanged: (value) =>
                              _update(settings.copyWith(retention: value)),
                        ),
                        if (settings.retention ==
                            PlayedDownloadRetention.delayed)
                          _RuleDropdown<int>(
                            title: 'Deletion delay',
                            value: settings.retentionDelayHours,
                            values: const [1, 6, 12, 24, 48, 72, 168, 720],
                            label: (value) => value < 24
                                ? '$value hours'
                                : value == 24
                                ? '1 day'
                                : value < 168
                                ? '${value ~/ 24} days'
                                : value == 168
                                ? '1 week'
                                : '30 days',
                            onChanged: (value) => _update(
                              settings.copyWith(retentionDelayHours: value),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RuleDropdown<T> extends StatelessWidget {
  const _RuleDropdown({
    required this.title,
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final T value;
  final List<T> values;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    trailing: DropdownButton<T>(
      value: value,
      items: values
          .map(
            (value) =>
                DropdownMenuItem<T>(value: value, child: Text(label(value))),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    ),
  );
}
