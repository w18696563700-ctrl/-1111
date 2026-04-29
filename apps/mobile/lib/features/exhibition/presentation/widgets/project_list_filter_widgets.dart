part of '../exhibition_trade_pages.dart';

class _ProjectFilterFieldButton extends StatelessWidget {
  const _ProjectFilterFieldButton({
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final display = value?.trim().isNotEmpty == true
        ? value!.trim()
        : placeholder;
    final isSelected = value?.trim().isNotEmpty == true;

    return InkWell(
      onTap: onTap,
      borderRadius: AppVisualTokens.radiusMediumBorder,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppVisualTokens.cardBackground,
          borderRadius: AppVisualTokens.radiusMediumBorder,
          border: Border.all(
            color: isSelected
                ? AppVisualTokens.brandGold.withValues(alpha: 0.24)
                : AppVisualTokens.borderSoft,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextTokens.caption.copyWith(
                  color: AppVisualTokens.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTokens.bodyStrong.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppVisualTokens.textPrimary
                            : AppVisualTokens.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppVisualTokens.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectFilterSummaryChip extends StatelessWidget {
  const _ProjectFilterSummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppInfoChip(label: label, value: value);
  }
}
