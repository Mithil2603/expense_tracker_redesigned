import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../di/injection_container.dart';
import '../widgets/subscription_plans_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    sl<FingoState>().addListener(_refresh);
  }

  @override
  void dispose() {
    sl<FingoState>().removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = sl<FingoState>();

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenHPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/fingo_mascot.png',
                              width: 74,
                              height: 74,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text('🪙', style: TextStyle(fontSize: 48)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Budgeting Champion', style: AppTextStyles.h2),
                      Text('Mithil', style: AppTextStyles.bodySM),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${state.level}',
                              style: AppTextStyles.labelMD,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              '${state.streak} Days',
                              style: AppTextStyles.labelMD,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Premium Banner
                GestureDetector(
                  onTap: () => showSubscriptionPlansBottomSheet(context),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentDark.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UPGRADE TO FINGO SUPER',
                                style: AppTextStyles.labelMD.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Unlock daily lives, unlimited quests, and double XP!',
                                style: AppTextStyles.bodySM.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                // Achievements section
                Text("My Achievements", style: AppTextStyles.h2),
                const SizedBox(height: 12),
                _buildAchievementRow(
                  'Streak Starter',
                  'Keep a streak of 3 days.',
                  state.streak >= 3,
                ),
                _buildAchievementRow(
                  'Budget Sentinel',
                  'Never breach budget for a week.',
                  state.totalSpent > 0 &&
                      state.totalSpent <= state.monthlyBudget,
                ),
                _buildAchievementRow(
                  'Gold Miner',
                  'Collect 100 XP points.',
                  state.level > 1 || state.xp >= 100,
                ),
                const SizedBox(height: 100), // spacing for bottom bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementRow(String name, String desc, bool unlocked) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: AppCard(
        color: unlocked
            ? null
            : (isLight ? const Color(0xFFF2F2F2) : const Color(0xFF1E2428)),
        borderColor: unlocked ? AppColors.accent : Colors.transparent,
        child: Row(
          children: [
            Text(unlocked ? '🏆' : '🔒', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelMD.copyWith(
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                  Text(desc, style: AppTextStyles.bodySM),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
