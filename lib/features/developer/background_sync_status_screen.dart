import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/sync/background_sync.dart';
import '../../providers.dart';

class BackgroundSyncStatusScreen extends ConsumerStatefulWidget {
  const BackgroundSyncStatusScreen({super.key});

  @override
  ConsumerState<BackgroundSyncStatusScreen> createState() =>
      _BackgroundSyncStatusScreenState();
}

class _BackgroundSyncStatusScreenState
    extends ConsumerState<BackgroundSyncStatusScreen> {
  late Future<_StatusData> _status;

  @override
  void initState() {
    super.initState();
    _status = _load();
  }

  Future<_StatusData> _load() async {
    final results = await Future.wait<Object>([
      BackgroundSyncDiagnostics().read(),
      ref.read(databaseProvider).pendingMutations(),
      ref.read(databaseProvider).failedMutations(),
    ]);
    return _StatusData(
      diagnostics: results[0] as BackgroundSyncSnapshot,
      pendingMutations: results[1] as List<PendingMutation>,
      failedMutations: results[2] as List<PendingMutation>,
    );
  }

  Future<void> _reload() async {
    final next = _load();
    setState(() => _status = next);
    await next;
  }

  Future<void> _foregroundRefresh() async {
    try {
      await ref.read(appControllerProvider).refresh();
    } catch (_) {
      // AppController exposes a user-facing offline state; diagnostics still
      // need to reload so the outbox count remains useful.
    }
    if (mounted) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background sync status'),
        actions: [
          IconButton(
            tooltip: 'Reload diagnostics',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<_StatusData>(
        future: _status,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.requireData;
          final diagnostics = data.diagnostics;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _StatusBanner(diagnostics: diagnostics),
                const SizedBox(height: 18),
                const _SectionTitle('Scheduler'),
                _StatusCard(
                  children: [
                    _StatusRow('Integration', diagnostics.scheduler),
                    _StatusRow(
                      'Registered',
                      diagnostics.scheduled ? 'Yes' : 'No',
                    ),
                    _StatusRow(
                      'Scheduled at',
                      _formatDate(diagnostics.scheduledAt),
                    ),
                    _StatusRow('Policy', diagnostics.policy),
                    _StatusRow(
                      'Scheduler detail',
                      diagnostics.schedulingDetail,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Last background run'),
                _StatusCard(
                  children: [
                    _StatusRow('Outcome', _outcomeLabel(diagnostics.outcome)),
                    _StatusRow(
                      'Started',
                      _formatDate(diagnostics.lastStartedAt),
                    ),
                    _StatusRow(
                      'Completed',
                      _formatDate(diagnostics.lastCompletedAt),
                    ),
                    _StatusRow(
                      'Duration',
                      diagnostics.durationMilliseconds == null
                          ? '—'
                          : '${diagnostics.durationMilliseconds} ms',
                    ),
                    _StatusRow('Detail', diagnostics.detail),
                    _StatusRow(
                      'Outbox before / after',
                      diagnostics.pendingBefore == null
                          ? '—'
                          : '${diagnostics.pendingBefore} / '
                                '${diagnostics.pendingAfter ?? '—'}',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Correctness fallback'),
                _StatusCard(
                  children: [
                    _StatusRow(
                      'Pending mutations now',
                      '${data.pendingMutations.length}',
                    ),
                    _StatusRow(
                      'Failed mutations now',
                      '${data.failedMutations.length}',
                    ),
                    _StatusRow(
                      'Last foreground sync',
                      _formatDate(app.lastSyncedAt),
                    ),
                    const _StatusRow(
                      'Foreground behavior',
                      'Refreshes on app startup, resume, pull-to-refresh, and '
                          'the action below.',
                    ),
                  ],
                ),
                if (data.pendingMutations.isNotEmpty ||
                    data.failedMutations.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const _SectionTitle('Mutation outbox'),
                  _StatusCard(
                    children: [
                      for (final mutation in [
                        ...data.pendingMutations,
                        ...data.failedMutations,
                      ])
                        _MutationRow(mutation),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: app.busy ? null : _foregroundRefresh,
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Run foreground refresh'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Background execution is opportunistic. Android and iOS may '
                  'delay or skip a run; foreground refresh is always the '
                  'correctness fallback.',
                  style: TextStyle(color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusData {
  const _StatusData({
    required this.diagnostics,
    required this.pendingMutations,
    required this.failedMutations,
  });

  final BackgroundSyncSnapshot diagnostics;
  final List<PendingMutation> pendingMutations;
  final List<PendingMutation> failedMutations;
}

class _MutationRow extends StatelessWidget {
  const _MutationRow(this.mutation);

  final PendingMutation mutation;

  @override
  Widget build(BuildContext context) {
    final failed = mutation.state == 'failed';
    final subtitle = <String>[
      if (mutation.episodeId != null) 'episode ${mutation.episodeId}',
      '${mutation.attempts} attempt${mutation.attempts == 1 ? '' : 's'}',
      if (!failed && mutation.nextAttemptAt != null)
        'retry ${_formatDate(mutation.nextAttemptAt)}',
      if (failed && mutation.failedAt != null)
        'failed ${_formatDate(mutation.failedAt)}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            failed ? Icons.error_outline : Icons.schedule,
            color: failed ? Colors.red : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mutation.type.replaceAll('_', ' '),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
                if (mutation.lastError != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    mutation.lastError!,
                    style: TextStyle(
                      color: failed ? Colors.red.shade700 : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.diagnostics});

  final BackgroundSyncSnapshot diagnostics;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (diagnostics.outcome) {
      BackgroundSyncOutcome.succeeded => (Colors.green, Icons.check_circle),
      BackgroundSyncOutcome.failed => (Colors.red, Icons.error),
      BackgroundSyncOutcome.running => (Colors.blue, Icons.sync),
      BackgroundSyncOutcome.skippedOffline ||
      BackgroundSyncOutcome.skippedNoSession => (Colors.orange, Icons.schedule),
      BackgroundSyncOutcome.neverRun => (Colors.blueGrey, Icons.schedule),
    };
    return Card(
      color: color.withValues(alpha: .1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnostics.scheduled
                        ? 'Background refresh registered'
                        : 'Background refresh not registered',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(_outcomeLabel(diagnostics.outcome)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 7),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Column(children: children),
    ),
  );
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 128,
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(child: SelectableText(value)),
      ],
    ),
  );
}

String _formatDate(DateTime? value) =>
    value == null ? '—' : DateFormat.yMMMd().add_jms().format(value.toLocal());

String _outcomeLabel(BackgroundSyncOutcome outcome) => switch (outcome) {
  BackgroundSyncOutcome.neverRun => 'Never run',
  BackgroundSyncOutcome.running => 'Running',
  BackgroundSyncOutcome.succeeded => 'Succeeded',
  BackgroundSyncOutcome.skippedOffline => 'Skipped: offline',
  BackgroundSyncOutcome.skippedNoSession => 'Skipped: no session',
  BackgroundSyncOutcome.failed => 'Failed; Android will retry',
};
