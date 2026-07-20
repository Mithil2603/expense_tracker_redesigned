import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../expenses/domain/entities/transaction_entity.dart';
import '../../domain/entities/financial_report.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final FinancialReport report;

  const CategoryBreakdownCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final hasExpenses = report.categoryExpenses.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Category Breakdown', style: AppTextStyles.h2),
        const SizedBox(height: 10),
        if (!hasExpenses)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.pie_chart_outline_rounded,
                    color: AppColors.textTertiary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text('No expenses logged for this range.', style: AppTextStyles.labelMD),
                ],
              ),
            ),
          )
        else
          ...report.categoryExpenses.entries.map((entry) {
            final cat = entry.key;
            final amount = entry.value;
            final percentage = report.totalExpense > 0
                ? (amount / report.totalExpense * 100.0)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(cat.icon, color: cat.color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cat.displayName, style: AppTextStyles.labelSM),
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100.0,
                              minHeight: 6,
                              color: cat.color,
                              backgroundColor: isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(amount.toCurrency(), style: AppTextStyles.amountSM.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
