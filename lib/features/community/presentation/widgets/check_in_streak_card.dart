import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class CheckInStreakCard extends StatelessWidget {
  final int checkInStreak;

  const CheckInStreakCard({
    super.key,
    required this.checkInStreak,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Determine milestone bracket
    int prevMilestone = 0;
    int nextMilestone = 3;
    int nextDiamondReward = 10;
    if (checkInStreak >= 30) {
      prevMilestone = 30;
      nextMilestone = 60;
      nextDiamondReward = 200;
    } else if (checkInStreak >= 14) {
      prevMilestone = 14;
      nextMilestone = 30;
      nextDiamondReward = 100;
    } else if (checkInStreak >= 7) {
      prevMilestone = 7;
      nextMilestone = 14;
      nextDiamondReward = 50;
    } else if (checkInStreak >= 3) {
      prevMilestone = 3;
      nextMilestone = 7;
      nextDiamondReward = 25;
    }

    final int range = nextMilestone - prevMilestone;
    final int progress = (checkInStreak - prevMilestone).clamp(0, range);
    final double progressRatio = range > 0 ? progress / range : 1.0;

    // Status label
    String statusLabel;
    if (checkInStreak == 0) {
      statusLabel = 'Start your streak today!';
    } else if (checkInStreak < 3) {
      statusLabel = 'Great start — keep going! 🚀';
    } else if (checkInStreak < 7) {
      statusLabel = 'Building momentum! 💪';
    } else if (checkInStreak < 14) {
      statusLabel = 'On a hot streak! 🔥';
    } else if (checkInStreak < 30) {
      statusLabel = 'Unstoppable! You\'re crushing it! 🏆';
    } else {
      statusLabel = 'Legendary dedication! 👑';
    }

    return AppCard(
      padding: EdgeInsets.zero,
      color: isLight ? const Color(0xFFFFFBF0) : const Color(0xFF221B0D),
      borderColor: Colors.amber.withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero gradient header ──────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLight
                    ? [const Color(0xFFFF9800), const Color(0xFFFF5722)]
                    : [const Color(0xFFE65100), const Color(0xFFBF360C)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: label + huge number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Text('✨', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              'DAILY CHECK-IN STREAK',
                              style: AppTextStyles.overline.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$checkInStreak',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    offset: const Offset(0, 2),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              checkInStreak == 1 ? 'day' : 'days',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: flame badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ],
            ),
          ),

          // ── Progress to next milestone ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress to next milestone',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isLight
                            ? AppColors.textSecondaryLight
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                    Text(
                      '$progress / $range days',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 10,
                    backgroundColor: isLight
                        ? const Color(0xFFFFE0B2)
                        : const Color(0xFF3D2C0A),
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFFFF9800)),
                  ),
                ),
              ],
            ),
          ),

          // ── Reward banner ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: isLight ? 0.12 : 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Text('💎', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reach $nextMilestone-day streak',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isLight
                                ? const Color(0xFF7B5800)
                                : Colors.amber.shade300,
                          ),
                        ),
                        Text(
                          'Earn +$nextDiamondReward diamonds',
                          style: AppTextStyles.caption.copyWith(
                            color: isLight
                                ? AppColors.textSecondaryLight
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+$nextDiamondReward 💎',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
