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
                  _frontStageStateLabel(value),
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
