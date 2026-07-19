import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/prayer_time_service.dart';
import '../../settings/application/settings_provider.dart';

final locationServiceProvider = Provider((ref) => LocationService());
final prayerTimeServiceProvider = Provider((ref) => PrayerTimeService());
final notificationServiceProvider = Provider((ref) => NotificationService());

/// Fetches the device's current GPS position. Call `ref.invalidate` on this
/// provider to retry after a permission/location error.
final currentPositionProvider = FutureProvider<Position>((ref) {
  return ref.watch(locationServiceProvider).getCurrentLocation();
});

/// Resolves the raw GPS position to its city center, so prayer times match
/// what an official per-city table would publish instead of drifting with
/// GPS jitter between neighbors in the same city.
final calculationLocationProvider = FutureProvider<CalculationLocation>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  return ref.watch(locationServiceProvider).resolveCalculationLocation(position);
});

class TodayPrayerTimes {
  const TodayPrayerTimes({required this.times, required this.tomorrowFajr});

  final Map<DailyPrayer, DateTime> times;
  final DateTime tomorrowFajr;
}

/// Computes today's five prayer times (plus tomorrow's Fajr, for the
/// post-Isha countdown) from the current location and calculation settings,
/// then schedules local notifications for them.
final todayPrayerTimesProvider = FutureProvider<TodayPrayerTimes>((ref) async {
  final location = await ref.watch(calculationLocationProvider.future);
  final settings = ref.watch(prayerSettingsProvider);
  final service = ref.watch(prayerTimeServiceProvider);

  final now = DateTime.now();
  final today = service.calculateForDate(
    date: now,
    latitude: location.latitude,
    longitude: location.longitude,
    method: settings.method,
    madhab: settings.madhab,
    minuteAdjustments: settings.adjustments,
  );
  final tomorrow = service.calculateForDate(
    date: now.add(const Duration(days: 1)),
    latitude: location.latitude,
    longitude: location.longitude,
    method: settings.method,
    madhab: settings.madhab,
    minuteAdjustments: settings.adjustments,
  );

  final times = service.asMap(today);

  final notificationService = ref.watch(notificationServiceProvider);
  await notificationService.initialize();
  await notificationService.scheduleDailyPrayerNotifications(
    times,
    soundModes: settings.soundModes,
    reciter: settings.reciter,
    overrideSilentMode: settings.overrideSilentMode,
    locale: Locale(settings.languageCode),
  );

  if (settings.azkarEnabled) {
    await notificationService.scheduleRandomAzkarNotifications(count: settings.azkarCount);
  } else {
    await notificationService.cancelAllAzkarNotifications();
  }

  await notificationService.scheduleFridayKahfReminder(enabled: settings.fridayKahfReminderEnabled);

  final tomorrowFajr = tomorrow.fajr.toLocal();
  final locale = Locale(settings.languageCode);
  if (settings.nextPrayerStatusEnabled) {
    final next = service.nextPrayer(times, now, tomorrowFajr: tomorrowFajr);
    await notificationService.showNextPrayerStatus(prayer: next.prayer, time: next.time, locale: locale);

    final following = service.nextPrayer(
      times,
      next.time.add(const Duration(seconds: 1)),
      tomorrowFajr: tomorrowFajr,
    );
    await notificationService.scheduleNextPrayerStatusUpdate(
      currentNextTime: next.time,
      followingPrayer: following.prayer,
      followingTime: following.time,
      locale: locale,
    );
  } else {
    await notificationService.cancelNextPrayerStatus();
  }

  return TodayPrayerTimes(times: times, tomorrowFajr: tomorrowFajr);
});
