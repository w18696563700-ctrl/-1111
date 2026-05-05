part of '../exhibition_trade_pages.dart';

class _ProjectCommunicationWorkbenchSection extends StatefulWidget {
  const _ProjectCommunicationWorkbenchSection({
    required this.loading,
    required this.result,
    required this.onOpenEntry,
  });

  final bool loading;
  final CounterpartConversationResult<ProjectCommunicationWorkbenchView>?
  result;
  final ValueChanged<ProjectCommunicationWorkbenchEntryView> onOpenEntry;

  @override
  State<_ProjectCommunicationWorkbenchSection> createState() =>
      _ProjectCommunicationWorkbenchSectionState();
}

class _ProjectCommunicationWorkbenchSectionState
    extends State<_ProjectCommunicationWorkbenchSection> {
  final Set<String> _expandedGroupKeys = <String>{};

  @override
  Widget build(BuildContext context) {
    final view = widget.result?.data;
    if (widget.loading || view == null) {
      return _WorkbenchUnavailableBox(
        loading: widget.loading,
        message: widget.result?.message ?? '工作台状态暂不可读',
      );
    }
    final groups = <_WorkbenchGroupData>[
      _WorkbenchGroupData(
        key: 'publisher_materials',
        title: '发布方资料',
        summary: '效果图、尺寸图 / 施工图、材质图 / 材料样板、设备物料、服务清单',
        entries: view.entries
            .where((entry) => entry.group == 'publisher_materials')
            .toList(growable: false),
      ),
      _WorkbenchGroupData(
        key: 'bid_materials',
        title: '竞标资料',
        summary: '项目理解、报价表、进度安排',
        entries: view.entries
            .where((entry) => entry.group == 'bid_materials')
            .toList(growable: false),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < groups.length; index += 1) ...<Widget>[
          if (index > 0) const SizedBox(height: 8),
          _WorkbenchGroup(
            data: groups[index],
            expanded: _expandedGroupKeys.contains(groups[index].key),
            onToggle: () => _toggleGroup(groups[index].key),
            onOpenEntry: widget.onOpenEntry,
          ),
        ],
      ],
    );
  }

  void _toggleGroup(String key) {
    setState(() {
      if (!_expandedGroupKeys.add(key)) {
        _expandedGroupKeys.remove(key);
      }
    });
  }
}

class _WorkbenchUnavailableBox extends StatelessWidget {
  const _WorkbenchUnavailableBox({
    required this.loading,
    required this.message,
  });

  final bool loading;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            if (loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            else
              Icon(Icons.info_outline_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: loading
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkbenchGroup extends StatelessWidget {
  const _WorkbenchGroup({
    required this.data,
    required this.expanded,
    required this.onToggle,
    required this.onOpenEntry,
  });

  final _WorkbenchGroupData data;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<ProjectCommunicationWorkbenchEntryView> onOpenEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _groupStatus(data.entries);
    final style = _workbenchStatusStyle(theme, status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      _groupIcon(data.key),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  data.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _MaterialConfirmationStatusPill(
                                label: _groupStatusLabel(data.entries, status),
                                foreground: style.pillForeground,
                                background: style.pillBackground,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            data.summary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      expanded ? '收起' : '展开',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded) ...<Widget>[
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(10),
              child: _WorkbenchGroupTiles(
                entries: data.entries,
                onOpenEntry: onOpenEntry,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _groupIcon(String key) {
    return switch (key) {
      'publisher_materials' => Icons.article_outlined,
      'bid_materials' => Icons.assignment_outlined,
      _ => Icons.assignment_turned_in_outlined,
    };
  }
}

class _WorkbenchGroupTiles extends StatelessWidget {
  const _WorkbenchGroupTiles({
    required this.entries,
    required this.onOpenEntry,
  });

  final List<ProjectCommunicationWorkbenchEntryView> entries;
  final ValueChanged<ProjectCommunicationWorkbenchEntryView> onOpenEntry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 340;
        final tileWidth = twoColumns
            ? (constraints.maxWidth - 8) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final entry in entries)
              SizedBox(
                width: _wideEntry(entry) && twoColumns
                    ? constraints.maxWidth
                    : tileWidth,
                child: _WorkbenchEntryTile(
                  entry: entry,
                  onTap: () => onOpenEntry(entry),
                ),
              ),
          ],
        );
      },
    );
  }

  bool _wideEntry(ProjectCommunicationWorkbenchEntryView entry) {
    return entry.entryKey == 'publisher_equipment_material_list_review';
  }
}

class _WorkbenchEntryTile extends StatelessWidget {
  const _WorkbenchEntryTile({required this.entry, required this.onTap});

  final ProjectCommunicationWorkbenchEntryView entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _style(theme, entry);
    return Material(
      color: style.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: style.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Icon(_icon(entry), color: style.foreground),
                  if (entry.badgeCount > 0)
                    Positioned(
                      right: -7,
                      top: -7,
                      child: _BusinessTodoBadge(
                        count: entry.badgeCount,
                        compact: true,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: style.foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _MaterialConfirmationStatusPill(
                label: _statusLabel(entry),
                foreground: style.pillForeground,
                background: style.pillBackground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(ProjectCommunicationWorkbenchEntryView entry) {
    return switch (entry.entryKey) {
      'publisher_effect_image_review' => Icons.image_outlined,
      'publisher_construction_doc_review' => Icons.straighten_outlined,
      'publisher_material_sample_review' => Icons.texture_outlined,
      'publisher_equipment_material_list_review' => Icons.inventory_2_outlined,
      'publisher_service_list_review' => Icons.fact_check_outlined,
      'bid_project_understanding_review' => Icons.psychology_outlined,
      'bid_quote_sheet_review' => Icons.receipt_long_outlined,
      'bid_schedule_plan_review' => Icons.event_note_outlined,
      _ => Icons.assignment_outlined,
    };
  }

  String _statusLabel(ProjectCommunicationWorkbenchEntryView entry) {
    return switch (entry.reviewState ?? entry.availabilityState) {
      'unsubmitted' => '未提交',
      'pending_review' => '待确认',
      'confirmed' => '已确认',
      'needs_supplement' => '需补充',
      _ => '暂不可读',
    };
  }

  _ProjectMaterialConfirmationTileStyle _style(
    ThemeData theme,
    ProjectCommunicationWorkbenchEntryView entry,
  ) {
    return _workbenchStatusStyle(theme, _workbenchEntryState(entry));
  }
}

bool _isMaterialWorkbenchEntry(ProjectCommunicationWorkbenchEntryView entry) {
  return entry.group == 'publisher_materials' || entry.group == 'bid_materials';
}

bool _isDealWorkbenchEntry(ProjectCommunicationWorkbenchEntryView entry) {
  return entry.group == 'deal_confirmation';
}
