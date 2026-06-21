import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../di/injection_container.dart';
import '../../features/expenses/domain/entities/transaction_entity.dart';
import '../../features/expenses/domain/repositories/transaction_repository.dart';
import '../utils/sms_parser.dart';
import '../utils/utils.dart';

/// Static background entry-point callback for NotificationsListener.
/// Must be a top-level or static function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
void _notificationCallback(NotificationEvent evt) {
  final SendPort? send = IsolateNameServer.lookupPortByName("_notification_listener_");
  send?.send(evt);
}

/// [NotificationSyncService] — listens to notifications from banking/payment apps,
/// parses financial alerts locally in-memory, and securely writes transactions to Firestore.
class NotificationSyncService {
  StreamSubscription? _subscription;
  final ReceivePort _port = ReceivePort();
  bool _isListening = false;

  static const String _keyNotificationEnabled = 'notification_tracker_enabled';

  // Allowed financial/messaging package names for strict security filtering
  static const List<String> _allowedPackages = [
    'com.google.android.apps.nbu.paisa.user', // Google Pay
    'com.phonepe.app',                         // PhonePe
    'net.one97.paytm',                         // Paytm
    'com.google.android.apps.messaging',       // Google Messages (Default SMS app)
    'com.android.mms',                         // Stock Messaging app
    'com.samsung.android.messaging',           // Samsung Messages app
  ];

  /// Check if the auto notification tracker is enabled by the user
  Future<bool> isEnabled() async {
    final storage = sl<FlutterSecureStorage>();
    final val = await storage.read(key: _keyNotificationEnabled);
    return val == 'true';
  }

  /// Toggle and persist the tracker setting
  Future<void> setEnabled(bool enabled) async {
    final storage = sl<FlutterSecureStorage>();
    await storage.write(key: _keyNotificationEnabled, value: enabled.toString());
    if (enabled) {
      await startListening();
    } else {
      await stopListening();
    }
  }

  /// Initialize and start listening if enabled on app startup
  Future<void> init() async {
    if (await isEnabled()) {
      await startListening();
    }
  }

  /// Start listening to incoming notifications
  Future<void> startListening() async {
    if (_isListening) return;

    try {
      final hasPermission = await NotificationsListener.hasPermission;
      if (hasPermission != true) {
        AppLogger.w('NotificationSyncService: Notification Access permission not granted.');
        return;
      }

      // Initialize compiler handle callback
      await NotificationsListener.initialize(callbackHandle: _notificationCallback);

      // Register communication port between background isolate and main isolate
      IsolateNameServer.removePortNameMapping("_notification_listener_");
      IsolateNameServer.registerPortWithName(_port.sendPort, "_notification_listener_");

      _subscription = _port.listen((dynamic message) async {
        if (message is NotificationEvent) {
          await _processIncomingNotification(message);
        }
      });

      // Start the Android background service
      final isRunning = await NotificationsListener.isRunning;
      if (isRunning != true) {
        await NotificationsListener.startService(
          title: "Fingo Auto-Tracker Active",
          description: "Listening to transaction notifications in the background",
        );
      }

      _isListening = true;
      AppLogger.i('NotificationSyncService started listening for transaction alerts.');
    } catch (e) {
      AppLogger.e('NotificationSyncService failed to start: $e');
    }
  }

  /// Stop listening to incoming notifications
  Future<void> stopListening() async {
    _subscription?.cancel();
    _subscription = null;
    IsolateNameServer.removePortNameMapping("_notification_listener_");
    _isListening = false;
    
    try {
      await NotificationsListener.stopService();
      AppLogger.i('NotificationSyncService stopped listening.');
    } catch (e) {
      AppLogger.e('NotificationSyncService failed to stop service: $e');
    }
  }

  /// Process the incoming notification event locally and securely
  Future<void> _processIncomingNotification(NotificationEvent evt) async {
    final packageName = evt.packageName ?? '';
    final title = evt.title ?? '';
    final text = evt.text ?? '';

    // 1. Strict Security Filter: Only process allowed packages
    if (!_allowedPackages.contains(packageName.toLowerCase().trim())) {
      return;
    }

    // 2. Parse locally in-memory
    final parsed = SmsParser.parse(title, text);
    if (parsed == null) return; // Skip if not a financial alert

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppLogger.w('Auto-logging skipped: No user authenticated.');
      return;
    }

    // Generate deterministic document ID to prevent duplicate logs of same notification
    final timestamp = DateTime.now();
    final uniqueId = _generateUniqueDocId(packageName, parsed.amount, parsed.type, timestamp);

    final transaction = TransactionEntity(
      id: uniqueId,
      userId: user.uid,
      title: parsed.title,
      amount: parsed.amount,
      type: parsed.type,
      expenseCategory: parsed.expenseCategory,
      incomeCategory: parsed.incomeCategory,
      date: timestamp,
      paymentMethod: parsed.paymentMethod,
      notes: 'Auto-logged from notification alert by ${title.toUpperCase()}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isRecurring: false,
      processedForXp: false,
    );

    final repository = sl<TransactionRepository>();
    final result = await repository.addTransaction(transaction, user.uid);
    result.fold(
      (failure) => AppLogger.e('Notification auto-logging failed: ${failure.message}'),
      (_) => AppLogger.i('Successfully auto-logged notification transaction: ${parsed.title} - INR ${parsed.amount}'),
    );
  }

  /// Generate deterministic document ID based on transaction parameters to avoid duplicates
  String _generateUniqueDocId(String packageName, double amount, TransactionType type, DateTime time) {
    final cleanedPkg = packageName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
    // Round to nearest minute for deduplication (in case system notifies twice or delays)
    final roundedTime = DateTime(time.year, time.month, time.day, time.hour, time.minute);
    final timestamp = roundedTime.millisecondsSinceEpoch;
    final amountStr = amount.toStringAsFixed(2).replaceAll('.', '_');
    return 'notify_${cleanedPkg}_${type.name}_${amountStr}_$timestamp';
  }
}
