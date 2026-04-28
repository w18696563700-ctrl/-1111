part of 'exhibition_home_page.dart';

class _HomeChannelAction {
  const _HomeChannelAction({
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final IconData? icon;
}

class _HomeChannelActionRail extends StatelessWidget {
  const _HomeChannelActionRail({required this.actions});

  final List<_HomeChannelAction> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pillShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: actions
            .map((action) {
              final Widget button;
              if (action.primary) {
                button = FilledButton.icon(
                  onPressed: action.onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: ExhibitionHomeVisualTokens.brandGoldLight,
                    foregroundColor: ExhibitionHomeVisualTokens.brandGoldDeep,
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    shape: pillShape,
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  icon: Icon(
                    action.icon ?? Icons.arrow_forward_rounded,
                    size: 17,
                  ),
                  label: Text(action.label),
                );
              } else {
                button = TextButton.icon(
                  onPressed: action.onPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: ExhibitionHomeVisualTokens.textSecondary,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    shape: pillShape,
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: Icon(action.icon ?? Icons.more_horiz_rounded, size: 17),
                  label: Text(action.label),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: button,
              );
            })
            .toList(growable: false),
      ),
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
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? ExhibitionHomeVisualTokens.brandGoldLight
                            : const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        option.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: selected
                              ? ExhibitionHomeVisualTokens.brandGoldDeep
                              : ExhibitionHomeVisualTokens.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w900
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
