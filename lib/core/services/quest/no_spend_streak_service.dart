import '../../../../features/expenses/domain/entities/transaction_entity.dart';

class NoSpendStreakData {
  final int currentStreak;
  final int longestStreak;
  final int totalNoSpendDays;
  final int thisMonthNoSpendDays;
  final int lastMonthNoSpendDays;
  final DateTime? streakStartDate;
  final DateTime? longestStreakStartDate;
  final DateTime? longestStreakEndDate;

  const NoSpendStreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalNoSpendDays,
    required this.thisMonthNoSpendDays,
    required this.lastMonthNoSpendDays,
    this.streakStartDate,
    this.longestStreakStartDate,
    this.longestStreakEndDate,
  });
}

class NoSpendStreakService {
  bool _isExpense(TransactionEntity t) {
    return t.type == TransactionType.expense;
  }

  bool isTodayNoSpend(List<TransactionEntity> transactions, [DateTime? now]) {
    final dt = now ?? DateTime.now();
    return !transactions.any((t) =>
        _isExpense(t) &&
        t.date.year == dt.year &&
        t.date.month == dt.month &&
        t.date.day == dt.day);
  }

  NoSpendStreakData calculateFromTransactions(
      List<TransactionEntity> transactions, [DateTime? now]) {
    final dt = now ?? DateTime.now();
    final today = DateTime(dt.year, dt.month, dt.day);

    if (transactions.isEmpty) {
      return const NoSpendStreakData(
        currentStreak: 0,
        longestStreak: 0,
        totalNoSpendDays: 0,
        thisMonthNoSpendDays: 0,
        lastMonthNoSpendDays: 0,
      );
    }

    // Find all expense dates truncated to day
    final expenseDays = transactions
        .where(_isExpense)
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet();

    // Find earliest date in transactions
    DateTime earliest = today;
    for (final t in transactions) {
      final tDay = DateTime(t.date.year, t.date.month, t.date.day);
      if (tDay.isBefore(earliest)) earliest = tDay;
    }

    int currentStreak = 0;
    int longestStreak = 0;
    int totalNoSpendDays = 0;
    int thisMonthNoSpendDays = 0;
    int lastMonthNoSpendDays = 0;

    int tempStreak = 0;
    DateTime? tempStart;
    DateTime? longestStart;
    DateTime? longestEnd;
    DateTime? currentStart;

    final prevMonth = dt.month == 1 ? 12 : dt.month - 1;
    final prevMonthYear = dt.month == 1 ? dt.year - 1 : dt.year;

    // Iterate through all calendar days from earliest up to today
    for (DateTime d = earliest;
        !d.isAfter(today);
        d = d.add(const Duration(days: 1))) {
      final isNoSpend = !expenseDays.contains(d);

      if (isNoSpend) {
        totalNoSpendDays++;
        if (d.year == dt.year && d.month == dt.month) {
          thisMonthNoSpendDays++;
        } else if (d.year == prevMonthYear && d.month == prevMonth) {
          lastMonthNoSpendDays++;
        }

        if (tempStreak == 0) tempStart = d;
        tempStreak++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
          longestStart = tempStart;
          longestEnd = d;
        }
      } else {
        tempStreak = 0;
        tempStart = null;
      }
    }

    // Current streak is backwards from today (or yesterday if today has no spend)
    // If today has an expense, currentStreak is 0.
    if (expenseDays.contains(today)) {
      currentStreak = 0;
      currentStart = null;
    } else {
      // Count backwards from today
      int count = 0;
      DateTime? start;
      for (DateTime d = today;
          !d.isBefore(earliest);
          d = d.subtract(const Duration(days: 1))) {
        if (!expenseDays.contains(d)) {
          count++;
          start = d;
        } else {
          break;
        }
      }
      currentStreak = count;
      currentStart = start;
    }

    return NoSpendStreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalNoSpendDays: totalNoSpendDays,
      thisMonthNoSpendDays: thisMonthNoSpendDays,
      lastMonthNoSpendDays: lastMonthNoSpendDays,
      streakStartDate: currentStart,
      longestStreakStartDate: longestStart,
      longestStreakEndDate: longestEnd,
    );
  }

  Map<int, double> calculateDayOfMonthNoSpendRate(
      List<TransactionEntity> transactions, [DateTime? now]) {
    final dt = now ?? DateTime.now();
    final today = DateTime(dt.year, dt.month, dt.day);
    final rates = <int, double>{};

    if (transactions.isEmpty) {
      for (int i = 1; i <= 31; i++) {
        rates[i] = 0.0;
      }
      return rates;
    }

    final expenseDays = transactions
        .where(_isExpense)
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet();

    DateTime earliest = today;
    for (final t in transactions) {
      final tDay = DateTime(t.date.year, t.date.month, t.date.day);
      if (tDay.isBefore(earliest)) earliest = tDay;
    }

    final totalOccurrences = <int, int>{};
    final noSpendOccurrences = <int, int>{};
    for (int i = 1; i <= 31; i++) {
      totalOccurrences[i] = 0;
      noSpendOccurrences[i] = 0;
    }

    for (DateTime d = earliest;
        !d.isAfter(today);
        d = d.add(const Duration(days: 1))) {
      final dayOfMonth = d.day;
      totalOccurrences[dayOfMonth] = (totalOccurrences[dayOfMonth] ?? 0) + 1;
      if (!expenseDays.contains(d)) {
        noSpendOccurrences[dayOfMonth] =
            (noSpendOccurrences[dayOfMonth] ?? 0) + 1;
      }
    }

    for (int i = 1; i <= 31; i++) {
      final total = totalOccurrences[i] ?? 0;
      final noSpend = noSpendOccurrences[i] ?? 0;
      if (total == 0) {
        rates[i] = 0.0;
      } else {
        rates[i] = (noSpend / total) * 100.0;
      }
    }

    return rates;
  }

  int? checkMilestone(int newStreak) {
    switch (newStreak) {
      case 3:
        return 15;
      case 7:
        return 50;
      case 14:
        return 100;
      case 30:
        return 300;
      default:
        return null;
    }
  }

  Map<DateTime, bool> getRecentDaysMap(
      List<TransactionEntity> transactions, {int days = 14, DateTime? now}) {
    final dt = now ?? DateTime.now();
    final today = DateTime(dt.year, dt.month, dt.day);
    final expenseDays = transactions
        .where(_isExpense)
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet();

    final result = <DateTime, bool>{};
    for (int i = days - 1; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      result[d] = !expenseDays.contains(d);
    }
    return result;
  }
}
