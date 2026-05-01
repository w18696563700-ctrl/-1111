part of 'forum_pages.dart';

class _ForumActionableCard extends StatelessWidget {
  const _ForumActionableCard({
    required this.title,
    required this.summary,
    required this.meta,
    required this.actions,
    this.footer,
  });

  final String title;
  final String summary;
  final String meta;
  final String? footer;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      withShadow: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextTokens.cardTitle,
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextTokens.body.copyWith(
              color: AppVisualTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _metaChips(meta)),
          if (footer != null && footer!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(footer!, style: AppTextTokens.caption),
          ],
          if (actions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }

  List<Widget> _metaChips(String value) {
    return value
        .split('|')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .map((String item) => AppInfoChip(label: item))
        .toList(growable: false);
  }
}

class _ForumDangerButton extends StatelessWidget {
  const _ForumDangerButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, AppVisualTokens.primaryButtonHeight),
        foregroundColor: const Color(0xFFA13B34),
        backgroundColor: AppVisualTokens.dangerSoft,
        side: const BorderSide(color: Color(0xFFEBC2BD)),
        shape: RoundedRectangleBorder(
          borderRadius: AppVisualTokens.radiusPillBorder,
        ),
        textStyle: AppTextTokens.buttonText,
      ),
      child: child,
    );
  }
}
