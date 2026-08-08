import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../home/home_screen.dart';
import '../encyclopedia/encyclopedia_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: const [
          HomeScreen(),
          EncyclopediaScreen(),
          HistoryScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: UrPlantTheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: (index) {
            ref.read(selectedTabProvider.notifier).state = index;
          },
          height: 64,
          backgroundColor: UrPlantTheme.surface,
          indicatorColor: UrPlantTheme.primaryAccent.withValues(alpha: 0.12),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 24),
              selectedIcon: Icon(Icons.home_rounded, size: 24),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined, size: 24),
              selectedIcon: Icon(Icons.menu_book_rounded, size: 24),
              label: 'Encyclopedia',
            ),
            NavigationDestination(
              icon: Icon(Icons.history, size: 24),
              selectedIcon: Icon(Icons.history_rounded, size: 24),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, size: 24),
              selectedIcon: Icon(Icons.person_rounded, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}