import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../providers/app_provider.dart';
import 'journal_screen.dart';
import 'strategy_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

// ── Tab destination model ─────────────────────────────────────────────────────
class _Tab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  const _Tab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}

const _tabs = [
  _Tab(
    label:      'Journal',
    icon:       Icons.book_outlined,
    activeIcon: Icons.book,
    path:       '/journal',
  ),
  _Tab(
    label:      'Vault',
    icon:       Icons.shield_outlined,
    activeIcon: Icons.shield,
    path:       '/vault',
  ),
  _Tab(
    label:      'Analytics',
    icon:       Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
    path:       '/analytics',
  ),
  _Tab(
    label:      'Settings',
    icon:       Icons.person_outline,
    activeIcon: Icons.person,
    path:       '/settings',
  ),
];

// ── Shell Screen ──────────────────────────────────────────────────────────────
class ShellScreen extends StatefulWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAll();
    });
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => t.path == location);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: C.background,
          border: Border(
            top: BorderSide(color: C.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex:        currentIndex,
          backgroundColor:     C.background,
          elevation:           0,
          type:                BottomNavigationBarType.fixed,
          selectedItemColor:   C.accent,
          unselectedItemColor: C.muted,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize:   11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize:   11,
          ),
          onTap: (index) => context.go(_tabs[index].path),
          items: _tabs.map((tab) {
            return BottomNavigationBarItem(
              icon:       Icon(tab.icon,       size: 22),
              activeIcon: Icon(tab.activeIcon, size: 22),
              label:      tab.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Tab wrapper widgets (used by router) ──────────────────────────────────────
class JournalTab extends StatelessWidget {
  const JournalTab({super.key});
  @override
  Widget build(BuildContext context) => const JournalScreen();
}

class VaultTab extends StatelessWidget {
  const VaultTab({super.key});
  @override
  Widget build(BuildContext context) => const StrategyScreen();
}

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});
  @override
  Widget build(BuildContext context) => const AnalyticsScreen();
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  @override
  Widget build(BuildContext context) => const SettingsScreen();
}