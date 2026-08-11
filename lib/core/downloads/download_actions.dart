import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../database/app_database.dart';
import 'download_models.dart';

Future<void> startDownloadWithCellularConfirmation(
  BuildContext context,
  WidgetRef ref,
  EpisodeRecord episode,
) async {
  final manager = ref.read(downloadManagerProvider);
  try {
    await manager.start(episode);
  } on CellularDownloadConfirmationRequired {
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Download using cellular data?'),
        content: const Text(
          'You are not connected to Wi-Fi. This episode may use a significant amount of cellular data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await manager.start(episode, allowCellular: true);
    }
  }
}
