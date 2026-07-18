import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calendar/presentation/hijri_calendar_screen.dart';
import '../../features/prayer_times/presentation/home_screen.dart';
import '../../features/qibla/presentation/qibla_screen.dart';
import '../../features/settings/application/settings_provider.dart';
import '../../features/tracking/presentation/tracking_screen.dart';
import 'ayah_popup.dart';

/// Hosts the app's top-level tabs.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    (icon: Icons.explore_outlined, selectedIcon: Icons.explore, label: 'Qibla'),
    (icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month, label: 'Calendar'),
    (icon: Icons.check_circle_outline, selectedIcon: Icons.check_circle, label: 'Tracking'),
  ];

  static const _screens = [
    HomeScreen(),
    QiblaScreen(),
    HijriCalendarScreen(),
    TrackingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(prayerSettingsProvider).showAyahOnOpen) {
        showRandomAyahDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(icon: Icon(tab.icon), selectedIcon: Icon(tab.selectedIcon), label: tab.label),
          ],
        ),
      ),
    );
  }
}
