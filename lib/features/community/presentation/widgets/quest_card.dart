import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/domain/entities/quest.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;

  const QuestCard({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final progressVal = (quest.currentProgress / (quest.targetValue > 0 ? quest.targetValue : 1)).clamp(0.0, 1.0);

    final String iconStr;
    if (quest.isCompleted) {
      iconStr = '✅';
    } else if (quest.currentProgress > 0) {
      iconStr = '🔥';
    } else {
      iconStr = '🎯';
    }

    return Opacity(
      opacity: quest.isCompleted ? 0.7 : 1.0,
      child: AppCard(
        color: quest.isCompleted
            ? (isLight ? AppColors.successSurfaceLight : AppColors.successSurfaceDark)
            : (isLight ? AppColors.surfaceLight : AppColors.surfaceDark),
        borderColor: quest.isCompleted
            ? AppColors.primary.withValues(alpha: 0.5)
            : (isLight ? AppColors.outlineLight : AppColors.outlineDark),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: quest.isCompleted
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : (isLight ? Colors.white : AppColors.bgDark),
                shape: BoxShape.circle,
                border: Border.all(
                  color: quest.isCompleted ? AppColors.primary : AppColors.outline,
                  width: 2,
                ),
              ),
              child: Text(iconStr, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          quest.title,
                          style: AppTextStyles.labelMD.copyWith(
                            fontWeight: FontWeight.w900,
                            decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${quest.xpReward} XP',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${quest.diamondReward} 💎',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quest.description,
                    style: AppTextStyles.bodySM.copyWith(
                      color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                          child: SizedBox(
                            height: 8,
                            child: LinearProgressIndicator(
                              value: progressVal,
                              color: quest.isCompleted ? AppColors.primary : AppColors.accent,
                              backgroundColor: isLight ? const Color(0xFFE5E5E5) : AppColors.bgDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        quest.isCompleted ? 'Completed' : '${quest.currentProgress}/${quest.targetValue}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: quest.isCompleted ? AppColors.primary : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
