import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text_styles.dart';

/// AppBarVariant controls the visual style of [AppCustomAppBar].
enum AppBarVariant {
  /// Default — transparent bg, used on most content screens.
  transparent,

  /// Solid navy surface — used on forms, modals, detail screens.
  solid,

  /// Blurred frosted glass — used on screens with scrollable content behind.
  frosted,
}

/// [AppCustomAppBar] — production-grade app bar used across all screens.
///
/// Features:
///   • Consistent height and padding from [AppSizes]
///   • Optional leading back button (auto-detected or custom)
///   • Optional subtitle below the title
///   • Optional bottom widget (e.g. a TabBar)
///   • Correct [SystemUiOverlayStyle] status bar
///   • Implements [PreferredSizeWidget] so it plugs directly into [Scaffold]
///
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: AppCustomAppBar(
///     title: 'Expenses',
///     actions: [
///       AppBarAction(icon: Icons.search_rounded, onTap: () {}),
///       AppBarAction(icon: Icons.tune_rounded, onTap: () {}),
///     ],
///   ),
/// )
/// ```
class AppCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppCustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions = const [],
    this.bottom,
    this.variant = AppBarVariant.transparent,
    this.centerTitle = false,
    this.onLeadingTap,
    this.backgroundColor,
    this.titleStyle,
  }) : assert(
          title != null || titleWidget != null || !automaticallyImplyLeading,
          'Provide either title or titleWidget.',
        );

  /// Plain text title. Ignored if [titleWidget] is provided.
  final String? title;

  /// Custom title widget. Takes priority over [title].
  final Widget? titleWidget;

  /// Optional subtitle shown below the title in smaller text.
  final String? subtitle;

  /// Custom leading widget. Overrides back-button auto-detection.
  final Widget? leading;

  /// Whether to show a back button automatically when a route can be popped.
  final bool automaticallyImplyLeading;

  /// Action buttons shown on the trailing side.
  final List<AppBarAction> actions;

  /// Widget rendered in the [PreferredSizeWidget.preferredSize] bottom slot
  /// (e.g. a [TabBar]).
  final PreferredSizeWidget? bottom;

  /// Visual variant — controls background treatment.
  final AppBarVariant variant;

  final bool centerTitle;
  final VoidCallback? onLeadingTap;

  /// Override the background color (takes precedence over [variant]).
  final Color? backgroundColor;

  /// Override the title text style.
  final TextStyle? titleStyle;

  @override
  Size get preferredSize => Size.fromHeight(
        AppSizes.appBarHeight + (bottom?.preferredSize.height ?? 0),
      );

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showLeading = leading != null || (automaticallyImplyLeading && canPop);

    final resolvedBg = backgroundColor ?? _resolveBackground(variant);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Container(
        color: resolvedBg,
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: AppSizes.appBarHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenHPadding,
                  ),
                  child: Row(
                    children: [
                      // ── Leading ──────────────────────────────────────────
                      if (showLeading) ...[
                        _LeadingButton(
                          custom: leading,
                          onTap: onLeadingTap ?? () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: AppSizes.s12),
                      ],

                      // ── Title ────────────────────────────────────────────
                      if (!centerTitle)
                        Expanded(child: _TitleSection(title: title, titleWidget: titleWidget, subtitle: subtitle, style: titleStyle)),
                      if (centerTitle) ...[
                        Expanded(child: const SizedBox.shrink()),
                        _TitleSection(title: title, titleWidget: titleWidget, subtitle: subtitle, style: titleStyle),
                        const Spacer(),
                      ],

                      // ── Actions ──────────────────────────────────────────
                      if (actions.isNotEmpty) ...[
                        const SizedBox(width: AppSizes.s8),
                        ...actions.map((a) => _ActionButton(action: a)),
                      ],
                    ],
                  ),
                ),
              ),
              if (bottom != null) bottom!,
              const _AppBarDivider(),
            ],
          ),
        ),
      ),
    );
  }

  Color _resolveBackground(AppBarVariant v) {
    switch (v) {
      case AppBarVariant.transparent:
        return Colors.transparent;
      case AppBarVariant.solid:
        return AppColors.surface;
      case AppBarVariant.frosted:
        return AppColors.surface.withOpacity(0.85);
    }
  }
}

// ─── Internal Widgets ─────────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({this.title, this.titleWidget, this.subtitle, this.style});

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (titleWidget != null) return titleWidget!;

    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title ?? '', style: style ?? AppTextStyles.h3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 1),
          Text(subtitle!, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
        ],
      );
    }

    return Text(title ?? '', style: style ?? AppTextStyles.h3, overflow: TextOverflow.ellipsis);
  }
}

class _LeadingButton extends StatelessWidget {
  const _LeadingButton({required this.onTap, this.custom});

  final VoidCallback onTap;
  final Widget? custom;

  @override
  Widget build(BuildContext context) {
    if (custom != null) return custom!;
    return _AppBarIconButton(
      icon: Icons.arrow_back_ios_new_rounded,
      onTap: onTap,
      tooltip: 'Back',
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});
  final AppBarAction action;

  @override
  Widget build(BuildContext context) {
    return _AppBarIconButton(
      icon: action.icon,
      onTap: action.onTap,
      tooltip: action.tooltip,
      badge: action.badge,
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Tooltip(
          message: tooltip ?? '',
          child: Container(
            width: AppSizes.s40,
            height: AppSizes.s40,
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.textPrimary, size: AppSizes.iconMD),
          ),
        ),
      ),
    );

    if (badge == null || badge == 0) return btn;

    return Badge(
      label: Text('$badge'),
      backgroundColor: AppColors.accent,
      textColor: AppColors.textOnAccent,
      textStyle: AppTextStyles.caption,
      child: btn,
    );
  }
}

class _AppBarDivider extends StatelessWidget {
  const _AppBarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.borderThin,
      color: AppColors.outline.withOpacity(0.5),
    );
  }
}

// ─── AppBarAction model ────────────────────────────────────────────────────────

/// Data class representing a single action button in [AppCustomAppBar].
class AppBarAction {
  const AppBarAction({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  /// Optional notification count overlay on the icon.
  final int? badge;
}
