import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_text_styles.dart';

/// AppTheme — single entry point for all ThemeData configuration.
///
/// Usage:
///   MaterialApp(
///     theme: AppTheme.dark,   // primary theme
///     // themeMode: ThemeMode.dark,
///   )
abstract final class AppTheme {
  // ─── Color Scheme ────────────────────────────────────────────────────────────

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.secondary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryVariant,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.accent,
    onSecondary: AppColors.textOnAccent,
    secondaryContainer: AppColors.accentLight,
    onSecondaryContainer: AppColors.primary,
    tertiary: AppColors.secondaryVariant,
    onTertiary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceElevated,
    onSurfaceVariant: AppColors.textSecondary,
    background: AppColors.background,
    onBackground: AppColors.textPrimary,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorSurface,
    onErrorContainer: AppColors.error,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.primary,
    inversePrimary: AppColors.secondary,
  );

  // ─── Main Theme ──────────────────────────────────────────────────────────────

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'DMSans',
      textTheme: AppTextStyles.textTheme,

      // ── App Bar ──────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: AppSizes.screenHPadding,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: AppSizes.iconMD,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.textSecondary,
          size: AppSizes.iconMD,
        ),
        titleTextStyle: AppTextStyles.h3,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ── Bottom Navigation ────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSM,
        unselectedLabelStyle: AppTextStyles.labelSM,
      ),

      // ── Navigation Bar (M3) ──────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.secondary.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.secondary, size: AppSizes.iconMD);
          }
          return const IconThemeData(color: AppColors.textTertiary, size: AppSizes.iconMD);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSM.copyWith(color: AppColors.secondary);
          }
          return AppTextStyles.labelSM;
        }),
        height: AppSizes.bottomNavHeight,
      ),

      // ── Cards ────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          side: const BorderSide(color: AppColors.outline, width: AppSizes.borderThin),
        ),
      ),

      // ── Buttons ──────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.outline,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightLG),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          elevation: 0,
          textStyle: AppTextStyles.labelLG,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          disabledForegroundColor: AppColors.textTertiary,
          side: const BorderSide(color: AppColors.secondary, width: AppSizes.borderMD),
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
          foregroundColor: AppColors.secondary,
          textStyle: AppTextStyles.labelMD,
          minimumSize: const Size(0, AppSizes.buttonHeightMD),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textOnAccent,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeightLG),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: AppTextStyles.labelLG,
        ),
      ),

      // ── Input Fields ─────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingMD,
        ),
        hintStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.textTertiary),
        labelStyle: AppTextStyles.labelMD.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle: AppTextStyles.labelSM.copyWith(color: AppColors.secondary),
        errorStyle: AppTextStyles.bodySM.copyWith(color: AppColors.error),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.outline, width: AppSizes.borderMD),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.outline, width: AppSizes.borderMD),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.secondary, width: AppSizes.borderThick),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: AppSizes.borderMD),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: AppSizes.borderThick),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(
            color: AppColors.outline.withOpacity(0.5),
            width: AppSizes.borderThin,
          ),
        ),
      ),

      // ── Divider ──────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: AppSizes.borderThin,
        space: 0,
      ),

      // ── Chip ─────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.secondary.withOpacity(0.2),
        disabledColor: AppColors.outline,
        labelStyle: AppTextStyles.labelSM,
        secondaryLabelStyle: AppTextStyles.labelSM.copyWith(color: AppColors.secondary),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSM,
          vertical: AppSizes.paddingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          side: const BorderSide(color: AppColors.outline),
        ),
        side: const BorderSide(color: AppColors.outline),
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Dialog / Bottom Sheet ─────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppSizes.elevationLG,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.bodyMD,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBackgroundColor: AppColors.surface,
        modalElevation: AppSizes.elevationLG,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXL),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.outline,
      ),

      // ── Snackbar ─────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppTextStyles.bodyMD,
        actionTextColor: AppColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // ── Switch / Checkbox / Radio ────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.secondary;
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary.withOpacity(0.3);
          }
          return AppColors.outline;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.secondary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.outline, width: AppSizes.borderMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXS),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.secondary;
          return AppColors.textTertiary;
        }),
      ),

      // ── Progress / Slider ────────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
        linearTrackColor: AppColors.outline,
        circularTrackColor: AppColors.outline,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.secondary,
        inactiveTrackColor: AppColors.outline,
        thumbColor: AppColors.secondary,
        overlayColor: AppColors.secondary.withOpacity(0.15),
        valueIndicatorColor: AppColors.secondary,
        valueIndicatorTextStyle: AppTextStyles.labelSM.copyWith(color: Colors.white),
      ),

      // ── List Tile ────────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.surface,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.screenHPadding,
          vertical: AppSizes.s4,
        ),
      ),

      // ── Tab Bar ──────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelMD,
        unselectedLabelStyle: AppTextStyles.labelMD,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.outline,
      ),

      // ── Icon ─────────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppSizes.iconMD,
      ),

      // ── Popup Menu ───────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: AppSizes.elevationMD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          side: const BorderSide(color: AppColors.outline, width: AppSizes.borderThin),
        ),
        textStyle: AppTextStyles.bodyMD,
        labelTextStyle: WidgetStateProperty.all(AppTextStyles.bodyMD),
      ),

      // ── Tooltip ──────────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          border: Border.all(color: AppColors.outline, width: AppSizes.borderThin),
        ),
        textStyle: AppTextStyles.bodySM,
        preferBelow: false,
      ),

      // ── Page Transitions ─────────────────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
