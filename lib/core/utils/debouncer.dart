import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer — schedules a task to run after a delay.
///
/// If a new task is scheduled before the timer triggers, the previous
/// task is cancelled. This is essential for search fields and rate-limiting CTAs.
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// Runs [action] after the configured delay [duration].
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancels any scheduled task.
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes of the debouncer timer.
  void dispose() {
    _timer?.cancel();
  }
}
