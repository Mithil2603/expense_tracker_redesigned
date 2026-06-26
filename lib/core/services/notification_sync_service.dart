import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../di/injection_container.dart';
import '../../features/expenses/domain/repositories/transaction_repository.dart';
import 'detection/detection_pipeline.dart';
import '../utils/utils.dart';
import 'entitlement/entitlement_service.dart';
import 'entitlement/models/feature.dart';
import 'entitlement/models/subscription_plan.dart';
import '../utils/fingo_state.dart';

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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppLogger.w('Auto-logging skipped: No user authenticated.');
      return;
    }

    final entitlementService = sl<EntitlementService>();
    final hasAccess = entitlementService.hasAccess(Feature.autoDetectionBasic);
    if (!hasAccess) {
      AppLogger.d('Auto-logging skipped: User does not have access to auto-detection.');
      return;
    }

    final currentPlan = entitlementService.currentSubscription.plan;
    final state = sl<FingoState>();

    if (currentPlan == SubscriptionPlan.free) {
      if (state.health <= 0) {
        AppLogger.d('Auto-logging skipped: Free tier user has 0 health.');
        return;
      }
    }

    // 1. Process via DetectionPipeline
    final result = await DetectionPipeline.process(
      packageName: packageName,
      title: title,
      body: text,
      userId: user.uid,
    );

    if (result == null) return;
    
    if (result.isDuplicate) {
      AppLogger.i('Auto-logging skipped: Duplicate transaction detected.');
      return;
    }

    if (result.transaction == null) {
      if (result.exclusionReason == null && result.confidence < DetectionPipeline.autoCreateThreshold) {
         AppLogger.d('Auto-logging skipped: Low confidence (${result.confidence})');
      }
      return;
    }

    final transaction = result.transaction!;

    final repository = sl<TransactionRepository>();
    final dbResult = await repository.addTransaction(transaction, user.uid);
    dbResult.fold(
      (failure) => AppLogger.e('Notification auto-logging failed: ${failure.message}'),
      (_) {
        AppLogger.i('Successfully auto-logged notification transaction: ${transaction.title} - INR ${transaction.amount}');
        // Deduct health for free users
        if (currentPlan == SubscriptionPlan.free) {
          state.deductHealth(5);
        }
      },
    );
  }
}
