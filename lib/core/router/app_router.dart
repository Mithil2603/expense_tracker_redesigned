import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../core.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/community/presentation/pages/community_hub_screen.dart';
import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/expenses/presentation/pages/transaction_form_screen.dart';
import '../../features/expenses/presentation/pages/pending_transaction_review_screen.dart';
import '../../features/expenses/domain/entities/transaction_entity.dart';
import '../../features/auth/presentation/pages/auth_screen.dart';
import '../../features/onboarding/presentation/pages/notification_onboarding_screen.dart';
import 'widgets/scaffold_with_navigation.dart';
import 'pages/route_error_screen.dart';
import '../../features/gamification/presentation/pages/health_refill_screen.dart';
import '../../di/injection_container.dart';
import '../../features/ipo/presentation/pages/ipo_hub_screen.dart';

// Key for root navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

/// AppRouter — central navigation configuration using GoRouter.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboardPath,
    refreshListenable: sl<AuthNotifier>(),
    errorBuilder: (context, state) => const RouteErrorScreen(),
    redirect: (context, state) async {
      final authNotifier = sl<AuthNotifier>();
      final loggedIn = authNotifier.isAuthenticated;
      final currentPath = state.matchedLocation;
      final loggingIn = currentPath == AppRoutes.authPath;
      final onOnboarding = currentPath == AppRoutes.notificationOnboardingPath;

      // ─── Not logged in ────────────────────────────────────────────────────
      if (!loggedIn) {
        return loggingIn ? null : AppRoutes.authPath;
      }

      // ─── Logged in + on auth screen → go to dashboard ────────────────────
      if (loggingIn) {
        // Before going to dashboard, check if onboarding is needed
        final needsOnboarding = await _needsNotificationOnboarding();
        return needsOnboarding
            ? AppRoutes.notificationOnboardingPath
            : AppRoutes.dashboardPath;
      }

      // ─── Logged in + onboarding already shown → skip onboarding ──────────
      if (onOnboarding) {
        // Allow onboarding screen to show
        return null;
      }

      // ─── Logged in + going to dashboard → check onboarding ───────────────
      if (currentPath == AppRoutes.dashboardPath) {
        final needsOnboarding = await _needsNotificationOnboarding();
        if (needsOnboarding) {
          return AppRoutes.notificationOnboardingPath;
        }
      }

      // ─── No redirect needed ───────────────────────────────────────────────
      return null;
    },

    routes: [
      // ─── Shell Route for Bottom Navigation ──────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboardPath,
            name: AppRoutes.dashboardName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.addExpensePath,
                name: AppRoutes.addExpenseName,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const TransactionFormScreen(),
              ),
              GoRoute(
                path: AppRoutes.editExpensePath,
                name: AppRoutes.editExpenseName,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final transaction = state.extra as TransactionEntity?;
                  return TransactionFormScreen(transaction: transaction);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.questsPath,
            name: AppRoutes.questsName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const CommunityHubScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.analyticsPath,
            name: AppRoutes.analyticsName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const AnalyticsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.profilePath,
            name: AppRoutes.profileName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      // ─── Standalone Auth Route ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.authPath,
        name: AppRoutes.authName,
        builder: (context, state) => const AuthScreen(),
      ),
      // ─── Standalone Onboarding Route ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.notificationOnboardingPath,
        name: AppRoutes.notificationOnboardingName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationOnboardingScreen(),
      ),
      // ─── Pending Transaction Review Route ────────────────────────────────────
      GoRoute(
        path: AppRoutes.pendingReviewPath,
        name: AppRoutes.pendingReviewName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final transactionId = state.pathParameters['transactionId'] ?? '';
          return PendingTransactionReviewScreen(transactionId: transactionId);
        },
      ),
      // ─── Standalone Gamification Routes ──────────────────────────────────────
      GoRoute(
        path: '/health-refill',
        name: 'health-refill',
        builder: (context, state) => const HealthRefillScreen(),
      ),
      // ─── IPO Capital Hub & ASBA Engine Route ──────────────────────────────────
      GoRoute(
        path: AppRoutes.ipoHubPath,
        name: AppRoutes.ipoHubName,
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) {
          final user = sl<AuthNotifier>().user;
          if (user == null) {
            return AppRoutes.authPath;
          }
          return null;
        },
        builder: (context, state) {
          final user = sl<AuthNotifier>().user;
          if (user == null) {
            return const SizedBox.shrink();
          }
          return IpoHubScreen(userId: user.uid);
        },
      ),
    ],
  );

  /// Check whether the notification onboarding screen should be shown.
  /// Returns true if the onboarding flag has NOT been stored yet.
  static Future<bool> _needsNotificationOnboarding() async {
    try {
      const storage = FlutterSecureStorage();
      final val = await storage.read(key: 'fingo_notification_onboarding_shown');
      return val != 'true';
    } catch (_) {
      return false; // On error, skip onboarding to avoid blocking the user
    }
  }
}
