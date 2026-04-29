import 'package:flutter/material.dart';

final class AppVisualTokens {
  const AppVisualTokens._();

  static const pageBackground = Color(0xFFFCFBF8);
  static const cardBackground = Color(0xFFFFFFFF);
  static const brandGold = Color(0xFFB27628);
  static const brandGoldDark = Color(0xFF875214);
  static const brandGoldLight = Color(0xFFFFF1D8);
  static const textPrimary = Color(0xFF171A21);
  static const textSecondary = Color(0xFF6F7480);
  static const textTertiary = Color(0xFF9AA0AA);
  static const borderSoft = Color(0xFFECE7DF);
  static const warningSoft = Color(0xFFFFF4DF);
  static const successSoft = Color(0xFFEAF7EF);
  static const dangerSoft = Color(0xFFFCE8E6);

  static const pagePadding = 20.0;
  static const cardPadding = 16.0;
  static const sectionGap = 16.0;
  static const itemGap = 10.0;
  static const chipGap = 8.0;

  static const radiusSmall = 10.0;
  static const radiusMedium = 14.0;
  static const radiusLarge = 20.0;
  static const radiusXLarge = 26.0;
  static const radiusPill = 999.0;

  static const bottomNavHeight = 78.0;
  static const floatingButtonSize = 48.0;
  static const minTouchTarget = 44.0;
  static const inputHeight = 48.0;
  static const primaryButtonHeight = 48.0;

  static BorderRadius get radiusSmallBorder =>
      BorderRadius.circular(radiusSmall);
  static BorderRadius get radiusMediumBorder =>
      BorderRadius.circular(radiusMedium);
  static BorderRadius get radiusLargeBorder =>
      BorderRadius.circular(radiusLarge);
  static BorderRadius get radiusXLargeBorder =>
      BorderRadius.circular(radiusXLarge);
  static BorderRadius get radiusPillBorder => BorderRadius.circular(radiusPill);

  static List<BoxShadow> shadowSoft({double opacity = 0.04}) {
    return <BoxShadow>[
      BoxShadow(
        color: const Color(0xFF1A2233).withValues(alpha: opacity),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static List<BoxShadow> shadowCard({double opacity = 0.06}) {
    return <BoxShadow>[
      BoxShadow(
        color: const Color(0xFF1A2233).withValues(alpha: opacity),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static List<BoxShadow> shadowFloating({double opacity = 0.08}) {
    return <BoxShadow>[
      BoxShadow(
        color: const Color(0xFF1A2233).withValues(alpha: opacity),
        blurRadius: 28,
        offset: const Offset(0, 14),
      ),
    ];
  }
}

final class AppTextTokens {
  const AppTextTokens._();

  static const pageTitle = TextStyle(
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w900,
    color: AppVisualTokens.textPrimary,
  );

  static const sectionTitle = TextStyle(
    fontSize: 18,
    height: 1.22,
    fontWeight: FontWeight.w800,
    color: AppVisualTokens.textPrimary,
  );

  static const cardTitle = TextStyle(
    fontSize: 17,
    height: 1.26,
    fontWeight: FontWeight.w800,
    color: AppVisualTokens.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: AppVisualTokens.textSecondary,
  );

  static const bodyStrong = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w800,
    color: AppVisualTokens.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppVisualTokens.textTertiary,
  );

  static const badgeText = TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w800,
  );

  static const buttonText = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w800,
  );
}
