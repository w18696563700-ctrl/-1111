part of 'exhibition_home_page.dart';

class _HomeProjectRecommendationSection extends StatelessWidget {
  const _HomeProjectRecommendationSection({
    required this.areaLabel,
    required this.loading,
    required this.result,
    required this.projectItems,
    required this.onRetry,
    required this.onOpenShowcase,
    required this.onOpenWorkbench,
    required this.onOpenProjectCreate,
    required this.onOpenProjectDetail,
  });

  final String areaLabel;
  final bool loading;
  final ExhibitionLoadResult? result;
  final List<Map<String, Object?>> projectItems;
  final VoidCallback onRetry;
  final VoidCallback onOpenShowcase;
  final VoidCallback onOpenWorkbench;
  final VoidCallback onOpenProjectCreate;
  final ValueChanged<String> onOpenProjectDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = result?.state;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                _HomePill(
                  label: _homeSectionTag(loading: loading, result: result),
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                _HomePill(
                  label: '1. 本省搭建项目',
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  foregroundColor: colorScheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$areaLabel项目推荐',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _homeSectionMessage(
                areaLabel: areaLabel,
                loading: loading,
                result: result,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 16),
            if (loading && result == null)
              const _HomeLoadingNotice()
            else if (state == AppPageState.content && projectItems.isNotEmpty)
              ..._buildProjectCards(context)
            else if (state == AppPageState.empty)
              _HomeStateNotice(
                title: '$areaLabel当前还没有公开项目',
                message: '可以先发布项目，或回到项目工作台继续当前私域进度。',
                actions: <Widget>[
                  FilledButton(
                    onPressed: onOpenProjectCreate,
                    child: const Text('去发布项目'),
                  ),
                  FilledButton.tonal(
                    onPressed: onOpenWorkbench,
                    child: const Text('回到项目工作台'),
                  ),
                ],
              )
            else
              _HomeStateNotice(
                title: _failureTitleForState(areaLabel, state),
                message: _failureMessageForState(state),
                actions: <Widget>[
                  FilledButton(onPressed: onRetry, child: const Text('重试整页刷新')),
                  FilledButton.tonal(
                    onPressed: onOpenShowcase,
                    child: const Text('查看项目展示'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: onOpenShowcase,
                  child: const Text('查看全部项目展示'),
                ),
                OutlinedButton(onPressed: onRetry, child: const Text('刷新首页')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProjectCards(BuildContext context) {
    return projectItems.take(3).map((Map<String, Object?> item) {
      final projectId = _homeTrimmedString(item['projectId']);
      final title = _homeTrimmedString(item['title']) ?? '未命名项目';
      final projectNo = _homeTrimmedString(item['projectNo']) ?? '未提供';
      final state = _homeTrimmedString(item['state']);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _HomeProjectCard(
          title: title,
          projectNo: projectNo,
          budgetLabel: _homeCurrencyText(item['budgetAmount']),
          stateLabel: _homeFrontStateLabel(state),
          summary: _homeProjectGuidance(state),
          actionLabel: _homeCanContinueBid(state) ? '进入项目详情' : '查看项目说明',
          onPressed: projectId == null
              ? null
              : () => onOpenProjectDetail(projectId),
        ),
      );
    }).toList();
  }

  String _failureTitleForState(String areaLabel, AppPageState? state) {
    return switch (state) {
      AppPageState.errorRetryable => '$areaLabel项目推荐暂时没有刷新成功',
      AppPageState.errorNonRetryable => '$areaLabel项目推荐当前不能继续承接',
      AppPageState.unauthorized => '$areaLabel项目推荐需要先恢复登录',
      AppPageState.forbidden => '$areaLabel项目推荐当前未开放',
      AppPageState.notFound => '$areaLabel项目推荐暂未稳定承接',
      _ => '$areaLabel项目推荐正在准备中',
    };
  }

  String _failureMessageForState(AppPageState? state) {
    return switch (state) {
      AppPageState.errorRetryable =>
        '当前不会用本地演示项目替代云端推荐。你可以先重试；如仍未恢复，再去项目展示页查看当前已接通内容。',
      AppPageState.errorNonRetryable => '当前保持受控失败态，不会伪装成只是“还没写完”。',
      AppPageState.unauthorized => '当前页需要先恢复登录或授权状态，页面不会继续假装可进入。',
      AppPageState.forbidden => '当前页明确告诉你“现在不能做什么”，避免把未开放内容伪装成没做完。',
      AppPageState.notFound => '当前实例还没有稳定承接到这一页，所以页面先停在受控状态。',
      _ => '当前推荐区还在准备中。',
    };
  }
}

class _HomePlaceholderRecommendationSection extends StatelessWidget {
  const _HomePlaceholderRecommendationSection({
    required this.title,
    required this.summary,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String summary;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
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
            const SizedBox(height: 14),
            FilledButton.tonal(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _HomeBoundaryNoteCard extends StatelessWidget {
  const _HomeBoundaryNoteCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '合同、履约、验收、评价和争议继续保留在正式链路页面里；首页现在改成天气卡壳层、六模块入口、本省推荐和私域导流的干净首页。',
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.45,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
