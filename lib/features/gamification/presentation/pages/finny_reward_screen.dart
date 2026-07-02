import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/fingo_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../../di/injection_container.dart';
import '../utils/finny_asset_resolver.dart';
import '../utils/finny_message_bank.dart';

/// Full-screen celebration screen shown automatically when a reward fires.
/// Triggered for daily check-in (tier 1), weekly budget adherence (tier 2),
/// and monthly budget adherence (tier 3).
class FinnyRewardScreen extends StatefulWidget {
  final RewardType rewardType;

  const FinnyRewardScreen({super.key, required this.rewardType});

  @override
  State<FinnyRewardScreen> createState() => _FinnyRewardScreenState();
}

class _FinnyRewardScreenState extends State<FinnyRewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _finnyController;
  late AnimationController _diamondController;
  late AnimationController _confettiController;

  late Animation<double> _finnyScale;
  late Animation<double> _finnyBounce;
  late int _displayedDiamonds;
  late int _targetDiamonds;
  late String _message;

  @override
  void initState() {
    super.initState();

    _targetDiamonds = _diamondAmount;
    _displayedDiamonds = 0;

    final trigger = _trigger;
    final result = FinnyMessageBank.getMessageForTrigger(trigger);
    _message = result.message;

    // Finny entry animation
    _finnyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _finnyScale = CurvedAnimation(parent: _finnyController, curve: Curves.elasticOut);
    _finnyBounce = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _finnyController, curve: Curves.easeInOut),
    );
    _finnyController.forward();

    // Diamond count-up
    _diamondController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _diamondController.addListener(() {
      setState(() {
        _displayedDiamonds = (_diamondController.value * _targetDiamonds).round();
      });
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _diamondController.forward();
    });

    // Confetti loop
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _finnyController.dispose();
    _diamondController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  int get _diamondAmount {
    switch (widget.rewardType) {
      case RewardType.daily:   return kDailyStreakRewardDiamonds;
      case RewardType.weekly:  return kWeeklyRewardDiamonds;
      case RewardType.monthly: return kMonthlyRewardDiamonds;
    }
  }

  FinnyTrigger get _trigger {
    switch (widget.rewardType) {
      case RewardType.daily:   return FinnyTrigger.dailyStreakComplete;
      case RewardType.weekly:  return FinnyTrigger.weeklyComplete;
      case RewardType.monthly: return FinnyTrigger.monthlyComplete;
    }
  }

  String get _title {
    switch (widget.rewardType) {
      case RewardType.daily:   return 'Daily Check-in!';
      case RewardType.weekly:  return 'Weekly Budget Crushed!';
      case RewardType.monthly: return 'Monthly Champion!';
    }
  }

  double get _finnySize {
    switch (widget.rewardType) {
      case RewardType.daily:   return 160.0;
      case RewardType.weekly:  return 200.0;
      case RewardType.monthly: return 240.0;
    }
  }

  int get _confettiCount {
    switch (widget.rewardType) {
      case RewardType.daily:   return 40;
      case RewardType.weekly:  return 70;
      case RewardType.monthly: return 120;
    }
  }

  List<Color> get _gradientColors {
    switch (widget.rewardType) {
      case RewardType.daily:
        return [const Color(0xFF4DD0A1), const Color(0xFF2A9D8F)];
      case RewardType.weekly:
        return [const Color(0xFFFFB36B), const Color(0xFFFF7A45)];
      case RewardType.monthly:
        return [const Color(0xFF9B59B6), const Color(0xFFE74C3C)];
    }
  }

  void _dismiss() {
    sl<FingoState>().clearPendingReward(widget.rewardType);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _dismiss,
      child: Scaffold(
        body: Stack(
          children: [
            // ── Gradient background ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // ── Confetti ─────────────────────────────────────────────────
            AnimatedBuilder(
              animation: _confettiController,
              builder: (_, child) => CustomPaint(
                size: size,
                painter: _ConfettiPainter(
                  progress: _confettiController.value,
                  count: _confettiCount,
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Finny
                  ScaleTransition(
                    scale: _finnyScale,
                    child: AnimatedBuilder(
                      animation: _finnyBounce,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, -_finnyBounce.value),
                        child: child,
                      ),
                      child: FinnyAssetResolver.resolveHero(
                        FinnyEmotion.celebrating,
                        size: _finnySize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _title,
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Finny's message
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _message,
                      style: AppTextStyles.bodyLG.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Diamond award pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Text(
                          '+$_displayedDiamonds',
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Dismiss button
                  GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Awesome!',
                        style: AppTextStyles.labelLG.copyWith(
                          color: _gradientColors.first,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
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
}

// ── Confetti Painter ──────────────────────────────────────────────────────────

class _ConfettiPiece {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
  final double horizontalDrift;

  const _ConfettiPiece({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.horizontalDrift,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final int count;

  static final _random = Random(42); // Fixed seed for deterministic layout
  static final List<_ConfettiPiece> _pieces = [];

  _ConfettiPainter({required this.progress, required this.count}) {
    if (_pieces.isEmpty) {
      _initPieces();
    }
  }

  static const _colors = [
    Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4),
    Color(0xFF45B7D1), Color(0xFFFF9FF3), Color(0xFFFECA57),
    Color(0xFFFF9F43), Color(0xFF54A0FF), Color(0xFF5F27CD),
  ];

  void _initPieces() {
    for (int i = 0; i < 120; i++) {
      _pieces.add(_ConfettiPiece(
        x: _random.nextDouble(),
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 4 + _random.nextDouble() * 8,
        color: _colors[_random.nextInt(_colors.length)],
        rotationSpeed: _random.nextDouble() * 4 - 2,
        horizontalDrift: _random.nextDouble() * 0.1 - 0.05,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final displayCount = count.clamp(0, _pieces.length);

    for (int i = 0; i < displayCount; i++) {
      final piece = _pieces[i];
      final t = ((progress * piece.speed) + i / displayCount) % 1.0;
      final x = (piece.x + piece.horizontalDrift * t) * size.width;
      final y = t * (size.height + 40) - 20;
      final rotation = t * piece.rotationSpeed * pi * 4;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      paint.color = piece.color.withValues(alpha: t < 0.9 ? 1.0 : (1.0 - t) * 10);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
