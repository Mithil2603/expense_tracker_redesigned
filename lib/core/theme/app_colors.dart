import 'package:flutter/material.dart';

/// AppColors — single source of truth for every color in the Fingo application.
///
/// Palette inspired by Duolingo: high contrast, vibrant, friendly, flat-3D compatible.
abstract final class AppColors {
  // ─── Brand Colors ──────────────────────────────────────────────────────────

  /// Fingo Green — primary brand color (used for normal positive actions, success, checkmarks)
  static const Color primary = Color(0xFF58CC02);
  static const Color primaryDark = Color(0xFF46A302); // for 3D buttons bottom shadow

  /// Streak Flame Orange — secondary brand color (used for streaks, fire animations, daily quests)
  static const Color secondary = Color(0xFFFF9600);
  static const Color secondaryDark = Color(0xFFE27C00); // for 3D buttons bottom shadow

  /// Gold/Yellow — accent color (used for XP, gems, crowns, coins, achievements)
  static const Color accent = Color(0xFFFFC01E);
  static const Color accentDark = Color(0xFFE0A300); // for 3D buttons bottom shadow
  static const Color accentLight = Color(0xFFFFF0D0);

  /// Sky Blue — informational color (used for navigation hints, levels, sub-stats)
  static const Color info = Color(0xFF1CB0F6);
  static const Color infoDark = Color(0xFF1899D6);
  static const Color infoSurfaceDark = Color(0xFF0C242F);
  static const Color infoSurfaceLight = Color(0xFFE1F5FE);

  /// Heart Red — semantic danger color (used for over-budget warnings, hearts/lives, errors)
  static const Color error = Color(0xFFFF4B4B);
  static const Color errorDark = Color(0xFFEA2B2B);
  static const Color errorSurfaceDark = Color(0xFF2F0F0F);
  static const Color errorSurfaceLight = Color(0xFFFFEBEE);

  /// Success mapping
  static const Color success = Color(0xFF58CC02);
  static const Color successDark = Color(0xFF46A302);
  static const Color successSurfaceDark = Color(0xFF0C2702);
  static const Color successSurfaceLight = Color(0xFFE8F5E9);

  /// Warning mapping
  static const Color warning = Color(0xFFFF9600);
  static const Color warningSurfaceDark = Color(0xFF2F1F00);
  static const Color warningSurfaceLight = Color(0xFFFFF3E0);

  // ─── Dark Mode Surfaces ─────────────────────────────────────────────────────

  /// Dark background (Duolingo Dark Navy/Slate)
  static const Color bgDark = Color(0xFF131F24);

  /// Dark card surfaces
  static const Color surfaceDark = Color(0xFF1E2E35);

  /// Dark elevated surfaces (modals, active headers)
  static const Color surfaceElevatedDark = Color(0xFF2B3D45);

  /// Dark borders (thick playful outlines)
  static const Color outlineDark = Color(0xFF37464F);

  // ─── Light Mode Surfaces ────────────────────────────────────────────────────

  /// Light background (Pure white)
  static const Color bgLight = Color(0xFFFFFFFF);

  /// Light card surfaces (super light gray)
  static const Color surfaceLight = Color(0xFFF7F7F7);

  /// Light elevated surfaces
  static const Color surfaceElevatedLight = Color(0xFFEFEFEF);

  /// Light borders
  static const Color outlineLight = Color(0xFFE5E5E5);

  // ─── Text Colors (Dark Mode) ────────────────────────────────────────────────

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFAFB9C0);
  static const Color textTertiaryDark = Color(0xFF6B7F8A);
  static const Color textOnButtonDark = Color(0xFFFFFFFF);

  // ─── Text Colors (Light Mode) ───────────────────────────────────────────────

  static const Color textPrimaryLight = Color(0xFF3C3C3C);
  static const Color textSecondaryLight = Color(0xFF777777);
  static const Color textTertiaryLight = Color(0xFFADADAD);
  static const Color textOnButtonLight = Color(0xFFFFFFFF);

  // ─── Category Specific Colors ──────────────────────────────────────────────
  // Playful variations for charts and logs
  static const Color catFood = Color(0xFFFF6B6B);
  static const Color catTravel = Color(0xFF2ECC71);
  static const Color catBills = Color(0xFF9B59B6);
  static const Color catShopping = Color(0xFF3498DB);
  static const Color catHealth = Color(0xFF1ABC9C);
  static const Color catEntertainment = Color(0xFFF1C40F);
  static const Color catOther = Color(0xFF95A5A6);

  // ─── Compatibility Aliases (for pre-existing widgets) ─────────────────────
  static const Color surface = surfaceDark;
  static const Color outline = outlineDark;
  static const Color background = bgDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textTertiary = textTertiaryDark;
  static const Color textOnAccent = Colors.black;
}
