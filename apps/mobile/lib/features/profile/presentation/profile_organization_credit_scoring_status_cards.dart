part of 'profile_detail_pages.dart';

enum _ProfileReserveTone { gold, gray, amber, red, blue, green }

class _ProfileReserveOverviewGrid extends StatelessWidget {
  const _ProfileReserveOverviewGrid({required this.items});

  final List<_ProfileReserveInfoCardData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final columns = constraints.maxWidth < 340 ? 1 : 2;
        final width =
            (constraints.maxWidth - ((columns - 1) * _reserveCardGap)) /
            columns;
        return Wrap(
          spacing: _reserveCardGap,
          runSpacing: _reserveCardGap,
          children: items
              .map(
                (_ProfileReserveInfoCardData item) => SizedBox(
                  width: width,
                  child: _ProfileReserveInfoCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ProfileReserveStatsGrid extends StatelessWidget {
  const _ProfileReserveStatsGrid({required this.items});

  final List<_ProfileReserveStatCardData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final columns = constraints.maxWidth >= 860
            ? 4
            : constraints.maxWidth >= 560
            ? 3
            : 2;
        final width =
            (constraints.maxWidth - ((columns - 1) * _reserveCardGap)) /
            columns;
        return Wrap(
          spacing: _reserveCardGap,
          runSpacing: _reserveCardGap,
          children: items
              .map(
                (_ProfileReserveStatCardData item) => SizedBox(
                  width: width,
                  child: _ProfileReserveStatCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ProfileReserveInfoCard extends StatelessWidget {
  const _ProfileReserveInfoCard({required this.item});

  final _ProfileReserveInfoCardData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _profileReserveToneColors(item.tone);
    return DecoratedBox(
      decoration: _profileReserveCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ProfileReserveIconBox(icon: item.icon, tone: item.tone),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppVisualTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileReserveStatCard extends StatelessWidget {
  const _ProfileReserveStatCard({required this.item});

  final _ProfileReserveStatCardData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _profileReserveToneColors(item.tone);
    return DecoratedBox(
      decoration: _profileReserveCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppVisualTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _ProfileReserveIconBox(
                  icon: item.icon,
                  tone: item.tone,
                  compact: true,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: colors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileReserveActionCard extends StatelessWidget {
  const _ProfileReserveActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: _profileReserveCardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: <Widget>[
                _ProfileReserveIconBox(
                  icon: icon,
                  tone: _ProfileReserveTone.gold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppVisualTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppVisualTokens.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileReserveIconBox extends StatelessWidget {
  const _ProfileReserveIconBox({
    required this.icon,
    required this.tone,
    this.compact = false,
  });

  final IconData icon;
  final _ProfileReserveTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _profileReserveToneColors(tone);
    final size = compact ? 34.0 : 40.0;
    final iconSize = compact ? 18.0 : 21.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(compact ? 12 : 14),
        border: Border.all(color: colors.border),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: colors.foreground, size: iconSize),
    );
  }
}

class _ProfileReserveBadge extends StatelessWidget {
  const _ProfileReserveBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF0D9B0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppVisualTokens.brandGoldDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ProfileReserveInlineChip extends StatelessWidget {
  const _ProfileReserveInlineChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF0D9B0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: AppVisualTokens.brandGoldDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppVisualTokens.brandGoldDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileReserveInfoCardData {
  const _ProfileReserveInfoCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String value;
  final _ProfileReserveTone tone;
}

class _ProfileReserveStatCardData {
  const _ProfileReserveStatCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String value;
  final _ProfileReserveTone tone;
}

class _ProfileReserveToneColors {
  const _ProfileReserveToneColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

BoxDecoration _profileReserveCardDecoration() {
  return BoxDecoration(
    color: AppVisualTokens.cardBackground,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppVisualTokens.borderSoft),
    boxShadow: AppVisualTokens.shadowCard(opacity: 0.05),
  );
}

_ProfileReserveToneColors _profileReserveToneColors(_ProfileReserveTone tone) {
  return switch (tone) {
    _ProfileReserveTone.gold => const _ProfileReserveToneColors(
      background: Color(0xFFFFF1D8),
      foreground: Color(0xFF9A6419),
      border: Color(0xFFF0D9B0),
    ),
    _ProfileReserveTone.gray => const _ProfileReserveToneColors(
      background: Color(0xFFF2F3F5),
      foreground: Color(0xFF6E7580),
      border: Color(0xFFE1E4E8),
    ),
    _ProfileReserveTone.amber => const _ProfileReserveToneColors(
      background: Color(0xFFFFF4DF),
      foreground: Color(0xFFB06A11),
      border: Color(0xFFF7DEAE),
    ),
    _ProfileReserveTone.red => const _ProfileReserveToneColors(
      background: Color(0xFFFCE8E6),
      foreground: Color(0xFFD14E48),
      border: Color(0xFFF4C9C5),
    ),
    _ProfileReserveTone.blue => const _ProfileReserveToneColors(
      background: Color(0xFFEAF6FF),
      foreground: Color(0xFF2077B5),
      border: Color(0xFFCFEAFF),
    ),
    _ProfileReserveTone.green => const _ProfileReserveToneColors(
      background: Color(0xFFEAF7EF),
      foreground: Color(0xFF2D8550),
      border: Color(0xFFCFEBD9),
    ),
  };
}
