import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/fingo_state.dart';
import '../../../../core/domain/entities/quest_completion_reward.dart';
import '../../../../di/injection_container.dart';
import '../utils/finny_asset_resolver.dart';
import '../utils/finny_message_bank.dart';

class FinnyRewardScreen extends StatefulWidget {
  final RewardType? rewardType;
  final List<QuestCompletionReward>? questRewards;

  const FinnyRewardScreen({super.key, this.rewardType, this.questRewards});

  @override
  State<FinnyRewardScreen> createState() => _FinnyRewardScreenState();
}

class _FinnyRewardScreenState extends State<FinnyRewardScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _countController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late AnimationController _shineController;

  late Animation<double> _slideUp;
  late Animation<double> _fadeIn;
  late Animation<double> _cardScale;
  late Animation<double> _pulse;
  late Animation<double> _shine;

  late int _displayedDiamonds;
  late int _targetDiamonds;
  late int _displayedXp;
  late int _targetXp;
  late String _message;

  bool get _isQuestReward =>
      widget.questRewards != null && widget.questRewards!.isNotEmpty;
  bool get _isMultiQuest => _isQuestReward && widget.questRewards!.length > 1;

  @override
  void initState() {
    super.initState();

    _targetDiamonds = _diamondAmount;
    _displayedDiamonds = 0;
    _targetXp = _xpAmount;
    _displayedXp = 0;

    if (_isQuestReward) {
      if (_isMultiQuest) {
        _message =
            'You crushed ${widget.questRewards!.length} quests at once! You\'re unstoppable!';
      } else {
        _message = 'Quest complete! Finny is proud of you! 🎉';
      }
    } else {
      final trigger = _trigger;
      final result = FinnyMessageBank.getMessageForTrigger(trigger);
      _message = result.message;
    }

    // Entry animation (slide up + fade)
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _slideUp = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6),
      ),
    );
    _cardScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _entryController.forward();

    // Count-up animation
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _countController.addListener(() {
      setState(() {
        final t = Curves.easeOutCubic.transform(_countController.value);
        _displayedDiamonds = (t * _targetDiamonds).round();
        _displayedXp = (t * _targetXp).round();
      });
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _countController.forward();
    });

    // Confetti
    _confettiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Reward badge pulse
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shine sweep
    _shineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _shine = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _countController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  int get _diamondAmount {
    if (_isQuestReward) {
      return widget.questRewards!.fold<int>(
        0,
        (sum, r) => sum + r.diamondsAwarded,
      );
    }
    switch (widget.rewardType ?? RewardType.daily) {
      case RewardType.daily:
        return kDailyStreakRewardDiamonds;
      case RewardType.weekly:
        return kWeeklyRewardDiamonds;
      case RewardType.monthly:
        return kMonthlyRewardDiamonds;
    }
  }

  int get _xpAmount {
    if (_isQuestReward) {
      return widget.questRewards!.fold<int>(0, (sum, r) => sum + r.xpAwarded);
    }
    return 0;
  }

  FinnyTrigger get _trigger {
    switch (widget.rewardType ?? RewardType.daily) {
      case RewardType.daily:
        return FinnyTrigger.dailyStreakComplete;
      case RewardType.weekly:
        return FinnyTrigger.weeklyComplete;
      case RewardType.monthly:
        return FinnyTrigger.monthlyComplete;
    }
  }

  String get _title {
    if (_isQuestReward) {
      return _isMultiQuest ? 'Multi-Quest\nComplete!' : 'Quest\nCompleted!';
    }
    switch (widget.rewardType ?? RewardType.daily) {
      case RewardType.daily:
        return 'Daily\nCheck-in!';
      case RewardType.weekly:
        return 'Weekly Budget\nCrushed!';
      case RewardType.monthly:
        return 'Monthly\nChampion!';
    }
  }

  String get _subtitle {
    if (_isQuestReward) return 'Rewards earned';
    switch (widget.rewardType ?? RewardType.daily) {
      case RewardType.daily:
        return 'Keep the streak alive!';
      case RewardType.weekly:
        return 'You stayed within budget!';
      case RewardType.monthly:
        return 'Outstanding financial discipline!';
    }
  }

  String get _emoji {
    if (_isQuestReward) return _isMultiQuest ? '🏆' : '⭐';
    switch (widget.rewardType ?? RewardType.daily) {
      case RewardType.daily:
        return '🔥';
      case RewardType.weekly:
        return '📊';
      case RewardType.monthly:
        return '👑';
    }
  }

  List<Color> get _gradientColors {
    if (_isQuestReward) {
      return [const Color(0xFF7C3AED), const Color(0xFFDB2777)];
    }
    switch (widget.rewardType ?? RewardType.daily) {
      case RewardType.daily:
        return [const Color(0xFFF97316), const Color(0xFFEF4444)];
      case RewardType.weekly:
        return [const Color(0xFF0EA5E9), const Color(0xFF6366F1)];
      case RewardType.monthly:
        return [const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
    }
  }

  Color get _accentColor {
    if (_isQuestReward) return const Color(0xFFFDE68A);
    switch (widget.rewardType ?? RewardType.daily) {
      case RewardType.daily:
        return const Color(0xFFFDE68A);
      case RewardType.weekly:
        return const Color(0xFFBAE6FD);
      case RewardType.monthly:
        return const Color(0xFFE9D5FF);
    }
  }

  Future<void> _dismiss() async {
    if (_isQuestReward) {
      await sl<FingoState>().clearAllPendingQuestRewards();
    } else if (widget.rewardType != null) {
      await sl<FingoState>().clearPendingReward(widget.rewardType!);
    }
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _dismiss();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Deep dark gradient background ─────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    _gradientColors.first.withValues(alpha: 0.9),
                    _gradientColors.last,
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // ── Subtle glow circle behind mascot ─────────────────────
            Positioned(
              top: size.height * 0.08,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Confetti ─────────────────────────────────────────────
            AnimatedBuilder(
              animation: _confettiController,
              builder: (_, _) => CustomPaint(
                size: size,
                painter: _ConfettiPainter(
                  progress: _confettiController.value,
                  count: _confettiCount,
                  accentColor: _accentColor,
                ),
              ),
            ),

            // ── Main content ──────────────────────────────────────────
            SafeArea(
              child: AnimatedBuilder(
                animation: _entryController,
                builder: (_, child) => FadeTransition(
                  opacity: _fadeIn,
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 1),

                    // ── Mascot ──────────────────────────────────────
                    ScaleTransition(
                      scale: _cardScale,
                      child: FinnyAssetResolver.resolveHero(
                        FinnyEmotion.celebrating,
                        size: _finnySize,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ── Title + emoji ───────────────────────────────
                    Text(_emoji, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 10),
                    Text(
                      _title,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _accentColor.withValues(alpha: 0.9),
                        letterSpacing: 0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // ── Finny's message ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Text(
                        _message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const Spacer(flex: 1),

                    // ── Reward cards ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildRewardSection(),
                    ),

                    const Spacer(flex: 1),

                    // ── CTA button ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _buildClaimButton(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap anywhere to continue',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardSection() {
    if (_isMultiQuest) {
      return Column(
        children: [
          // Quest list
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: widget.questRewards!.length,
              separatorBuilder: (_, _) => Divider(
                color: Colors.white.withValues(alpha: 0.08),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final r = widget.questRewards![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          r.questTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SmallBadge(
                        '+${r.xpAwarded} XP',
                        color: const Color(0xFFFDE68A),
                      ),
                      const SizedBox(width: 6),
                      _SmallBadge(
                        '+${r.diamondsAwarded} 💎',
                        color: Colors.white,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          // Totals
          Row(
            children: [
              Expanded(
                child: _RewardBigCard(
                  icon: '⭐',
                  value: '+$_displayedXp',
                  label: 'XP Total',
                  color: const Color(0xFFFDE68A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RewardBigCard(
                  icon: '💎',
                  value: '+$_displayedDiamonds',
                  label: 'Diamonds',
                  color: const Color(0xFFBAE6FD),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_isQuestReward) {
      return Row(
        children: [
          Expanded(
            child: _RewardBigCard(
              icon: '⭐',
              value: '+$_displayedXp',
              label: 'XP Earned',
              color: const Color(0xFFFDE68A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _RewardBigCard(
              icon: '💎',
              value: '+$_displayedDiamonds',
              label: 'Diamonds',
              color: const Color(0xFFBAE6FD),
            ),
          ),
        ],
      );
    }

    // Daily / Weekly / Monthly single reward
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
      child: AnimatedBuilder(
        animation: _shine,
        builder: (_, child) => ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              child!,
              // Shine sweep overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(_shine.value - 0.5, -1),
                      end: Alignment(_shine.value + 0.5, 1),
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcOver,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _accentColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _gradientColors.first.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💎', style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+$_displayedDiamonds',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: _accentColor.withValues(alpha: 0.6),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Diamonds earned',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _accentColor.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClaimButton() {
    return GestureDetector(
      onTap: _dismiss,
      child: AnimatedBuilder(
        animation: _entryController,
        builder: (_, child) => ScaleTransition(scale: _cardScale, child: child),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, _accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            _isMultiQuest ? '🎉  Claim All Rewards' : '🎉  Claim Reward',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: _gradientColors.last,
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  double get _finnySize {
    if (_isMultiQuest) return 130.0;
    if (_isQuestReward) return 150.0;
    switch (widget.rewardType ?? RewardType.daily) {
      case RewardType.daily:
        return 140.0;
      case RewardType.weekly:
        return 160.0;
      case RewardType.monthly:
        return 180.0;
    }
  }

  int get _confettiCount {
    if (_isQuestReward) return _isMultiQuest ? 110 : 70;
    switch (widget.rewardType ?? RewardType.daily) {
      case RewardType.daily:
        return 50;
      case RewardType.weekly:
        return 80;
      case RewardType.monthly:
        return 130;
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _RewardBigCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _RewardBigCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _SmallBadge(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
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
  final bool isCircle;

  const _ConfettiPiece({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
    required this.horizontalDrift,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final int count;
  final Color accentColor;

  static final _random = Random(42);
  static final List<_ConfettiPiece> _pieces = [];

  _ConfettiPainter({
    required this.progress,
    required this.count,
    required this.accentColor,
  }) {
    if (_pieces.isEmpty) _initPieces();
  }

  static const _baseColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFFFF9FF3),
    Color(0xFFFECA57),
    Color(0xFFFF9F43),
    Color(0xFF54A0FF),
    Color(0xFFA29BFE),
    Color(0xFFFFFFFF),
    Color(0xFFFFD700),
  ];

  void _initPieces() {
    for (int i = 0; i < 130; i++) {
      _pieces.add(
        _ConfettiPiece(
          x: _random.nextDouble(),
          speed: 0.25 + _random.nextDouble() * 0.75,
          size: 4 + _random.nextDouble() * 9,
          color: _baseColors[_random.nextInt(_baseColors.length)],
          rotationSpeed: _random.nextDouble() * 5 - 2.5,
          horizontalDrift: _random.nextDouble() * 0.12 - 0.06,
          isCircle: _random.nextBool(),
        ),
      );
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
      final y = t * (size.height + 50) - 30;
      final rotation = t * piece.rotationSpeed * pi * 4;
      final alpha = t < 0.85 ? 1.0 : (1.0 - t) * (1.0 / 0.15);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      paint.color = piece.color.withValues(alpha: alpha.clamp(0.0, 1.0));

      if (piece.isCircle) {
        canvas.drawCircle(Offset.zero, piece.size * 0.45, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.55,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress || old.accentColor != accentColor;
}
