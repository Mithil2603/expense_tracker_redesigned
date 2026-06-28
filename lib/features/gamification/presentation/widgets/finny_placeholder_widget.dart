import 'package:flutter/material.dart';
import '../../../../di/injection_container.dart';
import '../controllers/finny_controller.dart';
import '../utils/finny_asset_resolver.dart';
import '../utils/finny_message_bank.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FinnyPlaceholderWidget extends StatefulWidget {
  const FinnyPlaceholderWidget({super.key});

  @override
  State<FinnyPlaceholderWidget> createState() => _FinnyPlaceholderWidgetState();
}

class _FinnyPlaceholderWidgetState extends State<FinnyPlaceholderWidget>
    with SingleTickerProviderStateMixin {
  late final FinnyController _controller;
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = sl<FinnyController>();
    _controller.addListener(_onStateChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
      if (_controller.currentMessage != null) {
        _animController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isVisible) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // The Mascot
        GestureDetector(
          onTap: () {
            _controller.triggerEvent(FinnyTrigger.genericTap);
          },
          child: FinnyAssetResolver.resolve(
            _controller.currentEmotion,
            size: 64.0,
          ),
        ),

        // The Speech Bubble
        if (_controller.currentMessage != null)
          Positioned(
            right: 50,
            bottom: 50,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Text(
                  _controller.currentMessage!,
                  style: AppTextStyles.bodySM.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
