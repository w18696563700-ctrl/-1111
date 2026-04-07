import 'package:flutter/material.dart';

class ForumPageFrame extends StatelessWidget {
  const ForumPageFrame({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.scopeLabel,
    required this.routeLabel,
    required this.children,
    this.heroActions = const <Widget>[],
    this.showRouteMeta = false,
  });

  final String eyebrow;
  final String title;
  final String summary;
  final String scopeLabel;
  final String routeLabel;
  final List<Widget> heroActions;
  final List<Widget> children;
  final bool showRouteMeta;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: <Widget>[
        ForumSectionCard(
          eyebrow: eyebrow,
          title: title,
          summary: summary,
          emphasis: true,
          children: <Widget>[
            if (showRouteMeta)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  ForumInfoPill(label: scopeLabel, highlighted: true),
                  ForumInfoPill(label: routeLabel),
                ],
              ),
            if (heroActions.isNotEmpty) ...<Widget>[
              SizedBox(height: showRouteMeta ? 16 : 4),
              Wrap(spacing: 12, runSpacing: 12, children: heroActions),
            ],
          ],
        ),
        for (final Widget child in children) ...<Widget>[
          const SizedBox(height: 16),
          child,
        ],
      ],
    );
  }
}

class ForumSectionCard extends StatelessWidget {
  const ForumSectionCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.children,
    this.emphasis = false,
  });

  final String eyebrow;
  final String title;
  final String summary;
  final List<Widget> children;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasis
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ForumInfoPill(label: eyebrow, highlighted: emphasis),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            if (children.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              ..._withSpacing(children),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> items) {
    return <Widget>[
      for (var index = 0; index < items.length; index += 1) ...<Widget>[
        items[index],
        if (index < items.length - 1) const SizedBox(height: 12),
      ],
    ];
  }
}

class ForumInfoPill extends StatelessWidget {
  const ForumInfoPill({
    super.key,
    required this.label,
    this.highlighted = false,
  });

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

class ForumShortcutCard extends StatelessWidget {
  const ForumShortcutCard({
    super.key,
    required this.title,
    required this.summary,
    required this.actionLabel,
    this.onPressed,
  });

  final String title;
  final String summary;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class ForumPostPreviewCard extends StatelessWidget {
  const ForumPostPreviewCard({
    super.key,
    required this.title,
    required this.summary,
    required this.meta,
    this.footer,
  });

  final String title;
  final String summary;
  final String meta;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 10),
            Text(
              meta,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (footer != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                footer!,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ForumPlaceholderField extends StatelessWidget {
  const ForumPlaceholderField({
    super.key,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14, 14, 14, multiline ? 52 : 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }
}
