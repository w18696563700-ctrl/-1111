part of '../exhibition_trade_pages.dart';

Future<bool> _showBidServiceFeeAuthorizationConfirmSheet(
  BuildContext context,
) async {
  if (!RcReleaseFlags.bidServiceFeeAuthorizationEnabled) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(const SnackBar(content: Text(rcFeatureUnavailableTitle)));
    return false;
  }
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BidServiceFeeAuthorizationConfirmSheet(),
  );
  return result ?? false;
}

class _BidServiceFeeAuthorizationConfirmSheet extends StatelessWidget {
  const _BidServiceFeeAuthorizationConfirmSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFCF8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5DED3),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '预授权确认',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF17151A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _BidServiceFeeAuthorizationAmountBanner(theme: theme),
              const SizedBox(height: 14),
              const _BidServiceFeeAuthorizationChannelCard(),
              const SizedBox(height: 12),
              const _BidServiceFeeAuthorizationTruthNote(),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: const Color(0xFFB77A20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('去支付宝确认预授权'),
              ),
              const SizedBox(height: 6),
              Text(
                '取消只会关闭当前面板，不会创建预授权记录，也不会改变 Server 状态。',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8A8178),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BidServiceFeeAuthorizationAmountBanner extends StatelessWidget {
  const _BidServiceFeeAuthorizationAmountBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF4DF), Color(0xFFFFE3B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6C58B)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '4000 元',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF17151A),
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '竞标服务费预授权额度，不是扣款',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6F5630),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BidServiceFeeAuthorizationChannelCard extends StatelessWidget {
  const _BidServiceFeeAuthorizationChannelCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDE3D8)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F7A4E1D),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: const Column(
        children: <Widget>[
          _BidServiceFeeAuthorizationConfirmRow(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: Color(0xFF1677FF),
            title: '支付宝预授权',
            subtitle: '当前仅支持支付宝确认 4000 元预授权额度',
            checked: true,
            useAlipayLogo: true,
          ),
          Divider(height: 18),
          _BidServiceFeeAuthorizationConfirmRow(
            icon: Icons.lock_clock_outlined,
            iconColor: Color(0xFFB77A20),
            title: '等待 Server 回读',
            subtitle: '未回读 frozen 前不显示完成，也不解锁消息发送',
            checked: false,
          ),
        ],
      ),
    );
  }
}

class _BidServiceFeeAuthorizationConfirmRow extends StatelessWidget {
  const _BidServiceFeeAuthorizationConfirmRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.checked,
    this.useAlipayLogo = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool checked;
  final bool useAlipayLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: useAlipayLogo
              ? const _BidServiceFeeAuthorizationAlipayLogo()
              : Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF17151A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF77717A),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          checked ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: checked ? const Color(0xFFB77A20) : const Color(0xFFC9C2BA),
        ),
      ],
    );
  }
}

class _BidServiceFeeAuthorizationAlipayLogo extends StatelessWidget {
  const _BidServiceFeeAuthorizationAlipayLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _BidServiceFeeAuthorizationAlipayLogoPainter(),
      ),
    );
  }
}

class _BidServiceFeeAuthorizationAlipayLogoPainter extends CustomPainter {
  const _BidServiceFeeAuthorizationAlipayLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 24;
    final backgroundPaint = Paint()
      ..color = const Color(0xFF1677FF)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(5.5 * scale)),
      backgroundPaint,
    );

    final barPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.2 * scale;
    canvas.drawLine(
      Offset(4.4 * scale, 7.1 * scale),
      Offset(19.6 * scale, 7.1 * scale),
      barPaint,
    );
    canvas.drawLine(
      Offset(12.5 * scale, 3.2 * scale),
      Offset(12.5 * scale, 12.7 * scale),
      barPaint,
    );
    canvas.drawLine(
      Offset(6.0 * scale, 11.7 * scale),
      Offset(16.8 * scale, 11.7 * scale),
      barPaint,
    );

    final slashPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.5 * scale;
    canvas.drawLine(
      Offset(17.0 * scale, 11.0 * scale),
      Offset(13.0 * scale, 19.5 * scale),
      slashPaint,
    );

    final curvePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0 * scale;
    final curve = Path()
      ..moveTo(20.0 * scale, 12.4 * scale)
      ..cubicTo(
        17.8 * scale,
        17.5 * scale,
        9.4 * scale,
        22.4 * scale,
        3.6 * scale,
        18.8 * scale,
      )
      ..cubicTo(
        -0.2 * scale,
        16.3 * scale,
        3.3 * scale,
        12.2 * scale,
        11.4 * scale,
        12.8 * scale,
      )
      ..cubicTo(
        17.8 * scale,
        13.3 * scale,
        21.2 * scale,
        15.8 * scale,
        25.4 * scale,
        17.0 * scale,
      );
    canvas.drawPath(curve, curvePaint);
  }

  @override
  bool shouldRepaint(
    covariant _BidServiceFeeAuthorizationAlipayLogoPainter oldDelegate,
  ) {
    return false;
  }
}

class _BidServiceFeeAuthorizationTruthNote extends StatelessWidget {
  const _BidServiceFeeAuthorizationTruthNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EA),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(14),
      child: Text(
        '本面板不是收银台，只确认当前竞标服务费预授权入口；未开通能力不会出现在这里。',
        style: theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6F665D),
          height: 1.45,
        ),
      ),
    );
  }
}
