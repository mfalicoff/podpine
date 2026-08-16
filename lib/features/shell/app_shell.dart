import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../core/l10n.dart';
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

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    InboxScreen(),
    LibraryScreen(),
    QueueScreen(),
    SearchScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final app = ref.read(appControllerProvider);
    final lastSync = app.lastSyncedAt;
    if (lastSync != null &&
        DateTime.now().difference(lastSync) < const Duration(minutes: 1)) {
      return;
    }
    unawaited(app.refresh(silent: true));
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(appControllerProvider);
    ref.watch(downloadManagerProvider);
    final destinations = _destinations(context);
    return Scaffold(
      body: CallbackShortcuts(
        bindings: {
          for (var index = 0; index < _pages.length; index++)
            SingleActivator(
              <LogicalKeyboardKey>[
                LogicalKeyboardKey.digit1,
                LogicalKeyboardKey.digit2,
                LogicalKeyboardKey.digit3,
                LogicalKeyboardKey.digit4,
                LogicalKeyboardKey.digit5,
              ][index],
              alt: true,
            ): () =>
                _select(index),
        },
        child: Focus(
          autofocus: true,
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useRail = constraints.maxWidth >= 840;
                if (!useRail) {
                  return IndexedStack(index: _index, children: _pages);
                }
                return Row(
                  children: [
                    Semantics(
                      container: true,
                      label: context.l10n.navigationLabel,
                      child: NavigationRail(
                        selectedIndex: _index,
                        onDestinationSelected: _select,
                        labelType: NavigationRailLabelType.all,
                        destinations: [
                          for (final destination in destinations)
                            NavigationRailDestination(
                              icon: destination.icon,
                              selectedIcon: destination.selectedIcon,
                              label: Text(destination.label),
                            ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: IndexedStack(
                              index: _index,
                              children: _pages,
                            ),
                          ),
                          const PlayerBar(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width >= 840
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PlayerBar(),
                Semantics(
                  container: true,
                  label: context.l10n.navigationLabel,
                  child: NavigationBar(
                    selectedIndex: _index,
                    onDestinationSelected: _select,
                    destinations: destinations,
                  ),
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

  void _select(int value) {
    if (_index != value) setState(() => _index = value);
  }

  List<NavigationDestination> _destinations(BuildContext context) {
    final l10n = context.l10n;
    Widget orderedIcon(int order, IconData icon) => Semantics(
      sortKey: OrdinalSortKey(order.toDouble()),
      excludeSemantics: true,
      child: Icon(icon),
    );

    return [
      NavigationDestination(
        icon: orderedIcon(0, Icons.home_outlined),
        selectedIcon: orderedIcon(0, Icons.home_rounded),
        label: l10n.home,
      ),
      NavigationDestination(
        icon: const _InboxIcon(),
        selectedIcon: const _InboxIcon(selected: true),
        label: l10n.inbox,
      ),
      NavigationDestination(
        icon: orderedIcon(2, Icons.library_music_outlined),
        selectedIcon: orderedIcon(2, Icons.library_music_rounded),
        label: l10n.library,
      ),
      NavigationDestination(
        icon: orderedIcon(3, Icons.queue_music_outlined),
        selectedIcon: orderedIcon(3, Icons.queue_music_rounded),
        label: l10n.queue,
      ),
      NavigationDestination(
        icon: orderedIcon(4, Icons.search_rounded),
        label: l10n.search,
      ),
    ];
  }
}

class _InboxIcon extends ConsumerWidget {
  const _InboxIcon({this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(inboxUnreadCountProvider).valueOrNull ?? 0;
    return Semantics(
      sortKey: const OrdinalSortKey(1),
      value: count > 0 ? '$count' : null,
      excludeSemantics: true,
      child: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: Icon(selected ? Icons.inbox_rounded : Icons.inbox_outlined),
      ),
    );
  }
}
