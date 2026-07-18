import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/prayer_status.dart';
import '../../../core/services/prayer_time_service.dart';
import '../../../core/services/prayer_tracking_service.dart';

final prayerTrackingServiceProvider = Provider((ref) => PrayerTrackingService());

/// Bump this to force today's statuses / streak / month grid to reload
/// after a status change.
final trackingRevisionProvider = StateProvider((ref) => 0);

final todayStatusesProvider = FutureProvider<Map<DailyPrayer, PrayerStatus>>((ref) async {
  ref.watch(trackingRevisionProvider);
  return ref.watch(prayerTrackingServiceProvider).getStatusesForDate(DateTime.now());
});

final currentStreakProvider = FutureProvider<int>((ref) async {
  ref.watch(trackingRevisionProvider);
  return ref.watch(prayerTrackingServiceProvider).getCurrentStreak();
});

class MonthKey {
  const MonthKey(this.year, this.month);

  final int year;
  final int month;

  @override
  bool operator ==(Object other) => other is MonthKey && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

final monthStatusesProvider =
    FutureProvider.family<Map<String, Map<DailyPrayer, PrayerStatus>>, MonthKey>((ref, key) async {
  ref.watch(trackingRevisionProvider);
  final start = DateTime(key.year, key.month, 1);
  final end = DateTime(key.year, key.month + 1, 0);
  return ref.watch(prayerTrackingServiceProvider).getStatusesForRange(start, end);
});

class TrackingActions {
  TrackingActions(this.ref);

  final Ref ref;

  Future<void> setStatus(DailyPrayer prayer, PrayerStatus status) async {
    await ref.read(prayerTrackingServiceProvider).setStatus(DateTime.now(), prayer, status);
    ref.read(trackingRevisionProvider.notifier).state++;
  }

  Future<void> clearStatus(DailyPrayer prayer) async {
    await ref.read(prayerTrackingServiceProvider).clearStatus(DateTime.now(), prayer);
    ref.read(trackingRevisionProvider.notifier).state++;
  }
}

final trackingActionsProvider = Provider((ref) => TrackingActions(ref));
