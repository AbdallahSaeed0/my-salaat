import 'package:adhan_dart/adhan_dart.dart';

import '../models/calculation_settings.dart';

/// The five daily obligatory prayers (excludes sunrise, which adhan_dart
/// exposes only as a reference point for the Dhuhr/Asr window).
enum DailyPrayer { fajr, dhuhr, asr, maghrib, isha }

extension DailyPrayerLabel on DailyPrayer {
  String get label {
    switch (this) {
      case DailyPrayer.fajr:
        return 'Fajr';
      case DailyPrayer.dhuhr:
        return 'Dhuhr';
      case DailyPrayer.asr:
        return 'Asr';
      case DailyPrayer.maghrib:
        return 'Maghrib';
      case DailyPrayer.isha:
        return 'Isha';
    }
  }
}

/// Computes prayer times for a given day/location/method using adhan_dart,
/// applying per-prayer minute adjustments on top of the raw calculation.
class PrayerTimeService {
  PrayerTimes calculateForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
    required PrayerCalculationMethod method,
    required PrayerMadhab madhab,
    Map<DailyPrayer, int> minuteAdjustments = const {},
  }) {
    final params = method.toParameters();
    params.madhab = madhab.toMadhab();
    if (minuteAdjustments.isNotEmpty) {
      params.adjustments = {
        Prayer.fajr: minuteAdjustments[DailyPrayer.fajr] ?? 0,
        Prayer.dhuhr: minuteAdjustments[DailyPrayer.dhuhr] ?? 0,
        Prayer.asr: minuteAdjustments[DailyPrayer.asr] ?? 0,
        Prayer.maghrib: minuteAdjustments[DailyPrayer.maghrib] ?? 0,
        Prayer.isha: minuteAdjustments[DailyPrayer.isha] ?? 0,
      };
    }

    return PrayerTimes(
      date: date,
      coordinates: Coordinates(latitude, longitude),
      calculationParameters: params,
    );
  }

  /// adhan_dart returns UTC-tagged DateTimes (the absolute instant is
  /// correct, but the wall-clock fields must be converted with [toLocal]
  /// before display/scheduling or they'll read as the raw UTC hour).
  Map<DailyPrayer, DateTime> asMap(PrayerTimes times) => {
        DailyPrayer.fajr: times.fajr.toLocal(),
        DailyPrayer.dhuhr: times.dhuhr.toLocal(),
        DailyPrayer.asr: times.asr.toLocal(),
        DailyPrayer.maghrib: times.maghrib.toLocal(),
        DailyPrayer.isha: times.isha.toLocal(),
      };

  /// Returns the next prayer (today or tomorrow's Fajr) relative to [now],
  /// resolved against the five obligatory prayers only.
  ({DailyPrayer prayer, DateTime time}) nextPrayer(
    Map<DailyPrayer, DateTime> today,
    DateTime now, {
    DateTime? tomorrowFajr,
  }) {
    for (final prayer in DailyPrayer.values) {
      final time = today[prayer]!;
      if (time.isAfter(now)) {
        return (prayer: prayer, time: time);
      }
    }
    return (prayer: DailyPrayer.fajr, time: tomorrowFajr ?? today[DailyPrayer.fajr]!);
  }
}
