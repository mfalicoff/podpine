import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../home/home_screen.dart';
import '../inbox/inbox_screen.dart';
import '../library/library_screen.dart';
import '../player/player_bar.dart';
import '../queue/queue_screen.dart';
import '../search/search_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    InboxScreen(),
    LibraryScreen(),
    QueueScreen(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PlayerBar(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: _InboxIcon(),
                selectedIcon: _InboxIcon(selected: true),
                label: 'Inbox',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.queue_music_outlined),
                selectedIcon: Icon(Icons.queue_music_rounded),
                label: 'Queue',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: app.busy
          ? const SizedBox(
              width: 42,
              height: 42,
              child: FloatingActionButton(
                onPressed: null,
                child: Padding(
                  padding: EdgeInsets.all(11),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : null,
    );
  }
}

class _InboxIcon extends ConsumerWidget {
  const _InboxIcon({this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(inboxUnreadCountProvider).valueOrNull ?? 0;
    return Badge(
      isLabelVisible: count > 0,
      label: Text(count > 99 ? '99+' : '$count'),
      child: Icon(selected ? Icons.inbox_rounded : Icons.inbox_outlined),
    );
  }
}
