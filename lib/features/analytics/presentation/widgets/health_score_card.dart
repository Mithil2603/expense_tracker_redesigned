import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../domain/entities/financial_intelligence.dart';

class HealthScoreCard extends StatelessWidget {
  final HealthScore score;

  const HealthScoreCard({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;

    Color scoreColor = AppColors.primary;
    if (score.score < 50) {
      scoreColor = AppColors.error;
    } else if (score.score < 80) {
      scoreColor = AppColors.secondary;
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // Circular Indicator Stack
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: score.score / 100.0,
                        strokeWidth: 8,
                        color: scoreColor,
                        backgroundColor: isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark,
                      ),
                      Text(
                        '${score.score}',
                        style: AppTextStyles.h1.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Score Explanation Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            'FINANCIAL HEALTH SCORE',
                            style: AppTextStyles.overline.copyWith(color: scoreColor, fontWeight: FontWeight.w900),
                          ),
                          if (score.delta != 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: score.delta > 0 ? AppColors.successSurfaceLight : AppColors.errorSurfaceLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                score.delta > 0 ? '+${score.delta}' : '${score.delta}',
                                style: TextStyle(
                                  color: score.delta > 0 ? AppColors.primaryDark : AppColors.errorDark,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (score.positiveReasons.isNotEmpty || score.negativeReasons.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ...score.positiveReasons.map((reason) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: AppTextStyles.caption.copyWith(color: textColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )),
              ...score.negativeReasons.map((reason) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: AppTextStyles.caption.copyWith(color: textColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
