import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';
import '../utils/fingo_state.dart';
import '../../di/injection_container.dart';

// ══════════════════════════════════════════════════════════════════════════════
// APP TEXT FIELDS
// ══════════════════════════════════════════════════════════════════════════════

/// [AppTextField] — standard single-line text input.
///
/// Handles all decoration, validation error state, and keyboard type.
///
/// ```dart
/// AppTextField(
///   label: 'Title',
///   hint: 'e.g. Grocery run',
///   prefixIcon: Icons.title_rounded,
///   controller: _titleCtrl,
///   validator: (v) => v!.isEmpty ? 'Required' : null,
/// )
/// ```
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.initialValue,
    this.onTap,
    this.autofocus = false,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final String? initialValue;
  final VoidCallback? onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      initialValue: initialValue,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      autofocus: autofocus,
      onTap: onTap,
      style: AppTextStyles.bodyMD.copyWith(color: Theme.of(context).colorScheme.onSurface),
      cursorColor: AppColors.secondary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: AppSizes.iconSM)
            : null,
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );
  }
}

/// [AppPasswordField] — password input with show/hide toggle built in.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.label = 'Password',
    this.hint = '••••••••',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction = TextInputAction.done,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: const [AutofillHints.password],
      prefixIcon: Icons.lock_outline_rounded,
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _obscure = !_obscure),
        child: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: AppSizes.iconSM,
          color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// [AppAmountField] — numeric amount input with currency prefix.
class AppAmountField extends StatelessWidget {
  const AppAmountField({
    super.key,
    this.label = 'Amount',
    this.hint = '0.00',
    this.currency = '₹',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String hint;
  final String currency;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: AppTextStyles.amountMD,
      cursorColor: AppColors.secondary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
          child: Text(
            currency,
            style: AppTextStyles.amountMD.copyWith(color: AppColors.accent),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

/// [AppSearchField] — search bar with clear button.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.hint = 'Search expenses...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.autofocus = false,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _ctrl;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _ctrl.addListener(() => setState(() => _hasText = _ctrl.text.isNotEmpty));
  }

  @override
  void dispose() {
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.bodyMD,
      cursorColor: AppColors.secondary,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconSM),
        suffixIcon: _hasText
            ? GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  widget.onChanged?.call('');
                },
                child: const Icon(Icons.close_rounded, size: AppSizes.iconSM),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingSM,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// APP BUTTONS
// ══════════════════════════════════════════════════════════════════════════════

/// [AppButton] — primary CTA button.
///
/// Handles loading state (replaces label with a spinner).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.enabled = true,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool enabled;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppSizes.buttonHeightLG,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, AppSizes.buttonHeightLG),
        ),
        onPressed: (enabled && !loading) ? onTap : null,
        child: loading
            ? const SizedBox.square(
                dimension: AppSizes.iconSM,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppSizes.iconSM),
                  const SizedBox(width: AppSizes.s8),
                  Text(label),
                ],
              )
            : Text(label),
      ),
    );
  }
}

/// [AppOutlineButton] — secondary/outline variant.
class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.enabled = true,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool enabled;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: AppSizes.buttonHeightLG,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, AppSizes.buttonHeightLG),
        ),
        onPressed: (enabled && !loading) ? onTap : null,
        child: loading
            ? SizedBox.square(
                dimension: AppSizes.iconSM,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                ),
              )
            : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppSizes.iconSM),
                  const SizedBox(width: AppSizes.s8),
                  Text(label),
                ],
              )
            : Text(label),
      ),
    );
  }
}

/// [AppIconButton] — circular icon button used in lists, cards, app bars.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.backgroundColor,
    this.size = AppSizes.iconMD,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.s8),
            child: Icon(
              icon,
              size: size,
              color: color ?? Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// APP CARD
// ══════════════════════════════════════════════════════════════════════════════

/// [AppCard] — standard card container with consistent radius and border.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderColor,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusLG);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBgColor = color ?? (isLight ? AppColors.surfaceLight : AppColors.surfaceDark);
    final cardBorderColor = borderColor ?? (isLight ? AppColors.outlineLight : AppColors.outlineDark);
    return Material(
      color: cardBgColor,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: cardBorderColor,
              width: AppSizes.borderThin,
            ),
          ),
          padding: padding ?? const EdgeInsets.all(AppSizes.paddingMD),
          child: child,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// APP CHIP / TAG
// ══════════════════════════════════════════════════════════════════════════════

/// [AppChip] — selectable category chip used in filters and forms.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Color used for the selected state border + label.
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.secondary;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final chipBgColor = selected
        ? activeColor.withValues(alpha: 0.15)
        : (isLight ? AppColors.surfaceLight : AppColors.surfaceDark);
    final chipBorderColor = selected ? activeColor : (isLight ? AppColors.outlineLight : AppColors.outlineDark);
    final chipTextColor = selected ? activeColor : (isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s12,
          vertical: AppSizes.s6,
        ),
        decoration: BoxDecoration(
          color: chipBgColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: chipBorderColor,
            width: selected ? AppSizes.borderMD : AppSizes.borderThin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppSizes.iconXS,
                color: chipTextColor,
              ),
              const SizedBox(width: AppSizes.s4),
            ],
            Text(
              label,
              style: AppTextStyles.labelSM.copyWith(
                color: chipTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// APP DIVIDER / SECTION HEADER
// ══════════════════════════════════════════════════════════════════════════════

/// Horizontal rule with optional label centered in it.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.label, this.indent = 0});

  final String? label;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).colorScheme.outline;
    if (label == null) {
      return Divider(
        color: dividerColor,
        thickness: AppSizes.borderThin,
        indent: indent,
        endIndent: indent,
      );
    }
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: AppSizes.borderThin,
            indent: indent,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
          child: Text(label!, style: AppTextStyles.caption),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: AppSizes.borderThin,
            endIndent: indent,
          ),
        ),
      ],
    );
  }
}

/// Section header used above list groups (e.g. "Today", "Yesterday").
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.screenHPadding,
        right: AppSizes.screenHPadding,
        top: AppSizes.s20,
        bottom: AppSizes.s8,
      ),
      child: Row(
        children: [
          Text(title.toUpperCase(), style: AppTextStyles.overline),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// APP EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════════

/// Centered empty-state widget with icon, title, and optional CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) {
                final isLight = Theme.of(context).brightness == Brightness.light;
                return Container(
                  padding: const EdgeInsets.all(AppSizes.s24),
                  decoration: BoxDecoration(
                    color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: isLight ? AppColors.outlineLight : AppColors.outlineDark),
                  ),
                  child: Icon(
                    icon,
                    size: AppSizes.icon2XL,
                    color: isLight ? AppColors.textTertiaryLight : AppColors.textTertiaryDark,
                  ),
                );
              }
            ),
            const SizedBox(height: AppSizes.s20),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSizes.s8),
              Builder(
                builder: (context) {
                  final isLight = Theme.of(context).brightness == Brightness.light;
                  return Text(
                    message!,
                    style: AppTextStyles.bodyMD.copyWith(
                      color: isLight ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
                    ),
                    textAlign: TextAlign.center,
                  );
                }
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSizes.s24),
              AppButton(label: actionLabel!, onTap: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// APP LOADING INDICATOR
// ══════════════════════════════════════════════════════════════════════════════

/// Centered full-screen loading spinner.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.secondary),
            strokeWidth: 2.5,
          ),
          if (message != null) ...[
            const SizedBox(height: AppSizes.s16),
            Text(
              message!,
              style: AppTextStyles.bodyMD.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// APP BADGE / STATUS INDICATOR
// ══════════════════════════════════════════════════════════════════════════════

enum AppBadgeVariant { success, error, warning, info, neutral }

/// Colored badge used for status labels.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
  });

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      AppBadgeVariant.success => (
        AppColors.successSurfaceLight,
        AppColors.success,
      ),
      AppBadgeVariant.error => (AppColors.errorSurfaceLight, AppColors.error),
      AppBadgeVariant.warning => (
        AppColors.warningSurfaceLight,
        AppColors.warning,
      ),
      AppBadgeVariant.info => (AppColors.infoSurfaceLight, AppColors.info),
      AppBadgeVariant.neutral => (
          Theme.of(context).brightness == Brightness.light ? AppColors.surfaceLight : AppColors.surfaceDark,
          Theme.of(context).brightness == Brightness.light ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.s8,
        vertical: AppSizes.s2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GAMIFIED WIDGETS (FIN-GO / DUOLINGO STYLE)
// ══════════════════════════════════════════════════════════════════════════════

/// [App3DButton] — A physical press-animate button with a bottom shadow bevel.
class App3DButton extends StatefulWidget {
  const App3DButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
    this.shadowColor = AppColors.primaryDark,
    this.textColor = Colors.white,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.height = 54.0,
    this.shadowHeight = 4.0,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final IconData? icon;
  final bool loading;
  final bool enabled;
  final double height;
  final double shadowHeight;
  final bool expand;

  @override
  State<App3DButton> createState() => _App3DButtonState();
}

class _App3DButtonState extends State<App3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasTap = widget.enabled && !widget.loading && widget.onTap != null;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Fallbacks for disabled state
    final buttonColor = hasTap
        ? widget.color
        : (isLight ? const Color(0xFFE5E5E5) : const Color(0xFF2B3D45));
    final shadowColor = hasTap
        ? widget.shadowColor
        : (isLight ? const Color(0xFFCDCDCD) : const Color(0xFF1E2E35));
    final textColor = hasTap
        ? widget.textColor
        : (isLight ? const Color(0xFFAFAFAF) : const Color(0xFF6B7F8A));

    Widget buttonBody = Stack(
      children: [
        // Bevel layer
        Container(
          height: widget.height + widget.shadowHeight,
          decoration: BoxDecoration(
            color: shadowColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
        ),
        // Active top layer
        AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          margin: EdgeInsets.only(
            top: _isPressed ? widget.shadowHeight : 0,
            bottom: _isPressed ? 0 : widget.shadowHeight,
          ),
          height: widget.height,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            border: Border.all(
              color: Colors.white.withValues(alpha: isLight ? 0.15 : 0.08),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? SizedBox.square(
                  dimension: AppSizes.iconSM,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(textColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: textColor,
                        size: AppSizes.iconSM + 2,
                      ),
                      const SizedBox(width: AppSizes.s8),
                    ],
                    Text(
                      widget.label.toUpperCase(),
                      style: AppTextStyles.labelLG.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: hasTap ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: hasTap ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: hasTap ? () => setState(() => _isPressed = false) : null,
      onTap: hasTap ? widget.onTap : null,
      child: widget.expand ? buttonBody : IntrinsicWidth(child: buttonBody),
    );
  }
}

/// [AppXPProgressBar] — Duolingo-style rounded progress bar displaying XP or leveling status.
class AppXPProgressBar extends StatelessWidget {
  const AppXPProgressBar({
    super.key,
    required this.currentXP,
    required this.targetXP,
    this.height = 16.0,
  });

  final int currentXP;
  final int targetXP;
  final double height;

  @override
  Widget build(BuildContext context) {
    final double ratio = (currentXP / targetXP).clamp(0.0, 1.0);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final trackColor = isLight
        ? const Color(0xFFE5E5E5)
        : AppColors.outlineDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Goal'.toUpperCase(),
              style: AppTextStyles.labelSM.copyWith(
                color: isLight
                    ? AppColors.textSecondaryLight
                    : AppColors.textSecondaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            Text(
              '$currentXP / $targetXP XP',
              style: AppTextStyles.labelSM.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    width: constraints.maxWidth * ratio,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFFFFA000)],
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// [AppStreakIndicator] — Playful flame streak indicator for daily interactions.
class AppStreakIndicator extends StatelessWidget {
  const AppStreakIndicator({super.key, required this.streak, this.onTap});

  final int streak;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final activeBg = isLight
        ? AppColors.warningSurfaceLight
        : AppColors.warningSurfaceDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s12,
          vertical: AppSizes.s6,
        ),
        decoration: BoxDecoration(
          color: activeBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.4),
            width: AppSizes.borderThick,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 18)),
            const SizedBox(width: AppSizes.s4),
            Text(
              '$streak',
              style: AppTextStyles.labelMD.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [AppHeartIndicator] — Playful hearts container representing remaining daily budget buffer or "lives".
class AppHeartIndicator extends StatelessWidget {
  const AppHeartIndicator({
    super.key,
    required this.lives,
    this.maxLives = 5,
    this.onTap,
  });

  final int lives;
  final int maxLives;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final activeBg = isLight
        ? AppColors.errorSurfaceLight
        : AppColors.errorSurfaceDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s12,
          vertical: AppSizes.s6,
        ),
        decoration: BoxDecoration(
          color: activeBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.4),
            width: AppSizes.borderThick,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('❤️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: AppSizes.s4),
            Text(
              '$lives/$maxLives',
              style: AppTextStyles.labelMD.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [AppQuestCard] — A checkable daily quest item with XP reward.
class AppQuestCard extends StatelessWidget {
  const AppQuestCard({
    super.key,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.progress,
    required this.target,
    this.completed = false,
    this.onTap,
  });

  final String title;
  final String description;
  final int xpReward;
  final int progress;
  final int target;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final double ratio = (progress / target).clamp(0.0, 1.0);

    return AppCard(
      onTap: onTap,
      color: completed
          ? (isLight
                ? AppColors.successSurfaceLight
                : AppColors.successSurfaceDark)
          : null,
      borderColor: completed ? AppColors.primary.withValues(alpha: 0.6) : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.labelMD.copyWith(
                          color: completed
                              ? AppColors.primary
                              : (isLight
                                    ? AppColors.textPrimaryLight
                                    : AppColors.textPrimaryDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.s8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '+$xpReward XP',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySM.copyWith(
                    color: isLight
                        ? AppColors.textSecondaryLight
                        : AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                // Tiny progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: ratio,
                            color: completed
                                ? AppColors.primary
                                : AppColors.info,
                            backgroundColor: isLight
                                ? const Color(0xFFE5E5E5)
                                : AppColors.bgDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$progress/$target',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isLight
                            ? AppColors.textSecondaryLight
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.s12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: completed ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: completed
                    ? AppColors.primary
                    : (isLight
                          ? const Color(0xFFCCCCCC)
                          : AppColors.outlineDark),
                width: 2,
              ),
            ),
            child: completed
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        ],
      ),
    );
  }
}

/// [FingoGamifiedAppBar] — Production-grade custom top bar featuring streak, health bar, and XP stats.
class FingoGamifiedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FingoGamifiedAppBar({super.key});

  String _getAnimalTier(int level) {
    if (level <= 3) return '🐜 Ant';
    if (level <= 6) return '🐿️ Squirrel';
    if (level <= 9) return '🦫 Beaver';
    if (level <= 12) return '🦊 Fox';
    if (level <= 15) return '🦉 Owl';
    if (level <= 18) return '🐺 Wolf';
    if (level <= 21) return '🦅 Eagle';
    if (level <= 24) return '🦁 Lion';
    if (level <= 27) return '🐘 Elephant';
    return '🐉 Dragon';
  }

  @override
  Widget build(BuildContext context) {
    final state = sl<FingoState>();
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
          height: AppSizes.borderThick,
        ),
      ),
      title: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final currentHealth = state.health;
          final maxHealth = state.maxHealth;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenHPadding,
            ),
            child: Row(
              children: [
                // FINGO Branding and Animal League Badge on left
                Row(
                  children: [
                    Text(
                      'FINGO',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _getAnimalTier(state.level),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),


                // Diamonds
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${state.diamonds}',
                      style: AppTextStyles.labelMD.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Health Bar (Lives)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // Navigate to health refill screen
                    GoRouter.of(context).push('/health-refill');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('❤️', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        '$currentHealth/$maxHealth',
                        style: AppTextStyles.labelMD.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
