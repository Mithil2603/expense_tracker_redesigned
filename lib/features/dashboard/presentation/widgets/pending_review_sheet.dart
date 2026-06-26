import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/core.dart';
import '../../../expenses/domain/entities/transaction_entity.dart';
import '../../../expenses/presentation/bloc/transaction_bloc.dart';
import '../../../expenses/presentation/bloc/transaction_event.dart';

class PendingReviewSheet extends StatelessWidget {
  final List<TransactionEntity> pendingTransactions;

  const PendingReviewSheet({super.key, required this.pendingTransactions});

  static Future<void> show(BuildContext context, List<TransactionEntity> transactions) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PendingReviewSheet(pendingTransactions: transactions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(AppSizes.screenHPadding),
          decoration: BoxDecoration(
            color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Pending Review', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                'Fingo found these transactions in your notifications, but isn\'t fully confident. Approve or reject them.',
                style: AppTextStyles.bodySM,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  itemCount: pendingTransactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = pendingTransactions[index];
                    return AppCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: tx.categoryColor.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                                ),
                                child: Icon(tx.categoryIcon, color: tx.categoryColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.title, style: AppTextStyles.labelMD, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text('${tx.categoryName} • ${AppFormatters.formatTime(tx.date)}', style: AppTextStyles.bodySM),
                                  ],
                                ),
                              ),
                              Text(
                                '${tx.type == TransactionType.expense ? '-' : '+'}${tx.amount.toCurrency(decimals: 0)}',
                                style: AppTextStyles.amountSM.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  context.read<TransactionBloc>().add(DeleteTransactionEvent(tx.id, tx.userId));
                                  Navigator.of(context).pop();
                                },
                                child: Text('REJECT', style: AppTextStyles.labelMD.copyWith(color: AppColors.error)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMD)),
                                ),
                                onPressed: () {
                                  final approvedTx = TransactionEntity(
                                    id: tx.id,
                                    userId: tx.userId,
                                    title: tx.title,
                                    amount: tx.amount,
                                    type: tx.type,
                                    expenseCategory: tx.expenseCategory,
                                    incomeCategory: tx.incomeCategory,
                                    date: tx.date,
                                    paymentMethod: tx.paymentMethod,
                                    notes: tx.notes,
                                    createdAt: tx.createdAt,
                                    updatedAt: tx.updatedAt,
                                    detectionMeta: tx.detectionMeta,
                                    isPending: false, // Mark as approved!
                                  );
                                  context.read<TransactionBloc>().add(UpdateTransactionEvent(approvedTx, tx.userId));
                                  Navigator.of(context).pop();
                                },
                                child: Text('APPROVE', style: AppTextStyles.labelMD.copyWith(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
