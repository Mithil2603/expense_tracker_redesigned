import 'dart:io';
import 'package:flutter/foundation.dart';

class BackgroundFileLogger {
  static Future<File> getLogFile() async {
    final docDir = Directory('/data/user/0/com.example.expense_tracker/app_flutter');
    File logFile;
    if (await docDir.exists()) {
      logFile = File('${docDir.path}/background_debug_log.txt');
    } else {
      logFile = File('${Directory.systemTemp.path}/background_debug_log.txt');
    }
    if (!await logFile.exists()) {
      await logFile.create(recursive: true);
    }
    return logFile;
  }

  static Future<void> log(String message) async {
    try {
      final file = await getLogFile();
      final timestamp = DateTime.now().toIso8601String();
      await file.writeAsString(
        '[$timestamp] $message\n',
        mode: FileMode.append,
        flush: true,
      );
      // Also print to console
      debugPrint('[FILE_LOG] $message');
    } catch (e, st) {
      debugPrint('Failed to write to file log: $e\n$st');
    }
  }

  static Future<String> readLogs() async {
    try {
      final file = await getLogFile();
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      return 'Error reading logs: $e';
    }
    return 'Log file does not exist.';
  }

  static Future<void> clearLogs() async {
    try {
      final file = await getLogFile();
      if (await file.exists()) {
        await file.writeAsString('');
      }
    } catch (e) {
      debugPrint('Error clearing logs: $e');
    }
  }
}
