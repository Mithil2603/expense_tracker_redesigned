import 'package:intl/intl.dart';

/// AppFormatters — static methods for standard text, number and date formatting.
abstract final class AppFormatters {
  static final NumberFormat _indianCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactIndianCurrencyFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  /// Formats double amount to standard Indian Currency: ₹12,34,567.89
  static String formatCurrency(double amount, {String? symbol}) {
    if (symbol != null && symbol != '₹') {
      final formatter = NumberFormat.currency(
        symbol: symbol,
        decimalDigits: 2,
      );
      return formatter.format(amount);
    }
    return _indianCurrencyFormat.format(amount);
  }

  /// Compact Indian Currency: ₹1.2L, ₹12.3K, ₹1.5Cr
  static String formatCompactCurrency(double amount, {String? symbol}) {
    if (symbol != null && symbol != '₹') {
      final formatter = NumberFormat.compactCurrency(symbol: symbol);
      return formatter.format(amount);
    }
    return _compactIndianCurrencyFormat.format(amount);
  }

  /// Format Date: 12 Jun 2026
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format Time: 04:30 PM
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format Month & Year: June 2026
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format relative date: "Today", "Yesterday", or "12 Jun 2026"
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final compareDate = DateTime(date.year, date.month, date.day);

    if (compareDate == today) {
      return 'Today';
    } else if (compareDate == yesterday) {
      return 'Yesterday';
    } else {
      return formatDate(date);
    }
  }

  /// Formats percentage value: 0.125 -> "12.5%" or 52 -> "52.0%"
  static String formatPercentage(double value) {
    final percentFormat = NumberFormat.percentPattern();
    // If the value is already out of 100 (e.g. 52.5), divide by 100 first
    final val = value > 1.0 ? value / 100.0 : value;
    return percentFormat.format(val);
  }

  /// Formats XP points: 250 -> "250 XP"
  static String formatXP(int xp) {
    return '$xp XP';
  }

  /// Formats Streak count: 5 -> "5 Days 🔥"
  static String formatStreak(int days) {
    return '$days Day${days == 1 ? '' : 's'} 🔥';
  }
}
