part of 'exhibition_home_page.dart';

final class ExhibitionHomeVisualTokens {
  const ExhibitionHomeVisualTokens._();

  static const brandGold = Color(0xFFB27628);
  static const brandGoldDeep = Color(0xFF875214);
  static const brandGoldLight = Color(0xFFFFF1D8);
  static const textPrimary = Color(0xFF151922);
  static const textSecondary = Color(0xFF747B86);
  static const pageBackground = Color(0xFFFCFCFD);
  static const cardBackground = Color(0xFFFFFFFF);
  static const borderSoft = Color(0xFFECEEF2);
  static const shadowSoft = Color(0xFF1A2233);
  static const radiusLarge = 30.0;
  static const radiusMedium = 18.0;
  static const spacingPage = 20.0;
  static const spacingCard = 18.0;

  static List<BoxShadow> cardShadow({double opacity = 0.07}) {
    return <BoxShadow>[
      BoxShadow(
        color: shadowSoft.withValues(alpha: opacity),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }
}

enum CityVisualKey { chongqing, generic }

CityVisualKey resolveCityVisualKey({
  String? regionName,
  String? cityName,
  String? districtName,
  String? cityCode,
}) {
  final normalized = <String?>[
    regionName,
    cityName,
    districtName,
    cityCode,
  ].whereType<String>().join(' ');
  const chongqingSignals = <String>[
    '重庆',
    '重庆市',
    '南岸',
    '渝中',
    '江北',
    '沙坪坝',
    '九龙坡',
    '渝北',
    '巴南',
    '北碚',
  ];
  if (chongqingSignals.any(normalized.contains)) {
    return CityVisualKey.chongqing;
  }
  return CityVisualKey.generic;
}

class ExhibitionCityHeroBackground extends StatelessWidget {
  const ExhibitionCityHeroBackground({super.key, required this.visualKey});

  final CityVisualKey visualKey;

  @override
  Widget build(BuildContext context) {
    final palette = switch (visualKey) {
      CityVisualKey.chongqing => const (
        start: Color(0xFFEAF6FF),
        middle: Color(0xFFDDEFFF),
        end: Color(0xFFFFF4E3),
        line: Color(0xFF7B9FC4),
        accent: Color(0xFFE4A14A),
      ),
      CityVisualKey.generic => const (
        start: Color(0xFFF4F8FF),
        middle: Color(0xFFEFF5FB),
        end: Color(0xFFFFF8EB),
        line: Color(0xFF9AA9BA),
        accent: Color(0xFFD7A04F),
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[palette.start, palette.middle, palette.end],
        ),
      ),
      child: CustomPaint(
        painter: _CityHeroPainter(
          visualKey: visualKey,
          lineColor: palette.line,
          accentColor: palette.accent,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CityHeroPainter extends CustomPainter {
  const _CityHeroPainter({
    required this.visualKey,
    required this.lineColor,
    required this.accentColor,
  });

  final CityVisualKey visualKey;
  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    _paintRiver(canvas, size);
    _paintSkyline(canvas, size);
    _paintBridge(canvas, size);
    if (visualKey == CityVisualKey.chongqing) {
      _paintMountainLayers(canvas, size);
    }
  }

  void _paintRiver(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader =
          LinearGradient(
            colors: <Color>[
              Colors.white.withValues(alpha: 0.1),
              lineColor.withValues(alpha: 0.18),
            ],
          ).createShader(
            Offset(0, size.height * 0.62) & Size(size.width, size.height),
          );
    final path = Path()
      ..moveTo(0, size.height * 0.72)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.58,
        size.width * 0.58,
        size.height * 0.86,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintSkyline(Canvas canvas, Size size) {
    final paint = Paint()..color = lineColor.withValues(alpha: 0.34);
    final baseY = size.height * 0.64;
    final startX = size.width * 0.50;
    final widths = <double>[12, 18, 10, 26, 14, 20, 12, 16];
    final heights = <double>[58, 92, 70, 126, 84, 108, 68, 86];
    var x = startX;
    for (var i = 0; i < widths.length; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, baseY - heights[i], widths[i], heights[i]),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
      x += widths[i] + 7;
    }

    if (visualKey == CityVisualKey.chongqing) {
      final tower = Path()
        ..moveTo(size.width * 0.77, baseY)
        ..lineTo(size.width * 0.80, baseY - 150)
        ..lineTo(size.width * 0.84, baseY)
        ..close();
      canvas.drawPath(
        tower,
        Paint()..color = lineColor.withValues(alpha: 0.42),
      );
    }
  }

  void _paintBridge(Canvas canvas, Size size) {
    final bridgePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final y = size.height * 0.70;
    canvas.drawLine(
      Offset(size.width * 0.48, y),
      Offset(size.width * 0.96, y),
      bridgePaint,
    );
    for (var x = size.width * 0.52; x < size.width * 0.94; x += 20) {
      canvas.drawLine(Offset(x, y), Offset(x + 9, y + 24), bridgePaint);
    }
  }

  void _paintMountainLayers(Canvas canvas, Size size) {
    final paint = Paint()..color = lineColor.withValues(alpha: 0.12);
    final path = Path()
      ..moveTo(size.width * 0.45, size.height * 0.58)
      ..lineTo(size.width * 0.58, size.height * 0.42)
      ..lineTo(size.width * 0.72, size.height * 0.55)
      ..lineTo(size.width * 0.86, size.height * 0.38)
      ..lineTo(size.width, size.height * 0.52)
      ..lineTo(size.width, size.height * 0.72)
      ..lineTo(size.width * 0.45, size.height * 0.72)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CityHeroPainter oldDelegate) {
    return visualKey != oldDelegate.visualKey ||
        lineColor != oldDelegate.lineColor ||
        accentColor != oldDelegate.accentColor;
  }
}
