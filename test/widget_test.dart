import 'package:audio_service/audio_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/features/onboarding/connect_screen.dart';
import 'package:podpine/features/player/player_bar.dart';
import 'package:podpine/features/player/player_controller.dart';
import 'package:podpine/providers.dart';

void main() {
  testWidgets('shows Pinepods onboarding on first launch', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final app = AppController(
      database,
      const CredentialStore(FlutterSecureStorage()),
    )..initialized = true;
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appControllerProvider.overrideWith((ref) => app)],
        child: const MaterialApp(home: ConnectScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Your podcasts,\nwherever you listen.'), findsOneWidget);
    expect(find.text('Connect securely'), findsOneWidget);
    expect(find.text('Explore with a demo library'), findsOneWidget);
  });

  testWidgets('full player shows sanitized episode show notes', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final player = PlayerController(
      database,
      _TestAudioHandler(),
      (_, _) async {},
      (_, _) async {},
    );
    final episode = EpisodeRecord(
      id: 7,
      podcastId: 3,
      podcastTitle: 'Test Cast',
      title: 'Playing episode',
      description:
          '<script>alert(1)</script><p>These are the show notes &amp; links.</p>',
      artworkUrl: '',
      audioUrl: '',
      publishedAt: DateTime.utc(2026, 8, 10),
      durationSeconds: 120,
      positionSeconds: 0,
      completed: false,
      queued: false,
      downloaded: false,
      isYoutube: false,
      chaptersJson: '[]',
      updatedAt: DateTime.utc(2026, 8, 10),
    );
    player.current = episode;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [playerControllerProvider.overrideWith((ref) => player)],
        child: const MaterialApp(
          home: Scaffold(bottomNavigationBar: PlayerBar()),
        ),
      ),
    );
    await tester.tap(find.text('Playing episode').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Show notes'), findsOneWidget);
    expect(find.text('These are the show notes & links.'), findsOneWidget);
    expect(find.textContaining('alert(1)'), findsNothing);
  });
}

class _TestAudioHandler extends BaseAudioHandler {}
