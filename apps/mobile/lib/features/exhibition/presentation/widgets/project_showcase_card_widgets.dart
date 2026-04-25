part of '../exhibition_trade_pages.dart';

class _ProjectShowcaseCompactCard extends StatelessWidget {
  const _ProjectShowcaseCompactCard({
    required this.item,
    required this.onPressed,
    this.onRequestNameAccess,
    this.requestInProgress = false,
  });

  final Map<String, Object?> item;
  final VoidCallback onPressed;
  final VoidCallback? onRequestNameAccess;
  final bool requestInProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = _projectDisplayTitle(item);
    final brandName = _projectDisplayBrandLine(item);
    final location = _projectPrimaryLocationText(item);
    final dateRange = _projectDateRangeLabel(item) ?? '当前项目暂未提供';
    final status = _stateFromPayload(item);
    final projectNo = _normalizeId(item['projectNo'] as String?) ?? '未提供';
    final shouldShowNameAccessControls = _projectShouldShowNameAccessControls(
      item,
    );
    final nameAccessStatus = _projectNameAccessStatus(item);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (status != null)
                  _StatusPill(
                    label: _frontStageStateLabel(status),
                    tone: _ActionCardTone.muted,
                  ),
              ],
            ),
            if (brandName != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                brandName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: <Widget>[
                _CompactProjectMeta(label: '项目编号', value: projectNo),
                _CompactProjectMeta(
                  label: '预算',
                  value: _currencyText(item['budgetAmount']),
                  highlight: true,
                ),
                _CompactProjectMeta(
                  label: '面积',
                  value: _projectAreaText(item['areaSqm'] as num?),
                ),
                _CompactProjectMeta(label: '搭建地', value: location),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                      children: <InlineSpan>[
                        TextSpan(
                          text: '时间：',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: dateRange,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onPressed,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('查看详情'),
                ),
              ],
            ),
            if (shouldShowNameAccessControls) ...<Widget>[
              const SizedBox(height: 14),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _StatusPill(
                            label: _projectNameAccessStatusLabel(
                              nameAccessStatus,
                            ),
                            tone: _ActionCardTone.muted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _projectNameAccessStatusBody(item),
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.45,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed:
                            requestInProgress ||
                                !_projectCanRequestNameAccess(item)
                            ? null
                            : onRequestNameAccess,
                        child: Text(
                          requestInProgress
                              ? '提交中...'
                              : _projectNameAccessActionLabel(item),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompactProjectMeta extends StatelessWidget {
  const _CompactProjectMeta({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w700,
      height: 1.3,
    );
    final valueStyle =
        (highlight ? theme.textTheme.titleMedium : theme.textTheme.titleSmall)
            ?.copyWith(
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w700,
              height: 1.25,
            );

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 128, maxWidth: 220),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: '$label：', style: labelStyle),
            TextSpan(text: value, style: valueStyle),
          ],
        ),
      ),
    );
  }
}
