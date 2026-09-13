import 'fingo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/services/remote_config_service.dart';
import 'core/services/entitlement/entitlement_service.dart';
import 'core/services/quest/quest_engine_service.dart';
import 'core/services/auto_transaction_notification_service.dart';
import 'core/domain/entities/quest_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safeguarded Firebase initialization
  bool isFirebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    AppLogger.i('Firebase has been successfully initialized.');
    isFirebaseInitialized = true;
  } catch (e, stackTrace) {
    AppLogger.w(
      'Firebase initialization bypassed. This is expected if Firebase '
      'configuration files (google-services.json / GoogleService-Info.plist) are missing.',
    );
    AppLogger.e('Firebase Init Error Details:', e, stackTrace);
  }

  // Initialize service locator dependencies
  await init();

  // Load persisted user stats
  await sl<FingoState>().loadStats();

  if (isFirebaseInitialized) {
    try {
      await sl<EntitlementService>().init();
      await sl<RemoteConfigService>().init();
      await sl<NotificationSyncService>().init();

      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'default_user';
      final fingoState = sl<FingoState>();
      await sl<QuestEngineService>().ensureQuestsForCurrentPeriods(
        uid,
        fingoState.level,
        fingoState.monthlyBudget,
      );
      await sl<QuestEngineService>().recordEvent(
        QuestEvent(
          type: QuestEventType.appOpen,
          timestamp: DateTime.now(),
        ),
        uid,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Post-Firebase startup error:', e, stackTrace);
    }
  }

  // Initialize local notification service and register tap handler.
  // The tap handler routes the user to the pending transaction review screen.
  await AutoTransactionNotificationService.initialize(
    onNotificationTapped: (String? transactionId) {
      if (transactionId != null && transactionId.isNotEmpty) {
        AppLogger.i('Notification tapped — navigating to pending review: $transactionId');
        AppRouter.router.go('/pending-review/$transactionId');
      } else {
        // Fallback: navigate to dashboard
        AppRouter.router.go(AppRoutes.dashboardPath);
      }
    },
  );

  // Handle cold-start via notification tap (app was killed and re-launched by tapping notification)
  final coldStartTransactionId =
      await AutoTransactionNotificationService.getAppLaunchTransactionId();
  if (coldStartTransactionId != null && coldStartTransactionId.isNotEmpty) {
    AppLogger.i('Cold-start via notification. Queuing deep-link to: $coldStartTransactionId');
    // Use post-frame callback to navigate after router is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go('/pending-review/$coldStartTransactionId');
    });
  }

  runApp(const FingoApp());
}
