import 'package:flutter/material.dart';

/// AppColors — single source of truth for every color in the app.
///
/// Palette philosophy:
///   Primary   → Deep Navy       (#0D1B2A) — authority, trust
///   Secondary → Electric Indigo (#4F46E5) — action, energy
///   Accent    → Warm Gold       (#F5A623) — premium, highlight
///   Surface   → Slate layers    — depth without darkness
///   Semantic  → Green/Red/Amber — status at a glance
abstract final class AppColors {
  // ─── Brand ──────────────────────────────────────────────────────────────────

  /// Deep navy — primary brand color, backgrounds, app bar
  static const Color primary = Color(0xFF0D1B2A);

  /// Mid-navy — cards, elevated surfaces
  static const Color primaryVariant = Color(0xFF1A2E45);

  /// Electric indigo — CTAs, active states, links
  static const Color secondary = Color(0xFF4F46E5);

  /// Lighter indigo — hover/pressed states
  static const Color secondaryVariant = Color(0xFF6D64EE);

  /// Warm gold — accent, badges, highlights
  static const Color accent = Color(0xFFF5A623);

  /// Lighter gold — subtle accent tints
  static const Color accentLight = Color(0xFFFFF0D0);

  // ─── Surfaces ───────────────────────────────────────────────────────────────

  /// Page/scaffold background
  static const Color background = Color(0xFF07111C);

  /// Primary card surface
  static const Color surface = Color(0xFF112233);

  /// Elevated card / bottom sheet
  static const Color surfaceElevated = Color(0xFF1C3450);

  /// Dividers, outlines, subtle borders
  static const Color outline = Color(0xFF2A4060);

  /// Pressed / ripple / hover overlay
  static const Color overlay = Color(0x1AFFFFFF);

  // ─── Text ───────────────────────────────────────────────────────────────────

  /// High-emphasis body text (near white)
  static const Color textPrimary = Color(0xFFF0F4F8);

  /// Medium-emphasis — labels, subtitles
  static const Color textSecondary = Color(0xFF8DA0B5);

  /// Low-emphasis — placeholders, disabled
  static const Color textTertiary = Color(0xFF4E6680);

  /// Text on colored (accent/secondary) backgrounds
  static const Color textOnAccent = Color(0xFF0D1B2A);

  // ─── Semantic ───────────────────────────────────────────────────────────────

  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFF0E2B1A);

  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFF2B0E0E);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFF2B1F0A);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFF0E1E2B);

  // ─── Category Colors ────────────────────────────────────────────────────────
  // Each category gets a distinct, harmonious color for chips/icons/charts.

  static const Color catFood = Color(0xFFFF6B6B);
  static const Color catTravel = Color(0xFF4ECDC4);
  static const Color catBills = Color(0xFFF5A623);
  static const Color catShopping = Color(0xFFA78BFA);
  static const Color catHealth = Color(0xFF34D399);
  static const Color catEntertainment = Color(0xFFFB7185);
  static const Color catOther = Color(0xFF8DA0B5);

  // ─── Gradients ──────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2E45), Color(0xFF0D1B2A)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5A623), Color(0xFFE8920F)],
  );

  static const LinearGradient indogoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C3450), Color(0xFF112233)],
  );
}
