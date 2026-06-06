/// AppSizes — unified spacing, radius, icon-size and font-size scale.
///
/// Use these constants everywhere instead of magic numbers so the entire
/// layout can be adjusted from one file.
abstract final class AppSizes {
  // ─── Spacing ────────────────────────────────────────────────────────────────
  // 4-point grid. Use multiples wherever possible.

  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s56 = 56.0;
  static const double s64 = 64.0;
  static const double s80 = 80.0;
  static const double s96 = 96.0;

  // ─── Named semantic spacing ──────────────────────────────────────────────────

  /// Inside a chip, tag, small badge
  static const double paddingXS = s4;

  /// Inside compact components (list tile padding, icon button padding)
  static const double paddingSM = s8;

  /// Standard widget internal padding
  static const double paddingMD = s16;

  /// Cards, modal sheets, screen-level horizontal padding
  static const double paddingLG = s24;

  /// Hero sections, large cards
  static const double paddingXL = s32;

  // ─── Border Radius ──────────────────────────────────────────────────────────

  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radius2XL = 28.0;
  static const double radiusFull = 100.0; // pill shape

  // ─── Icon Sizes ─────────────────────────────────────────────────────────────

  static const double iconXS = 14.0;
  static const double iconSM = 18.0;
  static const double iconMD = 22.0;
  static const double iconLG = 28.0;
  static const double iconXL = 36.0;
  static const double icon2XL = 48.0;

  // ─── Font Sizes ─────────────────────────────────────────────────────────────

  static const double fontXS = 10.0;
  static const double fontSM = 12.0;
  static const double fontMD = 14.0;
  static const double fontLG = 16.0;
  static const double fontXL = 18.0;
  static const double font2XL = 22.0;
  static const double font3XL = 26.0;
  static const double font4XL = 32.0;
  static const double font5XL = 40.0;

  // ─── Component Heights ──────────────────────────────────────────────────────

  /// Standard text field / input height
  static const double inputHeight = 56.0;

  /// Primary CTA button height
  static const double buttonHeightLG = 56.0;

  /// Secondary / compact button height
  static const double buttonHeightMD = 44.0;

  /// Small inline button (chips, tags)
  static const double buttonHeightSM = 34.0;

  /// App bar height
  static const double appBarHeight = 60.0;

  /// Bottom navigation bar height
  static const double bottomNavHeight = 72.0;

  /// Standard card minimum height
  static const double cardMinHeight = 80.0;

  // ─── Elevation & Border Width ────────────────────────────────────────────────

  static const double elevationSM = 2.0;
  static const double elevationMD = 6.0;
  static const double elevationLG = 12.0;

  static const double borderThin = 0.5;
  static const double borderMD = 1.0;
  static const double borderThick = 1.5;

  // ─── Screen Padding ─────────────────────────────────────────────────────────

  /// Horizontal padding applied to every screen's body content
  static const double screenHPadding = 20.0;

  /// Vertical padding applied to screen top (below app bar)
  static const double screenVPadding = 16.0;
}
