import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/models/adhan_sound_mode.dart';
import '../../../core/models/calculation_settings.dart';
import '../../../core/presentation/root_shell.dart' show updateServiceProvider;
import '../../../core/presentation/update_dialog.dart';
import '../../../core/services/adhan_audio_service.dart';
import '../../../core/services/prayer_time_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../prayer_times/application/prayer_times_provider.dart' show notificationServiceProvider;
import '../application/settings_provider.dart';

Future<void> _showNotificationsBlockedDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.notificationsBlockedTitle),
      content: Text(l10n.notificationsBlockedContent),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: Text(l10n.openSettings),
        ),
      ],
    ),
  );
}

Future<void> _runTest(BuildContext context, Future<bool> Function() send, String successMessage) async {
  final sent = await send();
  if (!context.mounted) return;
  if (sent) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
  } else {
    await _showNotificationsBlockedDialog(context);
  }
}

final _adhanAudioServiceProvider = Provider((ref) {
  final service = AdhanAudioService();
  ref.onDispose(service.dispose);
  return service;
});

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      (icon: Icons.calculate_outlined, label: l10n.tabPrayer),
      (icon: Icons.volume_up_outlined, label: l10n.tabAdhan),
      (icon: Icons.notifications_outlined, label: l10n.tabReminders),
      (icon: Icons.person_outline, label: l10n.tabProfile),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsTitle),
          bottom: TabBar(
            tabs: [for (final tab in tabs) Tab(icon: Icon(tab.icon), text: tab.label)],
          ),
        ),
        body: const TabBarView(
          children: [
            _PrayerTab(),
            _AdhanTab(),
            _RemindersTab(),
            _ProfileTab(),
          ],
        ),
      ),
    );
  }
}

class _PrayerTab extends ConsumerWidget {
  const _PrayerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(prayerSettingsProvider);
    final notifier = ref.read(prayerSettingsProvider.notifier);
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _SectionHeader(l10n.sectionCalculationMethod),
        Card(
          child: RadioGroup<PrayerCalculationMethod>(
            groupValue: settings.method,
            onChanged: (value) {
              if (value != null) notifier.setMethod(value);
            },
            child: Column(
              children: [
                for (final method in PrayerCalculationMethod.values) ...[
                  RadioListTile<PrayerCalculationMethod>(title: Text(method.label(l10n)), value: method),
                  if (method != PrayerCalculationMethod.values.last)
                    Divider(height: 1, indent: 16, endIndent: 16, color: outline),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(l10n.sectionMadhab),
        Card(
          child: RadioGroup<PrayerMadhab>(
            groupValue: settings.madhab,
            onChanged: (value) {
              if (value != null) notifier.setMadhab(value);
            },
            child: Column(
              children: [
                for (final madhab in PrayerMadhab.values) ...[
                  RadioListTile<PrayerMadhab>(title: Text(madhab.label(l10n)), value: madhab),
                  if (madhab != PrayerMadhab.values.last) Divider(height: 1, indent: 16, endIndent: 16, color: outline),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(l10n.sectionManualAdjustments),
        Text(
          l10n.manualAdjustmentsDesc,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (final prayer in DailyPrayer.values) ...[
                _AdjustmentRow(
                  prayer: prayer,
                  minutes: settings.adjustments[prayer] ?? 0,
                  onChanged: (minutes) => notifier.setAdjustment(prayer, minutes),
                ),
                if (prayer != DailyPrayer.values.last) Divider(height: 1, indent: 16, endIndent: 16, color: outline),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AdhanTab extends ConsumerStatefulWidget {
  const _AdhanTab();

  @override
  ConsumerState<_AdhanTab> createState() => _AdhanTabState();
}

class _AdhanTabState extends ConsumerState<_AdhanTab> {
  String? _playingReciterId;
  StreamSubscription<void>? _completeSub;

  void _listenTo(AdhanAudioService audio) {
    _completeSub ??= audio.onComplete.listen((_) {
      if (mounted) setState(() => _playingReciterId = null);
    });
  }

  Future<void> _togglePreview(AdhanAudioService audio, Reciter reciter) async {
    if (_playingReciterId == reciter.id) {
      await audio.stop();
      setState(() => _playingReciterId = null);
    } else {
      await audio.playReciter(reciter);
      setState(() => _playingReciterId = reciter.id);
    }
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(prayerSettingsProvider);
    final notifier = ref.read(prayerSettingsProvider.notifier);
    final audio = ref.watch(_adhanAudioServiceProvider);
    _listenTo(audio);
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final locale = Locale(settings.languageCode);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _SectionHeader(l10n.sectionAdhanSound),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(l10n.testNotificationTitle),
                subtitle: Text(l10n.testNotificationDesc),
                trailing: PopupMenuButton<AdhanSoundMode>(
                  icon: const Icon(Icons.notifications_active_outlined),
                  tooltip: l10n.sendTestNotificationTooltip,
                  onSelected: (mode) async {
                    final notificationService = ref.read(notificationServiceProvider);
                    await notificationService.initialize();
                    if (!context.mounted) return;
                    await _runTest(
                      context,
                      () => notificationService.sendTestNotification(
                        mode: mode,
                        reciter: settings.reciter,
                        overrideSilentMode: settings.overrideSilentMode,
                        locale: locale,
                      ),
                      l10n.testNotificationSent(mode.label(l10n)),
                    );
                  },
                  itemBuilder: (context) =>
                      AdhanSoundMode.values.map((mode) => PopupMenuItem(value: mode, child: Text(mode.label(l10n)))).toList(),
                ),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: outline),
              RadioGroup<String>(
                groupValue: settings.reciterId,
                onChanged: (value) {
                  if (value != null) notifier.setReciter(value);
                },
                child: Column(
                  children: [
                    for (final reciter in availableReciters) ...[
                      RadioListTile<String>(
                        title: Text(reciter.localizedName(l10n)),
                        value: reciter.id,
                        secondary: IconButton(
                          icon: Icon(_playingReciterId == reciter.id ? Icons.stop_circle_outlined : Icons.play_circle_outline),
                          tooltip: _playingReciterId == reciter.id ? l10n.stopTooltip : l10n.previewTooltip,
                          onPressed: () => _togglePreview(audio, reciter),
                        ),
                      ),
                      if (reciter != availableReciters.last) Divider(height: 1, indent: 16, endIndent: 16, color: outline),
                    ],
                  ],
                ),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: outline),
              SwitchListTile(
                title: Text(l10n.overrideSilentTitle),
                subtitle: Text(l10n.overrideSilentDesc),
                value: settings.overrideSilentMode,
                onChanged: (value) async {
                  if (!value) {
                    notifier.setOverrideSilentMode(false);
                    return;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.overrideSilentDialogTitle),
                      content: Text(l10n.overrideSilentDialogContent),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.allow)),
                      ],
                    ),
                  );
                  if (confirmed == true) notifier.setOverrideSilentMode(true);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final prayer in DailyPrayer.values) ...[
                  _SoundModeRow(
                    prayer: prayer,
                    mode: settings.soundModes[prayer] ?? AdhanSoundMode.full,
                    onChanged: (mode) => notifier.setSoundMode(prayer, mode),
                  ),
                  if (prayer != DailyPrayer.values.last) Divider(height: 1, indent: 16, endIndent: 16, color: outline),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RemindersTab extends ConsumerWidget {
  const _RemindersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(prayerSettingsProvider);
    final notifier = ref.read(prayerSettingsProvider.notifier);
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _SectionHeader(l10n.sectionAzkarReminders),
        Text(
          l10n.azkarDesc,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(l10n.enableAzkarReminders),
                value: settings.azkarEnabled,
                onChanged: notifier.setAzkarEnabled,
              ),
              if (settings.azkarEnabled) ...[
                Divider(height: 1, indent: 16, endIndent: 16, color: outline),
                ListTile(
                  title: Text(l10n.remindersPerDay),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: settings.azkarCount > 1 ? () => notifier.setAzkarCount(settings.azkarCount - 1) : null,
                      ),
                      SizedBox(width: 24, child: Text('${settings.azkarCount}', textAlign: TextAlign.center)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: settings.azkarCount < 12 ? () => notifier.setAzkarCount(settings.azkarCount + 1) : null,
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: outline),
                ListTile(
                  title: Text(l10n.testAzkarNotification),
                  subtitle: Text(l10n.testAzkarDesc),
                  trailing: IconButton(
                    icon: const Icon(Icons.notifications_active_outlined),
                    tooltip: l10n.sendTestAzkarTooltip,
                    onPressed: () async {
                      final notificationService = ref.read(notificationServiceProvider);
                      await notificationService.initialize();
                      if (!context.mounted) return;
                      await _runTest(
                        context,
                        notificationService.sendTestAzkarNotification,
                        l10n.testAzkarSent,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(l10n.sectionFridayKahf),
        Text(
          l10n.fridayKahfDesc,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(l10n.enableFridayReminder),
                value: settings.fridayKahfReminderEnabled,
                onChanged: notifier.setFridayKahfReminderEnabled,
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: outline),
              ListTile(
                title: Text(l10n.testFridayReminder),
                subtitle: Text(l10n.testFridayDesc),
                trailing: IconButton(
                  icon: const Icon(Icons.notifications_active_outlined),
                  tooltip: l10n.sendTestFridayTooltip,
                  onPressed: () async {
                    final notificationService = ref.read(notificationServiceProvider);
                    await notificationService.initialize();
                    if (!context.mounted) return;
                    await _runTest(
                      context,
                      notificationService.sendTestKahfReminder,
                      l10n.testFridaySent,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(l10n.sectionDailyAyah),
        Text(
          l10n.dailyAyahDesc,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            title: Text(l10n.showAyahOnOpen),
            value: settings.showAyahOnOpen,
            onChanged: notifier.setShowAyahOnOpen,
          ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(l10n.sectionNextPrayerStatus),
        Text(
          l10n.nextPrayerStatusDesc,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            title: Text(l10n.enableNextPrayerStatus),
            value: settings.nextPrayerStatusEnabled,
            onChanged: notifier.setNextPrayerStatusEnabled,
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends ConsumerStatefulWidget {
  const _ProfileTab();

  @override
  ConsumerState<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<_ProfileTab> {
  late final TextEditingController _controller;
  String? _versionText;
  bool _checkingForUpdate = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(prayerSettingsProvider).userName);
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _versionText = info.version);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _checkingForUpdate = true);
    try {
      final service = ref.read(updateServiceProvider);
      final info = await service.checkForUpdate(force: true);
      if (!mounted) return;
      if (info != null) {
        await showUpdateAvailableDialog(context, service, info);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.upToDate)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.updateCheckFailed)));
      }
    } finally {
      if (mounted) setState(() => _checkingForUpdate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(prayerSettingsProvider);
    final notifier = ref.read(prayerSettingsProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _SectionHeader(l10n.sectionYourName),
        Text(
          l10n.yourNameDesc,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.enterYourName,
              ),
              textInputAction: TextInputAction.done,
              onChanged: (value) => ref.read(prayerSettingsProvider.notifier).setUserName(value),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(l10n.sectionLanguage),
        Card(
          child: RadioGroup<String>(
            groupValue: settings.languageCode,
            onChanged: (value) {
              if (value != null) notifier.setLanguageCode(value);
            },
            child: Column(
              children: [
                RadioListTile<String>(title: Text(l10n.languageEnglish), value: 'en'),
                Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant),
                RadioListTile<String>(title: Text(l10n.languageArabic), value: 'ar'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(l10n.sectionAbout),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(l10n.appVersionLabel),
                trailing: Text(_versionText ?? '…'),
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).colorScheme.outlineVariant),
              ListTile(
                title: Text(l10n.checkForUpdates),
                trailing: _checkingForUpdate
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.system_update_outlined),
                onTap: _checkingForUpdate ? null : _checkForUpdates,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            l10n.madeByCredit,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 1.4),
      ),
    );
  }
}

class _AdjustmentRow extends StatelessWidget {
  const _AdjustmentRow({required this.prayer, required this.minutes, required this.onChanged});

  final DailyPrayer prayer;
  final int minutes;
  final ValueChanged<int> onChanged;

  static const _min = -30;
  static const _max = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = minutes == 0 ? '0' : (minutes > 0 ? '+$minutes' : '$minutes');
    return ListTile(
      title: Text(prayer.label(l10n)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: minutes > _min ? () => onChanged(minutes - 1) : null,
          ),
          SizedBox(
            width: 52,
            child: Text(l10n.minutesValueLabel(label), textAlign: TextAlign.center),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: minutes < _max ? () => onChanged(minutes + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _SoundModeRow extends StatelessWidget {
  const _SoundModeRow({required this.prayer, required this.mode, required this.onChanged});

  final DailyPrayer prayer;
  final AdhanSoundMode mode;
  final ValueChanged<AdhanSoundMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(prayer.label(l10n))),
          Expanded(
            child: SegmentedButton<AdhanSoundMode>(
              segments: [
                ButtonSegment(value: AdhanSoundMode.full, label: Text(l10n.soundModeFullCompact), icon: const Icon(Icons.volume_up)),
                ButtonSegment(value: AdhanSoundMode.short, label: Text(l10n.soundModeShortCompact), icon: const Icon(Icons.notifications)),
                ButtonSegment(value: AdhanSoundMode.silent, label: Text(l10n.soundModeSilentCompact), icon: const Icon(Icons.vibration)),
              ],
              selected: {mode},
              onSelectionChanged: (selection) => onChanged(selection.first),
              showSelectedIcon: false,
            ),
          ),
        ],
      ),
    );
  }
}
