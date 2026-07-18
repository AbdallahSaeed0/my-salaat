import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_reminder/core/models/prayer_status.dart';
import 'package:prayer_reminder/core/services/prayer_time_service.dart';
import 'package:prayer_reminder/core/services/prayer_tracking_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('setStatus/getStatusesForDate round-trips', () async {
    final service = PrayerTrackingService();
    final date = DateTime(2026, 7, 18);

    await service.setStatus(date, DailyPrayer.fajr, PrayerStatus.prayed);
    await service.setStatus(date, DailyPrayer.dhuhr, PrayerStatus.late);
    await service.setStatus(date, DailyPrayer.asr, PrayerStatus.missed);

    final statuses = await service.getStatusesForDate(date);
    expect(statuses[DailyPrayer.fajr], PrayerStatus.prayed);
    expect(statuses[DailyPrayer.dhuhr], PrayerStatus.late);
    expect(statuses[DailyPrayer.asr], PrayerStatus.missed);
    expect(statuses[DailyPrayer.maghrib], isNull);
  });

  test('setStatus overwrites a previous status for the same prayer/date', () async {
    final service = PrayerTrackingService();
    final date = DateTime(2026, 7, 19);

    await service.setStatus(date, DailyPrayer.isha, PrayerStatus.missed);
    await service.setStatus(date, DailyPrayer.isha, PrayerStatus.prayed);

    final statuses = await service.getStatusesForDate(date);
    expect(statuses[DailyPrayer.isha], PrayerStatus.prayed);
  });

  test('clearStatus removes a mark', () async {
    final service = PrayerTrackingService();
    final date = DateTime(2026, 7, 20);

    await service.setStatus(date, DailyPrayer.maghrib, PrayerStatus.prayed);
    await service.clearStatus(date, DailyPrayer.maghrib);

    final statuses = await service.getStatusesForDate(date);
    expect(statuses[DailyPrayer.maghrib], isNull);
  });

  test('streak counts consecutive fully-completed days and stops at a gap', () async {
    final service = PrayerTrackingService();
    final today = DateTime(2026, 7, 25);

    void markAllCompleted(DateTime date) {
      for (final prayer in DailyPrayer.values) {
        service.setStatus(date, prayer, PrayerStatus.prayed);
      }
    }

    // Complete today, yesterday, and the day before; leave a 3-day-ago gap
    // (missed Isha) which should stop the streak there.
    for (var i = 0; i <= 2; i++) {
      markAllCompleted(today.subtract(Duration(days: i)));
    }
    await Future.wait(DailyPrayer.values.map(
      (p) => service.setStatus(today.subtract(const Duration(days: 3)), p, p == DailyPrayer.isha ? PrayerStatus.missed : PrayerStatus.prayed),
    ));

    final streak = await service.getCurrentStreak(today: today);
    expect(streak, 3);
  });

  test('an incomplete today does not break the streak, just isn\'t counted yet', () async {
    final service = PrayerTrackingService();
    final today = DateTime(2026, 8, 1);

    for (final prayer in DailyPrayer.values) {
      await service.setStatus(today.subtract(const Duration(days: 1)), prayer, PrayerStatus.prayed);
    }
    // Today: only Fajr marked so far.
    await service.setStatus(today, DailyPrayer.fajr, PrayerStatus.prayed);

    final streak = await service.getCurrentStreak(today: today);
    expect(streak, 1);
  });

  test('getStatusesForRange returns entries keyed by yyyy-MM-dd', () async {
    final service = PrayerTrackingService();
    final date = DateTime(2026, 9, 5);
    await service.setStatus(date, DailyPrayer.fajr, PrayerStatus.prayed);

    final range = await service.getStatusesForRange(date, date);
    expect(range.containsKey('2026-09-05'), isTrue);
    expect(range['2026-09-05']![DailyPrayer.fajr], PrayerStatus.prayed);
  });
}
