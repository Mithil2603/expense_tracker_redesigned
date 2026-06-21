import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionEntity? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _notesCtrl;

  late bool _isExpense;
  late DateTime _selectedDate;
  late PaymentMethod _selectedPayment;
  
  ExpenseCategory? _selectedExpenseCategory;
  IncomeCategory? _selectedIncomeCategory;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    
    _isExpense = tx == null ? true : (tx.type == TransactionType.expense);
    _titleCtrl = TextEditingController(text: tx?.title);
    _amountCtrl = TextEditingController(text: tx != null ? tx.amount.toString() : '');
    _notesCtrl = TextEditingController(text: tx?.notes ?? '');
    _selectedDate = tx?.date ?? DateTime.now();
    _selectedPayment = tx?.paymentMethod ?? PaymentMethod.cash;

    if (_isExpense) {
      _selectedExpenseCategory = tx?.expenseCategory ?? ExpenseCategory.foodAndDining;
      _selectedIncomeCategory = IncomeCategory.salary;
    } else {
      _selectedExpenseCategory = ExpenseCategory.foodAndDining;
      _selectedIncomeCategory = tx?.incomeCategory ?? IncomeCategory.salary;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Delete Transaction?', style: AppTextStyles.h2),
          content: Text(
            'Are you sure you want to delete this transaction log? This action cannot be undone.',
            style: AppTextStyles.bodyMD,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final currentUserId = sl<AuthNotifier>().user?.uid ?? 'test-user-id';
                context.read<TransactionBloc>().add(
                      DeleteTransactionEvent(widget.transaction!.id, currentUserId),
                    );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  List<ExpenseCategory> _getDisplayExpenseCategories() {
    final defaults = [
      ExpenseCategory.foodAndDining,
      ExpenseCategory.transportation,
      ExpenseCategory.entertainmentAndLeisure,
      ExpenseCategory.shoppingAndFashion,
      ExpenseCategory.utilities,
    ];
    final selected = _selectedExpenseCategory ?? ExpenseCategory.foodAndDining;
    if (!defaults.contains(selected)) {
      defaults[4] = selected;
    }
    return defaults;
  }

  List<IncomeCategory> _getDisplayIncomeCategories() {
    final defaults = [
      IncomeCategory.salary,
      IncomeCategory.freelance,
      IncomeCategory.business,
      IncomeCategory.investments,
      IncomeCategory.sideHustle,
    ];
    final selected = _selectedIncomeCategory ?? IncomeCategory.salary;
    if (!defaults.contains(selected)) {
      defaults[4] = selected;
    }
    return defaults;
  }

  Widget _buildCategoryCard({
    required String displayName,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLight,
    required Color outlineColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isLight ? Colors.white : AppColors.surfaceDark),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isSelected ? color : outlineColor,
            width: AppSizes.borderThick,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    offset: const Offset(0, 3),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white24 : color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayName,
              style: AppTextStyles.bodySM.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isLight ? Colors.black87 : Colors.white),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreCard({
    required VoidCallback onTap,
    required bool isLight,
    required Color outlineColor,
  }) {
    final color = isLight ? Colors.grey[700]! : Colors.grey[400]!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? Colors.white : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: outlineColor,
            width: AppSizes.borderThick,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.grid_view_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'More...',
              style: AppTextStyles.bodySM.copyWith(
                color: isLight ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.normal,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  void _showAllCategoriesModal(BuildContext context, bool isLight, Color outlineColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isLight ? AppColors.bgLight : AppColors.bgDark,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
        side: BorderSide(color: outlineColor, width: AppSizes.borderThick),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categoriesCount = _isExpense 
                ? ExpenseCategory.values.length 
                : IncomeCategory.values.length;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLG,
                  vertical: AppSizes.paddingMD,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isLight ? Colors.grey[300] : Colors.grey[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isExpense ? 'All Expense Categories' : 'All Income Categories',
                      style: AppTextStyles.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: categoriesCount,
                        itemBuilder: (context, idx) {
                          if (_isExpense) {
                            final cat = ExpenseCategory.values[idx];
                            final isSelected = _selectedExpenseCategory == cat;
                            final catColor = cat.color;

                            return _buildCategoryCard(
                              displayName: cat.displayName,
                              icon: cat.icon,
                              color: catColor,
                              isSelected: isSelected,
                              isLight: isLight,
                              outlineColor: outlineColor,
                              onTap: () {
                                setModalState(() {
                                  _selectedExpenseCategory = cat;
                                });
                                setState(() {
                                  _selectedExpenseCategory = cat;
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          } else {
                            final cat = IncomeCategory.values[idx];
                            final isSelected = _selectedIncomeCategory == cat;
                            final catColor = cat.color;

                            return _buildCategoryCard(
                              displayName: cat.displayName,
                              icon: cat.icon,
                              color: catColor,
                              isSelected: isSelected,
                              isLight: isLight,
                              outlineColor: outlineColor,
                              onTap: () {
                                setModalState(() {
                                  _selectedIncomeCategory = cat;
                                });
                                setState(() {
                                  _selectedIncomeCategory = cat;
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid title and amount.')),
      );
      return;
    }

    final currentUserId = sl<AuthNotifier>().user?.uid ?? 'test-user-id';
    final isEdit = widget.transaction != null;
    
    final updatedTx = TransactionEntity(
      id: isEdit ? widget.transaction!.id : '',
      userId: currentUserId,
      title: title,
      amount: amount,
      type: _isExpense ? TransactionType.expense : TransactionType.income,
      expenseCategory: _isExpense ? _selectedExpenseCategory : null,
      incomeCategory: !_isExpense ? _selectedIncomeCategory : null,
      date: _selectedDate,
      paymentMethod: _selectedPayment,
      notes: _notesCtrl.text.trim(),
      createdAt: isEdit ? widget.transaction!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      isRecurring: isEdit ? widget.transaction!.isRecurring : false,
      recurringId: isEdit ? widget.transaction!.recurringId : null,
      processedForXp: isEdit ? widget.transaction!.processedForXp : false,
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
      SnackBar(
        content: Text(
          isEdit ? 'Transaction updated successfully!' : 'Transaction logged successfully!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;
    final isEdit = widget.transaction != null;

    return Scaffold(
      backgroundColor: isLight ? AppColors.bgLight : AppColors.bgDark,
      appBar: AppCustomAppBar(
        title: isEdit ? 'Edit Log' : 'Log Transaction',
        automaticallyImplyLeading: true,
        actions: isEdit
            ? [
                AppBarAction(
                  icon: Icons.delete_forever_rounded,
                  tooltip: 'Delete Log',
                  onTap: () => _confirmDelete(context),
                ),
              ]
            : const [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Segmented Mode Selector ──────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFF5F5F5) : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  border: Border.all(color: outlineColor, width: AppSizes.borderThick),
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpense = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isExpense ? AppColors.error : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            boxShadow: _isExpense
                                ? [
                                    BoxShadow(
                                      color: AppColors.errorDark,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'EXPENSE',
                            style: AppTextStyles.labelLG.copyWith(
                              color: _isExpense
                                  ? Colors.white
                                  : (isLight ? Colors.black54 : Colors.white70),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpense = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 48,
                          decoration: BoxDecoration(
                            color: !_isExpense ? AppColors.success : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                            boxShadow: !_isExpense
                                ? [
                                    BoxShadow(
                                      color: AppColors.successDark,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'INCOME',
                            style: AppTextStyles.labelLG.copyWith(
                              color: !_isExpense
                                  ? Colors.white
                                  : (isLight ? Colors.black54 : Colors.white70),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Description Input ──────────────────────────────────────────
              AppTextField(
                label: 'Description',
                hint: _isExpense ? 'e.g. McDonald Lunch' : 'e.g. Salary Payout',
                controller: _titleCtrl,
                prefixIcon: Icons.edit_rounded,
              ),
              const SizedBox(height: 16),

              // ─── Amount Input ───────────────────────────────────────────────
              AppAmountField(
                label: 'Amount (INR)',
                hint: '0.00',
                controller: _amountCtrl,
              ),
              const SizedBox(height: 20),

              // ─── Category Section ───────────────────────────────────────────
              Text('Select Category', style: AppTextStyles.labelMD),
              const SizedBox(height: 10),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: 6,
                itemBuilder: (context, idx) {
                  if (idx < 5) {
                    if (_isExpense) {
                      final displayCats = _getDisplayExpenseCategories();
                      final cat = displayCats[idx];
                      final isSelected = _selectedExpenseCategory == cat;
                      return _buildCategoryCard(
                        displayName: cat.displayName,
                        icon: cat.icon,
                        color: cat.color,
                        isSelected: isSelected,
                        isLight: isLight,
                        outlineColor: outlineColor,
                        onTap: () {
                          setState(() {
                            _selectedExpenseCategory = cat;
                          });
                        },
                      );
                    } else {
                      final displayCats = _getDisplayIncomeCategories();
                      final cat = displayCats[idx];
                      final isSelected = _selectedIncomeCategory == cat;
                      return _buildCategoryCard(
                        displayName: cat.displayName,
                        icon: cat.icon,
                        color: cat.color,
                        isSelected: isSelected,
                        isLight: isLight,
                        outlineColor: outlineColor,
                        onTap: () {
                          setState(() {
                            _selectedIncomeCategory = cat;
                          });
                        },
                      );
                    }
                  } else {
                    return _buildMoreCard(
                      isLight: isLight,
                      outlineColor: outlineColor,
                      onTap: () => _showAllCategoriesModal(context, isLight, outlineColor),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // ─── Payment Method Dropdown ───────────────────────────────────
              Text('Payment Method', style: AppTextStyles.labelMD),
              const SizedBox(height: 8),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _selectedPayment,
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
                    setState(() {
                      _selectedPayment = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // ─── Transaction Date & Time Selector ──────────────────────────
              Text('Transaction Date & Time', style: AppTextStyles.labelMD),
              const SizedBox(height: 8),
              AppOutlineButton(
                label: AppFormatters.formatDateTime(_selectedDate),
                icon: Icons.calendar_today_rounded,
                expand: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    if (!context.mounted) return;
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    } else {
                      setState(() {
                        _selectedDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          _selectedDate.hour,
                          _selectedDate.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              // ─── Notes Input ───────────────────────────────────────────────
              AppTextField(
                label: 'Notes',
                hint: _isExpense ? 'e.g. Spent with Sarah' : 'e.g. Monthly bonus included',
                controller: _notesCtrl,
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 28),

              // ─── Save Action Button ────────────────────────────────────────
              App3DButton(
                label: isEdit ? 'UPDATE TRANSACTION' : 'SAVE TRANSACTION',
                color: _isExpense ? AppColors.error : AppColors.success,
                shadowColor: _isExpense ? AppColors.errorDark : AppColors.successDark,
                onTap: _saveTransaction,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
