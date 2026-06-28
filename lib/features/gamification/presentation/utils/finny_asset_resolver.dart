import 'package:flutter/material.dart';

enum FinnyEmotion {
  happy,
  excited,
  focused,
  cheerUp,
}

class FinnyAssetResolver {
  /// Maps a [FinnyEmotion] to its corresponding placeholder widget.
  /// When production Rive/Lottie assets are ready, this is the only
  /// method that needs to change.
  static Widget resolve(FinnyEmotion emotion, {double size = 64.0}) {
    // These are the placeholder colors defined in the style guide:
    // #FFB36B, #FF7A45, #FFD6A5, #4DD0A1, #2A9D8F, #1E293B

    Color bgColor;
    Color borderColor;
    String emoji;

    switch (emotion) {
      case FinnyEmotion.happy:
        bgColor = const Color(0xFFFFD6A5); // Light Orange
        borderColor = const Color(0xFFFFB36B); // Orange
        emoji = '😊';
        break;
      case FinnyEmotion.excited:
        bgColor = const Color(0xFF4DD0A1); // Light Green
        borderColor = const Color(0xFF2A9D8F); // Dark Green
        emoji = '🤩';
        break;
      case FinnyEmotion.focused:
        bgColor = const Color(0xFF1E293B).withValues(alpha: 0.1); // Slate Blue
        borderColor = const Color(0xFF1E293B);
        emoji = '🧐';
        break;
      case FinnyEmotion.cheerUp:
        bgColor = const Color(0xFFFFB36B); // Orange
        borderColor = const Color(0xFFFF7A45); // Deep Orange
        emoji = '🥺';
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 3.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(fontSize: size * 0.5),
      ),
    );
  }
}
