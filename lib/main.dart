import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/diagnostics/diagnostics.dart';
import 'core/sync/background_sync.dart';
import 'features/player/podpine_audio_handler.dart';
import 'providers.dart';

Future<void> main() async {
  const dsn = String.fromEnvironment('PODPINE_SENTRY_DSN');
  const environment = String.fromEnvironment(
    'PODPINE_ENVIRONMENT',
    defaultValue: 'production',
  );
  await SentryFlutter.init(
    (options) => configureProductionDiagnostics(
      options,
      dsn: dsn,
      environment: environment,
    ),
    appRunner: _runPodpine,
  );
}

Future<void> _runPodpine() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBackgroundSync();
  final audioHandler = await initializeAudioService();
  runApp(
    ProviderScope(
      overrides: [audioHandlerProvider.overrideWithValue(audioHandler)],
      child: const PodpineApp(),
    ),
  );
}
