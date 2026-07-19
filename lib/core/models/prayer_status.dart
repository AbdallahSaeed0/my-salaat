import '../../l10n/generated/app_localizations.dart';

/// How a prayer was completed for tracking/streak purposes. Absence of a
/// status for a prayer means "not marked yet".
enum PrayerStatus {
  prayed,
  late,
  missed;

  String label(AppLocalizations l10n) {
    switch (this) {
      case PrayerStatus.prayed:
        return l10n.statusPrayed;
      case PrayerStatus.late:
        return l10n.statusLate;
      case PrayerStatus.missed:
        return l10n.statusMissed;
    }
  }

  /// Counts toward a completed day / streak.
  bool get countsAsCompleted => this == prayed || this == late;
}
