import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/entities/transaction_entity.dart';

class ExplainabilitySheet extends StatelessWidget {
  final TransactionEntity transaction;

  const ExplainabilitySheet({super.key, required this.transaction});

  static Future<void> show(BuildContext context, TransactionEntity transaction) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExplainabilitySheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = transaction.detectionMeta;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (meta == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.screenHPadding,
        left: AppSizes.screenHPadding,
        right: AppSizes.screenHPadding,
        top: AppSizes.screenHPadding,
      ),
      decoration: BoxDecoration(
        color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLG)),
        border: Border.all(
          color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
          width: AppSizes.borderThin,
        ),
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
                color: isLight ? AppColors.textTertiaryLight : AppColors.textTertiaryDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.s16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.s8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.primary),
              ),
              const SizedBox(width: AppSizes.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Logged Transaction',
                      style: AppTextStyles.h3,
                    ),
                    Text(
                      'Detected from ${meta.source.toUpperCase()}',
                      style: AppTextStyles.bodySM,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s24),
          _buildInfoRow('Confidence Score', '${(meta.confidence * 100).toInt()}%'),
          const SizedBox(height: AppSizes.s12),
          _buildInfoRow('Sender', meta.senderName),
          const SizedBox(height: AppSizes.s12),
          _buildInfoRow('Classification', meta.classificationMethod.replaceAll('_', ' ')),
          const SizedBox(height: AppSizes.s24),
          if (meta.matchedRules.isNotEmpty) ...[
            Text(
              'Detection Signals:',
              style: AppTextStyles.labelMD,
            ),
            const SizedBox(height: AppSizes.s8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: meta.matchedRules.map((rule) => _buildRuleChip(rule)).toList(),
            ),
            const SizedBox(height: AppSizes.s24),
          ],
          AppButton(
            label: 'Close',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMD,
        ),
        Text(
          value,
          style: AppTextStyles.labelMD,
        ),
      ],
    );
  }

  Widget _buildRuleChip(String rule) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        rule.replaceAll('_', ' '),
        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
      ),
    );
  }
}
