part of 'exhibition_page.dart';

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label, this.highlighted = false});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: highlighted
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _LoadingHeroCard extends StatelessWidget {
  const _LoadingHeroCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title),
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingSectionCard extends StatelessWidget {
  const _LoadingSectionCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(3, (int index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

String? _normalizeWorkbenchId(String? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _normalizeWorkbenchText(String? value) {
  return _normalizeWorkbenchId(value);
}

class _NodeStatusPill extends StatelessWidget {
  const _NodeStatusPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

class _NodeToneTheme {
  const _NodeToneTheme({
    required this.surfaceColor,
    required this.borderColor,
    required this.pillColor,
    required this.pillTextColor,
  });

  final Color surfaceColor;
  final Color borderColor;
  final Color pillColor;
  final Color pillTextColor;
}

_NodeToneTheme _containerToneTheme(
  ThemeData theme,
  ExhibitionWorkbenchContainerState state,
) {
  final colorScheme = theme.colorScheme;
  return switch (state) {
    ExhibitionWorkbenchContainerState.loading => _NodeToneTheme(
      surfaceColor: colorScheme.surfaceContainerHighest,
      borderColor: colorScheme.outlineVariant,
      pillColor: colorScheme.surfaceContainerHigh,
      pillTextColor: colorScheme.onSurfaceVariant,
    ),
    ExhibitionWorkbenchContainerState.empty => _NodeToneTheme(
      surfaceColor: colorScheme.surfaceContainerLow,
      borderColor: colorScheme.outlineVariant,
      pillColor: colorScheme.surfaceContainerHigh,
      pillTextColor: colorScheme.onSurfaceVariant,
    ),
    ExhibitionWorkbenchContainerState.content => _NodeToneTheme(
      surfaceColor: colorScheme.secondaryContainer.withValues(alpha: 0.32),
      borderColor: colorScheme.secondary.withValues(alpha: 0.18),
      pillColor: colorScheme.secondaryContainer,
      pillTextColor: colorScheme.onSecondaryContainer,
    ),
    ExhibitionWorkbenchContainerState.controlledFailure => _NodeToneTheme(
      surfaceColor: colorScheme.errorContainer.withValues(alpha: 0.35),
      borderColor: colorScheme.error.withValues(alpha: 0.18),
      pillColor: colorScheme.errorContainer,
      pillTextColor: colorScheme.onErrorContainer,
    ),
  };
}

_NodeToneTheme _nodeToneTheme(
  ThemeData theme,
  ExhibitionWorkbenchNodeTone tone,
) {
  final colorScheme = theme.colorScheme;
  return switch (tone) {
    ExhibitionWorkbenchNodeTone.primary => _NodeToneTheme(
      surfaceColor: colorScheme.primaryContainer.withValues(alpha: 0.35),
      borderColor: colorScheme.primary.withValues(alpha: 0.16),
      pillColor: colorScheme.primaryContainer,
      pillTextColor: colorScheme.onPrimaryContainer,
    ),
    ExhibitionWorkbenchNodeTone.continuation => _NodeToneTheme(
      surfaceColor: colorScheme.secondaryContainer.withValues(alpha: 0.28),
      borderColor: colorScheme.secondary.withValues(alpha: 0.16),
      pillColor: colorScheme.secondaryContainer,
      pillTextColor: colorScheme.onSecondaryContainer,
    ),
    ExhibitionWorkbenchNodeTone.frozen => _NodeToneTheme(
      surfaceColor: colorScheme.tertiaryContainer.withValues(alpha: 0.28),
      borderColor: colorScheme.tertiary.withValues(alpha: 0.16),
      pillColor: colorScheme.tertiaryContainer,
      pillTextColor: colorScheme.onTertiaryContainer,
    ),
    ExhibitionWorkbenchNodeTone.unavailable => _NodeToneTheme(
      surfaceColor: colorScheme.surfaceContainerLowest,
      borderColor: colorScheme.outlineVariant,
      pillColor: colorScheme.surfaceContainerHigh,
      pillTextColor: colorScheme.onSurfaceVariant,
    ),
  };
}
