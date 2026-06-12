import 'package:flutter/material.dart';
import '../../../../core/core.dart';

void showSubscriptionPlansBottomSheet(BuildContext context) {
  int selectedPlanIdx = 1; // Default to Annual
  final isLight = Theme.of(context).brightness == Brightness.light;
  final bgColor = isLight ? Colors.white : AppColors.surfaceDark;
  final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
              border: Border.all(color: outlineColor, width: AppSizes.borderThick),
            ),
            padding: const EdgeInsets.all(AppSizes.paddingLG),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: outlineColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⚡ ', style: TextStyle(fontSize: 24)),
                      Expanded(
                        child: Text(
                          'UPGRADE TO FINGO SUPER',
                          style: AppTextStyles.h2.copyWith(color: AppColors.accentDark, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Text(' ⚡', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock your full financial potential with zero interruptions.',
                    style: AppTextStyles.bodySM,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildSubscriptionPlanRowHelper(
                    context: context,
                    idx: 0,
                    title: 'Fingo Plus (Monthly)',
                    price: '₹199 / mo',
                    description: 'No ads, unlimited health, premium badges.',
                    isSelected: selectedPlanIdx == 0,
                    onTap: () => setModalState(() => selectedPlanIdx = 0),
                  ),
                  const SizedBox(height: 12),
                  _buildSubscriptionPlanRowHelper(
                    context: context,
                    idx: 1,
                    title: 'Fingo Premium (Annual Saver)',
                    price: '₹1,499 / yr',
                    description: 'Everything in Plus + weekly reports & widget designs. Save 37%!',
                    isSelected: selectedPlanIdx == 1,
                    isPopular: true,
                    onTap: () => setModalState(() => selectedPlanIdx = 1),
                  ),
                  const SizedBox(height: 12),
                  _buildSubscriptionPlanRowHelper(
                    context: context,
                    idx: 2,
                    title: 'Fingo Family (Group Plan)',
                    price: '₹399 / mo',
                    description: 'Up to 5 accounts, joint budgets, shared streaks.',
                    isSelected: selectedPlanIdx == 2,
                    onTap: () => setModalState(() => selectedPlanIdx = 2),
                  ),
                  const SizedBox(height: 24),
                  App3DButton(
                    label: 'Start 7-Day Free Trial',
                    color: AppColors.accent,
                    shadowColor: AppColors.accentDark,
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Welcome to Fingo Super! 🚀')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cancel anytime in Google Play Store. Terms apply.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildSubscriptionPlanRowHelper({
  required BuildContext context,
  required int idx,
  required String title,
  required String price,
  required String description,
  required bool isSelected,
  bool isPopular = false,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent.withValues(alpha: .1) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.outline,
          width: isSelected ? AppSizes.borderThick : AppSizes.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTextStyles.labelMD.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isSelected ? AppColors.accentDark : null,
                        ),
                      ),
                    ),
                    if (isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'POPULAR',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodySM),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: AppTextStyles.labelMD.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ),
  );
}
