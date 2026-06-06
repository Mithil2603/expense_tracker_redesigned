import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_text_styles.dart';

/// AppTheme — configuration for Light and Dark themes of the Fingo App.
abstract final class AppTheme {
  // ─── Color Schemes ─────────────────────────────────────────────────────────

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.outlineDark,
    onPrimaryContainer: AppColors.textPrimaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    tertiary: AppColors.accent,
    onTertiary: AppColors.bgDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorSurfaceDark,
    onErrorContainer: AppColors.error,
    outline: AppColors.outlineDark,
    shadow: Colors.black,
    scrim: Colors.black54,
  );

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.outlineLight,
    onPrimaryContainer: AppColors.textPrimaryLight,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    tertiary: AppColors.accent,
    onTertiary: AppColors.textPrimaryLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorSurfaceLight,
    onErrorContainer: AppColors.error,
    outline: AppColors.outlineLight,
    shadow: Colors.black12,
    scrim: Colors.black26,
  );

  // ─── Theme Getters ──────────────────────────────────────────────────────────

  /// Playful Dark Theme for Fingo
  static ThemeData get dark {
    return _buildTheme(
      colorScheme: _darkColorScheme,
      scaffoldBg: AppColors.bgDark,
      cardBg: AppColors.surfaceDark,
      outlineColor: AppColors.outlineDark,
      textPrimary: AppColors.textPrimaryDark,
      textSecondary: AppColors.textSecondaryDark,
      textTertiary: AppColors.textTertiaryDark,
      brightness: Brightness.dark,
    );
  }

  /// Playful Light Theme for Fingo
  static ThemeData get light {
    return _buildTheme(
      colorScheme: _lightColorScheme,
      scaffoldBg: AppColors.bgLight,
      cardBg: AppColors.surfaceLight,
      outlineColor: AppColors.outlineLight,
      textPrimary: AppColors.textPrimaryLight,
      textSecondary: AppColors.textSecondaryLight,
      textTertiary: AppColors.textTertiaryLight,
      brightness: Brightness.light,
    );
  }

  // ─── Theme Builder ──────────────────────────────────────────────────────────

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color cardBg,
    required Color outlineColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Brightness brightness,
  }) {
    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: brightness,
      systemNavigationBarColor: scaffoldBg,
      systemNavigationBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    );

    // Prepare typography tinted with context colors
    final rawTextTheme = AppTextStyles.textTheme;
    final tintedTextTheme = rawTextTheme.copyWith(
      displayLarge: rawTextTheme.displayLarge?.copyWith(color: textPrimary),
      displayMedium: rawTextTheme.displayMedium?.copyWith(color: textPrimary),
      displaySmall: rawTextTheme.displaySmall?.copyWith(color: textPrimary),
      headlineLarge: rawTextTheme.headlineLarge?.copyWith(color: textPrimary),
      headlineMedium: rawTextTheme.headlineMedium?.copyWith(color: textPrimary),
      headlineSmall: rawTextTheme.headlineSmall?.copyWith(color: textPrimary),
      titleLarge: rawTextTheme.titleLarge?.copyWith(color: textPrimary),
      titleMedium: rawTextTheme.titleMedium?.copyWith(color: textPrimary),
      titleSmall: rawTextTheme.titleSmall?.copyWith(color: textPrimary),
      bodyLarge: rawTextTheme.bodyLarge?.copyWith(color: textPrimary),
      bodyMedium: rawTextTheme.bodyMedium?.copyWith(color: textPrimary),
      bodySmall: rawTextTheme.bodySmall?.copyWith(color: textSecondary),
      labelLarge: rawTextTheme.labelLarge?.copyWith(color: textPrimary),
      labelMedium: rawTextTheme.labelMedium?.copyWith(color: textPrimary),
      labelSmall: rawTextTheme.labelSmall?.copyWith(color: textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: GoogleFonts.outfit().fontFamily,
      textTheme: tintedTextTheme,

      // ── App Bar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleSpacing: AppSizes.screenHPadding,
        iconTheme: IconThemeData(color: textPrimary, size: AppSizes.iconMD),
        actionsIconTheme: IconThemeData(color: textSecondary, size: AppSizes.iconMD),
        titleTextStyle: AppTextStyles.h3.copyWith(color: textPrimary),
        systemOverlayStyle: systemOverlay,
      ),

      // ── Cards ────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          side: BorderSide(color: outlineColor, width: AppSizes.borderThick),
        ),
      ),

      // ── Buttons ──────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: outlineColor,
          disabledForegroundColor: textTertiary,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightLG),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          elevation: 0,
          textStyle: AppTextStyles.labelLG.copyWith(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: textTertiary,
          side: BorderSide(color: AppColors.primary, width: AppSizes.borderThick),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightLG),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: AppTextStyles.labelLG,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelMD,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
        ),
      ),

      // ── Input Fields ─────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingMD,
        ),
        hintStyle: AppTextStyles.bodyMD.copyWith(color: textTertiary),
        labelStyle: AppTextStyles.labelMD.copyWith(color: textSecondary),
        floatingLabelStyle: AppTextStyles.labelSM.copyWith(color: AppColors.primary),
        errorStyle: AppTextStyles.bodySM.copyWith(color: AppColors.error),
        prefixIconColor: textTertiary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(color: outlineColor, width: AppSizes.borderThick),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(color: outlineColor, width: AppSizes.borderThick),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.primary, width: AppSizes.borderThick * 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: AppSizes.borderThick),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: AppSizes.borderThick * 1.5),
        ),
      ),

      // ── Divider ──────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: outlineColor,
        thickness: AppSizes.borderThick,
        space: 0,
      ),

      // ── Chip ─────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: cardBg,
        selectedColor: AppColors.primary.withOpacity(0.15),
        disabledColor: outlineColor,
        labelStyle: AppTextStyles.labelSM.copyWith(color: textSecondary),
        secondaryLabelStyle: AppTextStyles.labelSM.copyWith(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSM,
          vertical: AppSizes.paddingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          side: BorderSide(color: outlineColor, width: AppSizes.borderThick),
        ),
        side: BorderSide(color: outlineColor, width: AppSizes.borderThick),
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Dialog / Bottom Sheet ─────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: AppSizes.elevationLG,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          side: BorderSide(color: outlineColor, width: AppSizes.borderThick),
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(color: textPrimary),
        contentTextStyle: AppTextStyles.bodyMD.copyWith(color: textSecondary),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBackgroundColor: cardBg,
        modalElevation: AppSizes.elevationLG,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXL),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: outlineColor,
      ),

      // ── Progress Indicators ──────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.bgDark,
        circularTrackColor: AppColors.bgDark,
      ),
    );
  }
}
