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
  final String? badgeLabel;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasVisibleBadge = badgeLabel != null && badgeLabel!.trim().isNotEmpty;
    return Semantics(
      button: true,
      label: actionLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              color: ExhibitionHomeVisualTokens.cardBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: ExhibitionHomeVisualTokens.borderSoft.withValues(
                  alpha: 0.88,
                ),
              ),
              boxShadow: ExhibitionHomeVisualTokens.cardShadow(opacity: 0.04),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (badgeLabel case final String label
                      when label.trim().isNotEmpty) ...<Widget>[
                    _HomePill(
                      label: label,
                      backgroundColor:
                          ExhibitionHomeVisualTokens.brandGoldLight,
                      foregroundColor: ExhibitionHomeVisualTokens.brandGoldDeep,
                      dense: true,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: ExhibitionHomeVisualTokens.textPrimary,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: ExhibitionHomeVisualTokens.brandGoldDeep,
                        size: 19,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ExhibitionHomeVisualTokens.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  if (hasVisibleBadge) ...<Widget>[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onPressed,
                        style: TextButton.styleFrom(
                          foregroundColor:
                              ExhibitionHomeVisualTokens.brandGoldDeep,
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(actionLabel),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
