part of '../exhibition_trade_pages.dart';

class _ProjectShowcaseCompactCard extends StatelessWidget {
  const _ProjectShowcaseCompactCard({
    required this.item,
    required this.onPressed,
  });

  final Map<String, Object?> item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exhibitionName = _projectDisplayTitle(item);
    final brandName = _projectDisplayBrandLine(item) ?? '当前项目暂未提供';
    final location = _projectRegionLabel(item) ?? '当前项目暂未提供';
    final dateRange = _projectDateRangeLabel(item) ?? '当前项目暂未提供';
    final status = _stateFromPayload(item);

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
                    exhibitionName,
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
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: <Widget>[
                _CompactProjectMeta(label: '展会', value: exhibitionName),
                _CompactProjectMeta(label: '品牌', value: brandName),
                _CompactProjectMeta(
                  label: '金额',
                  value: _currencyText(item['budgetAmount']),
                  highlight: true,
                ),
                _CompactProjectMeta(
                  label: '面积',
                  value: _projectAreaLabel(item['areaSqm'] as num?),
                ),
                _CompactProjectMeta(label: '地点', value: location),
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
                FilledButton.tonal(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
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
          ],
        ),
      ),
    );
  }

  String? _projectRegionLabel(Map<String, Object?> item) {
    final provinceName = _normalizeId(item['provinceName'] as String?);
    final cityName = _normalizeId(item['cityName'] as String?);
    if (provinceName == null && cityName == null) {
      return null;
    }
    if (provinceName != null && cityName != null) {
      return '$provinceName / $cityName';
    }
    return provinceName ?? cityName;
  }

  String _projectAreaLabel(num? areaSqm) {
    if (areaSqm == null) {
      return '当前项目暂未提供';
    }
    final normalized = areaSqm
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return '$normalized ㎡';
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
