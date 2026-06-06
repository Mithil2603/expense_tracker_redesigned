import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_sizes.dart';

/// AppTextStyles — full typographic scale using Google Fonts.
///
/// Typographic Pairing:
///   Headlines, Display, Amounts  → Fredoka (vibrant, rounded, playful, friendly)
///   Body, Labels, TextFields     → Outfit (geometric, highly legible, modern)
abstract final class AppTextStyles {
  // ─── Display Styles (Fredoka) ──────────────────────────────────────────────

  static final TextStyle display1 = GoogleFonts.fredoka(
    fontSize: AppSizes.font5XL,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static final TextStyle display2 = GoogleFonts.fredoka(
    fontSize: AppSizes.font4XL,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.15,
  );

  // ─── Headlines (Fredoka) ───────────────────────────────────────────────────

  static final TextStyle h1 = GoogleFonts.fredoka(
    fontSize: AppSizes.font3XL,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static final TextStyle h2 = GoogleFonts.fredoka(
    fontSize: AppSizes.font2XL,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static final TextStyle h3 = GoogleFonts.fredoka(
    fontSize: AppSizes.fontXL,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static final TextStyle h4 = GoogleFonts.fredoka(
    fontSize: AppSizes.fontLG,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  // ─── Body Text (Outfit) ────────────────────────────────────────────────────

  static final TextStyle bodyLG = GoogleFonts.outfit(
    fontSize: AppSizes.fontLG,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static final TextStyle bodyMD = GoogleFonts.outfit(
    fontSize: AppSizes.fontMD,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static final TextStyle bodySM = GoogleFonts.outfit(
    fontSize: AppSizes.fontSM,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ─── UI Labels & Buttons (Outfit) ──────────────────────────────────────────

  static final TextStyle labelLG = GoogleFonts.outfit(
    fontSize: AppSizes.fontLG,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static final TextStyle labelMD = GoogleFonts.outfit(
    fontSize: AppSizes.fontMD,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );

  static final TextStyle labelSM = GoogleFonts.outfit(
    fontSize: AppSizes.fontSM,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // ─── Secondary Captions ────────────────────────────────────────────────────

  static final TextStyle caption = GoogleFonts.outfit(
    fontSize: AppSizes.fontXS,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static final TextStyle overline = GoogleFonts.outfit(
    fontSize: AppSizes.fontXS,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.3,
  );

  // ─── Numeric & Financial displays (Fredoka) ───────────────────────────────

  static final TextStyle amountLG = GoogleFonts.fredoka(
    fontSize: AppSizes.font3XL,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static final TextStyle amountMD = GoogleFonts.fredoka(
    fontSize: AppSizes.fontXL,
    fontWeight: FontWeight.w600,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static final TextStyle amountSM = GoogleFonts.fredoka(
    fontSize: AppSizes.fontMD,
    fontWeight: FontWeight.w500,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ─── Material TextTheme mapping ─────────────────────────────────────────────

  static TextTheme get textTheme {
    return TextTheme(
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
}
