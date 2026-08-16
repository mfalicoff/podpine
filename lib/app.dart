import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n.dart';
import 'core/theme.dart';
import 'features/onboarding/connect_screen.dart';
import 'features/shell/app_shell.dart';
import 'providers.dart';
import 'l10n/generated/app_localizations.dart';

class PodpineApp extends ConsumerWidget {
  const PodpineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appControllerProvider);
    final preferences = ref.watch(appPreferencesProvider);
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      theme: PodpineTheme.light,
      darkTheme: PodpineTheme.dark,
      themeMode: preferences.themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: !app.initialized
          ? const _BootScreen()
          : app.connected
          ? const AppShell()
          : const ConnectScreen(),
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PineMark(size: 64),
          const SizedBox(height: 20),
          Text(
            context.l10n.appName,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    ),
  );
}

class _PineMark extends StatelessWidget {
  const _PineMark({this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: PodpineTheme.pine,
      borderRadius: BorderRadius.circular(size * .31),
      boxShadow: const [
        BoxShadow(
          color: Color(0x24173F35),
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: Icon(
      Icons.park_rounded,
      color: const Color(0xFFF3C969),
      size: size * .58,
    ),
  );
}
