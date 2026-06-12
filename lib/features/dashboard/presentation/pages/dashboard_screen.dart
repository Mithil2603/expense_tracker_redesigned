import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../../features/expenses/domain/entities/transaction_entity.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _weekOffset = 0;

  @override
  void initState() {
    super.initState();
    sl<FingoState>().addListener(_onStateChange);
  }

  @override
  void dispose() {
    sl<FingoState>().removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  // ─── Navigation Constraints ───────────────────────────────────────────────

  bool _canGoBack() {
    final transactions = sl<FingoState>().transactions;
    if (transactions.isEmpty) return false;

    // Find earliest transaction date
    DateTime earliestDate = transactions.first.date;
    for (final tx in transactions) {
      if (tx.date.isBefore(earliestDate)) {
        earliestDate = tx.date;
      }
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));

    final earliestWeekStart = DateTime(
      earliestDate.year,
      earliestDate.month,
      earliestDate.day,
    ).subtract(Duration(days: earliestDate.weekday - 1));

    final diffDays = currentWeekStart.difference(earliestWeekStart).inDays;
    final maxPastWeeks = (diffDays / 7.0).ceil();

    return _weekOffset > -maxPastWeeks;
  }

  bool _canGoForward() {
    // Cannot go past the current week (offset 0) unless there are transactions in future weeks
    if (_weekOffset >= 0) {
      final transactions = sl<FingoState>().transactions;
      if (transactions.isEmpty) return false;

      // Find latest transaction date
      DateTime latestDate = transactions.first.date;
      for (final tx in transactions) {
        if (tx.date.isAfter(latestDate)) {
          latestDate = tx.date;
        }
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final currentWeekStart = today.subtract(
        Duration(days: today.weekday - 1),
      );

      final latestWeekStart = DateTime(
        latestDate.year,
        latestDate.month,
        latestDate.day,
      ).subtract(Duration(days: latestDate.weekday - 1));

      if (latestWeekStart.isBefore(currentWeekStart)) return false;

      final diffDays = latestWeekStart.difference(currentWeekStart).inDays;
      final maxFutureWeeks = (diffDays / 7.0).ceil();

      return _weekOffset < maxFutureWeeks;
    }
    return true; // Always allow moving forward towards current week if offset is negative
  }

  // ─── Week Calculations ─────────────────────────────────────────────────────

  DateTime _getStartOfWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today
        .subtract(Duration(days: today.weekday - 1))
        .add(Duration(days: _weekOffset * 7));
  }

  DateTime _getEndOfWeek(DateTime startOfWeek) {
    return startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
  }

  String _getWeekLabel(DateTime start, DateTime end) {
    if (_weekOffset == 0) return 'THIS WEEK';
    if (_weekOffset == -1) return 'LAST WEEK';
    if (_weekOffset == 1) return 'NEXT WEEK';
    return '${AppFormatters.formatDate(start).toUpperCase()} - ${AppFormatters.formatDate(end).toUpperCase()}';
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final startOfWeek = _getStartOfWeek();
    final endOfWeek = _getEndOfWeek(startOfWeek);
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Filter transactions belonging to selected week
    final filteredTxs = sl<FingoState>().transactions.where((tx) {
      return tx.date.isAfter(
            startOfWeek.subtract(const Duration(seconds: 1)),
          ) &&
          tx.date.isBefore(endOfWeek.add(const Duration(seconds: 1)));
    }).toList();

    // Group transactions by date
    final groupedTxs = <String, List<TransactionEntity>>{};
    for (final tx in filteredTxs) {
      final key = AppFormatters.formatRelativeDate(tx.date);
      if (!groupedTxs.containsKey(key)) {
        groupedTxs[key] = [];
      }
      groupedTxs[key]!.add(tx);
    }

    // Weekly spent calculates only expenses
    final totalSpentThisWeek = filteredTxs
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final canGoBack = _canGoBack();
    final canGoForward = _canGoForward();

    return Scaffold(
      appBar: const FingoGamifiedAppBar(),
      body: Column(
        children: [
          // Week selection row directly under the AppBar
          Container(
            color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppIconButton(
                  icon: Icons.chevron_left_rounded,
                  size: AppSizes.iconLG,
                  color: canGoBack ? null : Colors.grey.withValues(alpha: 0.4),
                  onTap: canGoBack
                      ? () {
                          setState(() {
                            _weekOffset--;
                          });
                        }
                      : () {},
                  tooltip: 'Previous Week',
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getWeekLabel(startOfWeek, endOfWeek),
                        style: AppTextStyles.labelMD.copyWith(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total spent: ${totalSpentThisWeek.toCurrency()}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: Icons.chevron_right_rounded,
                  size: AppSizes.iconLG,
                  color: canGoForward
                      ? null
                      : Colors.grey.withValues(alpha: 0.4),
                  onTap: canGoForward
                      ? () {
                          setState(() {
                            _weekOffset++;
                          });
                        }
                      : () {},
                  tooltip: 'Next Week',
                ),
              ],
            ),
          ),
          // Boundary outline divider
          Container(
            color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
            height: AppSizes.borderThick,
          ),
          // Expanded body region
          Expanded(
            child: filteredTxs.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: AppEmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: 'No transactions this week',
                        message:
                            'Fingo found no logged transactions for this period.',
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: AppSizes.screenHPadding,
                        right: AppSizes.screenHPadding,
                        top: AppSizes.s8,
                        bottom: 120, // spacing for floating navigation bar
                      ),
                      itemCount: groupedTxs.keys.length,
                      itemBuilder: (context, index) {
                        final groupKey = groupedTxs.keys.elementAt(index);
                        final groupItems = groupedTxs[groupKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppSectionHeader(title: groupKey),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: groupItems.length,
                              separatorBuilder: (context, idx) =>
                                  const AppDivider(indent: 8),
                              itemBuilder: (context, idx) {
                                final tx = groupItems[idx];
                                final catColor = tx.categoryColor;
                                final isExpense =
                                    tx.type == TransactionType.expense;

                                return ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(AppSizes.s8),
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMD,
                                      ),
                                      border: Border.all(
                                        color: catColor.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      tx.categoryIcon,
                                      color: catColor,
                                      size: 22,
                                    ),
                                  ),
                                  title: Text(
                                    tx.title,
                                    style: AppTextStyles.labelMD,
                                  ),
                                  subtitle: Text(
                                    '${tx.categoryName} • ${AppFormatters.formatTime(tx.date)}',
                                    style: AppTextStyles.bodySM,
                                  ),
                                  trailing: Text(
                                    '${isExpense ? '-' : '+'}${tx.amount.toCurrency(decimals: 0)}',
                                    style: AppTextStyles.amountSM.copyWith(
                                      color: isExpense
                                          ? (isLight
                                                ? AppColors.textPrimaryLight
                                                : AppColors.textPrimaryDark)
                                          : AppColors.success,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
