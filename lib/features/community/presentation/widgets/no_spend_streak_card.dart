import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/services/quest/no_spend_streak_service.dart';

class NoSpendStreakCard extends StatelessWidget {
  final NoSpendStreakData? streakData;
  final Map<DateTime, bool> recentDaysMap;

  const NoSpendStreakCard({
    super.key,
    required this.streakData,
    required this.recentDaysMap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final currentStreak = streakData?.currentStreak ?? 0;
    final longestStreak = streakData?.longestStreak ?? 0;

    // Milestone bracket
    int prevMilestone = 0;
    int nextMilestone = 3;
    int nextDiamondReward = 15;
    if (currentStreak >= 30) {
      prevMilestone = 30;
      nextMilestone = 60;
      nextDiamondReward = 500;
    } else if (currentStreak >= 14) {
      prevMilestone = 14;
      nextMilestone = 30;
      nextDiamondReward = 300;
    } else if (currentStreak >= 7) {
      prevMilestone = 7;
      nextMilestone = 14;
      nextDiamondReward = 100;
    } else if (currentStreak >= 3) {
      prevMilestone = 3;
      nextMilestone = 7;
      nextDiamondReward = 50;
    }

    final int range = nextMilestone - prevMilestone;
    final int progress = (currentStreak - prevMilestone).clamp(0, range);
    final double progressRatio = range > 0 ? progress / range : 1.0;

    // Status label
    String statusLabel;
    if (currentStreak == 0) {
      statusLabel = 'No spend day = free day! 💚';
    } else if (currentStreak < 3) {
      statusLabel = 'Saving mode activated! 💚';
    } else if (currentStreak < 7) {
      statusLabel = 'Wallet is safe! 🛡️';
    } else if (currentStreak < 14) {
      statusLabel = 'Super saver! You\'re amazing! ⭐';
    } else {
      statusLabel = 'Elite saver! Hall of fame! 🏆';
    }

    // Generate last 14 days sorted chronologically
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = <DateTime>[];
    for (int i = 13; i >= 0; i--) {
      days.add(today.subtract(Duration(days: i)));
    }

    // Count no-spend days in range
    final noSpendCount = days.where((d) => recentDaysMap[d] ?? true).length;

    return AppCard(
      padding: EdgeInsets.zero,
      color: isLight ? const Color(0xFFF3FCF7) : const Color(0xFF0D1F16),
      borderColor: AppColors.primary.withValues(alpha: 0.6),
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
                    ? [const Color(0xFF2A9D8F), const Color(0xFF1B6B5E)]
                    : [const Color(0xFF1A7A6E), const Color(0xFF0D4F45)],
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
                            const Text('🛡️', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              'NO-SPEND STREAK',
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
                              '$currentStreak',
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
                              currentStreak == 1 ? 'day' : 'days',
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
                // Right: shield badge
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
                    child: Text('💚', style: TextStyle(fontSize: 30)),
                  ),
                ),
              ],
            ),
          ),

          // ── Stats row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                _StatBox(
                  label: 'Best Streak',
                  value: '$longestStreak',
                  unit: 'days',
                  icon: '🏆',
                  isLight: isLight,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  label: 'No-Spend (14d)',
                  value: '$noSpendCount',
                  unit: '/ 14 days',
                  icon: '✅',
                  isLight: isLight,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          // ── Progress to next milestone ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next milestone: $nextMilestone days',
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
                        color: AppColors.primary,
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
                        ? const Color(0xFFB2DFDB)
                        : const Color(0xFF0D2B24),
                    valueColor:
                        AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // ── Reward banner ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isLight ? 0.09 : 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
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
                                ? AppColors.primaryDark
                                : AppColors.primary,
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
                      color: AppColors.primary,
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

          // ── 14-day heatmap ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Text(
              'PAST 14 DAYS',
              style: AppTextStyles.overline.copyWith(
                color: isLight
                    ? AppColors.textSecondaryLight
                    : AppColors.textSecondaryDark,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((date) {
                final isNoSpend = recentDaysMap[date] ?? true;
                final isToday = date == today;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 28,
                    decoration: BoxDecoration(
                      color: isNoSpend
                          ? AppColors.primary
                          : (isLight
                              ? const Color(0xFFE0E0E0)
                              : const Color(0xFF1A2E26)),
                      borderRadius: BorderRadius.circular(6),
                      border: isToday
                          ? Border.all(color: Colors.amberAccent, width: 2.5)
                          : Border.all(
                              color: isNoSpend
                                  ? AppColors.primaryDark
                                  : (isLight
                                      ? const Color(0xFFCCCCCC)
                                      : const Color(0xFF2A3E35)),
                              width: 1,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: isToday
                        ? Text(
                            '•',
                            style: TextStyle(
                              color: isNoSpend ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '14d ago',
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
                Text(
                  'Today',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String icon;
  final bool isLight;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.isLight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isLight ? 0.08 : 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: isLight
                            ? AppColors.textSecondaryLight
                            : AppColors.textSecondaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
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
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color.withValues(alpha: 0.8),
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
}
