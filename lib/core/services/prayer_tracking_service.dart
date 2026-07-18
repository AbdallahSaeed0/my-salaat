import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/prayer_status.dart';
import 'prayer_time_service.dart';

/// Local SQLite-backed history of which prayers were prayed/late/missed,
/// keyed by calendar date. Used for the streak counter and monthly heatmap.
class PrayerTrackingService {
  Database? _db;

  Future<Database> _database() async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = p.join(await getDatabasesPath(), 'prayer_tracking.db');
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE prayer_log ('
        'date TEXT NOT NULL, '
        'prayer TEXT NOT NULL, '
        'status TEXT NOT NULL, '
        'PRIMARY KEY (date, prayer)'
        ')',
      ),
    );
    _db = db;
    return db;
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> setStatus(DateTime date, DailyPrayer prayer, PrayerStatus status) async {
    final db = await _database();
    await db.insert(
      'prayer_log',
      {'date': _dateKey(date), 'prayer': prayer.name, 'status': status.name},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearStatus(DateTime date, DailyPrayer prayer) async {
    final db = await _database();
    await db.delete(
      'prayer_log',
      where: 'date = ? AND prayer = ?',
      whereArgs: [_dateKey(date), prayer.name],
    );
  }

  Future<Map<DailyPrayer, PrayerStatus>> getStatusesForDate(DateTime date) async {
    final range = await getStatusesForRange(date, date);
    return range[_dateKey(date)] ?? {};
  }

  /// Inclusive date range, returned as a map keyed by 'yyyy-MM-dd'.
  Future<Map<String, Map<DailyPrayer, PrayerStatus>>> getStatusesForRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _database();
    final rows = await db.query(
      'prayer_log',
      where: 'date >= ? AND date <= ?',
      whereArgs: [_dateKey(start), _dateKey(end)],
    );

    final result = <String, Map<DailyPrayer, PrayerStatus>>{};
    for (final row in rows) {
      final dateKey = row['date'] as String;
      final prayer = DailyPrayer.values.firstWhere((p) => p.name == row['prayer']);
      final status = PrayerStatus.values.firstWhere((s) => s.name == row['status']);
      (result[dateKey] ??= {})[prayer] = status;
    }
    return result;
  }

  /// Consecutive days (counting back from [today]) where all five prayers
  /// are marked prayed/late. A not-yet-complete today doesn't break the
  /// streak — it's simply not counted until finished.
  Future<int> getCurrentStreak({DateTime? today}) async {
    final referenceDate = today ?? DateTime.now();
    final start = referenceDate.subtract(const Duration(days: 400));
    final range = await getStatusesForRange(start, referenceDate);

    bool isComplete(DateTime date) {
      final statuses = range[_dateKey(date)];
      if (statuses == null) return false;
      return DailyPrayer.values.every((p) => statuses[p]?.countsAsCompleted ?? false);
    }

    var cursor = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    if (!isComplete(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (isComplete(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
