part of 'exhibition_home_page.dart';

class _HomeProjectCard extends StatelessWidget {
  const _HomeProjectCard({
    required this.title,
    required this.budgetLabel,
    required this.stateLabel,
    required this.cityLabel,
    required this.areaLabel,
    required this.entryTimeLabel,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String budgetLabel;
  final String stateLabel;
  final String cityLabel;
  final String areaLabel;
  final String entryTimeLabel;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ExhibitionHomeVisualTokens.cardBackground,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: ExhibitionHomeVisualTokens.borderSoft.withValues(
              alpha: 0.78,
            ),
          ),
          boxShadow: ExhibitionHomeVisualTokens.cardShadow(opacity: 0.035),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final useSideCover = constraints.maxWidth >= 370;
                  final coverWidth = useSideCover ? 124.0 : double.infinity;
                  final coverHeight = useSideCover ? 96.0 : 124.0;

                  final information = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: ExhibitionHomeVisualTokens.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _HomePill(
                            label: stateLabel,
                            backgroundColor: ExhibitionHomeVisualTokens
                                .brandGoldLight
                                .withValues(alpha: 0.72),
                            foregroundColor:
                                ExhibitionHomeVisualTokens.brandGoldDeep,
                            dense: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      LayoutBuilder(
                        builder:
                            (
                              BuildContext context,
                              BoxConstraints infoConstraints,
                            ) {
                              final infoTileWidth =
                                  (infoConstraints.maxWidth - 8) / 2;
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  _HomeProjectInfoTile(
                                    width: infoTileWidth,
                                    icon: Icons.calendar_month_outlined,
                                    label: '进场',
                                    value: entryTimeLabel,
                                    compact: useSideCover,
                                  ),
                                  _HomeProjectInfoTile(
                                    width: infoTileWidth,
                                    icon: Icons.location_on_outlined,
                                    label: '搭建地',
                                    value: cityLabel,
                                    compact: useSideCover,
                                  ),
                                  _HomeProjectInfoTile(
                                    width: infoTileWidth,
                                    icon: Icons.crop_square_outlined,
                                    label: '面积',
                                    value: areaLabel,
                                    compact: useSideCover,
                                  ),
                                  _HomeProjectInfoTile(
                                    width: infoTileWidth,
                                    icon: Icons.payments_outlined,
                                    label: '预算',
                                    value: budgetLabel,
                                    compact: useSideCover,
                                  ),
                                ],
                              );
                            },
                      ),
                    ],
                  );

                  if (!useSideCover) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _HomeDefaultProjectCover(
                          width: coverWidth,
                          height: coverHeight,
                        ),
                        const SizedBox(height: 12),
                        information,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _HomeDefaultProjectCover(
                        width: coverWidth,
                        height: coverHeight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: information),
                    ],
                  );
                },
              ),
              const SizedBox(height: 11),
              _HomeProjectPrimaryAction(
                label: actionLabel,
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeDefaultProjectCover extends StatelessWidget {
  const _HomeDefaultProjectCover({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Semantics(
      label: '商业示意默认封面，不代表项目真实图片',
      image: true,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFF3B3F45), Color(0xFFF7EEE1)],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CustomPaint(
                  painter: const _HomeDefaultProjectCoverPainter(),
                  child: const SizedBox.expand(),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withValues(alpha: 0.10),
                        Colors.black.withValues(alpha: 0.02),
                        Colors.black.withValues(alpha: 0.16),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      child: Text(
                        '示意图',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ExhibitionHomeVisualTokens.brandGoldDeep,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeDefaultProjectCoverPainter extends CustomPainter {
  const _HomeDefaultProjectCoverPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _paintCeiling(canvas, size);
    _paintBackPanels(canvas, size);
    _paintBooth(canvas, size);
    _paintLights(canvas, size);
    _paintForeground(canvas, size);
  }

  void _paintCeiling(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF20242A).withValues(alpha: 0.72);
    canvas.drawRect(Offset.zero & Size(size.width, size.height * 0.34), paint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var x = size.width * 0.12; x < size.width; x += size.width * 0.18) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.width * 0.18, size.height * 0.34),
        linePaint,
      );
    }
  }

  void _paintBackPanels(Canvas canvas, Size size) {
    final wallPaint = Paint()..color = const Color(0xFFF8F3EA);
    final wallRect = Rect.fromLTWH(
      size.width * 0.10,
      size.height * 0.32,
      size.width * 0.80,
      size.height * 0.44,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(wallRect, Radius.circular(size.width * 0.04)),
      wallPaint,
    );

    final shadowPaint = Paint()
      ..color = const Color(0xFF8A642C).withValues(alpha: 0.13)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.52, size.height * 0.73),
        width: size.width * 0.72,
        height: size.height * 0.18,
      ),
      shadowPaint,
    );
  }

  void _paintBooth(Canvas canvas, Size size) {
    final goldPaint = Paint()..color = const Color(0xFFC99245);
    final darkGoldPaint = Paint()..color = const Color(0xFF9B6A2C);
    final glassPaint = Paint()..color = Colors.white.withValues(alpha: 0.76);

    final canopy = Path()
      ..moveTo(size.width * 0.22, size.height * 0.36)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.20,
        size.width * 0.78,
        size.height * 0.36,
      )
      ..lineTo(size.width * 0.72, size.height * 0.43)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.31,
        size.width * 0.28,
        size.height * 0.43,
      )
      ..close();
    canvas.drawPath(canopy, goldPaint);

    final counterRect = Rect.fromLTWH(
      size.width * 0.24,
      size.height * 0.58,
      size.width * 0.52,
      size.height * 0.16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(counterRect, Radius.circular(size.width * 0.035)),
      glassPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.31,
          size.height * 0.60,
          size.width * 0.38,
          size.height * 0.10,
        ),
        Radius.circular(size.width * 0.025),
      ),
      Paint()..color = const Color(0xFFE5D3B7),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.26,
        size.height * 0.42,
        size.width * 0.035,
        size.height * 0.25,
      ),
      darkGoldPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.70,
        size.height * 0.42,
        size.width * 0.035,
        size.height * 0.25,
      ),
      darkGoldPaint,
    );
  }

  void _paintLights(Canvas canvas, Size size) {
    final lightPaint = Paint()
      ..color = const Color(0xFFFFE4A3).withValues(alpha: 0.72)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    for (final offset in <Offset>[
      Offset(size.width * 0.34, size.height * 0.43),
      Offset(size.width * 0.50, size.height * 0.38),
      Offset(size.width * 0.66, size.height * 0.43),
    ]) {
      canvas.drawCircle(offset, size.width * 0.035, lightPaint);
    }
  }

  void _paintForeground(Canvas canvas, Size size) {
    final floorPaint = Paint()
      ..shader =
          const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFFFFFFF), Color(0xFFE7D8C2)],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.72,
              size.width,
              size.height * 0.28,
            ),
          );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.72, size.width, size.height * 0.28),
      floorPaint,
    );

    final plantPaint = Paint()
      ..color = const Color(0xFF4E6B54).withValues(alpha: 0.74);
    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.69),
      size.width * 0.025,
      plantPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.69),
      size.width * 0.025,
      plantPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeDefaultProjectCoverPainter oldDelegate) {
    return false;
  }
}

class _HomeProjectInfoTile extends StatelessWidget {
  const _HomeProjectInfoTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.compact,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: ExhibitionHomeVisualTokens.textSecondary,
      fontWeight: FontWeight.w700,
      height: 1,
    );
    final valueStyle = theme.textTheme.labelMedium?.copyWith(
      color: ExhibitionHomeVisualTokens.textPrimary,
      fontWeight: FontWeight.w800,
      height: 1.12,
    );

    return SizedBox(
      width: width,
      height: compact ? 48 : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F1F4)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 7 : 9,
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          icon,
                          size: 14,
                          color: ExhibitionHomeVisualTokens.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(label, style: labelStyle),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: valueStyle,
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Icon(
                      icon,
                      size: 15,
                      color: ExhibitionHomeVisualTokens.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(label, style: labelStyle),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: valueStyle,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HomeProjectPrimaryAction extends StatelessWidget {
  const _HomeProjectPrimaryAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(17),
          child: Ink(
            height: 46,
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[Color(0xFFE2A047), Color(0xFFC27A28)],
                    )
                  : const LinearGradient(
                      colors: <Color>[Color(0xFFE6E2DA), Color(0xFFD8D3CA)],
                    ),
              borderRadius: BorderRadius.circular(17),
              boxShadow: enabled
                  ? <BoxShadow>[
                      BoxShadow(
                        color: ExhibitionHomeVisualTokens.brandGold.withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeStateNotice extends StatelessWidget {
  const _HomeStateNotice({
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ExhibitionHomeVisualTokens.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: ExhibitionHomeVisualTokens.cardShadow(opacity: 0.04),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: ExhibitionHomeVisualTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ExhibitionHomeVisualTokens.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 12, runSpacing: 12, children: actions),
          ],
        ),
      ),
    );
  }
}

class _HomeLoadingNotice extends StatelessWidget {
  const _HomeLoadingNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ExhibitionHomeVisualTokens.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: ExhibitionHomeVisualTokens.cardShadow(opacity: 0.04),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.hourglass_empty_rounded,
              color: ExhibitionHomeVisualTokens.brandGold,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ExhibitionHomeVisualTokens.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeForumFeedCard extends StatelessWidget {
  const _HomeForumFeedCard({
    required this.topicLabel,
    required this.title,
    required this.excerpt,
    required this.metaLabel,
    required this.statLabel,
    required this.onPressed,
  });

  final String topicLabel;
  final String title;
  final String excerpt;
  final String metaLabel;
  final String statLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ExhibitionHomeVisualTokens.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: ExhibitionHomeVisualTokens.cardShadow(opacity: 0.04),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HomePill(
              label: topicLabel,
              backgroundColor: ExhibitionHomeVisualTokens.brandGoldLight,
              foregroundColor: ExhibitionHomeVisualTokens.brandGoldDeep,
              dense: true,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: ExhibitionHomeVisualTokens.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              excerpt,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ExhibitionHomeVisualTokens.textSecondary,
                height: 1.45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  metaLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ExhibitionHomeVisualTokens.textSecondary,
                  ),
                ),
                _HomePill(
                  label: statLabel,
                  backgroundColor: const Color(0xFFF7F8FA),
                  foregroundColor: ExhibitionHomeVisualTokens.textPrimary,
                  dense: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              child: const Text('查看帖子'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePill extends StatelessWidget {
  const _HomePill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.dense = false,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 10 : 12,
          vertical: dense ? 5 : 6,
        ),
        child: Text(
          label,
          style:
              (dense
                      ? Theme.of(context).textTheme.labelSmall
                      : Theme.of(context).textTheme.labelMedium)
                  ?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
        ),
      ),
    );
  }
}

class _HomeIconPill extends StatelessWidget {
  const _HomeIconPill({
    required this.icon,
    required this.label,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: ExhibitionHomeVisualTokens.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: ExhibitionHomeVisualTokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
