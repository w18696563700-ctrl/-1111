import 'package:flutter/material.dart';
import 'package:mobile/shared/ui/app_visual_tokens.dart';

enum AppStatusTone {
  neutral,
  brand,
  warning,
  success,
  danger,
  info,
  pending,
  disabled,
  unknown,
}

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTextTokens.pageTitle),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(subtitle!, style: AppTextTokens.body),
              ],
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppVisualTokens.cardPadding),
    this.margin,
    this.borderColor = AppVisualTokens.borderSoft,
    this.backgroundColor = AppVisualTokens.cardBackground,
    this.radius = AppVisualTokens.radiusLarge,
    this.withShadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color borderColor;
  final Color backgroundColor;
  final double radius;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: withShadow ? AppVisualTokens.shadowCard() : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
    this.withShadow = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      withShadow: withShadow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: Text(title, style: AppTextTokens.sectionTitle)),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 10),
                trailing!,
              ],
            ],
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(subtitle!, style: AppTextTokens.body),
          ],
          if (children.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppVisualTokens.sectionGap),
            ...children,
          ],
        ],
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: Size(
          expanded ? double.infinity : 0,
          AppVisualTokens.primaryButtonHeight,
        ),
        backgroundColor: AppVisualTokens.brandGold,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFF0ECE7),
        disabledForegroundColor: AppVisualTokens.textTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: AppVisualTokens.radiusPillBorder,
        ),
        textStyle: AppTextTokens.buttonText,
      ),
      child: child,
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(
          expanded ? double.infinity : 0,
          AppVisualTokens.primaryButtonHeight,
        ),
        foregroundColor: AppVisualTokens.textPrimary,
        backgroundColor: AppVisualTokens.cardBackground,
        side: const BorderSide(color: AppVisualTokens.borderSoft),
        shape: RoundedRectangleBorder(
          borderRadius: AppVisualTokens.radiusPillBorder,
        ),
        textStyle: AppTextTokens.buttonText,
      ),
      child: child,
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
  });

  final String label;
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppVisualTokens.radiusPillBorder,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: AppTextTokens.badgeText.copyWith(color: colors.foreground),
        ),
      ),
    );
  }
}

class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      avatar: icon == null ? null : Icon(icon, size: 16),
      selected: selected,
      onSelected: onSelected,
      selectedColor: AppVisualTokens.brandGoldLight,
      backgroundColor: AppVisualTokens.cardBackground,
      side: BorderSide(
        color: selected
            ? AppVisualTokens.brandGold.withValues(alpha: 0.28)
            : AppVisualTokens.borderSoft,
      ),
      labelStyle: AppTextTokens.badgeText.copyWith(
        color: selected
            ? AppVisualTokens.brandGoldDark
            : AppVisualTokens.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppVisualTokens.radiusPillBorder,
      ),
    );
  }
}

class AppInfoChip extends StatelessWidget {
  const AppInfoChip({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.highlight = false,
  });

  final String label;
  final String? value;
  final IconData? icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final foreground = highlight
        ? AppVisualTokens.brandGoldDark
        : AppVisualTokens.textSecondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlight
            ? AppVisualTokens.brandGoldLight
            : const Color(0xFFF8F7F5),
        borderRadius: AppVisualTokens.radiusPillBorder,
        border: Border.all(color: AppVisualTokens.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
            ],
            Text(
              value == null ? label : '$label：$value',
              style: AppTextTokens.badgeText.copyWith(color: foreground),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: const Color(0xFFFEFDFB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextTokens.cardTitle),
          const SizedBox(height: 8),
          Text(message, style: AppTextTokens.body),
          if (action != null) ...<Widget>[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

class AppBottomSafePadding extends StatelessWidget {
  const AppBottomSafePadding({super.key, this.extra = 24});

  final double extra;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          AppVisualTokens.bottomNavHeight +
          MediaQuery.paddingOf(context).bottom +
          extra,
    );
  }
}

({Color background, Color border, Color foreground}) _toneColors(
  AppStatusTone tone,
) {
  return switch (tone) {
    AppStatusTone.brand => (
      background: AppVisualTokens.brandGoldLight,
      border: AppVisualTokens.brandGold.withValues(alpha: 0.22),
      foreground: AppVisualTokens.brandGoldDark,
    ),
    AppStatusTone.warning => (
      background: AppVisualTokens.warningSoft,
      border: const Color(0xFFF1D5A7),
      foreground: AppVisualTokens.brandGoldDark,
    ),
    AppStatusTone.success => (
      background: AppVisualTokens.successSoft,
      border: const Color(0xFFBFDCC9),
      foreground: const Color(0xFF2E6F43),
    ),
    AppStatusTone.danger => (
      background: AppVisualTokens.dangerSoft,
      border: const Color(0xFFEBC2BD),
      foreground: const Color(0xFFA13B34),
    ),
    AppStatusTone.info => (
      background: const Color(0xFFEAF3FF),
      border: const Color(0xFFBBD4F2),
      foreground: const Color(0xFF245C97),
    ),
    AppStatusTone.pending => (
      background: const Color(0xFFFFF7E8),
      border: const Color(0xFFF0D09B),
      foreground: const Color(0xFF8A5A10),
    ),
    AppStatusTone.disabled => (
      background: const Color(0xFFF0F0EF),
      border: const Color(0xFFD6D3CE),
      foreground: AppVisualTokens.textTertiary,
    ),
    AppStatusTone.unknown => (
      background: const Color(0xFFF7F4F0),
      border: AppVisualTokens.borderSoft,
      foreground: AppVisualTokens.textTertiary,
    ),
    AppStatusTone.neutral => (
      background: const Color(0xFFF8F7F5),
      border: AppVisualTokens.borderSoft,
      foreground: AppVisualTokens.textSecondary,
    ),
  };
}
