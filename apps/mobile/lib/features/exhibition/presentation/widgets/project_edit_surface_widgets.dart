part of '../exhibition_trade_pages.dart';

final Map<String, ValueNotifier<String?>> _projectEditHeaderStatusNotifiers =
    <String, ValueNotifier<String?>>{};

ValueNotifier<String?> _projectEditHeaderStatusNotifierFor(String projectId) {
  return _projectEditHeaderStatusNotifiers.putIfAbsent(
    projectId,
    () => ValueNotifier<String?>(null),
  );
}

void _publishProjectEditHeaderStatus(String? projectId, String? state) {
  final normalizedProjectId = _normalizeId(projectId);
  if (normalizedProjectId == null) {
    return;
  }
  _projectEditHeaderStatusNotifierFor(normalizedProjectId).value = _normalizeId(
    state,
  );
}

class ProjectEditStatusAppBarAction extends StatelessWidget {
  const ProjectEditStatusAppBarAction({super.key, required this.projectId});

  final String? projectId;

  @override
  Widget build(BuildContext context) {
    final normalizedProjectId = _normalizeId(projectId);
    if (normalizedProjectId == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ValueListenableBuilder<String?>(
      valueListenable: _projectEditHeaderStatusNotifierFor(normalizedProjectId),
      builder: (BuildContext context, String? value, Widget? child) {
        if (value == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: DecoratedBox(
              key: ValueKey<String>('project-edit-app-bar-status-$value'),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  _projectEditHeaderStatusLabel(value),
                  key: const ValueKey<String>('project-edit-app-bar-status'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProjectEditHeaderTitle extends StatelessWidget {
  const ProjectEditHeaderTitle({super.key, required this.projectId});

  final String? projectId;

  @override
  Widget build(BuildContext context) {
    final normalizedProjectId = _normalizeId(projectId);
    if (normalizedProjectId == null) {
      return const Text('编辑项目');
    }

    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = DefaultTextStyle.of(context).style;
    return ValueListenableBuilder<String?>(
      valueListenable: _projectEditHeaderStatusNotifierFor(normalizedProjectId),
      builder: (BuildContext context, String? value, Widget? child) {
        final label = value == null
            ? null
            : _projectEditHeaderStatusLabel(value);
        return Row(
          children: <Widget>[
            Text('编辑项目', style: titleStyle),
            if (label != null) ...<Widget>[
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  key: const ValueKey<String>('project-edit-app-bar-status'),
                  style: titleStyle.copyWith(
                    color: colorScheme.error,
                    fontWeight: titleStyle.fontWeight ?? FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

String _projectEditHeaderStatusLabel(String state) {
  return switch (state) {
    'draft' => '草稿 -> 预发布列表',
    _ => _frontStageStateLabel(state),
  };
}

class MyProjectDetailHeaderTitle extends StatelessWidget {
  const MyProjectDetailHeaderTitle({super.key, required this.projectId});

  final String? projectId;

  @override
  Widget build(BuildContext context) {
    final normalizedProjectId = _normalizeId(projectId);
    if (normalizedProjectId == null) {
      return const Text('我的项目详情');
    }

    final theme = Theme.of(context);
    final titleStyle = DefaultTextStyle.of(context).style;
    return ValueListenableBuilder<String?>(
      valueListenable: _projectEditHeaderStatusNotifierFor(normalizedProjectId),
      builder: (BuildContext context, String? value, Widget? child) {
        final stageTitle = switch (value) {
          'submitted' => '（预发布补资料并发布页）',
          'published' => '（已发布页）',
          _ => null,
        };
        if (stageTitle == null) {
          return Text('我的项目详情', style: titleStyle);
        }

        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              text: '我的项目详情',
              children: <InlineSpan>[
                TextSpan(
                  text: stageTitle,
                  style: titleStyle.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: titleStyle.fontWeight ?? FontWeight.w700,
                  ),
                ),
              ],
            ),
            key: const ValueKey<String>(
              'my-project-detail-stage-app-bar-title',
            ),
            maxLines: 1,
            style: titleStyle,
          ),
        );
      },
    );
  }
}

class _ProjectEditReviewSectionCard extends StatelessWidget {
  const _ProjectEditReviewSectionCard({
    required this.expanded,
    required this.summary,
    required this.titleBrandLabel,
    required this.locationScheduleLabel,
    required this.budgetAreaLabel,
    required this.onToggle,
  });

  final bool expanded;
  final String summary;
  final String titleBrandLabel;
  final String locationScheduleLabel;
  final String budgetAreaLabel;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      title: '当前内容核对',
      summary: summary,
      children: <Widget>[
        _DetailLine(label: '展会 / 品牌', value: titleBrandLabel),
        _DetailLine(label: '地点 / 时间', value: locationScheduleLabel),
        _DetailLine(label: '预算 / 面积', value: budgetAreaLabel),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            key: const ValueKey<String>('project-edit-review-toggle'),
            onPressed: onToggle,
            icon: Icon(
              expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            ),
            label: Text(expanded ? '收起当前内容核对' : '展开当前内容核对'),
          ),
        ),
      ],
    );
  }
}
