import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/fingo_state.dart';
import '../../../../core/theme/theme.dart';
import '../../../../di/injection_container.dart';

class HealthRefillScreen extends StatefulWidget {
  const HealthRefillScreen({super.key});

  @override
  State<HealthRefillScreen> createState() => _HealthRefillScreenState();
}

class _HealthRefillScreenState extends State<HealthRefillScreen> {
  bool _isWatchingAd = false;

  void _watchAd() async {
    final state = sl<FingoState>();
    if (state.health >= state.maxHealth) return;

    setState(() {
      _isWatchingAd = true;
    });

    // Simulate watching an ad
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isWatchingAd = false;
      });
      state.refillHealth(5); // Gives +5 health
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad finished! +5 Health ❤️')),
      );
    }
  }

  void _buyWithDiamonds() {
    final state = sl<FingoState>();
    if (state.health >= state.maxHealth) return;

    if (state.diamonds >= 50) {
      state.deductDiamonds(50);
      state.refillHealth(5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase successful! +5 Health ❤️')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough Diamonds! 💎')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = sl<FingoState>();
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isLight ? Colors.black : Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Health',
          style: AppTextStyles.h3.copyWith(
            color: isLight ? Colors.black : Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.screenHPadding),
            child: Row(
              children: [
                const Text('💎', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                ListenableBuilder(
                  listenable: state,
                  builder: (context, _) {
                    return Text(
                      '${state.diamonds}',
                      style: AppTextStyles.labelMD.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            final isFull = state.health >= state.maxHealth;
            final double healthRatio = state.health / state.maxHealth;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.screenHPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Bar Header
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.outlineLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: healthRatio.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '${state.health} / ${state.maxHealth}',
                                  style: AppTextStyles.labelSM.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('❤️', style: TextStyle(fontSize: 28)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.s32),

                  // Option 1: Buy with Diamonds
                  Opacity(
                    opacity: isFull ? 0.5 : 1.0,
                    child: InkWell(
                      onTap: isFull ? null : _buyWithDiamonds,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.s16),
                        decoration: BoxDecoration(
                          color: isLight ? Colors.white : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                          border: Border.all(
                            color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.outlineLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '5',
                                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimaryLight),
                              ),
                            ),
                            const SizedBox(width: AppSizes.s16),
                            Expanded(
                              child: Text(
                                '+5 health',
                                style: AppTextStyles.labelLG.copyWith(
                                  color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
                                ),
                              ),
                            ),
                            Text(
                              '💎 50',
                              style: AppTextStyles.labelMD.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.s16),

                  // Option 2: Watch Ad
                  Opacity(
                    opacity: isFull ? 0.5 : 1.0,
                    child: InkWell(
                      onTap: isFull || _isWatchingAd ? null : _watchAd,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.s16),
                        decoration: BoxDecoration(
                          color: isLight ? Colors.white : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                          border: Border.all(
                            color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.outlineLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '5',
                                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimaryLight),
                              ),
                            ),
                            const SizedBox(width: AppSizes.s16),
                            Expanded(
                              child: Text(
                                '+5 health',
                                style: AppTextStyles.labelLG.copyWith(
                                  color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
                                ),
                              ),
                            ),
                            if (_isWatchingAd)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              Text(
                                'WATCH AD',
                                style: AppTextStyles.labelMD.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.s32),
                  
                  if (isFull)
                    Text(
                      'You have full health! Keep up the great work!',
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      'Health naturally restores to full every midnight.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
