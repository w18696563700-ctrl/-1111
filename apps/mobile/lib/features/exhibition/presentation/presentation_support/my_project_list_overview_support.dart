part of '../exhibition_trade_pages.dart';

class _MyProjectOverviewCard extends StatelessWidget {
  const _MyProjectOverviewCard({
    required this.publishCount,
    required this.bidCount,
    required this.bidLoading,
  });

  final int publishCount;
  final int? bidCount;
  final bool bidLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bidValue = bidLoading ? '...' : (bidCount?.toString() ?? '--');
    final bidNote = bidCount == null && !bidLoading ? '切换后读取' : '真实列表';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.brandGoldLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppVisualTokens.brandGold.withValues(alpha: 0.18),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.folder_copy_rounded,
                      color: AppVisualTokens.brandGoldDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '当前展示：已接通内容',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '后续动作以后端实际承载状态为准。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MyProjectOverviewMetric(
                    icon: Icons.campaign_rounded,
                    label: '我的发布',
                    value: '$publishCount',
                    note: '展示层派生',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MyProjectOverviewMetric(
                    icon: Icons.near_me_rounded,
                    label: '我的竞标',
                    value: bidValue,
                    note: bidNote,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyProjectOverviewMetric extends StatelessWidget {
  const _MyProjectOverviewMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
  });

  final IconData icon;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppVisualTokens.brandGoldLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppVisualTokens.brandGoldDark,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
