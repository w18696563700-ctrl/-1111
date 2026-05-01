part of '../exhibition_trade_pages.dart';

Widget _buildMyProjectWorkspaceTabsCard({
  required _MyProjectWorkspaceBucket selectedWorkspace,
  required ValueChanged<_MyProjectWorkspaceBucket> onSelected,
}) {
  final current = _myProjectWorkspaceOption(selectedWorkspace);

  return Builder(
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '项目分类',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: _myProjectWorkspaceOptions.map((
                    _MyProjectWorkspaceOption option,
                  ) {
                    return Expanded(
                      child: _MyProjectWorkspaceSegmentButton(
                        option: option,
                        selected: option.value == selectedWorkspace,
                        onPressed: () => onSelected(option.value),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                current.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MyProjectWorkspaceSegmentButton extends StatelessWidget {
  const _MyProjectWorkspaceSegmentButton({
    required this.option,
    required this.selected,
    required this.onPressed,
  });

  final _MyProjectWorkspaceOption option;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: selected ? AppVisualTokens.brandGoldLight : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (selected) ...<Widget>[
                  const Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: AppVisualTokens.brandGoldDark,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppVisualTokens.brandGoldDark
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
