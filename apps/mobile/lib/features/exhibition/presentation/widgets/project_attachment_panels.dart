part of '../exhibition_trade_pages.dart';

class _SelectedProjectAttachmentCard extends StatelessWidget {
  const _SelectedProjectAttachmentCard({
    required this.draft,
    required this.attachmentKind,
    this.onPreview,
    this.previewing = false,
    this.onRemove,
  });

  final _ResolvedProjectAttachmentDraft draft;
  final String attachmentKind;
  final VoidCallback? onPreview;
  final bool previewing;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              draft.fileName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _DetailLine(
              label: '资料类型',
              value: _projectAttachmentKindLabel(attachmentKind),
              highlight: true,
            ),
            _DetailLine(
              label: '文件类型',
              value: _projectAttachmentFileTypeLabel(draft.extension),
            ),
            _DetailLine(
              label: '文件大小',
              value: _projectAttachmentSizeLabel(draft.sizeInBytes),
            ),
            if (onPreview != null || onRemove != null) ...<Widget>[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  if (onPreview != null)
                    OutlinedButton.icon(
                      onPressed: previewing ? null : onPreview,
                      icon: previewing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.visibility_outlined),
                      label: Text(
                        previewing
                            ? '处理中'
                            : _projectAttachmentDraftPreviewButtonLabel(
                                draft.mimeType,
                              ),
                      ),
                    ),
                  if (onRemove != null)
                    OutlinedButton.icon(
                      onPressed: previewing ? null : onRemove,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      label: const Text('移除当前附件'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
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
    this.selectedKind,
    this.onSelectKind,
    this.onAddKind,
  });

  final List<ProjectAttachmentReadModel> attachments;
  final String? selectedKind;
  final ValueChanged<String>? onSelectKind;
  final ValueChanged<String>? onAddKind;

  @override
  Widget build(BuildContext context) {
    final countsByKind = <String, int>{
      for (final option in _projectAttachmentKindOptions) option.value: 0,
    };
    for (final attachment in attachments) {
      final current = countsByKind[attachment.attachmentKind];
      if (current != null) {
        countsByKind[attachment.attachmentKind] = current + 1;
      }
    }

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
              '报价依据资料 checklist',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ..._projectAttachmentKindOptions.map((
              _ProjectAttachmentKindOption option,
            ) {
              final count = countsByKind[option.value] ?? 0;
              final satisfied = count > 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    Icon(
                      satisfied
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: satisfied
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: onSelectKind == null
                            ? null
                            : () => onSelectKind!(option.value),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            option.label,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: selectedKind == option.value
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      satisfied ? '已上传 $count' : '待补充',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: satisfied
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (onAddKind != null) ...<Widget>[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => onAddKind!(option.value),
                        child: Text(satisfied ? '继续补' : '添加'),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
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
          _EmptyNotice(title: '暂无报价依据资料', message: emptyMessage),
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
              : Icon(
                  Icons.insert_drive_file_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
