import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core.dart';

class ScaffoldWithNavigation extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavigation({
    super.key,
    required this.child,
  });

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

    final isLight = Theme.of(context).brightness == Brightness.light;
    final navBgColor = isLight ? Colors.white : AppColors.surfaceDark;
    final navOutlineColor = isLight
        ? const Color(0xFFE5E5E5)
        : AppColors.outlineDark;

    return Scaffold(
      body: Stack(
        children: [
          child,
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
                        isSelected: calculateSelectedIndex() == 0,
                        onTap: () => onItemTapped(0),
                        activeColor: AppColors.secondary,
                      ),
                      NavBarItem(
                        icon: Icons.emoji_events_rounded,
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
                        isSelected: calculateSelectedIndex() == 2,
                        onTap: () => onItemTapped(2),
                        activeColor: AppColors.info,
                      ),
                      NavBarItem(
                        icon: Icons.person_rounded,
                        isSelected: calculateSelectedIndex() == 3,
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

  const NavBarItem({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final unselectedColor = isLight
        ? const Color(0xFF8C8C8C)
        : AppColors.textTertiary;

    return Expanded(
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
    );
  }
}
