part of '../exhibition_trade_pages.dart';

class _ProjectDetailCompactMetaItemData {
  const _ProjectDetailCompactMetaItemData({
    required this.label,
    required this.value,
    this.highlight = false,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool highlight;
  final bool fullWidth;
}

class _ProjectDetailCompactMetaGrid extends StatelessWidget {
  const _ProjectDetailCompactMetaGrid({required this.items});

  final List<_ProjectDetailCompactMetaItemData> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const spacing = 12.0;
        final twoColumns = constraints.maxWidth >= 360;
        final itemWidth = twoColumns
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (_ProjectDetailCompactMetaItemData item) => SizedBox(
                  width: item.fullWidth ? constraints.maxWidth : itemWidth,
                  child: _ProjectDetailCompactMetaItem(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ProjectDetailCompactMetaItem extends StatelessWidget {
  const _ProjectDetailCompactMetaItem({required this.item});

  final _ProjectDetailCompactMetaItemData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: '${item.label}：',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          TextSpan(
            text: item.value,
            style:
                (item.highlight
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.bodyLarge)
                    ?.copyWith(
                      fontWeight: item.highlight
                          ? FontWeight.w800
                          : FontWeight.w600,
                      height: 1.35,
                    ),
          ),
        ],
      ),
    );
  }
}
