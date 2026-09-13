import '../../domain/entities/quest.dart';

class QuestPeriodManager {
  static (DateTime, DateTime) currentDailyPeriod([DateTime? now]) {
    final dt = now ?? DateTime.now();
    final start = DateTime(dt.year, dt.month, dt.day, 0, 0, 0);
    final end = DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);
    return (start, end);
  }

  static (DateTime, DateTime) currentWeeklyPeriod([DateTime? now]) {
    final dt = now ?? DateTime.now();
    // ISO 8601 week: Monday is 1, Sunday is 7
    final daysToSubtract = dt.weekday - 1;
    final monday = DateTime(dt.year, dt.month, dt.day, 0, 0, 0)
        .subtract(Duration(days: daysToSubtract));
    final sunday = monday
        .add(const Duration(days: 6))
        .add(const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    return (monday, sunday);
  }

  static (DateTime, DateTime) currentMonthlyPeriod([DateTime? now]) {
    final dt = now ?? DateTime.now();
    final start = DateTime(dt.year, dt.month, 1, 0, 0, 0);
    // Next month day 0 is last day of current month
    final end = DateTime(dt.year, dt.month + 1, 0, 23, 59, 59, 999);
    return (start, end);
  }

  static String generateQuestId(QuestCategory category, DateTime periodStart) {
    final dateKey = _dateStr(periodStart);
    return '${category.name}_$dateKey';
  }

  static String _dateStr(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String dailyPeriodKey([DateTime? now]) {
    final (start, _) = currentDailyPeriod(now);
    return _dateStr(start);
  }

  static String weeklyPeriodKey([DateTime? now]) {
    final (start, _) = currentWeeklyPeriod(now);
    return _dateStr(start);
  }

  static String monthlyPeriodKey([DateTime? now]) {
    final (start, _) = currentMonthlyPeriod(now);
    final y = start.year.toString().padLeft(4, '0');
    final m = start.month.toString().padLeft(2, '0');
    return '$y-$m';
  }

  static bool isDailyPeriodCurrent(String? storedKey, [DateTime? now]) {
    if (storedKey == null || storedKey.isEmpty) return false;
    return storedKey == dailyPeriodKey(now);
  }

  static bool isWeeklyPeriodCurrent(String? storedKey, [DateTime? now]) {
    if (storedKey == null || storedKey.isEmpty) return false;
    return storedKey == weeklyPeriodKey(now);
  }

  static bool isMonthlyPeriodCurrent(String? storedKey, [DateTime? now]) {
    if (storedKey == null || storedKey.isEmpty) return false;
    return storedKey == monthlyPeriodKey(now);
  }
}
