import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/community/presentation/pages/community_hub_screen.dart';
import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/expenses/presentation/pages/transaction_form_screen.dart';
import '../../features/expenses/domain/entities/transaction_entity.dart';
import '../../features/auth/presentation/pages/auth_screen.dart';
import 'widgets/scaffold_with_navigation.dart';
import 'pages/route_error_screen.dart';
import '../../features/gamification/presentation/pages/health_refill_screen.dart';

import '../../di/injection_container.dart';

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
    redirect: (context, state) {
      final authNotifier = sl<AuthNotifier>();
      final loggedIn = authNotifier.isAuthenticated;
      final loggingIn = state.matchedLocation == AppRoutes.authPath;

      if (!loggedIn) {
        // If not logged in and not already on the auth page, redirect to auth page
        return loggingIn ? null : AppRoutes.authPath;
      }

      // If logged in and trying to access the auth page, redirect to dashboard
      if (loggingIn) {
        return AppRoutes.dashboardPath;
      }

      // No redirect needed
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
      // ─── Standalone Gamification Routes ──────────────────────────────────────────────
      GoRoute(
        path: '/health-refill',
        name: 'health-refill',
        builder: (context, state) => const HealthRefillScreen(),
      ),
    ],
  );
}
