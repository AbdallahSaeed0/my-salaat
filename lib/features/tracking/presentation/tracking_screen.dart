import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/prayer_status.dart';
import '../../../core/services/prayer_time_service.dart';
import '../application/tracking_provider.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayStatusesProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final actions = ref.watch(trackingActionsProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Tracking')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _StreakCard(streak: streakAsync.valueOrNull ?? 0),
          const SizedBox(height: 28),
          const _SectionLabel('Today'),
          todayAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Failed to load: $e'),
            data: (statuses) => Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: DailyPrayer.values
                      .map((prayer) => _TrackingRow(
                            prayer: prayer,
                            status: statuses[prayer],
                            onSelected: (status) {
                              if (status == statuses[prayer]) {
                                actions.clearStatus(prayer);
                              } else {
                                actions.setStatus(prayer, status);
                              }
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const _SectionLabel('This Month'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _MonthHeatmap(year: now.year, month: now.month),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

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

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department_rounded, size: 44, color: colorScheme.primary),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: colorScheme.primary),
              ),
              Text('day streak', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackingRow extends StatelessWidget {
  const _TrackingRow({required this.prayer, required this.status, required this.onSelected});

  final DailyPrayer prayer;
  final PrayerStatus? status;
  final ValueChanged<PrayerStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(prayer.label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: Wrap(
              spacing: 6,
              children: PrayerStatus.values.map((s) {
                final isSelected = status == s;
                return ChoiceChip(
                  label: Text(s.label),
                  selected: isSelected,
                  onSelected: (_) => onSelected(s),
                  showCheckmark: false,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeatmap extends ConsumerWidget {
  const _MonthHeatmap({required this.year, required this.month});

  final int year;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthAsync = ref.watch(monthStatusesProvider(MonthKey(year, month)));

    return monthAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Failed to load: $e'),
      data: (statuses) {
        final daysInMonth = DateTime(year, month + 1, 0).day;
        final firstWeekday = DateTime(year, month, 1).weekday % 7;
        final colorScheme = Theme.of(context).colorScheme;
        final today = DateTime.now();

        String key(int day) =>
            '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

        return GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < firstWeekday; i++) const SizedBox.shrink(),
            for (var day = 1; day <= daysInMonth; day++)
              Builder(builder: (context) {
                final dayStatuses = statuses[key(day)];
                final completedCount =
                    dayStatuses == null ? 0 : DailyPrayer.values.where((p) => dayStatuses[p]?.countsAsCompleted ?? false).length;
                final missedCount = dayStatuses == null ? 0 : dayStatuses.values.where((s) => s == PrayerStatus.missed).length;
                final isToday = year == today.year && month == today.month && day == today.day;

                Color color;
                if (dayStatuses == null || dayStatuses.isEmpty) {
                  color = colorScheme.surfaceContainerHighest;
                } else if (missedCount > 0 && completedCount == 0) {
                  color = colorScheme.errorContainer;
                } else {
                  final opacity = (completedCount / DailyPrayer.values.length).clamp(0.15, 1.0);
                  color = colorScheme.primary.withValues(alpha: opacity);
                }

                return Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday ? Border.all(color: colorScheme.primary, width: 2) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: completedCount > DailyPrayer.values.length / 2 ? colorScheme.onPrimary : colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
