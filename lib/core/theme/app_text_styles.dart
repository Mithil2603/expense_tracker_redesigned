import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

/// AppTextStyles — full typographic scale.
///
/// Font pairing:
///   Display / Headlines → DM Serif Display   (character, elegance)
///   Body / UI           → DM Sans            (modern, readable, geometric)
///
/// Add to pubspec.yaml:
///   google_fonts: ^6.2.1
///
/// Then in theme data:
///   textTheme: AppTextStyles.textTheme
abstract final class AppTextStyles {
  // ─── Display ────────────────────────────────────────────────────────────────
  // Used in hero sections, large balance/amount displays.

  static const TextStyle display1 = TextStyle(
    fontFamily: 'DMSerifDisplay',
    fontSize: AppSizes.font5XL,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static const TextStyle display2 = TextStyle(
    fontFamily: 'DMSerifDisplay',
    fontSize: AppSizes.font4XL,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.15,
  );

  // ─── Headlines ──────────────────────────────────────────────────────────────

  static const TextStyle h1 = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.font3XL,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.font2XL,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontXL,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontLG,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.35,
  );

  // ─── Body ───────────────────────────────────────────────────────────────────

  static const TextStyle bodyLG = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontLG,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontMD,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle bodySM = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontSM,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ─── Labels ─────────────────────────────────────────────────────────────────
  // Short UI strings: button text, form labels, nav labels.

  static const TextStyle labelLG = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontLG,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMD = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontMD,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSM = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontSM,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  // ─── Caption / Overline ─────────────────────────────────────────────────────

  static const TextStyle caption = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontXS,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontXS,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.2,
    height: 1.4,
  );

  // ─── Numeric / Amount ────────────────────────────────────────────────────────
  // Tabular figures for consistent digit width in expense amounts.

  static const TextStyle amountLG = TextStyle(
    fontFamily: 'DMSerifDisplay',
    fontSize: AppSizes.font3XL,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountMD = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontXL,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountSM = TextStyle(
    fontFamily: 'DMSans',
    fontSize: AppSizes.fontMD,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ─── Material TextTheme mapping ─────────────────────────────────────────────

  static const TextTheme textTheme = TextTheme(
    displayLarge: display1,
    displayMedium: display2,
    displaySmall: h1,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: h3,
    titleMedium: h4,
    titleSmall: labelMD,
    bodyLarge: bodyLG,
    bodyMedium: bodyMD,
    bodySmall: bodySM,
    labelLarge: labelLG,
    labelMedium: labelMD,
    labelSmall: labelSM,
  );
}
