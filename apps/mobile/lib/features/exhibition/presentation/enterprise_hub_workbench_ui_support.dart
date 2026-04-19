part of 'enterprise_hub_workbench_pages.dart';

class _ReadonlyTruthField extends StatelessWidget {
  const _ReadonlyTruthField({
    super.key,
    required this.label,
    required this.sourceLabel,
    required this.placeholder,
    this.value,
    this.helperText,
  });

  final String label;
  final String sourceLabel;
  final String placeholder;
  final String? value;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasValue = value?.trim().isNotEmpty == true;
    final display = hasValue ? value!.trim() : placeholder;
    final displayStyle = hasValue
        ? theme.textTheme.bodyLarge
        : theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        sourceLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(display, style: displayStyle),
                ],
              ),
            ),
          ),
        ),
        if (helperText != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

enum _SectionNoticeTone { info, warning, neutral }

class _SectionNotice extends StatelessWidget {
  const _SectionNotice({
    super.key,
    required this.title,
    required this.lines,
    this.tone = _SectionNoticeTone.info,
    this.action,
  });

  final String title;
  final List<String> lines;
  final _SectionNoticeTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (backgroundColor, textColor) = switch (tone) {
      _SectionNoticeTone.info => (
        colorScheme.primaryContainer.withValues(alpha: 0.42),
        colorScheme.onPrimaryContainer,
      ),
      _SectionNoticeTone.warning => (
        colorScheme.errorContainer.withValues(alpha: 0.42),
        colorScheme.onErrorContainer,
      ),
      _SectionNoticeTone.neutral => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurface,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $line',
                style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              ),
            ),
          ),
          if (action != null) ...<Widget>[const SizedBox(height: 4), action!],
        ],
      ),
    );
  }
}
