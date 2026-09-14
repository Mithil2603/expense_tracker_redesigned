import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core.dart';

class ScaffoldWithNavigation extends StatefulWidget {
  final Widget child;

  const ScaffoldWithNavigation({
    super.key,
    required this.child,
  });

  @override
  State<ScaffoldWithNavigation> createState() => _ScaffoldWithNavigationState();
}

class _ScaffoldWithNavigationState extends State<ScaffoldWithNavigation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int calculateSelectedIndex() {
      if (location.startsWith(AppRoutes.dashboardPath)) return 0;
      if (location.startsWith(AppRoutes.questsPath)) return 1;
      if (location.startsWith(AppRoutes.analyticsPath)) return 2;
      return -1;
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
          _scaffoldKey.currentState?.openEndDrawer();
          break;
      }
    }

    final isLight = Theme.of(context).brightness == Brightness.light;
    final navBgColor = isLight ? Colors.white : AppColors.surfaceDark;
    final navOutlineColor = isLight
        ? const Color(0xFFE5E5E5)
        : AppColors.outlineDark;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const _AppEndDrawer(),
      body: Stack(
        children: [
          widget.child,
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Floating Bar with Symmetrical Layout
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: navBgColor,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: navOutlineColor,
                      width: AppSizes.borderThick,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isLight ? 0.08 : 0.25,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Symmetrical Left side of the FAB
                      NavBarItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isSelected: calculateSelectedIndex() == 0,
                        onTap: () => onItemTapped(0),
                        activeColor: AppColors.secondary,
                      ),
                      NavBarItem(
                        icon: Icons.emoji_events_rounded,
                        label: 'Quests',
                        isSelected: calculateSelectedIndex() == 1,
                        onTap: () => onItemTapped(1),
                        activeColor: AppColors.accent,
                      ),

                      const SizedBox(
                        width: 52,
                      ), // Spacer width for overlapping FAB
                      // Symmetrical Right side of the FAB
                      NavBarItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Analytics',
                        isSelected: calculateSelectedIndex() == 2,
                        onTap: () => onItemTapped(2),
                        activeColor: AppColors.info,
                      ),
                      NavBarItem(
                        icon: Icons.menu_rounded,
                        label: 'Menu',
                        isSelected: false,
                        onTap: () => onItemTapped(3),
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
                // Overflowing central FAB
                Positioned(
                  top: -20,
                  child: App3DFAB(
                    onTap: () => context.pushNamed(AppRoutes.addExpenseName),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class App3DFAB extends StatefulWidget {
  final VoidCallback onTap;
  const App3DFAB({super.key, required this.onTap});

  @override
  State<App3DFAB> createState() => _App3DFABState();
}

class _App3DFABState extends State<App3DFAB> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: SizedBox(
        width: 60,
        height: 64,
        child: Stack(
          children: [
            // Bevel bottom shadow layer
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
            ),
            // Playful top layer
            AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              margin: EdgeInsets.only(
                top: _isPressed ? 4 : 0,
                bottom: _isPressed ? 0 : 4,
              ),
              width: 60,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final String? label;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final unselectedColor = isLight
        ? const Color(0xFF8C8C8C)
        : AppColors.textTertiary;

    return Expanded(
      child: Tooltip(
        message: label ?? '',
        child: Semantics(
          label: label,
          button: true,
          selected: isSelected,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Center(
                child: Icon(
                  icon,
                  color: isSelected ? activeColor : unselectedColor,
                  size: AppSizes.iconMD + 4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppEndDrawer extends StatelessWidget {
  const _AppEndDrawer();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final drawerBg = isLight ? Colors.white : AppColors.surfaceDark;
    final outlineColor = isLight ? AppColors.outlineLight : AppColors.outlineDark;

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close Menu',
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: outlineColor,
            ),
            const SizedBox(height: 16),

            // Profile item
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.goNamed(AppRoutes.profileName);
                },
                leading: Container(
                  padding: const EdgeInsets.all(AppSizes.s8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                title: Text('Profile', style: AppTextStyles.labelLG),
                subtitle: Text('Account, stats & settings', style: AppTextStyles.bodySM),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
            const SizedBox(height: 8),

            // IPO Capital Hub item
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.pushNamed(AppRoutes.ipoHubName);
                },
                leading: Container(
                  padding: const EdgeInsets.all(AppSizes.s8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFF38BDF8),
                    size: 22,
                  ),
                ),
                title: Text('IPO Capital Hub', style: AppTextStyles.labelLG),
                subtitle: Text('ASBA engine & pooled capital', style: AppTextStyles.bodySM),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
