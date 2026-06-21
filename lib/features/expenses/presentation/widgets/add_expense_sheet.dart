import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../expenses/domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

/// Opens a bottom sheet to log a new expense or edit an existing one.
void showAddExpenseSheet(BuildContext context, {TransactionEntity? transaction}) {
  final transactionBloc = context.read<TransactionBloc>();
  final currentUserId = sl<AuthNotifier>().user?.uid ?? 'test-user-id';

  final titleCtrl = TextEditingController(text: transaction?.title);
  final amountCtrl = TextEditingController(text: transaction != null ? transaction.amount.toString() : '');
  final notesCtrl = TextEditingController(text: transaction?.notes ?? '');
  
  ExpenseCategory selectedCat = transaction?.expenseCategory ?? ExpenseCategory.foodAndDining;
  DateTime selectedDate = transaction?.date ?? DateTime.now();
  PaymentMethod selectedPayment = transaction?.paymentMethod ?? PaymentMethod.cash;

  final isLight = Theme.of(context).brightness == Brightness.light;
  final bgColor = isLight ? Colors.white : AppColors.surfaceDark;
  final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: transactionBloc,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            final isEdit = transaction != null;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEdit ? 'Edit Expense Log' : 'Log New Expense', style: AppTextStyles.h2),
                        if (isEdit)
                          IconButton(
                            icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                            onPressed: () {
                              context.read<TransactionBloc>().add(
                                    DeleteTransactionEvent(transaction.id, currentUserId),
                                  );
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Expense deleted successfully!')),
                              );
                            },
                          ),
                      ],
                    ),
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
                    Text('Payment Method', style: AppTextStyles.labelMD),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<PaymentMethod>(
                      initialValue: selectedPayment,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: PaymentMethod.values.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Row(
                            children: [
                              Icon(method.icon, size: 20),
                              const SizedBox(width: 8),
                              Text(method.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedPayment = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Additional Notes',
                      hint: 'e.g. Spent with Sarah',
                      controller: notesCtrl,
                      prefixIcon: Icons.notes_rounded,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Transaction Date & Time', style: AppTextStyles.labelMD),
                        AppOutlineButton(
                          label: AppFormatters.formatDateTime(selectedDate),
                          icon: Icons.calendar_today_rounded,
                          expand: false,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (pickedDate != null) {
                              if (!context.mounted) return;
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDate),
                              );
                              if (pickedTime != null) {
                                setModalState(() {
                                  selectedDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              } else {
                                setModalState(() {
                                  selectedDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    selectedDate.hour,
                                    selectedDate.minute,
                                  );
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    App3DButton(
                      label: isEdit ? 'UPDATE LOG' : 'SAVE EXPENSE',
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

                        final updatedTx = TransactionEntity(
                          id: isEdit ? transaction.id : '',
                          userId: currentUserId,
                          title: title,
                          amount: amount,
                          type: TransactionType.expense,
                          expenseCategory: selectedCat,
                          date: selectedDate,
                          paymentMethod: selectedPayment,
                          notes: notesCtrl.text.trim(),
                          createdAt: isEdit ? transaction.createdAt : DateTime.now(),
                          updatedAt: DateTime.now(),
                          isRecurring: isEdit ? transaction.isRecurring : false,
                          recurringId: isEdit ? transaction.recurringId : null,
                          processedForXp: isEdit ? transaction.processedForXp : false,
                        );

                        if (isEdit) {
                          context.read<TransactionBloc>().add(
                                UpdateTransactionEvent(updatedTx, currentUserId),
                              );
                        } else {
                          context.read<TransactionBloc>().add(
                                AddTransactionEvent(updatedTx, currentUserId),
                              );
                        }

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isEdit ? 'Expense updated successfully!' : 'Expense logged successfully!')),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
