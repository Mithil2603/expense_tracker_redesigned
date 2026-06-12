import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../expenses/domain/entities/transaction_entity.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    sl<FingoState>().addListener(_refresh);
  }

  @override
  void dispose() {
    sl<FingoState>().removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = sl<FingoState>();
    final isLight = Theme.of(context).brightness == Brightness.light;
    final remainingBudget = state.monthlyBudget - state.totalSpent;
    final budgetRatio = (remainingBudget / state.monthlyBudget).clamp(0.0, 1.0);

    // Calculate category totals dynamically
    final expenseTxs = state.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final categoryTotals = <ExpenseCategory, double>{};
    for (final tx in expenseTxs) {
      final cat = tx.expenseCategory!;
      categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + tx.amount;
    }

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenHPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SAFE BUDGET',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${remainingBudget.toCurrency()} Left',
                            style: AppTextStyles.labelSM.copyWith(
                              color: remainingBudget < 1000.0
                                  ? AppColors.error
                                  : AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            state.totalSpent.toCurrency(),
                            style: AppTextStyles.display2,
                          ),
                          const SizedBox(width: 6),
                          Text('spent this month', style: AppTextStyles.bodySM),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        child: SizedBox(
                          height: 12,
                          child: LinearProgressIndicator(
                            value: budgetRatio,
                            color: remainingBudget < 1000.0
                                ? AppColors.error
                                : AppColors.primary,
                            backgroundColor: isLight
                                ? const Color(0xFFE5E5E5)
                                : AppColors.bgDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Image.asset(
                            'assets/fingo_mascot.png',
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Text('🪙', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              remainingBudget < 1000.0
                                  ? 'Careful! Fingo advises you to pause shopping now!'
                                  : 'You are in the Fingo Green Zone! Keep up the smart saves.',
                              style: AppTextStyles.bodySM.copyWith(
                                fontWeight: FontWeight.w600,
                                color: remainingBudget < 1000.0
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Budget breakdown section
                Text("Insights Breakdown", style: AppTextStyles.h2),
                const SizedBox(height: 12),
                if (expenseTxs.isEmpty)
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
                          Text(
                            'No expenses logged yet',
                            style: AppTextStyles.labelMD,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Log your expenses to view category insights.',
                            style: AppTextStyles.bodySM,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...categoryTotals.entries.map((entry) {
                    final cat = entry.key;
                    final total = entry.value;
                    return _buildCategoryUsageRow(
                      cat.displayName,
                      total,
                      cat.color,
                      cat.icon,
                    );
                  }),
                const SizedBox(height: 100), // spacing for bottom bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryUsageRow(
    String cat,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(cat, style: AppTextStyles.labelMD),
            const Spacer(),
            Text(amount.toCurrency(), style: AppTextStyles.amountSM),
          ],
        ),
      ),
    );
  }
}
