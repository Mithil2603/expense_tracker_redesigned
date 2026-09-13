import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../../../expenses/domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../../../../core/services/auto_transaction_notification_service.dart';

/// Full-screen modal for reviewing a single pending auto-detected transaction.
/// Opened when the user taps the system notification fired after auto-detection.
///
/// Shows the transaction details with ✓ (approve) and ✗ (reject) buttons front
/// and center. If the [transactionId] is no longer in the pending queue (already
/// reviewed), falls back to the Dashboard.
class PendingTransactionReviewScreen extends StatelessWidget {
  final String transactionId;

  const PendingTransactionReviewScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        // After approve or reject succeeds, navigate back to dashboard
        if (state is TransactionLoaded) {
          // Check if the transaction is no longer pending (was just acted on)
          final stillPending = state.transactions.any(
            (tx) => tx.id == transactionId && tx.isPending,
          );
          if (!stillPending) {
            // Cancel the notification for this transaction
            AutoTransactionNotificationService.cancelNotification(transactionId);
          }
        }
      },
      builder: (context, state) {
        TransactionEntity? pendingTx;
        if (state is TransactionLoaded) {
          try {
            pendingTx = state.transactions.firstWhere(
              (tx) => tx.id == transactionId && tx.isPending,
            );
          } catch (_) {
            // Transaction not found in pending queue — already reviewed
            pendingTx = null;
          }
        }

        return _PendingReviewView(
          transaction: pendingTx,
          transactionId: transactionId,
        );
      },
    );
  }
}

class _PendingReviewView extends StatelessWidget {
  final TransactionEntity? transaction;
  final String transactionId;

  const _PendingReviewView({
    required this.transaction,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final userId = sl<AuthNotifier>().user?.uid ?? '';

    // Fallback: transaction already reviewed — go to dashboard
    if (transaction == null) {
      return Scaffold(
        backgroundColor: isLight ? AppColors.bgLight : AppColors.bgDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 72, color: AppColors.success),
                const SizedBox(height: 20),
                Text(
                  'Already Reviewed',
                  style: AppTextStyles.h1.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'This transaction has already been reviewed.',
                  style: AppTextStyles.bodySM,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.dashboardPath),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Go to Dashboard'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final tx = transaction!;
    final isExpense = tx.type == TransactionType.expense;
    final catColor = tx.categoryColor;
    final amountStr = isExpense
        ? '-₹${tx.amount.toStringAsFixed(tx.amount.truncateToDouble() == tx.amount ? 0 : 2)}'
        : '+₹${tx.amount.toStringAsFixed(tx.amount.truncateToDouble() == tx.amount ? 0 : 2)}';
    final confidencePercent = tx.detectionMeta != null
        ? '${(tx.detectionMeta!.confidence * 100).toStringAsFixed(0)}%'
        : null;

    return Scaffold(
      backgroundColor: isLight ? AppColors.bgLight : AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.dashboardPath);
            }
          },
        ),
        title: Text(
          'Review Transaction',
          style: AppTextStyles.labelLG,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Auto-detected banner ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Fingo auto-detected this transaction${confidencePercent != null ? ' ($confidencePercent confidence)' : ''}. Review before it\'s saved.',
                              style: AppTextStyles.bodySM.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Transaction Card ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                        border: Border.all(
                          color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
                          width: AppSizes.borderThick,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isLight ? 0.05 : 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category icon + amount
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                                  border: Border.all(
                                    color: catColor.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(tx.categoryIcon, color: catColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.title,
                                      style: AppTextStyles.h2.copyWith(fontSize: 20),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tx.categoryName,
                                      style: AppTextStyles.bodySM.copyWith(
                                        color: catColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                amountStr,
                                style: AppTextStyles.amountLG.copyWith(
                                  color: isExpense
                                      ? (isLight
                                          ? AppColors.textPrimaryLight
                                          : AppColors.textPrimaryDark)
                                      : AppColors.success,
                                  fontSize: 26,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Details grid
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date',
                            value: AppFormatters.formatDate(tx.date),
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            icon: Icons.payment_outlined,
                            label: 'Method',
                            value: _paymentMethodLabel(tx.paymentMethod),
                          ),
                          if (tx.detectionMeta?.senderName.isNotEmpty == true) ...[
                            const SizedBox(height: 10),
                            _DetailRow(
                              icon: Icons.notifications_outlined,
                              label: 'Source',
                              value: tx.detectionMeta!.senderName,
                            ),
                          ],
                          if (tx.detectionMeta?.extractedRefNumber != null) ...[
                            const SizedBox(height: 10),
                            _DetailRow(
                              icon: Icons.tag,
                              label: 'Ref #',
                              value: tx.detectionMeta!.extractedRefNumber!,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Edit hint ─────────────────────────────────────────────
                    Align(
                      alignment: Alignment.center,
                      child: TextButton.icon(
                        onPressed: () {
                          context.pushNamed(AppRoutes.editExpenseName, extra: tx);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit details before approving'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Action Buttons ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
                border: Border(
                  top: BorderSide(
                    color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // ✗ Reject button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<TransactionBloc>().add(
                              DeleteTransactionEvent(tx.id, userId),
                            );
                        AutoTransactionNotificationService.cancelNotification(tx.id);
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go(AppRoutes.dashboardPath);
                        }
                      },
                      icon: const Icon(Icons.close, color: AppColors.error),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ✓ Approve button
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        final approved = tx.copyWith(isPending: false);
                        context.read<TransactionBloc>().add(
                              UpdateTransactionEvent(approved, userId),
                            );
                        AutoTransactionNotificationService.cancelNotification(tx.id);
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          context.go(AppRoutes.dashboardPath);
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.other:
        return 'Other';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary.withValues(alpha: 0.8)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySM.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySM,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
