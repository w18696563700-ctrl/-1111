part of 'profile_detail_pages.dart';

enum _PaymentBillingTone { gold, red, gray, blue, purple }

class _PaymentBillingSection extends StatelessWidget {
  const _PaymentBillingSection({
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final String? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    for (var index = 0; index < children.length; index += 1) {
      if (index > 0) {
        rows.add(const Divider(height: 1, color: Color(0xFFEDE7DF)));
      }
      rows.add(children[index]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1B1B24),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  trailing!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A8292),
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEDE7DF)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0D1E1A13),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(children: rows),
          ),
        ),
      ],
    );
  }
}

class _PaymentBillingInfoRow extends StatelessWidget {
  const _PaymentBillingInfoRow({
    required this.icon,
    required this.iconTone,
    required this.title,
    required this.description,
    this.badgeLabel,
    this.badgeTone = _PaymentBillingTone.blue,
    this.onTap,
  });

  final IconData icon;
  final _PaymentBillingTone iconTone;
  final String title;
  final String description;
  final String? badgeLabel;
  final _PaymentBillingTone badgeTone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeLabel = this.badgeLabel;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          _PaymentBillingIconBox(icon: icon, tone: iconTone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF24212B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF746E7A),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (badgeLabel != null) ...<Widget>[
            const SizedBox(width: 10),
            _PaymentBillingBadge(label: badgeLabel, tone: badgeTone),
          ],
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: const Color(
              0xFF9D96A3,
            ).withValues(alpha: onTap == null ? 0.55 : 1),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

class _PaymentBillingIconBox extends StatelessWidget {
  const _PaymentBillingIconBox({required this.icon, required this.tone});

  final IconData icon;
  final _PaymentBillingTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(tone);

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: colors.foreground, size: 21),
    );
  }
}

class _PaymentBillingBadge extends StatelessWidget {
  const _PaymentBillingBadge({required this.label, required this.tone});

  final String label;
  final _PaymentBillingTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(tone);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PaymentBillingMiniChip extends StatelessWidget {
  const _PaymentBillingMiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEAD5B2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF6C4C20),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PaymentBillingToneColors {
  const _PaymentBillingToneColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

_PaymentBillingToneColors _toneColors(_PaymentBillingTone tone) {
  return switch (tone) {
    _PaymentBillingTone.gold => const _PaymentBillingToneColors(
      background: Color(0xFFFFF0D4),
      foreground: Color(0xFF9A6419),
      border: Color(0xFFF2D2A0),
    ),
    _PaymentBillingTone.red => const _PaymentBillingToneColors(
      background: Color(0xFFFFE7E7),
      foreground: Color(0xFFD14E48),
      border: Color(0xFFFFCDCD),
    ),
    _PaymentBillingTone.gray => const _PaymentBillingToneColors(
      background: Color(0xFFF2F3F5),
      foreground: Color(0xFF6E7580),
      border: Color(0xFFE1E4E8),
    ),
    _PaymentBillingTone.blue => const _PaymentBillingToneColors(
      background: Color(0xFFEAF6FF),
      foreground: Color(0xFF2077B5),
      border: Color(0xFFCFEAFF),
    ),
    _PaymentBillingTone.purple => const _PaymentBillingToneColors(
      background: Color(0xFFF1E9FF),
      foreground: Color(0xFF7C4DCE),
      border: Color(0xFFE2D3FF),
    ),
  };
}
