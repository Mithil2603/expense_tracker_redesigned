import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';

// Key for root navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// AppRouter — central navigation configuration using GoRouter.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboardPath,
    errorBuilder: (context, state) => const _RouteErrorScreen(),
    routes: [
      // ─── Shell Route for Bottom Navigation ──────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboardPath,
            name: AppRoutes.dashboardName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            routes: [
              // Details go here
              GoRoute(
                path: AppRoutes.addExpensePath,
                name: AppRoutes.addExpenseName,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const _AddExpenseMockScreen(),
              ),
              GoRoute(
                path: AppRoutes.editExpensePath,
                name: AppRoutes.editExpenseName,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const _EditExpenseMockScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.questsPath,
            name: AppRoutes.questsName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const _QuestsMockScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.analyticsPath,
            name: AppRoutes.analyticsName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const _AnalyticsMockScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.profilePath,
            name: AppRoutes.profileName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const _ProfileMockScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        builder: (context, state) => const _AuthMockScreen(),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SCAFFOLD WITH BOTTOM NAVIGATION BAR
// ══════════════════════════════════════════════════════════════════════════════

class _ScaffoldWithNavigation extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithNavigation({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int calculateSelectedIndex() {
      if (location.startsWith(AppRoutes.dashboardPath)) return 0;
      if (location.startsWith(AppRoutes.questsPath)) return 1;
      if (location.startsWith(AppRoutes.analyticsPath)) return 2;
      if (location.startsWith(AppRoutes.profilePath)) return 3;
      return 0;
    }

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.goNamed(AppRoutes.dashboardName);
          break;
        case 1:
          context.goNamed(AppRoutes.questsName);
          break;
        case 2:
          context.goNamed(AppRoutes.analyticsName);
          break;
        case 3:
          context.goNamed(AppRoutes.profileName);
          break;
      }
    }

    // Check if the current theme is light
    final isLight = Theme.of(context).brightness == Brightness.light;
    final navBgColor = isLight ? Colors.white : AppColors.surface;
    final navOutlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outline;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(
            top: BorderSide(color: navOutlineColor, width: AppSizes.borderThick),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.s4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Fingo',
                  isSelected: calculateSelectedIndex() == 0,
                  onTap: () => onItemTapped(0),
                  activeColor: AppColors.secondary,
                ),
                _NavBarItem(
                  icon: Icons.emoji_events_rounded,
                  label: 'Quests',
                  isSelected: calculateSelectedIndex() == 1,
                  onTap: () => onItemTapped(1),
                  activeColor: AppColors.accent,
                ),
                _NavBarItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Insights',
                  isSelected: calculateSelectedIndex() == 2,
                  onTap: () => onItemTapped(2),
                  activeColor: AppColors.info,
                ),
                _NavBarItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: calculateSelectedIndex() == 3,
                  onTap: () => onItemTapped(3),
                  activeColor: AppColors.success,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final unselectedColor = isLight ? const Color(0xFF8C8C8C) : AppColors.textTertiary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : unselectedColor,
                size: AppSizes.iconMD + 2,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.labelSM.copyWith(
                  color: isSelected ? activeColor : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ROUTE MOCK & ERROR SCREENS
// ══════════════════════════════════════════════════════════════════════════════

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Text('Route not found!', style: AppTextStyles.h2),
      ),
    );
  }
}

class _QuestsMockScreen extends StatelessWidget {
  const _QuestsMockScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Quests & Badges Coming Soon!', style: AppTextStyles.h2),
      ),
    );
  }
}

class _AnalyticsMockScreen extends StatelessWidget {
  const _AnalyticsMockScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Insights & Analytics Coming Soon!', style: AppTextStyles.h2),
      ),
    );
  }
}

class _ProfileMockScreen extends StatelessWidget {
  const _ProfileMockScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('User Profile Coming Soon!', style: AppTextStyles.h2),
      ),
    );
  }
}

class _AddExpenseMockScreen extends StatelessWidget {
  const _AddExpenseMockScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Center(
        child: Text('Add Expense Screen Coming Soon!', style: AppTextStyles.h2),
      ),
    );
  }
}

class _EditExpenseMockScreen extends StatelessWidget {
  const _EditExpenseMockScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: Center(
        child: Text('Edit Expense Screen Coming Soon!', style: AppTextStyles.h2),
      ),
    );
  }
}

class _AuthMockScreen extends StatelessWidget {
  const _AuthMockScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Authentication Screen Coming Soon!', style: AppTextStyles.h2),
      ),
    );
  }
}
