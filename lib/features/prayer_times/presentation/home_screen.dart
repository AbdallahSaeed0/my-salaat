import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/services/prayer_time_service.dart';
import '../../settings/application/settings_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/prayer_times_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final Timer _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);
    final prayerTimeService = ref.watch(prayerTimeServiceProvider);
    final calculationLocation = ref.watch(calculationLocationProvider).valueOrNull;
    final userName = ref.watch(prayerSettingsProvider).userName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Salaat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentPositionProvider);
          await ref.read(todayPrayerTimesProvider.future);
        },
        child: prayerTimesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(currentPositionProvider),
          ),
          data: (data) {
            final next = prayerTimeService.nextPrayer(
              data.times,
              _now,
              tomorrowFajr: data.tomorrowFajr,
            );
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                if (userName.trim().isNotEmpty) ...[
                  _Greeting(name: userName.trim()),
                  const SizedBox(height: 12),
                ],
                _DateHeader(cityLabel: calculationLocation?.cityLabel),
                const SizedBox(height: 20),
                _NextPrayerCard(prayer: next.prayer, time: next.time, now: _now),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'TODAY',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 1.4),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final p in DailyPrayer.values) ...[
                          _PrayerRow(
                            prayer: p,
                            time: data.times[p]!,
                            isNext: p == next.prayer && data.times[p] == next.time,
                          ),
                          if (p != DailyPrayer.values.last)
                            Divider(height: 1, indent: 20, endIndent: 20, color: Theme.of(context).colorScheme.outlineVariant),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      'سلام عليكم $name',
      textDirection: TextDirection.rtl,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({this.cityLabel});

  final String? cityLabel;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final gregorian = DateFormat.yMMMMd().format(now);
    final hijri = HijriCalendar.now().fullDate();
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hijri, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                gregorian + (cityLabel != null ? ' · $cityLabel' : ''),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.prayer, required this.time, required this.now});

  final DailyPrayer prayer;
  final DateTime time;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final remaining = time.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    final countdown =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'NEXT PRAYER',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: colorScheme.onSurfaceVariant, letterSpacing: 1.4),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            prayer.label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat.jm().format(time),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Text(
            countdown,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 2,
                ),
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.prayer, required this.time, required this.isNext});

  final DailyPrayer prayer;
  final DateTime time;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isNext ? colorScheme.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: isNext ? null : Border.all(color: colorScheme.outlineVariant, width: 1.5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              prayer.label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: isNext ? FontWeight.w700 : FontWeight.w500),
            ),
          ),
          Text(
            DateFormat.jm().format(time),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isNext ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
