import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/onboarding/connect_screen.dart';
import 'features/shell/app_shell.dart';
import 'providers.dart';

class PodpineApp extends ConsumerWidget {
  const PodpineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appControllerProvider);
    return MaterialApp(
      title: 'Podpine',
      debugShowCheckedModeBanner: false,
      theme: PodpineTheme.light,
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
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PineMark(size: 64),
          SizedBox(height: 20),
          Text(
            'Podpine',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 20),
          SizedBox(
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
