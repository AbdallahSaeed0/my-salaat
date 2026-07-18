/// How a prayer was completed for tracking/streak purposes. Absence of a
/// status for a prayer means "not marked yet".
enum PrayerStatus {
  prayed('Prayed'),
  late('Prayed Late'),
  missed('Missed');

  const PrayerStatus(this.label);

  final String label;

  /// Counts toward a completed day / streak.
  bool get countsAsCompleted => this == prayed || this == late;
}
