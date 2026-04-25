part of 'exhibition_home_page.dart';

class _HomeEnterpriseRecommendationCard extends StatelessWidget {
  const _HomeEnterpriseRecommendationCard({
    required this.title,
    required this.summary,
    required this.badgeLabel,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String summary;
  final String badgeLabel;
  final String actionLabel;
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
              label: badgeLabel,
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
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ExhibitionHomeVisualTokens.textSecondary,
                height: 1.45,
              ),
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
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
