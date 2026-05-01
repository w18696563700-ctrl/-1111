part of '../exhibition_trade_pages.dart';

class _MyProjectStageHint extends StatelessWidget {
  const _MyProjectStageHint({
    required this.label,
    required this.count,
    required this.body,
  });

  final String label;
  final int count;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Icon(
            Icons.circle,
            size: 7,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label · $count 个。$body',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _MyProjectSectionCountLine extends StatelessWidget {
  const _MyProjectSectionCountLine({
    required this.count,
    required this.stageLabel,
  });

  final int count;
  final String stageLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      '当前展示 $stageLabel，共 $count 个项目',
      style: theme.textTheme.labelLarge?.copyWith(
        color: AppVisualTokens.brandGoldDark,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

String _myProjectStageSectionTitle(_MyProjectStageBucket stage) {
  return switch (stage) {
    _MyProjectStageBucket.all => '全部项目',
    _MyProjectStageBucket.draft => '草稿列表',
    _MyProjectStageBucket.submitted => '预发布项目',
    _MyProjectStageBucket.archived => '已归档列表',
    _ => _myProjectStageOption(stage).label,
  };
}

String _myProjectStageSectionSummary(_MyProjectStageBucket stage) {
  return switch (stage) {
    _MyProjectStageBucket.all => '按当前项目真实阶段聚合展示，切换上方标签可查看单阶段。',
    _MyProjectStageBucket.submitted => '项目已进入发布前核对阶段，补齐资料后可确认发布。',
    _ => _myProjectStageShortDescription(stage),
  };
}

String _myProjectStageShortDescription(_MyProjectStageBucket stage) {
  return switch (stage) {
    _MyProjectStageBucket.all => '切换标签可查看各阶段。',
    _MyProjectStageBucket.draft => '未完成项目收在低频入口。',
    _MyProjectStageBucket.submitted => '补齐资料后可确认发布。',
    _MyProjectStageBucket.published => '项目正在公域竞标。',
    _MyProjectStageBucket.active => '进入授标、订单或履约承接。',
    _MyProjectStageBucket.archived => '历史项目只读查看。',
  };
}

String _myProjectStageListNextStep(_MyProjectStageBucket stage) {
  return switch (stage) {
    _MyProjectStageBucket.all => '按项目当前阶段处理',
    _MyProjectStageBucket.draft => '继续编辑项目资料',
    _MyProjectStageBucket.submitted => '补齐资料后在详情页确认发布',
    _MyProjectStageBucket.published => '查看详情，必要时补充资料',
    _MyProjectStageBucket.active => '进入详情查看履约承接',
    _MyProjectStageBucket.archived => '只读查看历史项目',
  };
}

class _MyProjectSecondaryStageEntrances extends StatelessWidget {
  const _MyProjectSecondaryStageEntrances({
    required this.draftCount,
    required this.archivedCount,
    required this.selectedStage,
    required this.onSelected,
  });

  final int draftCount;
  final int archivedCount;
  final _MyProjectStageBucket selectedStage;
  final ValueChanged<_MyProjectStageBucket> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '低频入口',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _MyProjectSecondaryStageTile(
          label: '草稿',
          count: draftCount,
          summary: '未完成项目先收起，需要继续编辑或删除时再进入。',
          selected: selectedStage == _MyProjectStageBucket.draft,
          onPressed: () => onSelected(_MyProjectStageBucket.draft),
        ),
        const SizedBox(height: 10),
        _MyProjectSecondaryStageTile(
          label: '已归档',
          count: archivedCount,
          summary: '历史项目只保留查看入口，不开放删除。',
          selected: selectedStage == _MyProjectStageBucket.archived,
          onPressed: () => onSelected(_MyProjectStageBucket.archived),
        ),
      ],
    );
  }
}

class _MyProjectSecondaryStageTile extends StatelessWidget {
  const _MyProjectSecondaryStageTile({
    required this.label,
    required this.count,
    required this.summary,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final int count;
  final String summary;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = selected
        ? colorScheme.primary.withValues(alpha: 0.38)
        : colorScheme.outlineVariant;
    final backgroundColor = selected
        ? colorScheme.primaryContainer.withValues(alpha: 0.42)
        : colorScheme.surface;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '$label · $count 个',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: selected ? colorScheme.primary : colorScheme.outline,
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
