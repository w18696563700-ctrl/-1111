part of '../exhibition_trade_pages.dart';

class _ProjectShowcaseCompactCard extends StatelessWidget {
  const _ProjectShowcaseCompactCard({
    required this.item,
    required this.onPressed,
  });

  final Map<String, Object?> item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final title = _projectDisplayTitle(item);
    final brandName = _projectDisplayBrandLine(item);
    final location = _projectPrimaryLocationText(item);
    final dateRange = _projectDateRangeLabel(item) ?? '当前项目暂未提供';
    final status = _stateFromPayload(item);
    final projectNo = _normalizeId(item['projectNo'] as String?) ?? '未提供';
    final shouldShowNameAccessBadge = _projectShouldShowNameAccessControls(
      item,
    );
    final nameAccessStatus = _projectNameAccessStatus(item);

    return Semantics(
      button: true,
      label: '查看$title详情',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: AppCard(
            radius: AppVisualTokens.radiusXLarge,
            withShadow: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTokens.sectionTitle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: <Widget>[
                          if (shouldShowNameAccessBadge)
                            AppStatusBadge(
                              label: _projectNameAccessStatusLabel(
                                nameAccessStatus,
                              ),
                              tone: _projectNameAccessBadgeTone(
                                nameAccessStatus,
                              ),
                            ),
                          if (status != null)
                            AppStatusBadge(
                              label: _frontStageStateLabel(status),
                              tone: AppStatusTone.warning,
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (brandName != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      brandName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTokens.body,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: AppVisualTokens.chipGap,
                    runSpacing: AppVisualTokens.chipGap,
                    children: <Widget>[
                      _CompactProjectMeta(label: '项目编号', value: projectNo),
                      _CompactProjectMeta(
                        label: '预算',
                        value: _currencyText(item['budgetAmount']),
                        highlight: true,
                      ),
                      _CompactProjectMeta(
                        label: '面积',
                        value: _projectAreaText(item['areaSqm'] as num?),
                      ),
                      _CompactProjectMeta(label: '搭建地', value: location),
                      _CompactProjectMeta(label: '时间', value: dateRange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

AppStatusTone _projectNameAccessBadgeTone(String? status) {
  return switch (status) {
    'pending' => AppStatusTone.warning,
    'rejected' => AppStatusTone.danger,
    'requestable' => AppStatusTone.brand,
    'visible' => AppStatusTone.success,
    _ => AppStatusTone.neutral,
  };
}

class _CompactProjectMeta extends StatelessWidget {
  const _CompactProjectMeta({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 122, maxWidth: 220),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: highlight
              ? AppVisualTokens.brandGoldLight
              : const Color(0xFFF8F7F5),
          borderRadius: AppVisualTokens.radiusPillBorder,
          border: Border.all(color: AppVisualTokens.borderSoft),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: '$label：',
                  style: AppTextTokens.badgeText.copyWith(
                    color: highlight
                        ? AppVisualTokens.brandGoldDark
                        : AppVisualTokens.textSecondary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppTextTokens.badgeText.copyWith(
                    color: AppVisualTokens.textPrimary,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
