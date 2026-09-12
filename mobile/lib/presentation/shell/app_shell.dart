import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import '../encyclopedia/encyclopedia_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../camera/camera_screen.dart';

final selectedTabProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);
    final l = AppLocalizations.of(context);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedTab,
        children: const [
          HomeScreen(),
          EncyclopediaScreen(),
          HistoryScreen(),
          ProfileScreen(),
        ],
      ),
      // Floating pill dock with a raised scan FAB (Playful Guide DNA)
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 10 + MediaQuery.paddingOf(context).bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 34), // optical balance vs FAB bulge
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: UrPlantTheme.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: UrPlantTheme.line),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x2E14281B),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      children: [
                        _dockItem(l.nav_home, Icons.explore_outlined, Icons.explore_rounded, 0, selectedTab, ref),
                        _dockItem(l.nav_encyclopedia, Icons.menu_book_outlined, Icons.menu_book_rounded, 1, selectedTab, ref),
                        const SizedBox(width: 52), // room under the FAB
                        _dockItem(l.nav_history, Icons.history_rounded, Icons.history_toggle_off_rounded, 2, selectedTab, ref),
                        _dockItem(l.nav_profile, Icons.person_outline_rounded, Icons.person_rounded, 3, selectedTab, ref),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 34),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -10),
        child: _ScanFab(l10n: l),
      ),
    );
  }

  Widget _dockItem(String label, IconData idle, IconData active, int index,
      int selected, WidgetRef ref) {
    final on = selected == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: on,
        label: label,
        child: _DockItem(index, ref, on, label, idle, active),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final int index; final WidgetRef ref; final bool on; final String label;
  final IconData idle; final IconData active;
  const _DockItem(this.index, this.ref, this.on, this.label, this.idle, this.active);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => ref.read(selectedTabProvider.notifier).state = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: on ? UrPlantTheme.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: Tween<double>(begin: 0.7, end: 1).animate(anim), child: child),
              child: Icon(on ? active : idle,
                key: ValueKey(on),
                size: on ? 26 : 24,
                color: on ? UrPlantTheme.primaryDark : UrPlantTheme.inkFaint),
            ),
            const SizedBox(height: 2),
            Text(label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                color: on ? UrPlantTheme.primaryDark : UrPlantTheme.inkFaint,
                height: 1.1,
              )),
          ],
        ),
      ),
    );
  }
}

class _ScanFab extends StatelessWidget {
  final AppLocalizations l10n;
  const _ScanFab({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: l10n.nav_scan,
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CameraScreen(), fullscreenDialog: true)),
        child: Container(
          width: 62, height: 62,
          decoration: BoxDecoration(
            gradient: UrPlantTheme.leafGradient,
            shape: BoxShape.circle,
            border: Border.all(color: UrPlantTheme.primaryEdge, width: 2),
            boxShadow: const [
              BoxShadow(color: UrPlantTheme.primaryEdge, offset: Offset(0, 5)),
              BoxShadow(color: Color(0x3314281B), blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
