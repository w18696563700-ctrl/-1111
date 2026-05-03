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
      _WorkbenchGroupData(
        key: 'deal_confirmation',
        title: '中间方成交确认',
        summary: '合同确认、最终成交金额',
        entries: view.entries
            .where((entry) => entry.group == 'deal_confirmation')
            .toList(growable: false),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 360;
        final buttonWidth = twoColumns
            ? (constraints.maxWidth - 8) / 2
            : constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '资料入口',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final group in groups)
                  SizedBox(
                    width: group.key == 'deal_confirmation' && twoColumns
                        ? constraints.maxWidth
                        : buttonWidth,
                    child: _WorkbenchGroupButton(
                      data: group,
                      onPressed: () => _openGroupSheet(context, group),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _openGroupSheet(BuildContext context, _WorkbenchGroupData data) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _WorkbenchGroupSheet(
        data: data,
        onOpenEntry: (entry) {
          Navigator.of(sheetContext).pop();
          widget.onOpenEntry(entry);
        },
      ),
    );
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

class _WorkbenchGroupButton extends StatelessWidget {
  const _WorkbenchGroupButton({required this.data, required this.onPressed});

  final _WorkbenchGroupData data;
  final VoidCallback onPressed;

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
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
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
                    const SizedBox(width: 6),
                    Text(
                      '查看',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _groupIcon(String key) {
    return switch (key) {
      'publisher_materials' => Icons.article_outlined,
      'bid_materials' => Icons.assignment_outlined,
      'deal_confirmation' => Icons.workspace_premium_outlined,
      _ => Icons.assignment_turned_in_outlined,
    };
  }
}

class _WorkbenchGroupSheet extends StatelessWidget {
  const _WorkbenchGroupSheet({required this.data, required this.onOpenEntry});

  final _WorkbenchGroupData data;
  final ValueChanged<ProjectCommunicationWorkbenchEntryView> onOpenEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _groupStatus(data.entries);
    final style = _workbenchStatusStyle(theme, status);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(_groupIcon(data.key), color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 14),
            Flexible(
              child: data.entries.isEmpty
                  ? const _WorkbenchSheetEmptyState()
                  : SingleChildScrollView(
                      child: _WorkbenchGroupTiles(
                        entries: data.entries,
                        onOpenEntry: onOpenEntry,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _groupIcon(String key) {
    return switch (key) {
      'publisher_materials' => Icons.article_outlined,
      'bid_materials' => Icons.assignment_outlined,
      'deal_confirmation' => Icons.workspace_premium_outlined,
      _ => Icons.assignment_turned_in_outlined,
    };
  }
}

class _WorkbenchSheetEmptyState extends StatelessWidget {
  const _WorkbenchSheetEmptyState();

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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.info_outline_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '当前分组暂无可展示资料',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
        final twoColumns = constraints.maxWidth >= 520;
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
    return entry.entryKey == 'publisher_equipment_material_list_review' ||
        entry.entryKey == 'final_confirmed_amount_confirmation';
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
              Icon(_icon(entry), color: style.foreground),
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
      'contract_confirmation' => Icons.description_outlined,
      'final_confirmed_amount_confirmation' => Icons.price_check_outlined,
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
