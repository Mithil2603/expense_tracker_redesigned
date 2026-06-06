import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─── BuildContext Extensions ──────────────────────────────────────────────────

extension ContextX on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Screen dimensions
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;

  // Navigation
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) => Navigator.of(this).push(
        MaterialPageRoute(builder: (_) => page),
      );

  // Snackbars
  void showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final color = isError
        ? AppColors.error
        : isSuccess
            ? AppColors.success
            : AppColors.accent;

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: AppTextStyles.bodyMD)),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }

  void hideSnackBars() => ScaffoldMessenger.of(this).hideCurrentSnackBar();

  // Focus
  void unfocus() => FocusScope.of(this).unfocus();
}

// ─── String Extensions ────────────────────────────────────────────────────────

extension StringX on String {
  String get capitalizeFirst =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  bool get isValidEmail => RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  bool get isValidPassword => length >= 8;

  bool get isNumeric => double.tryParse(this) != null;

  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  String truncate(int max, {String ellipsis = '...'}) =>
      length > max ? '${substring(0, max)}$ellipsis' : this;
}

// ─── Numeric Extensions ───────────────────────────────────────────────────────

extension NumX on num {
  /// Format as Indian currency string: ₹1,23,456.00
  String toCurrency({String symbol = '₹', int decimals = 2}) {
    final absVal = abs();
    final formatted = _formatIndian(absVal.toStringAsFixed(decimals));
    final sign = this < 0 ? '-' : '';
    return '$sign$symbol$formatted';
  }

  String _formatIndian(String numStr) {
    final parts = numStr.split('.');
    String intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (intPart.length <= 3) return '$intPart$decPart';

    final lastThree = intPart.substring(intPart.length - 3);
    final remaining = intPart.substring(0, intPart.length - 3);
    final groups = <String>[];
    for (var i = remaining.length; i > 0; i -= 2) {
      groups.insert(0, remaining.substring(i < 2 ? 0 : i - 2, i));
    }
    return '${groups.join(',')},${lastThree}$decPart';
  }

  /// E.g. 1234567 → "₹12.3L" or "₹1.2Cr"
  String toCompactCurrency({String symbol = '₹'}) {
    if (abs() >= 10000000) return '$symbol${(this / 10000000).toStringAsFixed(1)}Cr';
    if (abs() >= 100000) return '$symbol${(this / 100000).toStringAsFixed(1)}L';
    if (abs() >= 1000) return '$symbol${(this / 1000).toStringAsFixed(1)}K';
    return toCurrency(symbol: symbol);
  }
}

// ─── DateTime Extensions ──────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return day == yesterday.day && month == yesterday.month && year == yesterday.year;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return isAfter(weekAgo) && isBefore(now.add(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }

  /// Returns "Today", "Yesterday", or "12 Jun 2025"
  String toRelativeLabel() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return toFormattedDate();
  }

  /// "12 Jun 2025"
  String toFormattedDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '$day ${months[month - 1]} $year';
  }

  /// "Jun 2025"
  String toMonthYear() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $year';
  }

  /// "09:45 AM"
  String toTimeLabel() {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

// ─── Widget Extensions ───────────────────────────────────────────────────────

extension WidgetX on Widget {
  Widget padAll(double value) => Padding(padding: EdgeInsets.all(value), child: this);
  Widget padH(double value) => Padding(padding: EdgeInsets.symmetric(horizontal: value), child: this);
  Widget padV(double value) => Padding(padding: EdgeInsets.symmetric(vertical: value), child: this);
  Widget padOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) =>
      Padding(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);

  Widget withOpacity(double opacity) => Opacity(opacity: opacity, child: this);

  Widget centered() => Center(child: this);

  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
}
