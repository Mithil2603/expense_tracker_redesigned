import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../expenses/domain/entities/transaction_entity.dart';

void showAddExpenseSheet(BuildContext context) {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  ExpenseCategory selectedCat = ExpenseCategory.foodAndDining;
  DateTime selectedDate = DateTime.now();

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
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingLG,
              left: AppSizes.paddingLG,
              right: AppSizes.paddingLG,
              top: AppSizes.paddingMD,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Log New Expense', style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Expense Description',
                    hint: 'e.g. McDonald Lunch',
                    controller: titleCtrl,
                    prefixIcon: Icons.edit_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppAmountField(
                    label: 'Amount (INR)',
                    hint: '0.00',
                    controller: amountCtrl,
                  ),
                  const SizedBox(height: 16),
                  Text('Category', style: AppTextStyles.labelMD),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ExpenseCategory.values.length,
                      separatorBuilder: (context, idx) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = ExpenseCategory.values[idx];
                        final isSelected = cat == selectedCat;
                        return AppChip(
                          label: cat.displayName,
                          icon: cat.icon,
                          selected: isSelected,
                          color: cat.color,
                          onTap: () {
                            setModalState(() {
                              selectedCat = cat;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transaction Date', style: AppTextStyles.labelMD),
                      AppOutlineButton(
                        label: AppFormatters.formatDate(selectedDate),
                        icon: Icons.calendar_today_rounded,
                        expand: false,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  App3DButton(
                    label: 'Save Expense',
                    color: AppColors.error,
                    shadowColor: AppColors.errorDark,
                    onTap: () {
                      final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid title and amount.')),
                        );
                        return;
                      }

                      sl<FingoState>().addTransaction(
                        title: title,
                        amount: amount,
                        type: TransactionType.expense,
                        expenseCategory: selectedCat,
                        date: selectedDate,
                      );

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense logged successfully!')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
