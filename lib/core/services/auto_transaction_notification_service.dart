import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/logger.dart';
import '../../features/expenses/domain/entities/transaction_entity.dart';

/// Notification channel IDs
const String _channelId = 'fingo_auto_transaction';
const String _channelName = 'Auto-detected Transactions';
const String _channelDesc = 'Alerts when a financial transaction is automatically detected';

/// Global plugin instance — must be top-level for background access.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Callback type for notification taps.
typedef NotificationTapCallback = void Function(String? transactionId);

/// [AutoTransactionNotificationService] — manages local push notifications for
/// auto-detected transactions.
///
/// Architecture notes:
/// - Foreground: fires as heads-up banner; user sees it without leaving current screen.
/// - Background: fires while app is in background; appears in notification shade.
/// - Killed: fires from background isolate; also appears in notification shade.
///   On cold-start via notification tap, [getAppLaunchTransactionId] returns the ID.
class AutoTransactionNotificationService {
  static NotificationTapCallback? _tapCallback;

  // ─── Initialization ──────────────────────────────────────────────────────

  /// Initialize channels and tap handler. Call once in main() after DI setup.
  static Future<void> initialize({
    NotificationTapCallback? onNotificationTapped,
  }) async {
    _tapCallback = onNotificationTapped;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );

    // Create the high-importance channel for transaction alerts
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    AppLogger.i('AutoTransactionNotificationService initialized.');
  }

  // ─── Tap Handlers ─────────────────────────────────────────────────────────

  /// Called when user taps a notification while app is in foreground/background.
  static void _onNotificationResponse(NotificationResponse response) {
    AppLogger.i('Notification tapped (fg/bg): payload=${response.payload}');
    _tapCallback?.call(response.payload);
  }

  /// Called when user taps a notification while app was killed.
  /// Must be a top-level function annotated with @pragma('vm:entry-point').
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    AppLogger.i('Notification tapped (killed): payload=${response.payload}');
    // Store the ID in a static field — the main isolate will pick it up
    // via getAppLaunchTransactionId() after re-initialization.
    _pendingDeepLinkId = response.payload;
    _tapCallback?.call(response.payload);
  }

  // ─── Deep-link State ──────────────────────────────────────────────────────

  static String? _pendingDeepLinkId;

  /// Returns the transaction ID from a cold-start notification tap, then clears it.
  static String? consumePendingDeepLinkId() {
    final id = _pendingDeepLinkId;
    _pendingDeepLinkId = null;
    return id;
  }

  /// Check if the app was launched by tapping a notification (cold-start).
  /// Returns the transaction ID payload, or null if not notification-launched.
  static Future<String?> getAppLaunchTransactionId() async {
    try {
      final launchDetails =
          await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true) {
        final payload = launchDetails?.notificationResponse?.payload;
        AppLogger.i('App launched via notification tap. Payload: $payload');
        return payload;
      }
    } catch (e) {
      AppLogger.e('Error checking notification launch details: $e');
    }
    return null;
  }

  // ─── Show Notification ────────────────────────────────────────────────────

  /// Fire a heads-up notification for a detected transaction.
  /// Safe to call from both the main isolate and background isolates
  /// (plugin instance is global top-level).
  static Future<void> showTransactionDetectedNotification(
    TransactionEntity transaction,
  ) async {
    try {
      final isExpense = transaction.type == TransactionType.expense;
      final typeLabel = isExpense ? 'Expense' : 'Income';
      final amountStr = '₹${transaction.amount.toStringAsFixed(transaction.amount.truncateToDouble() == transaction.amount ? 0 : 2)}';
      final body = '${transaction.title} • $amountStr • $typeLabel';

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        // Sub-text shown below the body on Android
        subText: 'Tap to review',
        icon: '@mipmap/ic_launcher',
        // Auto-cancel when tapped (not when swipe-dismissed — transaction stays in queue)
        autoCancel: true,
        // Show as heads-up banner even if app is in foreground
        fullScreenIntent: false,
      );

      await flutterLocalNotificationsPlugin.show(
        // Unique notification ID per transaction (hashCode is deterministic for same ID)
        transaction.id.hashCode.abs(),
        '💳 New transaction detected',
        body,
        const NotificationDetails(android: androidDetails),
        // Payload carries the transaction ID for deep-link routing on tap
        payload: transaction.id,
      );

      AppLogger.i('Notification fired for transaction: ${transaction.id}');
    } catch (e) {
      AppLogger.e('Failed to show transaction notification: $e');
    }
  }

  /// Background-isolate-safe variant. Initializes the plugin first since
  /// the isolate may not have run initialize() yet.
  ///
  /// Called from [_notificationCallback] in notification_sync_service.dart.
  static Future<void> showFromBackground(TransactionEntity transaction) async {
    try {
      // Initialize minimal settings for background use (no tap callback needed
      // in background isolate — tap handling is done by main isolate on cold start)
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(android: androidInit),
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
      );

      // Ensure the channel exists (idempotent)
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await showTransactionDetectedNotification(transaction);
    } catch (e) {
      AppLogger.e('Background notification failed: $e');
    }
  }

  // ─── Cancel ───────────────────────────────────────────────────────────────

  /// Cancel the notification for a specific transaction (e.g. after user reviews it).
  static Future<void> cancelNotification(String transactionId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(transactionId.hashCode.abs());
    } catch (e) {
      AppLogger.e('Failed to cancel notification: $e');
    }
  }
}
