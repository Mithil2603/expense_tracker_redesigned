import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/core.dart';
import '../../../../core/services/notification_sync_service.dart';
import '../../../../di/injection_container.dart';
import '../../../gamification/presentation/utils/finny_asset_resolver.dart';

/// [NotificationOnboardingScreen] — shown once on first launch (after auth,
/// before the dashboard) to guide the user through granting both permissions
/// needed for auto-transaction detection.
///
/// Permission flow:
/// Step 1 — POST_NOTIFICATIONS (Android 13 / API 33+ only):
///   - Request via permission_handler
///   - Auto-advance to Step 2 after 500ms (granted or denied)
///   - Skipped entirely on Android 12 and below
///
/// Step 2 — Notification Listener Access:
///   - Deep-link to Settings → Notification Access
///   - On app resume, re-check if permission was granted
///   - Granted → celebrating Finny, "You're all set!", navigate to dashboard after 1.5s
///   - Denied / skipped → navigate to dashboard, auto-detection stays inactive
///
/// State machine:
///   _step = 1 → show POST_NOTIFICATIONS card
///   _step = 2 → show Notification Listener Access card
///   _step = 3 → success state, auto-navigate
class NotificationOnboardingScreen extends StatefulWidget {
  const NotificationOnboardingScreen({super.key});

  @override
  State<NotificationOnboardingScreen> createState() =>
      _NotificationOnboardingScreenState();
}

class _NotificationOnboardingScreenState
    extends State<NotificationOnboardingScreen>
    with WidgetsBindingObserver {
  static const _storageKey = 'fingo_notification_onboarding_shown';

  int _step = 1;
  bool _postNotifGranted = false;
  bool _listenerGranted = false;
  bool _isCheckingPermission = false;
  bool _requestingPermission = false;
  bool _navigating = false;

  // Whether the user left for Settings and we're waiting for them to return
  bool _waitingForResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePermissionState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ─── Lifecycle Observer ───────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForResume) {
      _waitingForResume = false;
      _checkListenerPermissionOnResume();
    }
  }

  // ─── Initialization ───────────────────────────────────────────────────────

  Future<void> _initializePermissionState() async {
    setState(() => _isCheckingPermission = true);

    // Check Notification Listener permission
    final hasListener = await NotificationsListener.hasPermission ?? false;
    _listenerGranted = hasListener;

    // Check POST_NOTIFICATIONS (Android 13+ only)
    final sdkInt = await _getApiLevel();
    if (sdkInt < 33) {
      // Android 12 and below: POST_NOTIFICATIONS not required
      _postNotifGranted = true;
    } else {
      final postStatus = await Permission.notification.status;
      _postNotifGranted = postStatus.isGranted;
    }

    // Determine starting state
    if (_listenerGranted) {
      // Both done — skip screen entirely
      _markShownAndNavigate();
      return;
    }

    if (_postNotifGranted) {
      // Already have POST_NOTIFICATIONS (or not needed) — go straight to Step 2
      _step = 2;
    } else {
      _step = 1;
    }

    if (mounted) {
      setState(() => _isCheckingPermission = false);
    }
  }

  // ─── Permission Checks ────────────────────────────────────────────────────

  Future<int> _getApiLevel() async {
    try {
      // Query the SDK version through a platform channel call.
      // We use AndroidInfo from device_info_plus if available, otherwise
      // fall back to a conservative check.
      const channel = MethodChannel('com.example.expense_tracker/device_info');
      try {
        final sdkInt = await channel.invokeMethod<int>('getSdkVersion');
        return sdkInt ?? 33;
      } catch (_) {
        // Platform channel not available — assume Android 13+ to be safe
        // (shows POST_NOTIFICATIONS step, which is skippable anyway)
        return 33;
      }
    } catch (_) {
      return 33;
    }
  }

  Future<void> _requestPostNotifications() async {
    setState(() => _requestingPermission = true);
    final status = await Permission.notification.request();
    setState(() {
      _postNotifGranted = status.isGranted;
      _requestingPermission = false;
    });

    // Auto-advance to Step 2 regardless of grant/deny
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _step = 2);
    }
  }

  Future<void> _openNotificationListenerSettings() async {
    _waitingForResume = true;
    await NotificationsListener.openPermissionSettings();
  }

  Future<void> _checkListenerPermissionOnResume() async {
    if (!mounted) return;
    setState(() => _isCheckingPermission = true);

    final hasPermission = await NotificationsListener.hasPermission ?? false;
    if (!mounted) return;

    setState(() {
      _listenerGranted = hasPermission;
      _isCheckingPermission = false;
    });

    if (hasPermission) {
      // Celebration → auto-navigate
      setState(() => _step = 3);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted && !_navigating) {
        _markShownAndNavigate();
      }
    }
    // If still not granted, remain on Step 2 with retry state
  }

  Future<void> _markShownAndNavigate() async {
    if (_navigating) return;
    _navigating = true;

    // Persist the flag so this screen never shows again
    final storage = sl<FlutterSecureStorage>();
    await storage.write(key: _storageKey, value: 'true');

    // Initialize the notification sync service if listener permission was granted
    if (_listenerGranted) {
      await sl<NotificationSyncService>().init();
    }

    if (mounted) {
      context.go(AppRoutes.dashboardPath);
    }
  }

  void _skipScreen() {
    _markShownAndNavigate();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? AppColors.bgLight : AppColors.bgDark,
      body: SafeArea(
        child: _isCheckingPermission
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  children: [
                    // ── Progress indicator ──────────────────────────────────
                    _buildProgressBar(isLight),
                    const Spacer(),

                    // ── Animated card switcher ──────────────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      transitionBuilder: (child, animation) {
                        final offset = Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ));
                        return SlideTransition(
                          position: offset,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: _buildCurrentStepCard(isLight),
                    ),

                    const Spacer(),

                    // ── Skip link (always visible except on success) ────────
                    if (_step != 3)
                      TextButton(
                        onPressed: _skipScreen,
                        child: Text(
                          'Skip for now',
                          style: AppTextStyles.bodySM.copyWith(
                            color: isLight
                                ? AppColors.textSecondaryLight
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgressBar(bool isLight) {
    final total = _postNotifGranted ? 1 : 2;
    final current = _step == 1 ? 1 : (_step == 3 ? total : total);

    return Row(
      children: List.generate(total, (i) {
        final active = i < current;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : (isLight ? AppColors.outlineLight : AppColors.outlineDark),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStepCard(bool isLight) {
    switch (_step) {
      case 1:
        return _buildStep1Card(isLight, key: const ValueKey('step1'));
      case 2:
        return _buildStep2Card(isLight, key: const ValueKey('step2'));
      case 3:
        return _buildSuccessCard(isLight, key: const ValueKey('step3'));
      default:
        return const SizedBox.shrink(key: ValueKey('empty'));
    }
  }

  // ─── Step 1: POST_NOTIFICATIONS ───────────────────────────────────────────

  Widget _buildStep1Card(bool isLight, {required Key key}) {
    return _PermissionCard(
      key: key,
      isLight: isLight,
      finnyEmotion: FinnyEmotion.happy,
      stepLabel: 'Step 1 of 2',
      title: 'Stay in the loop',
      body:
          'Fingo will notify you the moment a transaction is detected — so you can review it instantly.',
      ctaLabel: 'Allow Notifications',
      ctaIcon: Icons.notifications_outlined,
      loading: _requestingPermission,
      onCtaTap: _requestPostNotifications,
    );
  }

  // ─── Step 2: Notification Listener Access ─────────────────────────────────

  Widget _buildStep2Card(bool isLight, {required Key key}) {
    return _PermissionCard(
      key: key,
      isLight: isLight,
      finnyEmotion: FinnyEmotion.excited,
      stepLabel: _postNotifGranted ? 'Step 1 of 1' : 'Step 2 of 2',
      title: 'Auto-detect your transactions',
      body:
          'Let Fingo read payment alerts from your bank and UPI apps to log transactions automatically — no manual entry needed.',
      ctaLabel: 'Enable Auto-detection',
      ctaIcon: Icons.auto_awesome_outlined,
      loading: _isCheckingPermission,
      onCtaTap: _openNotificationListenerSettings,
      secondaryCta: _listenerGranted
          ? null
          : 'Grant in Settings',
      listenerGranted: _listenerGranted,
    );
  }

  // ─── Step 3: Success ──────────────────────────────────────────────────────

  Widget _buildSuccessCard(bool isLight, {required Key key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Celebrating Finny
        FinnyAssetResolver.resolve(FinnyEmotion.celebrating, size: 140),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            '✓  Permission granted',
            style: AppTextStyles.bodySM.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "You're all set! 🎉",
          style: AppTextStyles.h1.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Fingo will now automatically catch payment notifications and log transactions for you.',
          style: AppTextStyles.bodySM.copyWith(
            color: isLight
                ? AppColors.textSecondaryLight
                : AppColors.textSecondaryDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const _OemBatteryTip(),
      ],
    );
  }
}

// ─── Shared Permission Card ────────────────────────────────────────────────

class _PermissionCard extends StatelessWidget {
  final bool isLight;
  final FinnyEmotion finnyEmotion;
  final String stepLabel;
  final String title;
  final String body;
  final String ctaLabel;
  final IconData ctaIcon;
  final bool loading;
  final VoidCallback onCtaTap;
  final String? secondaryCta;
  final bool listenerGranted;

  const _PermissionCard({
    super.key,
    required this.isLight,
    required this.finnyEmotion,
    required this.stepLabel,
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.ctaIcon,
    required this.loading,
    required this.onCtaTap,
    this.secondaryCta,
    this.listenerGranted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Finny mascot
        Center(
          child: _FloatingFinny(emotion: finnyEmotion),
        ),
        const SizedBox(height: 32),

        // Step label pill
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              stepLabel,
              style: AppTextStyles.overline.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          title,
          style: AppTextStyles.h1.copyWith(fontSize: 26),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Body
        Text(
          body,
          style: AppTextStyles.bodySM.copyWith(
            color: isLight
                ? AppColors.textSecondaryLight
                : AppColors.textSecondaryDark,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // CTA Button
        FilledButton.icon(
          onPressed: loading ? null : onCtaTap,
          icon: loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Icon(ctaIcon),
          label: Text(ctaLabel),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            textStyle: AppTextStyles.labelMD.copyWith(fontWeight: FontWeight.w700),
          ),
        ),

        // OEM battery tip (shown on Step 2 for context)
        if (finnyEmotion == FinnyEmotion.excited && !listenerGranted) ...[
          const SizedBox(height: 16),
          const _OemBatteryTip(),
        ],
      ],
    );
  }
}

// ─── OEM Battery Tip ──────────────────────────────────────────────────────

class _OemBatteryTip extends StatelessWidget {
  const _OemBatteryTip();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.battery_alert_outlined, size: 18, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Xiaomi, OnePlus, Samsung users: also enable "Autostart" for Fingo in your device\'s battery settings for reliable background detection.',
              style: AppTextStyles.bodySM.copyWith(
                color: isLight
                    ? AppColors.textSecondaryLight
                    : AppColors.textSecondaryDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Finny with bounce animation ─────────────────────────────────

class _FloatingFinny extends StatefulWidget {
  final FinnyEmotion emotion;

  const _FloatingFinny({required this.emotion});

  @override
  State<_FloatingFinny> createState() => _FloatingFinnyState();
}

class _FloatingFinnyState extends State<_FloatingFinny>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -_animation.value),
        child: child,
      ),
      child: FinnyAssetResolver.resolve(widget.emotion, size: 120),
    );
  }
}
