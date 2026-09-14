import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../di/injection_container.dart';
import '../../features/expenses/domain/repositories/transaction_repository.dart';
import 'detection/detection_pipeline.dart';
import 'auto_transaction_notification_service.dart';
import '../utils/utils.dart';
import '../utils/background_file_logger.dart';
import 'entitlement/entitlement_service.dart';
import 'entitlement/models/feature.dart';
import 'entitlement/models/subscription_plan.dart';

// ─── Background Isolate Entry Point ──────────────────────────────────────────
//
// ARCHITECTURE NOTE:
// The flutter_notification_listener plugin's Kotlin NotificationsHandlerService is
// a system-bound Android NotificationListenerService. It continues running even
// when the app is killed. However, when the app is killed, the main Dart isolate
// is also destroyed — meaning the ReceivePort and IsolateNameServer registration
// in startListening() are gone.
//
// Without the self-contained processing below, the background Dart callback would
// call IsolateNameServer.lookupPortByName("_notification_listener_") → null →
// send?.send(evt) is a no-op → notification silently dropped every time.
//
// FIX: _notificationCallback now processes the transaction DIRECTLY inside the
// background isolate without requiring the main isolate to be alive:
//   1. WidgetsFlutterBinding.ensureInitialized() (background isolate safe)
//   2. Firebase.initializeApp() lazily — idempotent if already initialized
//   3. Run detection pipeline on the notification event
//   4. Write passing transactions directly to Firestore
//   5. Fire a local push notification via AutoTransactionNotificationService.showFromBackground()
//
// The ReceivePort bridge is KEPT as a fast path for when the app IS in the
// foreground — it avoids the Firebase re-init overhead in that case.
//
// OEM BATTERY OPTIMIZATION NOTE:
// On Xiaomi (MIUI), OnePlus (OxygenOS), Realme UI, Samsung One UI — users must
// additionally enable "Autostart" permission for Fingo in their device's security
// settings. This cannot be done programmatically. A one-time in-app tip (shown
// after the battery optimization prompt) should guide users:
//   - Xiaomi: Settings > Apps > Manage Apps > Fingo > Autostart > Enable
//   - OnePlus: Settings > Battery > Battery Optimization > Fingo > Don't Optimize
//   - Realme: Settings > Battery > Background Power Management > Fingo > No Restrictions
//   - Samsung: Settings > Apps > Fingo > Battery > Unrestricted
// Future work: implement a device-specific guide screen (OemBatteryGuideScreen)
// that detects the device manufacturer and shows the exact path.

/// Static background entry-point callback for NotificationsListener.
/// Must be a top-level or static function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
void _notificationCallback(NotificationEvent evt) async {
  // Fast path: if the main isolate is alive and listening, delegate to it
  // (avoids Firebase re-init overhead while app is foreground).
  final SendPort? send = IsolateNameServer.lookupPortByName('_notification_listener_');
  final sendPortFound = send != null;
  
  await BackgroundFileLogger.log('_notificationCallback entered. title: "${evt.title}", SendPort found: $sendPortFound');

  if (send != null) {
    try {
      send.send(<String, dynamic>{
        'packageName': evt.packageName,
        'title': evt.title,
        'text': evt.text,
      });
      return;
    } catch (e) {
      await BackgroundFileLogger.log('Error sending to SendPort: $e. Falling back to background processing.');
    }
  }

  // ── BACKGROUND PATH ──────────────────────────────────────────────────────
  // Main isolate is dead (app was killed). Process the notification directly
  // in this background isolate.
  await BackgroundFileLogger.log('Entered background path');
  try {
    // Step 1: Initialize Flutter bindings for the background isolate
    WidgetsFlutterBinding.ensureInitialized();
    await BackgroundFileLogger.log('After WidgetsFlutterBinding.ensureInitialized()');

    // Step 2: Lazily initialize Firebase (idempotent — Firebase handles double-init)
    await BackgroundFileLogger.log('Before Firebase.initializeApp()');
    try {
      Firebase.app(); // throws if not initialized
    } catch (_) {
      await Firebase.initializeApp();
    }
    await BackgroundFileLogger.log('Firebase initialized');

    // Step 3: Read persisted user ID and enabled flag from secure storage
    await BackgroundFileLogger.log('Before reading FlutterSecureStorage');
    const storage = FlutterSecureStorage();
    final enabledStr = await storage.read(key: NotificationSyncService._keyNotificationEnabled);
    await BackgroundFileLogger.log('SecureStorage value: "$enabledStr"');
    if (enabledStr != 'true') {
      await BackgroundFileLogger.log('EARLY RETURN: Notification sync not enabled (value: "$enabledStr")');
      return;
    }

    await BackgroundFileLogger.log('Before FirebaseAuth.instance.currentUser');
    final user = FirebaseAuth.instance.currentUser;
    await BackgroundFileLogger.log('currentUser: ${user == null ? "null" : "uid=${user.uid}"}');
    if (user == null) {
      await BackgroundFileLogger.log('EARLY RETURN: currentUser is null');
      return;
    }

    final packageName = evt.packageName ?? '';
    final title = evt.title ?? '';
    final text = evt.text ?? '';

    // Step 4: Run detection pipeline directly
    await BackgroundFileLogger.log('DetectionPipeline started');
    final result = await DetectionPipeline.process(
      packageName: packageName,
      title: title,
      body: text,
      userId: user.uid,
    );
    await BackgroundFileLogger.log('DetectionPipeline finished');

    if (result == null) {
      await BackgroundFileLogger.log('EARLY RETURN: DetectionPipeline returned null');
      return;
    }
    if (result.isDuplicate) {
      await BackgroundFileLogger.log('EARLY RETURN: Duplicate transaction detected');
      return;
    }
    if (result.transaction == null) {
      await BackgroundFileLogger.log('EARLY RETURN: Transaction is null (exclusionReason: ${result.exclusionReason})');
      return;
    }

    final transaction = result.transaction!;

    // Step 5: Write directly to Firestore (bypassing repository to avoid DI dependency)
    // We write the raw Firestore document to avoid needing the full DI container.
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(transaction.id);

    // Convert entity to Firestore map (matches TransactionModel.toJson())
    final data = <String, dynamic>{
      'id': transaction.id,
      'userId': transaction.userId,
      'title': transaction.title,
      'amount': transaction.amount,
      'type': transaction.type.name,
      'expenseCategory': transaction.expenseCategory?.name,
      'incomeCategory': transaction.incomeCategory?.name,
      'date': transaction.date.toIso8601String(),
      'notes': transaction.notes,
      'paymentMethod': transaction.paymentMethod.name,
      'attachmentUrl': transaction.attachmentUrl,
      'createdAt': transaction.createdAt.toIso8601String(),
      'updatedAt': transaction.updatedAt.toIso8601String(),
      'isRecurring': transaction.isRecurring,
      'recurringId': transaction.recurringId,
      'processedForXp': transaction.processedForXp,
      'isPending': transaction.isPending,
      'detectionMeta': transaction.detectionMeta != null
          ? {
              'confidence': transaction.detectionMeta!.confidence,
              'source': transaction.detectionMeta!.source,
              'senderPackage': transaction.detectionMeta!.senderPackage,
              'senderName': transaction.detectionMeta!.senderName,
              'matchedPatternId': transaction.detectionMeta!.matchedPatternId,
              'matchedRules': transaction.detectionMeta!.matchedRules,
              'classificationMethod': transaction.detectionMeta!.classificationMethod,
              'extractedRefNumber': transaction.detectionMeta!.extractedRefNumber,
              'extractedAccountLast4': transaction.detectionMeta!.extractedAccountLast4,
            }
          : null,
    };

    await BackgroundFileLogger.log('Firestore write started');
    await docRef.set(data);
    await BackgroundFileLogger.log('Firestore write completed');
    AppLogger.i('Background: auto-logged transaction ${transaction.id} (${transaction.title})');

    // Step 6: Fire local push notification to inform user
    await BackgroundFileLogger.log('Before showFromBackground()');
    await AutoTransactionNotificationService.showFromBackground(transaction);
    await BackgroundFileLogger.log('Notification shown');
  } catch (e, stackTrace) {
    await BackgroundFileLogger.log('EXCEPTION in background path: $e\n$stackTrace');
  }
}

/// [NotificationSyncService] — listens to notifications from banking/payment apps,
/// parses financial alerts locally in-memory, and securely writes transactions to Firestore.
class NotificationSyncService {
  StreamSubscription? _subscription;
  final ReceivePort _port = ReceivePort();
  bool _isListening = false;

  static const String _keyNotificationEnabled = 'notification_tracker_enabled';
  static const String _keyBatteryOptPromptShown = 'fingo_battery_opt_prompt_shown';

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

      // Initialize with the background-isolate-safe callback
      await NotificationsListener.initialize(callbackHandle: _notificationCallback);

      // Register the main isolate's ReceivePort — used as fast path when app is foreground.
      // The background isolate checks this port first; if null (app killed), it self-processes.
      IsolateNameServer.removePortNameMapping('_notification_listener_');
      IsolateNameServer.registerPortWithName(_port.sendPort, '_notification_listener_');

      _subscription = _port.listen((dynamic message) async {
        if (message is Map) {
          final packageName = (message['packageName'] as String?) ?? '';
          final title = (message['title'] as String?) ?? '';
          final text = (message['text'] as String?) ?? '';
          await _processIncomingNotification(
            packageName: packageName,
            title: title,
            text: text,
          );
        } else if (message is NotificationEvent) {
          await _processIncomingNotification(
            packageName: message.packageName ?? '',
            title: message.title ?? '',
            text: message.text ?? '',
          );
        }
      });

      // Start the Android foreground service (shows persistent status bar notification)
      final isRunning = await NotificationsListener.isRunning;
      if (isRunning != true) {
        await NotificationsListener.startService(
          title: 'Fingo Auto-Tracker Active',
          description: 'Listening to transaction notifications in the background',
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
    IsolateNameServer.removePortNameMapping('_notification_listener_');
    _isListening = false;

    try {
      await NotificationsListener.stopService();
      AppLogger.i('NotificationSyncService stopped listening.');
    } catch (e) {
      AppLogger.e('NotificationSyncService failed to stop service: $e');
    }
  }

  // ─── Battery Optimization Prompt ─────────────────────────────────────────

  /// Returns true if the battery optimization prompt has already been shown.
  Future<bool> hasBatteryOptPromptBeenShown() async {
    final storage = sl<FlutterSecureStorage>();
    final val = await storage.read(key: _keyBatteryOptPromptShown);
    return val == 'true';
  }

  /// Mark the battery optimization prompt as shown (call after displaying the dialog).
  Future<void> markBatteryOptPromptShown() async {
    final storage = sl<FlutterSecureStorage>();
    await storage.write(key: _keyBatteryOptPromptShown, value: 'true');
  }

  // ─── Main Isolate Processing ──────────────────────────────────────────────
  // This runs only when the app IS in the foreground (fast path).

  /// Process the incoming notification event locally and securely
  Future<void> _processIncomingNotification({
    required String packageName,
    required String title,
    required String text,
  }) async {
    AppLogger.i('[DEBUG_FLOW] 4. ENTERED _processIncomingNotification()');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppLogger.i('[DEBUG_FLOW] 9. Early return at line 290 (_processIncomingNotification): user == null');
      AppLogger.w('Auto-logging skipped: No user authenticated.');
      return;
    }

    final entitlementService = sl<EntitlementService>();
    final hasAccess = entitlementService.hasAccess(Feature.autoDetectionBasic);
    if (!hasAccess) {
      AppLogger.i('[DEBUG_FLOW] 9. Early return at line 297 (_processIncomingNotification): !hasAccess (Feature.autoDetectionBasic)');
      AppLogger.d('Auto-logging skipped: User does not have access to auto-detection.');
      return;
    }

    final currentPlan = entitlementService.currentSubscription.plan;
    final state = sl<FingoState>();

    if (currentPlan == SubscriptionPlan.free) {
      if (state.health <= 0) {
        AppLogger.i('[DEBUG_FLOW] 9. Early return at line 306 (_processIncomingNotification): free user health <= 0 (health: ${state.health})');
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

    if (result == null) {
      AppLogger.i('[DEBUG_FLOW] 9. Early return at line 318 (_processIncomingNotification): DetectionPipeline.process returned null');
      return;
    }

    if (result.isDuplicate) {
      AppLogger.i('[DEBUG_FLOW] 9. Early return at line 322 (_processIncomingNotification): duplicate transaction');
      AppLogger.i('Auto-logging skipped: Duplicate transaction detected.');
      return;
    }

    if (result.transaction == null) {
      AppLogger.i('[DEBUG_FLOW] 9. Early return at line 329 (_processIncomingNotification): result.transaction == null (exclusionReason: ${result.exclusionReason}, confidence: ${result.confidence})');
      if (result.exclusionReason == null && result.confidence < DetectionPipeline.autoCreateThreshold) {
        AppLogger.d('Auto-logging skipped: Low confidence (${result.confidence})');
      }
      return;
    }

    final transaction = result.transaction!;

    final repository = sl<TransactionRepository>();
    AppLogger.i('[DEBUG_FLOW] 5. About to save transaction');
    final dbResult = await repository.addTransaction(transaction, user.uid);
    dbResult.fold(
      (failure) {
        AppLogger.e('[DEBUG_FLOW] 6. Save transaction failure: ${failure.message}');
        AppLogger.e('Notification auto-logging failed: ${failure.message}');
      },
      (_) async {
        AppLogger.i('[DEBUG_FLOW] 6. Save transaction success');
        AppLogger.i('Successfully auto-logged notification transaction: ${transaction.title} - INR ${transaction.amount}');

        // Fire system notification to alert user of detection
        AppLogger.i('[DEBUG_FLOW] 7. Showing Auto Transaction notification');
        await AutoTransactionNotificationService.showTransactionDetectedNotification(transaction);

        // Deduct health for free users
        if (currentPlan == SubscriptionPlan.free) {
          AppLogger.i('[DEBUG_FLOW] 8. Deducting 5 energy');
          state.deductHealth(5);
        }
      },
    );
  }
}
