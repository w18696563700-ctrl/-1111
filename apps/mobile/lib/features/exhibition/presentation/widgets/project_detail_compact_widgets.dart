part of '../exhibition_trade_pages.dart';

class _ProjectDetailCompactMetaItemData {
  const _ProjectDetailCompactMetaItemData({
    required this.label,
    required this.value,
    this.highlight = false,
    this.fullWidth = false,
    this.icon,
  });

  final String label;
  final String value;
  final bool highlight;
  final bool fullWidth;
  final IconData? icon;
}

class _ProjectDetailOverviewCard extends StatelessWidget {
  const _ProjectDetailOverviewCard({
    required this.title,
    required this.children,
    this.statusLabel,
  });

  final String title;
  final String? statusLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFFFFFF), Color(0xFFFFFAF1)],
        ),
        borderRadius: AppVisualTokens.radiusXLargeBorder,
        border: Border.all(color: AppVisualTokens.borderSoft),
        boxShadow: AppVisualTokens.shadowCard(opacity: 0.045),
      ),
      child: ClipRRect(
        borderRadius: AppVisualTokens.radiusXLargeBorder,
        child: Stack(
          children: <Widget>[
            const Positioned(
              top: 18,
              right: 14,
              child: _ProjectDetailHeroIllustration(),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextTokens.pageTitle.copyWith(
                            fontSize: 26,
                            height: 1.18,
                          ),
                        ),
                      ),
                      if (statusLabel != null) ...<Widget>[
                        const SizedBox(width: 12),
                        AppStatusBadge(
                          label: statusLabel!,
                          tone: AppStatusTone.warning,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectDetailHeroIllustration extends StatelessWidget {
  const _ProjectDetailHeroIllustration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.72,
        child: SizedBox(
          width: 126,
          height: 104,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                right: 0,
                top: 8,
                child: Container(
                  width: 92,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE6B8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppVisualTokens.shadowSoft(opacity: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 18,
                top: 0,
                child: Transform.rotate(
                  angle: -0.08,
                  child: Container(
                    width: 78,
                    height: 86,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF3D6A8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 20, 12, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _IllustrationLine(width: 42),
                          const SizedBox(height: 8),
                          _IllustrationLine(width: 52),
                          const SizedBox(height: 8),
                          _IllustrationLine(width: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 7,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: <Color>[
                        Color(0xFFE7A545),
                        AppVisualTokens.brandGold,
                      ],
                    ),
                    boxShadow: AppVisualTokens.shadowSoft(opacity: 0.1),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IllustrationLine extends StatelessWidget {
  const _IllustrationLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 7,
      decoration: BoxDecoration(
        color: const Color(0xFFE6B978).withValues(alpha: 0.55),
        borderRadius: AppVisualTokens.radiusPillBorder,
      ),
    );
  }
}

class _ProjectDetailCompactMetaGrid extends StatelessWidget {
  const _ProjectDetailCompactMetaGrid({required this.items});

  final List<_ProjectDetailCompactMetaItemData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const spacing = 12.0;
        final twoColumns = constraints.maxWidth >= 360;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (_ProjectDetailCompactMetaItemData item) => SizedBox(
                  width: item.fullWidth ? constraints.maxWidth : itemWidth,
                  child: _ProjectDetailCompactMetaItem(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ProjectDetailCompactMetaItem extends StatelessWidget {
  const _ProjectDetailCompactMetaItem({required this.item});

  final _ProjectDetailCompactMetaItemData item;

  @override
  Widget build(BuildContext context) {
    final foreground = item.highlight
        ? AppVisualTokens.brandGoldDark
        : AppVisualTokens.textPrimary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ProjectDetailFieldIcon(
          icon: item.icon ?? Icons.info_outline_rounded,
          highlight: item.highlight,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.label,
                style: AppTextTokens.body.copyWith(
                  color: AppVisualTokens.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: AppTextTokens.cardTitle.copyWith(
                  color: foreground,
                  fontSize: item.highlight ? 19 : 18,
                  height: 1.22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectDetailInfoLine extends StatelessWidget {
  const _ProjectDetailInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppVisualTokens.borderSoft)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ProjectDetailFieldIcon(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: AppTextTokens.body.copyWith(
                        color: AppVisualTokens.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: AppTextTokens.bodyStrong.copyWith(
                        fontSize: 17,
                        height: 1.38,
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

class _ProjectDetailFieldIcon extends StatelessWidget {
  const _ProjectDetailFieldIcon({required this.icon, this.highlight = false});

  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: highlight
            ? AppVisualTokens.brandGoldLight
            : const Color(0xFFFBF4EA),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 18,
        color: highlight
            ? AppVisualTokens.brandGoldDark
            : AppVisualTokens.brandGold,
      ),
    );
  }
}
