import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/entities/financial_insight.dart';

class InsightsSection extends StatelessWidget {
  final List<FinancialInsight> insights;

  const InsightsSection({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final isLight = Theme.of(context).brightness == Brightness.light;
    final secTextColor = isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Key Insights', style: AppTextStyles.h2),
        const SizedBox(height: 10),
        ...insights.map((insight) {
          IconData iconData = Icons.lightbulb_rounded;
          Color priorityColor = AppColors.primary;

          switch (insight.priority) {
            case InsightPriority.critical:
              iconData = Icons.warning_rounded;
              priorityColor = AppColors.error;
              break;
            case InsightPriority.important:
              iconData = Icons.info_rounded;
              priorityColor = Colors.orange;
              break;
            case InsightPriority.positive:
              iconData = Icons.check_circle_rounded;
              priorityColor = Colors.green;
              break;
            case InsightPriority.achievement:
              iconData = Icons.emoji_events_rounded;
              priorityColor = AppColors.accent;
              break;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(iconData, color: priorityColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              insight.title,
                              style: AppTextStyles.labelSM.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                insight.category.toUpperCase(),
                                style: TextStyle(
                                  color: priorityColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight.amount != null
                              ? '${insight.message} (${insight.amount!.toCurrency()})'
                              : insight.message,
                          style: AppTextStyles.bodySM.copyWith(
                            color: secTextColor,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
