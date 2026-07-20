import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/entities/financial_intelligence.dart';

class MoneyLeaksCard extends StatelessWidget {
  final List<MoneyLeak> leaks;

  const MoneyLeaksCard({
    super.key,
    required this.leaks,
  });

  @override
  Widget build(BuildContext context) {
    if (leaks.isEmpty) return const SizedBox.shrink();

    final isLight = Theme.of(context).brightness == Brightness.light;
    final panelColor = AppColors.secondary;
    final panelBg = isLight ? AppColors.successSurfaceLight : AppColors.successSurfaceDark;

    return Container(
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: panelColor, width: AppSizes.borderThick),
      ),
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: panelColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'SAVINGS OPPORTUNITIES',
                style: AppTextStyles.labelSM.copyWith(
                  color: panelColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...leaks.map((leak) {
            Color confColor = Colors.orange;
            if (leak.confidenceLevel.toLowerCase() == 'high') {
              confColor = Colors.green;
            } else if (leak.confidenceLevel.toLowerCase() == 'low') {
              confColor = Colors.grey;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        leak.category,
                        style: AppTextStyles.labelSM.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: confColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: confColor, width: 1),
                        ),
                        child: Text(
                          '${leak.confidenceLevel} Confidence',
                          style: TextStyle(color: confColor, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    leak.leakReason,
                    style: AppTextStyles.bodySM.copyWith(height: 1.3, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  // Financial opportunity details
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'POTENTIAL MONTHLY SAVINGS',
                              style: AppTextStyles.overline.copyWith(fontSize: 8),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              leak.potentialMonthlySavings.toCurrency(),
                              style: AppTextStyles.labelMD.copyWith(
                                color: panelColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'POTENTIAL ANNUAL SAVINGS',
                              style: AppTextStyles.overline.copyWith(fontSize: 8),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              leak.potentialAnnualSavings.toCurrency(),
                              style: AppTextStyles.labelMD.copyWith(
                                color: panelColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💡 Actionable Tip: ${leak.actionableTip}',
                    style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                  ),
                  if (leaks.indexOf(leak) != leaks.length - 1)
                    Divider(height: 20, color: panelColor.withValues(alpha: 0.3)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
