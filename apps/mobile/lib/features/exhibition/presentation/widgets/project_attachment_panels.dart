part of '../exhibition_trade_pages.dart';

class _SelectedProjectAttachmentCard extends StatelessWidget {
  const _SelectedProjectAttachmentCard({
    required this.draft,
    required this.attachmentKind,
    required this.onPreview,
    required this.onOpen,
    this.previewing = false,
    this.onRemove,
  });

  final _ResolvedProjectAttachmentDraft draft;
  final String attachmentKind;
  final VoidCallback? onPreview;
  final VoidCallback? onOpen;
  final bool previewing;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final previewTooltip = _projectAttachmentCanOpenLocally(draft.mimeType)
        ? _projectAttachmentDraftPreviewButtonLabel(draft.mimeType)
        : '可尝试预览，无法预览时请使用打开';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _ProjectAttachmentFileTypeIcon(extension: draft.extension),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    draft.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${_projectAttachmentFileTypeLabel(draft.extension)} · '
                          '${_projectAttachmentSizeLabel(draft.sizeInBytes)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _TinyStatusPill(
                        label: '待确认',
                        color: AppVisualTokens.brandGold,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Tooltip(
              message: previewTooltip,
              child: IconButton(
                key: ValueKey<String>(
                  'project-attachment-draft-preview-$attachmentKind-${draft.fileName}',
                ),
                onPressed: previewing ? null : onPreview,
                icon: previewing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.visibility_outlined),
                tooltip: '预览',
              ),
            ),
            IconButton(
              key: ValueKey<String>(
                'project-attachment-draft-open-$attachmentKind-${draft.fileName}',
              ),
              onPressed: previewing ? null : onOpen,
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: '打开',
            ),
            IconButton(
              key: ValueKey<String>(
                'project-attachment-draft-remove-$attachmentKind-${draft.fileName}',
              ),
              onPressed: previewing ? null : onRemove,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: '移除',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectAttachmentFileTypeIcon extends StatelessWidget {
  const _ProjectAttachmentFileTypeIcon({required this.extension});

  final String extension;

  @override
  Widget build(BuildContext context) {
    final normalized = extension.toLowerCase();
    final color = switch (normalized) {
      'png' || 'jpg' || 'jpeg' || 'webp' || 'gif' => const Color(0xFF2E7D32),
      'pdf' => const Color(0xFFE53935),
      'doc' || 'docx' => const Color(0xFF1976D2),
      'xls' || 'xlsx' || 'csv' => const Color(0xFF2E7D32),
      _ => AppVisualTokens.brandGold,
    };
    final icon = switch (normalized) {
      'png' || 'jpg' || 'jpeg' || 'webp' || 'gif' => Icons.image_outlined,
      'pdf' => Icons.picture_as_pdf_outlined,
      'doc' || 'docx' => Icons.article_outlined,
      'xls' || 'xlsx' || 'csv' => Icons.table_chart_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
    final label = normalized.isEmpty ? 'FILE' : normalized.toUpperCase();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 42,
        height: 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 1),
            Text(
              label.length > 4 ? label.substring(0, 4) : label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectAttachmentFilterPill extends StatelessWidget {
  const _ProjectAttachmentFilterPill({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AppVisualTokens.brandGold : colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppVisualTokens.brandGold
                : colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? Colors.white : colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectAttachmentAutoUploadNotice extends StatelessWidget {
  const _ProjectAttachmentAutoUploadNotice();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.brandGold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.lightbulb_outline_rounded,
              color: AppVisualTokens.brandGold,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '选择文件后将自动上传，上传成功后可删除或重新上传。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectAttachmentCompactRecordRow extends StatelessWidget {
  const _ProjectAttachmentCompactRecordRow({
    required this.attachment,
    required this.openingPreview,
    required this.deleting,
    required this.onPreview,
    required this.onOpen,
    required this.onDelete,
  });

  final ProjectAttachmentReadModel attachment;
  final bool openingPreview;
  final bool deleting;
  final VoidCallback? onPreview;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final extension = _projectAttachmentExtension(attachment.fileName) ?? '';
    final meta = <String>[
      _projectAttachmentMimeTypeLabel(attachment.mimeType),
      _projectAttachmentTimestampLabel(attachment.createdAt),
      '已确认',
    ].join(' · ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final compactActions = constraints.maxWidth < 330;
            return Row(
              children: <Widget>[
                _ProjectAttachmentFileTypeIcon(extension: extension),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        attachment.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  key: ValueKey<String>(
                    'project-attachment-preview-${attachment.attachmentId}',
                  ),
                  onPressed: openingPreview || deleting ? null : onPreview,
                  icon: openingPreview
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.visibility_outlined),
                  tooltip: _projectAttachmentRecordPreviewButtonLabel(
                    attachment.mimeType,
                  ),
                ),
                if (!compactActions)
                  IconButton(
                    key: ValueKey<String>(
                      'project-attachment-open-${attachment.attachmentId}',
                    ),
                    onPressed: openingPreview || deleting ? null : onOpen,
                    icon: const Icon(Icons.open_in_new_rounded),
                    tooltip: '打开',
                  ),
                if (!compactActions)
                  IconButton(
                    key: ValueKey<String>(
                      'project-attachment-delete-${attachment.attachmentId}',
                    ),
                    onPressed: openingPreview || deleting ? null : onDelete,
                    icon: deleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline_rounded),
                    tooltip: '删除当前资料',
                  ),
                IconButton(
                  key: ValueKey<String>(
                    'project-attachment-more-${attachment.attachmentId}',
                  ),
                  onPressed: deleting
                      ? null
                      : () => _showProjectAttachmentMoreSheet(
                          context,
                          attachment: attachment,
                          onPreview: onPreview,
                          onOpen: onOpen,
                          onDelete: onDelete,
                        ),
                  icon: const Icon(Icons.more_horiz_rounded),
                  tooltip: '更多',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void _showProjectAttachmentMoreSheet(
  BuildContext context, {
  required ProjectAttachmentReadModel attachment,
  required VoidCallback? onPreview,
  required VoidCallback? onOpen,
  required VoidCallback? onDelete,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  attachment.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: onPreview == null
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              onPreview();
                            },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('预览'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onOpen == null
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              onOpen();
                            },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('打开'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onDelete == null
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              onDelete();
                            },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('删除当前资料'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DetailLine(label: '完整文件名', value: attachment.fileName),
                _DetailLine(label: 'FileAsset', value: attachment.fileAssetId),
                _DetailLine(label: '文件类型', value: attachment.mimeType),
                _DetailLine(
                  label: '可见范围',
                  value: _projectAttachmentVisibilityLabel(
                    attachment.visibility,
                  ),
                ),
                _DetailLine(label: '排序序号', value: '${attachment.sortOrder}'),
                _DetailLine(label: '创建时间', value: attachment.createdAt),
                if (attachment.createdBy != null)
                  _DetailLine(label: '创建人', value: attachment.createdBy!),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _TinyStatusPill extends StatelessWidget {
  const _TinyStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ProjectAttachmentKindIcon extends StatelessWidget {
  const _ProjectAttachmentKindIcon({
    required this.kind,
    required this.active,
    required this.workbenchMode,
  });

  final String kind;
  final bool active;
  final bool workbenchMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = active ? AppVisualTokens.brandGold : colorScheme.outline;
    final icon = workbenchMode
        ? _projectAttachmentKindWorkbenchIcon(kind)
        : active
        ? Icons.check_circle_rounded
        : Icons.radio_button_unchecked_rounded;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: workbenchMode ? 0.10 : 0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(workbenchMode ? 7 : 0),
        child: Icon(icon, size: workbenchMode ? 20 : 22, color: color),
      ),
    );
  }
}

IconData _projectAttachmentKindWorkbenchIcon(String kind) {
  return switch (kind) {
    _projectAttachmentKindEffectImage => Icons.image_outlined,
    _projectAttachmentKindConstructionDoc => Icons.straighten_outlined,
    _projectAttachmentKindMaterialSample => Icons.texture_outlined,
    _projectAttachmentKindEquipmentMaterialList => Icons.inventory_2_outlined,
    _projectAttachmentKindServiceList => Icons.assignment_outlined,
    _ => Icons.insert_drive_file_outlined,
  };
}

class _ProjectAttachmentKindPicker extends StatelessWidget {
  const _ProjectAttachmentKindPicker({
    required this.selectedValue,
    required this.onChanged,
  });

  final String selectedValue;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '资料类型',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _projectAttachmentKindOptions.map((
            _ProjectAttachmentKindOption item,
          ) {
            return ChoiceChip(
              label: Text(item.label),
              selected: item.value == selectedValue,
              onSelected: onChanged == null
                  ? null
                  : (_) => onChanged!(item.value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProjectAttachmentRequirementPanel extends StatelessWidget {
  const _ProjectAttachmentRequirementPanel({
    required this.attachments,
    this.selectedDraftsByKind =
        const <String, List<_ResolvedProjectAttachmentDraft>>{},
    this.selectedKind,
    this.openingAttachmentIds = const <String>{},
    this.deletingAttachmentIds = const <String>{},
    this.onSelectKind,
    this.onAddKind,
    this.onPreviewDraft,
    this.onOpenDraft,
    this.isDraftPreviewing,
    this.onRemoveDraft,
    this.onPreviewAttachment,
    this.onDeleteAttachment,
    this.workbenchMode = false,
  });

  final List<ProjectAttachmentReadModel> attachments;
  final Map<String, List<_ResolvedProjectAttachmentDraft>> selectedDraftsByKind;
  final String? selectedKind;
  final Set<String> openingAttachmentIds;
  final Set<String> deletingAttachmentIds;
  final ValueChanged<String>? onSelectKind;
  final ValueChanged<String>? onAddKind;
  final ValueChanged<_ResolvedProjectAttachmentDraft>? onPreviewDraft;
  final ValueChanged<_ResolvedProjectAttachmentDraft>? onOpenDraft;
  final bool Function(_ResolvedProjectAttachmentDraft draft)? isDraftPreviewing;
  final void Function(
    String attachmentKind,
    _ResolvedProjectAttachmentDraft draft,
  )?
  onRemoveDraft;
  final ValueChanged<ProjectAttachmentReadModel>? onPreviewAttachment;
  final ValueChanged<ProjectAttachmentReadModel>? onDeleteAttachment;
  final bool workbenchMode;

  @override
  Widget build(BuildContext context) {
    final attachmentsByKind = <String, List<ProjectAttachmentReadModel>>{
      for (final option in _projectAttachmentKindOptions)
        option.value: <ProjectAttachmentReadModel>[],
    };
    final unknownAttachments = <ProjectAttachmentReadModel>[];
    final countsByKind = <String, int>{
      for (final option in _projectAttachmentKindOptions) option.value: 0,
    };
    for (final attachment in attachments) {
      final current = countsByKind[attachment.attachmentKind];
      if (current != null) {
        countsByKind[attachment.attachmentKind] = current + 1;
        attachmentsByKind[attachment.attachmentKind]!.add(attachment);
      } else {
        unknownAttachments.add(attachment);
      }
    }
    final pendingCount = selectedDraftsByKind.values.fold<int>(
      0,
      (int total, List<_ResolvedProjectAttachmentDraft> drafts) =>
          total + drafts.length,
    );
    final missingKindCount = _projectAttachmentKindOptions.where((
      _ProjectAttachmentKindOption option,
    ) {
      return (countsByKind[option.value] ?? 0) == 0 &&
          (selectedDraftsByKind[option.value]?.isEmpty ?? true);
    }).length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: workbenchMode
                      ? const SizedBox.shrink()
                      : Text(
                          '报价依据资料 checklist',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                ),
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '资料说明',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (workbenchMode) ...<Widget>[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _ProjectAttachmentFilterPill(
                      label: '全部类型 5',
                      selected: true,
                    ),
                    _ProjectAttachmentFilterPill(
                      label: '待补充 $missingKindCount',
                    ),
                    _ProjectAttachmentFilterPill(label: '待上传 $pendingCount'),
                    _ProjectAttachmentFilterPill(
                      label: '已上传 ${attachments.length}',
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            ..._projectAttachmentKindOptions.map((
              _ProjectAttachmentKindOption option,
            ) {
              final count = countsByKind[option.value] ?? 0;
              final selected = selectedKind == option.value;
              final formalAttachments =
                  attachmentsByKind[option.value] ??
                  const <ProjectAttachmentReadModel>[];
              final selectedDrafts =
                  selectedDraftsByKind[option.value] ??
                  const <_ResolvedProjectAttachmentDraft>[];
              final draftCount = selectedDrafts.length;
              final satisfied = count > 0;
              final expanded = selected || draftCount > 0 || satisfied;
              final statusLabel = draftCount > 0
                  ? '待上传 $draftCount'
                  : satisfied
                  ? '已上传 $count'
                  : '待补充';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected
                        ? AppVisualTokens.brandGold.withValues(alpha: 0.08)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? AppVisualTokens.brandGold.withValues(alpha: 0.42)
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      key: ValueKey<String>(
                        'project-attachment-kind-${option.value}',
                      ),
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            _ProjectAttachmentKindIcon(
                              kind: option.value,
                              active: selected || draftCount > 0 || satisfied,
                              workbenchMode: workbenchMode,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: onSelectKind == null
                                    ? null
                                    : () => onSelectKind!(option.value),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: _ProjectAttachmentKindTitle(
                                    label: option.label,
                                    requiredKind:
                                        _projectRequiredQuoteBasisAttachmentKinds
                                            .contains(option.value),
                                    selected: selected,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              statusLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: draftCount > 0 || satisfied
                                        ? AppVisualTokens.brandGold
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            if (onAddKind != null) ...<Widget>[
                              const SizedBox(width: 8),
                              if (draftCount > 0)
                                _TinyStatusPill(
                                  label: '已选择',
                                  color: AppVisualTokens.brandGold,
                                )
                              else
                                TextButton(
                                  key: ValueKey<String>(
                                    'project-attachment-add-${option.value}',
                                  ),
                                  onPressed: () => onAddKind!(option.value),
                                  child: const Text('添加'),
                                ),
                            ],
                            if (formalAttachments.isNotEmpty) ...<Widget>[
                              const SizedBox(width: 4),
                              Icon(
                                expanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ],
                        ),
                        if (expanded &&
                            (selectedDrafts.isNotEmpty ||
                                formalAttachments.isNotEmpty)) ...<Widget>[
                          const SizedBox(height: 12),
                          ...selectedDrafts.asMap().entries.map((
                            MapEntry<int, _ResolvedProjectAttachmentDraft>
                            entry,
                          ) {
                            final draft = entry.value;
                            final isLast =
                                entry.key == selectedDrafts.length - 1;
                            return Padding(
                              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                              child: _SelectedProjectAttachmentCard(
                                draft: draft,
                                attachmentKind: option.value,
                                onPreview: onPreviewDraft == null
                                    ? null
                                    : () => onPreviewDraft!(draft),
                                onOpen: onOpenDraft == null
                                    ? null
                                    : () => onOpenDraft!(draft),
                                previewing:
                                    isDraftPreviewing?.call(draft) ?? false,
                                onRemove: onRemoveDraft == null
                                    ? null
                                    : () => onRemoveDraft!(option.value, draft),
                              ),
                            );
                          }),
                          ...formalAttachments.asMap().entries.map((
                            MapEntry<int, ProjectAttachmentReadModel> entry,
                          ) {
                            final attachment = entry.value;
                            final isLast =
                                entry.key == formalAttachments.length - 1;
                            return Padding(
                              padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                              child: _ProjectAttachmentCompactRecordRow(
                                attachment: attachment,
                                openingPreview: openingAttachmentIds.contains(
                                  attachment.attachmentId,
                                ),
                                deleting: deletingAttachmentIds.contains(
                                  attachment.attachmentId,
                                ),
                                onPreview: onPreviewAttachment == null
                                    ? null
                                    : () => onPreviewAttachment!(attachment),
                                onOpen: onPreviewAttachment == null
                                    ? null
                                    : () => onPreviewAttachment!(attachment),
                                onDelete: onDeleteAttachment == null
                                    ? null
                                    : () => onDeleteAttachment!(attachment),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (unknownAttachments.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('待确认归属附件'),
                children: unknownAttachments
                    .map(
                      (ProjectAttachmentReadModel attachment) =>
                          _ProjectAttachmentCompactRecordRow(
                            attachment: attachment,
                            openingPreview: openingAttachmentIds.contains(
                              attachment.attachmentId,
                            ),
                            deleting: deletingAttachmentIds.contains(
                              attachment.attachmentId,
                            ),
                            onPreview: onPreviewAttachment == null
                                ? null
                                : () => onPreviewAttachment!(attachment),
                            onOpen: onPreviewAttachment == null
                                ? null
                                : () => onPreviewAttachment!(attachment),
                            onDelete: onDeleteAttachment == null
                                ? null
                                : () => onDeleteAttachment!(attachment),
                          ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (workbenchMode && attachments.isEmpty && pendingCount == 0) ...[
              const SizedBox(height: 8),
              const _ProjectAttachmentLightEmptyNotice(
                message: '请至少补充一类资料，方便接单方准确报价。',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectAttachmentKindTitle extends StatelessWidget {
  const _ProjectAttachmentKindTitle({
    required this.label,
    required this.requiredKind,
    required this.selected,
  });

  final String label;
  final bool requiredKind;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w900,
      color: selected ? AppVisualTokens.brandGold : null,
    );
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: <InlineSpan>[
          TextSpan(text: label),
          if (requiredKind)
            TextSpan(
              text: '（必填项）',
              style: baseStyle?.copyWith(
                color: colorScheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ProjectAttachmentKindHint extends StatelessWidget {
  const _ProjectAttachmentKindHint({
    required this.option,
    this.compactCopy = false,
  });

  final _ProjectAttachmentKindOption option;
  final bool compactCopy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              option.label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (!compactCopy) ...<Widget>[
              const SizedBox(height: 6),
              Text(option.summary),
              const SizedBox(height: 8),
            ],
            _DetailLine(label: '支持文件', value: option.supportedTypes),
            if (!compactCopy)
              const _DetailLine(
                label: '说明',
                value: '这里会进入报价依据资料，只对 owner 私域可见。',
              ),
          ],
        ),
      ),
    );
  }
}

class _ProjectAttachmentStatePanel extends StatelessWidget {
  const _ProjectAttachmentStatePanel({
    required this.status,
    required this.message,
    required this.selectedDraft,
  });

  final _ProjectAttachmentUploadUiStatus status;
  final String? message;
  final _ResolvedProjectAttachmentDraft? selectedDraft;

  @override
  Widget build(BuildContext context) {
    final title = _title();
    final body = message ?? _body();
    final nextStep = _nextStep();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(body),
          if (nextStep != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              nextStep,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  String _title() {
    return switch (status) {
      _ProjectAttachmentUploadUiStatus.idle => '等待选择资料',
      _ProjectAttachmentUploadUiStatus.selecting => '正在选择附件',
      _ProjectAttachmentUploadUiStatus.selectedReady => '附件已选中',
      _ProjectAttachmentUploadUiStatus.initStarting => '正在申请上传',
      _ProjectAttachmentUploadUiStatus.initFailed => '上传初始化未完成',
      _ProjectAttachmentUploadUiStatus.directUploading => '正在上传附件',
      _ProjectAttachmentUploadUiStatus.directUploadFailed => '附件直传未完成',
      _ProjectAttachmentUploadUiStatus.confirming => '正在确认上传结果',
      _ProjectAttachmentUploadUiStatus.confirmFailed => '附件确认未完成',
      _ProjectAttachmentUploadUiStatus.binding => '正在形成正式附件',
      _ProjectAttachmentUploadUiStatus.bindFailed => '正式附件绑定未完成',
      _ProjectAttachmentUploadUiStatus.bindSucceeded => '正式附件已形成',
      _ProjectAttachmentUploadUiStatus.unsupportedType => '当前文件类型暂不支持',
    };
  }

  String _body() {
    return switch (status) {
      _ProjectAttachmentUploadUiStatus.idle => '当前还没有开始补充报价依据资料。',
      _ProjectAttachmentUploadUiStatus.selecting => '正在打开文件选择器，请选择当前项目要补充的附件。',
      _ProjectAttachmentUploadUiStatus.selectedReady =>
        '当前附件已经选中，可以直接上传并形成正式附件。',
      _ProjectAttachmentUploadUiStatus.initStarting => '页面正在申请当前附件的上传策略。',
      _ProjectAttachmentUploadUiStatus.initFailed ||
      _ProjectAttachmentUploadUiStatus.directUploadFailed ||
      _ProjectAttachmentUploadUiStatus.confirmFailed ||
      _ProjectAttachmentUploadUiStatus.bindFailed =>
        _projectAttachmentUploadErrorMessage(status),
      _ProjectAttachmentUploadUiStatus.directUploading => '页面正在把当前附件发送到签名直传地址。',
      _ProjectAttachmentUploadUiStatus.confirming => '直传已完成，页面正在确认当前附件的上传结果。',
      _ProjectAttachmentUploadUiStatus.binding =>
        '上传确认已完成，页面正在把已确认文件绑定成报价依据资料。',
      _ProjectAttachmentUploadUiStatus.bindSucceeded =>
        '当前附件已经形成报价依据资料；最终展示以后端资料列表回读为准。',
      _ProjectAttachmentUploadUiStatus.unsupportedType =>
        '当前资料类型与文件类型不匹配，请重新选择。',
    };
  }

  String? _nextStep() {
    return switch (status) {
      _ProjectAttachmentUploadUiStatus.selectedReady => '下一步：点击“上传并形成正式附件”继续。',
      _ProjectAttachmentUploadUiStatus.initFailed ||
      _ProjectAttachmentUploadUiStatus.directUploadFailed => '下一步：重新上传当前附件即可。',
      _ProjectAttachmentUploadUiStatus.confirmFailed =>
        '下一步：点击“再次确认上传结果”或重新上传当前附件。',
      _ProjectAttachmentUploadUiStatus.bindFailed =>
        '下一步：点击“再次绑定正式附件”或重新上传当前附件。',
      _ProjectAttachmentUploadUiStatus.bindSucceeded
          when selectedDraft != null =>
        '已形成当前资料：${selectedDraft!.fileName}',
      _ => null,
    };
  }
}

class _ProjectAttachmentFormalListPanel extends StatelessWidget {
  const _ProjectAttachmentFormalListPanel({
    required this.loading,
    required this.result,
    required this.attachments,
    required this.emptyMessage,
    required this.canContinue,
    required this.feedbackMessage,
    required this.deletingAttachmentIds,
    required this.onRetry,
    required this.openingAttachmentIds,
    required this.onPreview,
    required this.onDelete,
    required this.autoloaded,
    this.showChecklist = true,
    this.lightEmptyNotice = false,
  });

  final bool loading;
  final ExhibitionLoadResult? result;
  final List<ProjectAttachmentReadModel> attachments;
  final String emptyMessage;
  final bool canContinue;
  final String? feedbackMessage;
  final Set<String> deletingAttachmentIds;
  final VoidCallback? onRetry;
  final Set<String> openingAttachmentIds;
  final ValueChanged<ProjectAttachmentReadModel> onPreview;
  final ValueChanged<ProjectAttachmentReadModel> onDelete;
  final bool autoloaded;
  final bool showChecklist;
  final bool lightEmptyNotice;

  @override
  Widget build(BuildContext context) {
    if (!canContinue) {
      return const _EmptyNotice(
        title: '当前不可继续补充',
        message: '当前没有承接到项目实例时，附件补充入口会保持受控不可继续。',
      );
    }

    if (!autoloaded && result == null) {
      return _EmptyNotice(
        title: '当前还没有资料回读',
        message: '$emptyMessage bind 成功后，页面会回读当前资料列表。',
      );
    }

    if (loading) {
      return const _EmptyNotice(title: '正在读取资料列表', message: '正在读取报价依据资料列表。');
    }

    final loadResult = result;
    if (loadResult != null &&
        loadResult.state != AppPageState.content &&
        loadResult.state != AppPageState.empty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _EmptyNotice(
            title: '当前报价依据资料列表暂不可用',
            message: _projectAttachmentListFailureMessage(loadResult),
          ),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('重新读取')),
          ],
        ],
      );
    }

    if (attachments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showChecklist) ...<Widget>[
            _ProjectAttachmentRequirementPanel(attachments: attachments),
            const SizedBox(height: 12),
          ],
          lightEmptyNotice
              ? _ProjectAttachmentLightEmptyNotice(message: emptyMessage)
              : _EmptyNotice(title: '暂无报价依据资料', message: emptyMessage),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showChecklist) ...<Widget>[
          _ProjectAttachmentRequirementPanel(attachments: attachments),
          const SizedBox(height: 12),
        ],
        Text(
          '报价依据资料列表',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (feedbackMessage != null) ...<Widget>[
          const SizedBox(height: 12),
          _StateMessage(title: '当前反馈', body: feedbackMessage!),
        ],
        const SizedBox(height: 12),
        ...attachments.asMap().entries.map((
          MapEntry<int, ProjectAttachmentReadModel> entry,
        ) {
          final item = entry.value;
          final isLast = entry.key == attachments.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: _ProjectAttachmentFormalRecordCard(
              attachment: item,
              openingPreview: openingAttachmentIds.contains(item.attachmentId),
              deleting: deletingAttachmentIds.contains(item.attachmentId),
              onPreview: () => onPreview(item),
              onDelete: () => onDelete(item),
            ),
          );
        }),
      ],
    );
  }
}

class _ProjectAttachmentLightEmptyNotice extends StatelessWidget {
  const _ProjectAttachmentLightEmptyNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.brandGold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppVisualTokens.brandGold.withValues(alpha: 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: AppVisualTokens.brandGold,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '暂无报价依据资料',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectAttachmentFormalRecordCard extends StatelessWidget {
  const _ProjectAttachmentFormalRecordCard({
    required this.attachment,
    required this.openingPreview,
    required this.deleting,
    required this.onPreview,
    required this.onDelete,
  });

  final ProjectAttachmentReadModel attachment;
  final bool openingPreview;
  final bool deleting;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isImage = _projectAttachmentIsImageMimeType(attachment.mimeType);
    final meta = <String>[
      _projectAttachmentMimeTypeLabel(attachment.mimeType),
      _projectAttachmentTimestampLabel(attachment.createdAt),
    ].join(' · ');

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ProjectAttachmentThumbnail(attachment: attachment),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _projectAttachmentKindLabel(
                            attachment.attachmentKind,
                          ),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isImage ? '图片资料' : '文件资料',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: openingPreview || deleting ? null : onPreview,
                    icon: openingPreview
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.visibility_outlined),
                    label: Text(
                      openingPreview
                          ? '处理中'
                          : _projectAttachmentRecordPreviewButtonLabel(
                              attachment.mimeType,
                            ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: deleting || openingPreview ? null : onDelete,
                    icon: deleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_outline_rounded),
                    label: Text(deleting ? '正在删除' : '删除当前资料'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  '高级信息',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                children: <Widget>[
                  _DetailLine(label: '完整文件名', value: attachment.fileName),
                  _DetailLine(
                    label: 'FileAsset',
                    value: attachment.fileAssetId,
                  ),
                  _DetailLine(label: '文件类型', value: attachment.mimeType),
                  _DetailLine(
                    label: '可见范围',
                    value: _projectAttachmentVisibilityLabel(
                      attachment.visibility,
                    ),
                  ),
                  _DetailLine(label: '排序序号', value: '${attachment.sortOrder}'),
                  _DetailLine(label: '创建时间', value: attachment.createdAt),
                  if (attachment.createdBy != null)
                    _DetailLine(label: '创建人', value: attachment.createdBy!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectAttachmentThumbnail extends StatefulWidget {
  const _ProjectAttachmentThumbnail({required this.attachment});

  final ProjectAttachmentReadModel attachment;

  @override
  State<_ProjectAttachmentThumbnail> createState() =>
      _ProjectAttachmentThumbnailState();
}

class _ProjectAttachmentThumbnailState
    extends State<_ProjectAttachmentThumbnail> {
  late Future<List<int>?> _imageBytes;

  @override
  void initState() {
    super.initState();
    _imageBytes = _loadImageBytes();
  }

  @override
  void didUpdateWidget(_ProjectAttachmentThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachment.fileAssetId != widget.attachment.fileAssetId ||
        oldWidget.attachment.mimeType != widget.attachment.mimeType) {
      _imageBytes = _loadImageBytes();
    }
  }

  Future<List<int>?> _loadImageBytes() async {
    if (!_projectAttachmentIsImageMimeType(widget.attachment.mimeType)) {
      return null;
    }
    final result = await ExhibitionConsumerLayer.instance
        .requestProjectAttachmentAccess(
          fileAssetId: widget.attachment.fileAssetId,
          mode: 'preview',
        );
    if (!result.isSuccess) {
      return null;
    }
    final access = _projectAttachmentFileAccessFromPayload(result.payload);
    if (access == null) {
      return null;
    }
    return _loadProjectAttachmentRemoteImageBytes(access.accessUrl);
  }

  @override
  Widget build(BuildContext context) {
    final isImage = _projectAttachmentIsImageMimeType(
      widget.attachment.mimeType,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: isImage
              ? FutureBuilder<List<int>?>(
                  future: _imageBytes,
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<int>?> snapshot,
                      ) {
                        final bytes = snapshot.data;
                        if (bytes != null && bytes.isNotEmpty) {
                          return Image.memory(
                            Uint8List.fromList(bytes),
                            fit: BoxFit.cover,
                          );
                        }
                        return Icon(
                          snapshot.connectionState == ConnectionState.waiting
                              ? Icons.image_search_outlined
                              : Icons.image_outlined,
                          color: colorScheme.onSurfaceVariant,
                        );
                      },
                )
              : _ProjectAttachmentFileTypeBadge(attachment: widget.attachment),
        ),
      ),
    );
  }
}

class _ProjectAttachmentFileTypeBadge extends StatelessWidget {
  const _ProjectAttachmentFileTypeBadge({required this.attachment});

  final ProjectAttachmentReadModel attachment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final extension =
        _projectAttachmentExtension(attachment.fileName)?.toUpperCase() ??
        _projectAttachmentMimeTypeShortLabel(attachment.mimeType);
    final color = _projectAttachmentFileAccentColor(attachment.mimeType);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              _projectAttachmentFileIcon(attachment.mimeType),
              color: color,
              size: 26,
            ),
            const SizedBox(height: 5),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  extension,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _projectAttachmentFileIcon(String mimeType) {
  return switch (mimeType) {
    'application/pdf' => Icons.picture_as_pdf_outlined,
    'application/msword' ||
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
      Icons.article_outlined,
    'application/vnd.ms-excel' ||
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
    'text/csv' ||
    'application/csv' => Icons.table_chart_outlined,
    'application/vnd.ms-powerpoint' ||
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
      Icons.slideshow_outlined,
    'application/zip' ||
    'application/vnd.rar' ||
    'application/x-7z-compressed' => Icons.folder_zip_outlined,
    _ => Icons.description_outlined,
  };
}

Color _projectAttachmentFileAccentColor(String mimeType) {
  return switch (mimeType) {
    'application/pdf' => const Color(0xFFC62828),
    'application/msword' ||
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' =>
      const Color(0xFF1976D2),
    'application/vnd.ms-excel' ||
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
    'text/csv' ||
    'application/csv' => const Color(0xFF2E7D32),
    'application/vnd.ms-powerpoint' ||
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' =>
      const Color(0xFFD84315),
    'application/zip' ||
    'application/vnd.rar' ||
    'application/x-7z-compressed' => const Color(0xFF6D4C41),
    _ => AppVisualTokens.brandGold,
  };
}

String _projectAttachmentMimeTypeShortLabel(String mimeType) {
  final label = _projectAttachmentMimeTypeLabel(mimeType);
  final parts = label.split(' ');
  return parts.first.trim().isEmpty ? 'FILE' : parts.first.trim();
}
