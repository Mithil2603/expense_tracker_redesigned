import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/entities/financial_report.dart';

class SummaryCards extends StatelessWidget {
  final FinancialReport report;

  const SummaryCards({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Income Card
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              children: [
                const Icon(Icons.arrow_downward_rounded, color: AppColors.primary, size: 18),
                const SizedBox(height: 4),
                Text('INCOME', style: AppTextStyles.overline),
                const SizedBox(height: 4),
                Text(
                  report.totalIncome.toCurrency(),
                  style: AppTextStyles.amountSM.copyWith(color: AppColors.primary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 2. Expenses Card
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              children: [
                const Icon(Icons.arrow_upward_rounded, color: AppColors.error, size: 18),
                const SizedBox(height: 4),
                Text('SPENT', style: AppTextStyles.overline),
                const SizedBox(height: 4),
                Text(
                  report.totalExpense.toCurrency(),
                  style: AppTextStyles.amountSM.copyWith(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 3. Savings Card
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              children: [
                const Icon(Icons.savings_rounded, color: AppColors.secondary, size: 18),
                const SizedBox(height: 4),
                Text('SAVINGS', style: AppTextStyles.overline),
                const SizedBox(height: 4),
                Text(
                  '${report.savingsRate.toStringAsFixed(0)}%',
                  style: AppTextStyles.amountSM.copyWith(color: AppColors.secondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
