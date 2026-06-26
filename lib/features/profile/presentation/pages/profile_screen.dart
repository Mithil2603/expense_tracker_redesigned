import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import '../../../../core/core.dart';
import '../../../../core/services/notification_sync_service.dart';
import '../../../../core/services/entitlement/entitlement_service.dart';
import '../../../../core/services/entitlement/models/feature.dart';
import '../../../../di/injection_container.dart';
import 'package:expense_tracker_app/features/auth/domain/usecases/sign_out.dart';
import '../widgets/subscription_plans_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  bool _trackerEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sl<FingoState>().addListener(_refresh);
    _loadTrackerSetting();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    sl<FingoState>().removeListener(_refresh);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndSyncPermission();
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _loadTrackerSetting() async {
    final enabled = await sl<NotificationSyncService>().isEnabled();
    if (mounted) {
      setState(() {
        _trackerEnabled = enabled;
      });
    }
  }

  void _checkAndSyncPermission() async {
    final hasPermission = await NotificationsListener.hasPermission;
    final currentlyEnabled = await sl<NotificationSyncService>().isEnabled();
    
    if (currentlyEnabled && hasPermission != true) {
      await sl<NotificationSyncService>().setEnabled(false);
      if (mounted) {
        setState(() {
          _trackerEnabled = false;
        });
      }
    } else if (!currentlyEnabled && hasPermission == true && _trackerEnabled) {
      await sl<NotificationSyncService>().setEnabled(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto-Tracker activated successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showProminentDisclosure() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            side: BorderSide(
              color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
              width: AppSizes.borderThick,
            ),
          ),
          backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
          title: Text(
            '🔒 Prominent Disclosure',
            style: AppTextStyles.h2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Fingo requires Notification Access to automatically track and log your transactions.',
                style: AppTextStyles.labelMD,
              ),
              const SizedBox(height: 12),
              Text(
                '• ONLY reads transaction alerts from payment and bank apps (like Google Pay, PhonePe, and Paytm).\n'
                '• Processed strictly locally in-memory on your device.\n'
                '• We NEVER read, collect, or store private chats, SMS, emails, or personal data.',
                style: AppTextStyles.bodySM,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _trackerEnabled = false;
                });
              },
              child: Text(
                'CANCEL',
                style: AppTextStyles.labelMD.copyWith(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _trackerEnabled = true;
                });
                await NotificationsListener.openPermissionSettings();
              },
              child: Text(
                'PROCEED',
                style: AppTextStyles.labelMD.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleTracker(bool enabled) async {
    if (enabled) {
      final entitlementService = sl<EntitlementService>();
      final hasAccess = entitlementService.hasAccess(Feature.autoDetectionBasic);
      
      if (!hasAccess) {
        showSubscriptionPlansBottomSheet(context);
        return;
      }

      final hasPermission = await NotificationsListener.hasPermission;
      if (hasPermission == true) {
        await sl<NotificationSyncService>().setEnabled(true);
        setState(() {
          _trackerEnabled = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Auto-Notification Tracker enabled! 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        _showProminentDisclosure();
      }
    } else {
      await sl<NotificationSyncService>().setEnabled(false);
      setState(() {
        _trackerEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auto-Notification Tracker disabled.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = sl<FingoState>();
    final authNotifier = sl<AuthNotifier>();
    final displayName = authNotifier.userName;
    final photoUrl = authNotifier.userPhotoUrl;

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
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? Image.network(
                                  photoUrl,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/fingo_mascot.png',
                                    width: 74,
                                    height: 74,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Padding(
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
                      Text(displayName, style: AppTextStyles.h2),
                      Text('Budgeting Champion', style: AppTextStyles.bodySM),
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

                // Settings Section
                Text("Settings", style: AppTextStyles.h2),
                const SizedBox(height: 12),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto-Notification Expense Tracker',
                              style: AppTextStyles.labelMD,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Instantly log transactions from Google Pay, PhonePe, Paytm, and bank notifications.',
                              style: AppTextStyles.bodySM,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _trackerEnabled,
                        activeThumbColor: AppColors.accent,
                        onChanged: _toggleTracker,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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
                const SizedBox(height: 24),
                App3DButton(
                  label: 'SIGN OUT',
                  color: AppColors.error,
                  shadowColor: AppColors.errorDark,
                  onTap: () async {
                    await sl<SignOut>().call();
                    sl<FingoState>().reset();
                  },
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
