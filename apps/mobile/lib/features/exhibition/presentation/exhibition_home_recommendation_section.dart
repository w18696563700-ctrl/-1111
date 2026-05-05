part of 'exhibition_home_page.dart';

class _HomeEnterpriseRecommendationCard extends StatelessWidget {
  const _HomeEnterpriseRecommendationCard({
    required this.title,
    required this.summary,
    required this.badgeLabel,
    required this.actionLabel,
    required this.onPressed,
    this.imageUrl,
    this.locationLabel,
    this.chips = const <String>[],
    this.clean = false,
  });

  final String title;
  final String summary;
  final String? badgeLabel;
  final String actionLabel;
  final VoidCallback onPressed;
  final String? imageUrl;
  final String? locationLabel;
  final List<String> chips;
  final bool clean;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasVisibleBadge =
        !clean && badgeLabel != null && badgeLabel!.trim().isNotEmpty;
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
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _HomeEnterpriseRecommendationAvatar(
                    imageUrl: imageUrl,
                    fallback: title.characters.firstOrNull ?? '企',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (badgeLabel case final String label
                            when label.trim().isNotEmpty) ...<Widget>[
                          _HomePill(
                            label: label,
                            backgroundColor:
                                ExhibitionHomeVisualTokens.brandGoldLight,
                            foregroundColor:
                                ExhibitionHomeVisualTokens.brandGoldDeep,
                            dense: true,
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: ExhibitionHomeVisualTokens.textPrimary,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        if (locationLabel case final String label
                            when label.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ExhibitionHomeVisualTokens.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: ExhibitionHomeVisualTokens.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        if (!clean && chips.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: chips
                                .map(
                                  (String chip) => _HomePill(
                                    label: chip,
                                    backgroundColor: ExhibitionHomeVisualTokens
                                        .brandGoldLight,
                                    foregroundColor: ExhibitionHomeVisualTokens
                                        .textSecondary,
                                    dense: true,
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ],
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
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: Text(actionLabel),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: ExhibitionHomeVisualTokens.brandGoldDeep,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeEnterpriseRecommendationAvatar extends StatelessWidget {
  const _HomeEnterpriseRecommendationAvatar({
    required this.imageUrl,
    required this.fallback,
  });

  final String? imageUrl;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 70,
        height: 70,
        child: url == null || url.isEmpty
            ? _HomeEnterpriseAvatarFallback(fallback: fallback)
            : Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? progress,
                    ) {
                      if (progress == null) {
                        return child;
                      }
                      return _HomeEnterpriseAvatarFallback(fallback: fallback);
                    },
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return _HomeEnterpriseAvatarFallback(fallback: fallback);
                    },
              ),
      ),
    );
  }
}

class _HomeEnterpriseAvatarFallback extends StatelessWidget {
  const _HomeEnterpriseAvatarFallback({required this.fallback});

  final String fallback;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ExhibitionHomeVisualTokens.brandGoldLight,
      child: Center(
        child: Text(
          fallback,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: ExhibitionHomeVisualTokens.brandGoldDeep,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
