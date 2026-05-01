part of 'profile_detail_pages.dart';

class _ProfileCreditFeatureGrid extends StatelessWidget {
  const _ProfileCreditFeatureGrid({required this.items});

  final List<_ProfileCreditFeatureCardData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final columns = constraints.maxWidth < 340 ? 1 : 2;
        final width =
            (constraints.maxWidth - ((columns - 1) * _profileCreditCardGap)) /
            columns;
        return Wrap(
          spacing: _profileCreditCardGap,
          runSpacing: _profileCreditCardGap,
          children: items
              .map(
                (_ProfileCreditFeatureCardData item) => SizedBox(
                  width: width,
                  child: _ProfileCreditFeatureCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ProfileCreditFeatureCard extends StatelessWidget {
  const _ProfileCreditFeatureCard({required this.item});

  final _ProfileCreditFeatureCardData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _profileCreditToneColors(item.tone);
    return DecoratedBox(
      decoration: _profileCreditCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ProfileCreditIconBox(icon: item.icon, tone: item.tone),
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
                    style: theme.textTheme.bodySmall?.copyWith(
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

class _ProfileCreditSectionCard extends StatelessWidget {
  const _ProfileCreditSectionCard({
    required this.icon,
    required this.title,
    required this.tone,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final _ProfileCreditTone tone;
  final List<_ProfileCreditInfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: _profileCreditCardDecoration(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _ProfileCreditIconBox(icon: icon, tone: tone, compact: true),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppVisualTokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < rows.length; index += 1) ...<Widget>[
              if (index > 0)
                Divider(height: 1, color: AppVisualTokens.borderSoft),
              _ProfileCreditInfoRow(row: rows[index]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileCreditInfoRow extends StatelessWidget {
  const _ProfileCreditInfoRow({required this.row});

  final _ProfileCreditInfoRowData row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _profileCreditToneColors(row.tone);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ProfileCreditIconBox(icon: row.icon, tone: row.tone, compact: true),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              row.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppVisualTokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCreditActionCard extends StatelessWidget {
  const _ProfileCreditActionCard({
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
      decoration: _profileCreditCardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: <Widget>[
                _ProfileCreditIconBox(
                  icon: icon,
                  tone: _ProfileCreditTone.gold,
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

class _ProfileCreditSectionHeader extends StatelessWidget {
  const _ProfileCreditSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppVisualTokens.brandGold,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppVisualTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProfileCreditIconBox extends StatelessWidget {
  const _ProfileCreditIconBox({
    required this.icon,
    required this.tone,
    this.compact = false,
  });

  final IconData icon;
  final _ProfileCreditTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _profileCreditToneColors(tone);
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

class _ProfileCreditBadge extends StatelessWidget {
  const _ProfileCreditBadge({required this.label});

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

class _ProfileCreditInlineChip extends StatelessWidget {
  const _ProfileCreditInlineChip({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final _ProfileCreditTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _profileCreditToneColors(tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: colors.foreground),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                softWrap: true,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
