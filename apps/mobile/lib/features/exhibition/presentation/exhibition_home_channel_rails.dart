part of 'exhibition_home_page.dart';

class _HomeChannelAction {
  const _HomeChannelAction({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
}

class _HomeChannelActionRail extends StatelessWidget {
  const _HomeChannelActionRail({required this.actions});

  final List<_HomeChannelAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pillShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: actions
          .map((action) {
            if (action.primary) {
              return OutlinedButton(
                onPressed: action.onPressed,
                style: OutlinedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer.withValues(
                    alpha: 0.64,
                  ),
                  foregroundColor: colorScheme.onPrimaryContainer,
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: pillShape,
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(action.label),
              );
            }
            return TextButton(
              onPressed: action.onPressed,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                shape: pillShape,
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(action.label),
            );
          })
          .toList(growable: false),
    );
  }
}

class _HomeChannelFilterOption<T> {
  const _HomeChannelFilterOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _HomeChannelFilterRail<T> extends StatelessWidget {
  const _HomeChannelFilterRail({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<_HomeChannelFilterOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: options
            .map((option) {
              final selected = option.value == selectedValue;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => onSelected(option.value),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? colorScheme.primaryContainer.withValues(
                                alpha: 0.72,
                              )
                            : colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? colorScheme.primary.withValues(alpha: 0.14)
                              : colorScheme.outlineVariant.withValues(
                                  alpha: 0.42,
                                ),
                        ),
                      ),
                      child: Text(
                        option.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: selected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
