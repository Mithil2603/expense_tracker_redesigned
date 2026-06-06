import 'package:flutter/foundation.dart';

/// AppLogger — a lightweight, emoji-enhanced console logger.
///
/// Designed to provide clear, categorized log outputs in debug mode.
abstract final class AppLogger {
  /// Debug logs (green marker) — for verbose logs useful during development.
  static void d(String message) {
    if (kDebugMode) {
      debugPrint('🟢 [DEBUG] $message');
    }
  }

  /// Info logs (blue marker) — for structural operations (e.g. initialization, route changes).
  static void i(String message) {
    if (kDebugMode) {
      debugPrint('🔵 [INFO]  $message');
    }
  }

  /// Warning logs (yellow marker) — for non-critical warnings or fallback conditions.
  static void w(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ [WARN]  $message');
    }
  }

  /// Error logs (red marker) — for caught exceptions and failures.
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('🔴 [ERROR] $message');
      if (error != null) {
        debugPrint('   Details: $error');
      }
      if (stackTrace != null) {
        debugPrint('   Stack Trace:\n$stackTrace');
      }
    }
  }
}
