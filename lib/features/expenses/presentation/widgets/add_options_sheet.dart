import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import 'add_income_sheet.dart';
import 'add_expense_sheet.dart';

void showAddOptionsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final isLight = Theme.of(sheetContext).brightness == Brightness.light;
      final bgColor = isLight ? Colors.white : AppColors.surfaceDark;
      final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;
      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
          border: Border.all(color: outlineColor, width: AppSizes.borderThick),
        ),
        padding: const EdgeInsets.all(AppSizes.paddingLG),
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
            Text(
              'Select Transaction Type',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: App3DButton(
                    label: 'Income',
                    color: AppColors.success,
                    shadowColor: AppColors.successDark,
                    icon: Icons.arrow_upward_rounded,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      showAddIncomeSheet(context);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: App3DButton(
                    label: 'Expense',
                    color: AppColors.error,
                    shadowColor: AppColors.errorDark,
                    icon: Icons.arrow_downward_rounded,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      showAddExpenseSheet(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
