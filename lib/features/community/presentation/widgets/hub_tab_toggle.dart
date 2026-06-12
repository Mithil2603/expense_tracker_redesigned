import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class HubTabToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const HubTabToggle({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? const Color(0xFFF0F0F0) : AppColors.surfaceDark;
    final activeColor = AppColors.primary;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark,
          width: AppSizes.borderThick,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selectedIndex == 0 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  boxShadow: selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Daily Quests 🏆',
                  style: AppTextStyles.labelMD.copyWith(
                    color: selectedIndex == 0
                        ? Colors.white
                        : (isLight ? Colors.black87 : Colors.white70),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selectedIndex == 1 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  boxShadow: selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Social Feed 💬',
                  style: AppTextStyles.labelMD.copyWith(
                    color: selectedIndex == 1
                        ? Colors.white
                        : (isLight ? Colors.black87 : Colors.white70),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
