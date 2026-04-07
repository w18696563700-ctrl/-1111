part of '../exhibition_trade_pages.dart';

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.summary,
    this.showConnectionInfo = false,
    this.eyebrow = '当前页面',
    this.highlights = const <String>[],
    this.footnote,
  });

  final String title;
  final String summary;
  final bool showConnectionInfo;
  final String eyebrow;
  final List<String> highlights;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SectionEyebrow(label: eyebrow),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.52),
            ),
            if (highlights.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: highlights.map((String item) {
                  return _StatusPill(label: item, tone: _ActionCardTone.muted);
                }).toList(),
              ),
            ],
            if (footnote != null) ...<Widget>[
              const SizedBox(height: 14),
              Text(
                footnote!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            if (showConnectionInfo) ...<Widget>[
              const SizedBox(height: 14),
              _TechnicalDisclosure(
                title: '开发辅助（默认收起）',
                payloadLabel: '当前连接目标',
                payload: ExhibitionConsumerLayer.instance.configuredBaseUrl,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _ActionCardTone { standard, emphasis, muted }

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.children,
    this.summary,
    this.tone = _ActionCardTone.standard,
    this.eyebrow,
    this.footer,
  });

  final String title;
  final List<Widget> children;
  final String? summary;
  final _ActionCardTone tone;
  final String? eyebrow;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = switch (tone) {
      _ActionCardTone.standard => colorScheme.surface,
      _ActionCardTone.emphasis => colorScheme.surfaceContainerHigh,
      _ActionCardTone.muted => colorScheme.surfaceContainerLow,
    };
    final borderColor = switch (tone) {
      _ActionCardTone.standard => colorScheme.outlineVariant,
      _ActionCardTone.emphasis => colorScheme.primary.withValues(alpha: 0.18),
      _ActionCardTone.muted => colorScheme.outlineVariant,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (eyebrow != null) ...<Widget>[
              _SectionEyebrow(label: eyebrow!),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (summary != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                summary!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...children,
            if (footer != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                footer!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    this.tone = _ActionCardTone.standard,
  });

  final String label;
  final _ActionCardTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = switch (tone) {
      _ActionCardTone.standard => colorScheme.surfaceContainerHighest,
      _ActionCardTone.emphasis => colorScheme.primaryContainer,
      _ActionCardTone.muted => colorScheme.surfaceContainerLow,
    };
    final foregroundColor = switch (tone) {
      _ActionCardTone.standard => colorScheme.onSurfaceVariant,
      _ActionCardTone.emphasis => colorScheme.onPrimaryContainer,
      _ActionCardTone.muted => colorScheme.onSurfaceVariant,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label：$value',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          height: 1.45,
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _EntityCard extends StatelessWidget {
  const _EntityCard({
    required this.title,
    required this.description,
    required this.detailLines,
    this.statusLabel,
    this.tone = _ActionCardTone.standard,
    this.actionLabel,
    this.onPressed,
    this.actionSummary,
  });

  final String title;
  final String description;
  final List<Widget> detailLines;
  final String? statusLabel;
  final _ActionCardTone tone;
  final String? actionLabel;
  final VoidCallback? onPressed;
  final String? actionSummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (statusLabel != null) ...<Widget>[
                  const SizedBox(width: 12),
                  _StatusPill(label: statusLabel!, tone: tone),
                ],
              ],
            ),
            if (description.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            if (detailLines.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: detailLines,
                  ),
                ),
              ),
            ],
            if (actionSummary != null) ...<Widget>[
              const SizedBox(height: 14),
              _DetailLine(
                label: '当前建议动作',
                value: actionSummary!,
                highlight: true,
              ),
            ],
            if (actionLabel != null && onPressed != null) ...<Widget>[
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: onPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyNotice extends StatelessWidget {
  const _EmptyNotice({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}
