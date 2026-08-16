import 'package:audio_service/audio_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podpine/app_controller.dart';
import 'package:podpine/core/app_preferences.dart';
import 'package:podpine/core/database/app_database.dart';
import 'package:podpine/core/downloads/download_manager.dart';
import 'package:podpine/core/storage/credential_store.dart';
import 'package:podpine/core/theme.dart';
import 'package:podpine/features/player/player_bar.dart';
import 'package:podpine/features/player/player_controller.dart';
import 'package:podpine/features/shared/linkified_text.dart';
import 'package:podpine/features/shell/app_shell.dart';
import 'package:podpine/l10n/generated/app_localizations.dart';
import 'package:podpine/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phone breakpoint has screenshot coverage', (tester) async {
    final cleanup = await _pumpShell(tester, const Size(360, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/app_shell_phone.png'),
    );
    await cleanup();
  });

  testWidgets('tablet breakpoint has screenshot coverage', (tester) async {
    final cleanup = await _pumpShell(tester, const Size(900, 1100));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/app_shell_tablet.png'),
    );
    await cleanup();
  });

  testWidgets('web breakpoint has screenshot coverage', (tester) async {
    final cleanup = await _pumpShell(tester, const Size(1440, 900));

    expect(find.byType(NavigationRail), findsOneWidget);
    await expectLater(
      find.byType(Scaffold).first,
      matchesGoldenFile('goldens/app_shell_web.png'),
    );
    await cleanup();
  });

  testWidgets('large accessibility text does not overflow key shell screens', (
    tester,
  ) async {
    final cleanup = await _pumpShell(
      tester,
      const Size(360, 800),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pump();

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
    expect(tester.takeException(), isNull);
    await cleanup();
  });

  testWidgets('show-note URLs expose keyboard-focusable links', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _localizedApp(
        home: const Scaffold(
          body: LinkifiedText(
            'Read https://example.com/episode for the full transcript.',
          ),
        ),
      ),
    );

    expect(find.byType(Link), findsOneWidget);
    expect(
      find.bySemanticsLabel('Open https://example.com/episode'),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, isNotNull);
    semantics.dispose();
  });

  testWidgets('playback controls have labels and reduced motion', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final database = AppDatabase(NativeDatabase.memory());
    final player = PlayerController(
      database,
      _TestAudioHandler(),
      (_, _) async {},
      (_, _) async {},
    )..current = _episode;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [playerControllerProvider.overrideWith((ref) => player)],
        child: _localizedApp(
          disableAnimations: true,
          home: const Scaffold(bottomNavigationBar: PlayerBar()),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Skip back 15 seconds'), findsOneWidget);
    expect(find.bySemanticsLabel('Play'), findsOneWidget);
    expect(find.bySemanticsLabel('Skip forward 30 seconds'), findsOneWidget);

    await tester.tap(find.text('Accessible episode'));
    await tester.pump();
    expect(find.text('Show notes'), findsOneWidget);

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await database.close();
    await tester.pump();
  });

  test('light and dark content colors meet WCAG AA text contrast', () {
    for (final theme in [PodpineTheme.light, PodpineTheme.dark]) {
      final scheme = theme.colorScheme;
      expect(
        _contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(scheme.onErrorContainer, scheme.errorContainer),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('theme selection persists', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = AppPreferences();
    await preferences.setThemeMode(ThemeMode.dark);
    final restored = AppPreferences();
    await pumpEventQueue();

    expect(restored.themeMode, ThemeMode.dark);
  });
}

Future<Future<void> Function()> _pumpShell(
  WidgetTester tester,
  Size size, {
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final database = AppDatabase(NativeDatabase.memory());
  final app =
      AppController(database, const CredentialStore(FlutterSecureStorage()))
        ..initialized = true
        ..connected = true
        ..demoMode = true;
  final player = PlayerController(
    database,
    _TestAudioHandler(),
    (_, _) async {},
    (_, _) async {},
  );
  final downloads = DownloadManager(database);
  Future<void> cleanup() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
    await tester.pump();
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        appControllerProvider.overrideWith((ref) => app),
        playerControllerProvider.overrideWith((ref) => player),
        downloadManagerProvider.overrideWith((ref) => downloads),
        podcastsProvider.overrideWith(
          (ref) => Stream.value(const <PodcastRecord>[]),
        ),
        episodesProvider.overrideWith(
          (ref) => Stream.value(const <EpisodeRecord>[]),
        ),
        queueProvider.overrideWith(
          (ref) => Stream.value(const <EpisodeRecord>[]),
        ),
        inboxUnreadCountProvider.overrideWith((ref) => Stream.value(0)),
        downloadJobsProvider.overrideWith(
          (ref) => Stream.value(const <DownloadJobRecord>[]),
        ),
      ],
      child: _localizedApp(textScale: textScale, home: const AppShell()),
    ),
  );
  await tester.pumpAndSettle();
  return cleanup;
}

Widget _localizedApp({
  required Widget home,
  double textScale = 1,
  bool disableAnimations = false,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: PodpineTheme.light,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: disableAnimations,
    ),
    child: child!,
  ),
  home: home,
);

double _contrast(Color first, Color second) {
  final brightest = first.computeLuminance() > second.computeLuminance()
      ? first
      : second;
  final darkest = identical(brightest, first) ? second : first;
  return (brightest.computeLuminance() + .05) /
      (darkest.computeLuminance() + .05);
}

class _TestAudioHandler extends BaseAudioHandler {}

final _episode = EpisodeRecord(
  id: 21,
  podcastId: 7,
  podcastTitle: 'Accessible Cast',
  title: 'Accessible episode',
  description: 'Read https://example.com/notes for more.',
  artworkUrl: '',
  audioUrl: 'https://example.com/episode.mp3',
  publishedAt: DateTime.utc(2026, 8, 16),
  durationSeconds: 180,
  positionSeconds: 0,
  completed: false,
  queued: false,
  downloaded: false,
  isYoutube: false,
  chaptersJson: '[]',
  playbackIntent: 'progress',
  playbackMediaIdentity: 'https://example.com/episode.mp3',
  updatedAt: DateTime.utc(2026, 8, 16),
);
