part of '../exhibition_trade_pages.dart';

class _MyProjectCompactCard extends StatelessWidget {
  const _MyProjectCompactCard({
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.chips,
    required this.stageLabel,
    required this.nextStep,
    required this.projectNo,
    required this.formalStatus,
    required this.evaluationStatus,
    required this.actionLabel,
    required this.onPressed,
    this.secondaryActionLabel,
    this.onSecondaryPressed,
    this.highlighted = false,
    this.highlightLabel,
  });

  final String title;
  final String description;
  final String statusLabel;
  final List<String> chips;
  final String stageLabel;
  final String nextStep;
  final String projectNo;
  final String formalStatus;
  final String evaluationStatus;
  final String actionLabel;
  final VoidCallback onPressed;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryPressed;
  final bool highlighted;
  final String? highlightLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.errorContainer.withValues(alpha: 0.22)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlighted ? colorScheme.error : colorScheme.outlineVariant,
          width: highlighted ? 1.4 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.28,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _StatusPill(label: statusLabel, tone: _ActionCardTone.emphasis),
              ],
            ),
            if (highlighted) ...<Widget>[
              const SizedBox(height: 8),
              _StatusPill(
                label: highlightLabel ?? '创建时间暂未返回',
                tone: _ActionCardTone.emphasis,
              ),
            ],
            if (description.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: chips
                  .where((String item) => item.trim().isNotEmpty)
                  .map(
                    (String item) =>
                        _StatusPill(label: item, tone: _ActionCardTone.muted),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _MyProjectCompactLine(
                      label: '项目阶段',
                      value: stageLabel,
                      emphasized: true,
                    ),
                    const SizedBox(height: 6),
                    _MyProjectCompactLine(
                      label: '下一步',
                      value: nextStep,
                      emphasized: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              '项目编号：$projectNo · $formalStatus · $evaluationStatus',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.32,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: <Widget>[
                if (secondaryActionLabel != null && onSecondaryPressed != null)
                  OutlinedButton(
                    onPressed: onSecondaryPressed,
                    child: Text(secondaryActionLabel!),
                  ),
                FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppVisualTokens.brandGold,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(actionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _myProjectDraftHighlightLabel(Map<String, Object?> item) {
  final rawCreatedAt = item['projectCreatedAt'];
  final createdAt = _formatMyProjectCreatedAt(
    rawCreatedAt is String ? rawCreatedAt : null,
  );
  return createdAt == null ? '创建时间暂未返回' : '创建时间：$createdAt';
}

String? _formatMyProjectCreatedAt(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(raw.trim());
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
      '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
}

class _MyProjectCompactLine extends StatelessWidget {
  const _MyProjectCompactLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.35,
        ),
        children: <TextSpan>[
          TextSpan(text: '$label：'),
          TextSpan(
            text: value,
            style: TextStyle(
              color: emphasized ? colorScheme.onSurface : null,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
