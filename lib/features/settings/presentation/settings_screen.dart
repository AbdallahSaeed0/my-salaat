import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/models/adhan_sound_mode.dart';
import '../../../core/models/calculation_settings.dart';
import '../../../core/services/adhan_audio_service.dart';
import '../../../core/services/prayer_time_service.dart';
import '../../prayer_times/application/prayer_times_provider.dart' show notificationServiceProvider;
import '../application/settings_provider.dart';

Future<void> _showNotificationsBlockedDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Notifications Are Blocked'),
      content: const Text(
        'This app doesn\'t have permission to show notifications, so nothing will appear or play — '
        'not even real prayer/Azkar reminders. Enable notifications for My Salaat in system settings, '
        'then try the test again.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: const Text('Open Settings'),
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

  static const _tabs = [
    (icon: Icons.calculate_outlined, label: 'Prayer'),
    (icon: Icons.volume_up_outlined, label: 'Adhan'),
    (icon: Icons.notifications_outlined, label: 'Reminders'),
    (icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: TabBar(
            tabs: [for (final tab in _tabs) Tab(icon: Icon(tab.icon), text: tab.label)],
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
    final settings = ref.watch(prayerSettingsProvider);
    final notifier = ref.read(prayerSettingsProvider.notifier);
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const _SectionHeader('Calculation Method'),
        Card(
          child: RadioGroup<PrayerCalculationMethod>(
            groupValue: settings.method,
            onChanged: (value) {
              if (value != null) notifier.setMethod(value);
            },
            child: Column(
              children: [
                for (final method in PrayerCalculationMethod.values) ...[
                  RadioListTile<PrayerCalculationMethod>(title: Text(method.label), value: method),
                  if (method != PrayerCalculationMethod.values.last)
                    Divider(height: 1, indent: 16, endIndent: 16, color: outline),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const _SectionHeader('Asr Calculation (Madhab)'),
        Card(
          child: RadioGroup<PrayerMadhab>(
            groupValue: settings.madhab,
            onChanged: (value) {
              if (value != null) notifier.setMadhab(value);
            },
            child: Column(
              children: [
                for (final madhab in PrayerMadhab.values) ...[
                  RadioListTile<PrayerMadhab>(title: Text(madhab.label), value: madhab),
                  if (madhab != PrayerMadhab.values.last)
                    Divider(height: 1, indent: 16, endIndent: 16, color: outline),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const _SectionHeader('Manual Adjustments'),
        Text(
          'Nudge each prayer to match your local mosque. Applies daily until changed.',
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
    final settings = ref.watch(prayerSettingsProvider);
    final notifier = ref.read(prayerSettingsProvider.notifier);
    final audio = ref.watch(_adhanAudioServiceProvider);
    _listenTo(audio);
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const _SectionHeader('Adhan Sound'),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Test Notification'),
                subtitle: const Text('Fires a real notification now, exactly as a prayer time would.'),
                trailing: PopupMenuButton<AdhanSoundMode>(
                  icon: const Icon(Icons.notifications_active_outlined),
                  tooltip: 'Send a test notification',
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
                      ),
                      'Test ${mode.label} notification sent',
                    );
                  },
                  itemBuilder: (context) =>
                      AdhanSoundMode.values.map((mode) => PopupMenuItem(value: mode, child: Text(mode.label))).toList(),
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
                        title: Text(reciter.name),
                        value: reciter.id,
                        secondary: IconButton(
                          icon: Icon(_playingReciterId == reciter.id ? Icons.stop_circle_outlined : Icons.play_circle_outline),
                          tooltip: _playingReciterId == reciter.id ? 'Stop' : 'Preview',
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
                title: const Text('Play full Adhan even in Silent Mode'),
                subtitle: const Text("Like an alarm — bypasses your phone's silent/vibrate setting."),
                value: settings.overrideSilentMode,
                onChanged: (value) async {
                  if (!value) {
                    notifier.setOverrideSilentMode(false);
                    return;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Override Silent Mode?'),
                      content: const Text(
                        'The full Adhan will play at full volume for prayers set to "Full Adhan", '
                        'even if your phone is on silent or vibrate. Prayers set to Short Sound or '
                        'Silent are not affected.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Allow')),
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
    final settings = ref.watch(prayerSettingsProvider);
    final notifier = ref.read(prayerSettingsProvider.notifier);
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const _SectionHeader('Azkar Reminders'),
        Text(
          'Occasional dhikr reminders at random times through the day.',
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Enable Azkar Reminders'),
                value: settings.azkarEnabled,
                onChanged: notifier.setAzkarEnabled,
              ),
              if (settings.azkarEnabled) ...[
                Divider(height: 1, indent: 16, endIndent: 16, color: outline),
                ListTile(
                  title: const Text('Reminders per day'),
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
                  title: const Text('Test Azkar Notification'),
                  subtitle: const Text('Fires a random azkar reminder now.'),
                  trailing: IconButton(
                    icon: const Icon(Icons.notifications_active_outlined),
                    tooltip: 'Send a test azkar notification',
                    onPressed: () async {
                      final notificationService = ref.read(notificationServiceProvider);
                      await notificationService.initialize();
                      if (!context.mounted) return;
                      await _runTest(
                        context,
                        notificationService.sendTestAzkarNotification,
                        'Test azkar notification sent',
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _SectionHeader('Friday — Surah Al-Kahf'),
        Text(
          'A weekly reminder every Friday morning to read سورة الكهف.',
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Enable Friday Reminder'),
                value: settings.fridayKahfReminderEnabled,
                onChanged: notifier.setFridayKahfReminderEnabled,
              ),
              Divider(height: 1, indent: 16, endIndent: 16, color: outline),
              ListTile(
                title: const Text('Test Friday Reminder'),
                subtitle: const Text('Fires the reminder now.'),
                trailing: IconButton(
                  icon: const Icon(Icons.notifications_active_outlined),
                  tooltip: 'Send a test Friday reminder',
                  onPressed: () async {
                    final notificationService = ref.read(notificationServiceProvider);
                    await notificationService.initialize();
                    if (!context.mounted) return;
                    await _runTest(
                      context,
                      notificationService.sendTestKahfReminder,
                      'Test Friday reminder sent',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _SectionHeader('Daily Ayah'),
        Text(
          'Show a random Quranic ayah each time you open the app.',
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            title: const Text('Show Ayah on App Open'),
            value: settings.showAyahOnOpen,
            onChanged: notifier.setShowAyahOnOpen,
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(prayerSettingsProvider).userName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const _SectionHeader('Your Name'),
        Text(
          'Used for the greeting on the home screen.',
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your name',
              ),
              textInputAction: TextInputAction.done,
              onChanged: (value) => ref.read(prayerSettingsProvider.notifier).setUserName(value),
            ),
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
    final label = minutes == 0 ? '0' : (minutes > 0 ? '+$minutes' : '$minutes');
    return ListTile(
      title: Text(prayer.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: minutes > _min ? () => onChanged(minutes - 1) : null,
          ),
          SizedBox(
            width: 52,
            child: Text('$label min', textAlign: TextAlign.center),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(prayer.label)),
          Expanded(
            child: SegmentedButton<AdhanSoundMode>(
              segments: const [
                ButtonSegment(value: AdhanSoundMode.full, label: Text('Full'), icon: Icon(Icons.volume_up)),
                ButtonSegment(value: AdhanSoundMode.short, label: Text('Short'), icon: Icon(Icons.notifications)),
                ButtonSegment(value: AdhanSoundMode.silent, label: Text('Silent'), icon: Icon(Icons.vibration)),
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
