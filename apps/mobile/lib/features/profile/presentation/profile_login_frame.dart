import 'package:flutter/material.dart';
import 'package:mobile/features/profile/presentation/profile_login_types.dart';

class LoginHeroHeader extends StatelessWidget {
  const LoginHeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compactHeight = MediaQuery.sizeOf(context).height < 820;
    return SizedBox(
      height: compactHeight ? 204 : 238,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFFFFFBF5), Color(0xFFF3D9B3)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF9C6A22).withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: CustomPaint(painter: _VenueHeroPainter())),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  26,
                  compactHeight ? 26 : 34,
                  26,
                  compactHeight ? 34 : 52,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '欢迎登录',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1F2328),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '展览装修之家',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3D3429),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '登录后管理项目、企业身份与沟通协作',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6F6255),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthLoginCard extends StatelessWidget {
  const AuthLoginCard({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.agreement,
    required this.notice,
    required this.child,
  });

  final LoginEntryMode mode;
  final ValueChanged<LoginEntryMode> onModeChanged;
  final Widget agreement;
  final Widget notice;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LoginMethodTabs(mode: mode, onChanged: onModeChanged),
            const SizedBox(height: 22),
            child,
            const SizedBox(height: 14),
            agreement,
            notice,
          ],
        ),
      ),
    );
  }
}

class LoginMethodTabs extends StatelessWidget {
  const LoginMethodTabs({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final LoginEntryMode mode;
  final ValueChanged<LoginEntryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _LoginTab(
          label: '验证码登录',
          selected: mode == LoginEntryMode.otp,
          onTap: () => onChanged(LoginEntryMode.otp),
        ),
        const SizedBox(width: 10),
        _LoginTab(
          label: '账号密码登录',
          selected: mode == LoginEntryMode.password,
          onTap: () => onChanged(LoginEntryMode.password),
        ),
      ],
    );
  }
}

class _LoginTab extends StatelessWidget {
  const _LoginTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF3E1) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: selected
                      ? const Color(0xFFA86610)
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 30 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFB97418),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VenueHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.36),
          Colors.white.withValues(alpha: 0.08),
        ],
      ).createShader(Offset.zero & size);

    final baseY = size.height * 0.72;
    final skyline = Path()
      ..moveTo(size.width * 0.48, baseY)
      ..lineTo(size.width * 0.48, size.height * 0.47)
      ..lineTo(size.width * 0.55, size.height * 0.40)
      ..lineTo(size.width * 0.61, baseY)
      ..lineTo(size.width * 0.66, baseY)
      ..lineTo(size.width * 0.66, size.height * 0.30)
      ..lineTo(size.width * 0.72, size.height * 0.23)
      ..lineTo(size.width * 0.78, baseY)
      ..lineTo(size.width * 0.84, baseY)
      ..lineTo(size.width * 0.84, size.height * 0.38)
      ..lineTo(size.width * 0.90, size.height * 0.31)
      ..lineTo(size.width * 0.95, baseY);
    canvas.drawPath(skyline, linePaint);

    final venue = Path()
      ..moveTo(size.width * 0.38, size.height * 0.77)
      ..quadraticBezierTo(
        size.width * 0.63,
        size.height * 0.47,
        size.width * 1.04,
        size.height * 0.62,
      )
      ..lineTo(size.width * 1.04, size.height)
      ..lineTo(size.width * 0.38, size.height)
      ..close();
    canvas.drawPath(venue, fillPaint);
    canvas.drawPath(venue, linePaint);

    for (var i = 0; i < 9; i += 1) {
      final x = size.width * (0.54 + i * 0.052);
      canvas.drawLine(
        Offset(x, size.height * 0.66),
        Offset(x, size.height * 0.96),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
