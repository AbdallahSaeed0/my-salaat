import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calendar/presentation/hijri_calendar_screen.dart';
import '../../features/prayer_times/presentation/home_screen.dart';
import '../../features/qibla/presentation/qibla_screen.dart';
import '../../features/settings/application/settings_provider.dart';
import '../../features/tracking/presentation/tracking_screen.dart';
import '../../l10n/generated/app_localizations.dart';
import '../services/update_service.dart';
import 'ayah_popup.dart';
import 'update_dialog.dart';

final updateServiceProvider = Provider((ref) => UpdateService());

/// Hosts the app's top-level tabs.
class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    QiblaScreen(),
    HijriCalendarScreen(),
    TrackingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Settings load from disk asynchronously — wait for that to finish so
      // this reads what the user actually saved, not the provider's
      // just-constructed defaults.
      await ref.read(prayerSettingsProvider.notifier).ready;
      if (!mounted) return;
      if (ref.read(prayerSettingsProvider).showAyahOnOpen) {
        showRandomAyahDialog(context);
      }
      _checkForUpdateSilently();
    });
  }

  Future<void> _checkForUpdateSilently() async {
    try {
      final info = await ref.read(updateServiceProvider).checkForUpdate();
      if (info == null || !mounted) return;
      await showUpdateAvailableDialog(context, ref.read(updateServiceProvider), info);
    } catch (_) {
      // Silent on-launch check — network hiccups shouldn't interrupt the
      // user; the Settings "Check for Updates" button surfaces failures.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      (icon: Icons.home_outlined, selectedIcon: Icons.home, label: l10n.navHome),
      (icon: Icons.explore_outlined, selectedIcon: Icons.explore, label: l10n.navQibla),
      (icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month, label: l10n.navCalendar),
      (icon: Icons.check_circle_outline, selectedIcon: Icons.check_circle, label: l10n.navTracking),
    ];

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
            for (final tab in tabs)
              NavigationDestination(icon: Icon(tab.icon), selectedIcon: Icon(tab.selectedIcon), label: tab.label),
          ],
        ),
      ),
    );
  }
}
