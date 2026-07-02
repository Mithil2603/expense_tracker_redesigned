import 'package:flutter/material.dart';

enum FinnyEmotion {
  happy,
  excited,
  focused,
  cheerUp,
  celebrating, // New: for reward/goal-achieved screens
}

class FinnyAssetResolver {
  // Asset path map — each emotion maps to a real cropped PNG from assets/finny/
  static const Map<FinnyEmotion, String> _assetPaths = {
    FinnyEmotion.happy:       'assets/finny/finny_happy.png',
    FinnyEmotion.excited:     'assets/finny/finny_excited.png',
    FinnyEmotion.focused:     'assets/finny/finny_focused.png',
    FinnyEmotion.cheerUp:     'assets/finny/finny_cheerup.png',
    FinnyEmotion.celebrating: 'assets/finny/finny_celebrating.png',
  };

  // Background accent colors per emotion (used by companion bubble + reward screen)
  static const Map<FinnyEmotion, Color> bgColors = {
    FinnyEmotion.happy:       Color(0xFFFFD6A5),
    FinnyEmotion.excited:     Color(0xFF4DD0A1),
    FinnyEmotion.focused:     Color(0xFFE8EDF5),
    FinnyEmotion.cheerUp:     Color(0xFFFFB36B),
    FinnyEmotion.celebrating: Color(0xFFFFE066),
  };

  static const Map<FinnyEmotion, Color> borderColors = {
    FinnyEmotion.happy:       Color(0xFFFFB36B),
    FinnyEmotion.excited:     Color(0xFF2A9D8F),
    FinnyEmotion.focused:     Color(0xFF1E293B),
    FinnyEmotion.cheerUp:     Color(0xFFFF7A45),
    FinnyEmotion.celebrating: Color(0xFFFF7A45),
  };

  /// Returns a widget rendering the Finny mascot for [emotion] at the given [size].
  /// Uses the real cropped PNG. Falls back to placeholder circle if asset loading fails.
  static Widget resolve(FinnyEmotion emotion, {double size = 64.0}) {
    final assetPath = _assetPaths[emotion];

    if (assetPath == null) {
      return _placeholder(emotion, size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _placeholder(emotion, size),
      ),
    );
  }

  /// Returns a larger widget for full-screen reward moments.
  static Widget resolveHero(FinnyEmotion emotion, {double size = 180.0}) {
    return resolve(emotion, size: size);
  }

  /// Fallback: colored circle with emoji — used if asset path is null or image fails.
  static Widget _placeholder(FinnyEmotion emotion, double size) {
    final String emoji;
    switch (emotion) {
      case FinnyEmotion.happy:
        emoji = '😊';
        break;
      case FinnyEmotion.excited:
        emoji = '🤩';
        break;
      case FinnyEmotion.focused:
        emoji = '🧐';
        break;
      case FinnyEmotion.cheerUp:
        emoji = '🥺';
        break;
      case FinnyEmotion.celebrating:
        emoji = '🎉';
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColors[emotion] ?? const Color(0xFFFFD6A5),
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColors[emotion] ?? const Color(0xFFFFB36B),
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
