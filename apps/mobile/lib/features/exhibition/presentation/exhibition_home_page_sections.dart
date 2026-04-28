part of 'exhibition_home_page.dart';

class _HomeHeroHeader extends StatelessWidget {
  const _HomeHeroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              Text(
                '展览',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: ExhibitionHomeVisualTokens.textPrimary,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Text(
                '发现优质项目，把握商机',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: ExhibitionHomeVisualTokens.textSecondary,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                eyebrow,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: ExhibitionHomeVisualTokens.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: ExhibitionHomeVisualTokens.brandGold.withValues(
                  alpha: 0.72,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
