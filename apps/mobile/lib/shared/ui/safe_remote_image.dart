import 'package:flutter/material.dart';

class SafeRemoteAvatar extends StatelessWidget {
  const SafeRemoteAvatar({
    super.key,
    required this.label,
    this.imageUrl,
    this.radius = 18,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  final String label;
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedImageUrl = imageUrl?.trim();
    final resolvedBackgroundColor =
        backgroundColor ?? theme.colorScheme.primaryContainer;
    final resolvedForegroundColor =
        foregroundColor ?? theme.colorScheme.onPrimaryContainer;
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: resolvedBackgroundColor,
      foregroundColor: resolvedForegroundColor,
      child: Text(
        _safeAvatarSeed(label),
        style:
            textStyle ??
            theme.textTheme.titleSmall?.copyWith(
              color: resolvedForegroundColor,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
    if (normalizedImageUrl == null || normalizedImageUrl.isEmpty) {
      return fallback;
    }
    return ClipOval(
      child: SizedBox.square(
        dimension: radius * 2,
        child: Image.network(
          normalizedImageUrl,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    );
  }
}

String _safeAvatarSeed(String label) {
  final normalized = label.trim();
  if (normalized.isEmpty) {
    return '?';
  }
  return normalized.characters.first;
}
