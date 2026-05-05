part of 'forum_pages.dart';

extension _ForumPublishPageSections on _ForumPublishPageState {
  Widget _composerBody(
    BuildContext context, {
    required List<_ForumComposerTopicOption> topicOptions,
    required bool canSaveDraft,
  }) {
    final theme = Theme.of(context);
    final showDraftRestoreFailure =
        !_loading &&
        _selectedDraftId != null &&
        _draftDetailResult != null &&
        _draftDetailResult!.state != AppPageState.content;

    if (showDraftRestoreFailure) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          ForumSlimStatePanel(
            loading: false,
            state: _draftDetailResult!.state,
            emptyMessage: '当前草稿暂不可用',
            onRetry: _load,
            message: _draftDetailResult!.message,
          ),
        ],
      );
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: <Widget>[
        _topicSelector(context, topicOptions),
        const SizedBox(height: 14),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '写一个标题',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          onChanged: (_) => _markComposerDirty(),
        ),
        Divider(color: theme.colorScheme.outlineVariant, height: 20),
        TextField(
          controller: _bodyController,
          minLines: 10,
          maxLines: 16,
          decoration: const InputDecoration(
            hintText: '分享你的现场经验、材料协同建议或本地供应链提醒',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          onChanged: (_) => _markComposerDirty(),
        ),
        if (_inlineImageItems.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _ForumComposerInlineImageGrid(
            items: _inlineImageItems,
            onPreview: (item) => _showImagePreviewDialog(context, item),
            onRemove: (item) => _removeMedia(item.localId),
            onUpload: (item) => _startMediaUpload(item.localId),
            saving: _saving,
            publishing: _publishing,
          ),
        ],
        if (_inlineFileItems.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _inlineAttachmentList(context, _inlineFileItems),
        ],
        const SizedBox(height: 18),
        _mediaSection(context),
        if (_loading) ...<Widget>[
          const SizedBox(height: 12),
          ForumSlimStatePanel(
            loading: true,
            state: AppPageState.loading,
            emptyMessage: '加载中',
            onRetry: _load,
          ),
        ],
        if (!canSaveDraft &&
            !_loading &&
            _selectedTopicId != null &&
            (_titleController.text.trim().isEmpty ||
                _bodyController.text.trim().isEmpty)) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            '标题和正文写完后，请先保存草稿；保存后可直接继续发布，离开后也可从草稿箱继续。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _topicSelector(
    BuildContext context,
    List<_ForumComposerTopicOption> topicOptions,
  ) {
    final theme = Theme.of(context);
    if (topicOptions.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: <Widget>[
              Text(
                '分类暂不可用',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '暂不可选',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentLabel = topicOptions
        .firstWhere(
          (_ForumComposerTopicOption item) => item.topicId == _selectedTopicId,
          orElse: () => topicOptions.first,
        )
        .label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _pickComposerTopic(context, topicOptions),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: <Widget>[
                ForumCategoryBadge(label: currentLabel, compact: true),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '分类：$currentLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppVisualTokens.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickComposerTopic(
    BuildContext context,
    List<_ForumComposerTopicOption> topicOptions,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '选择发帖分类',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '分类只影响帖子显示在哪个讨论区。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: topicOptions.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final item = topicOptions[index];
                    return ListTile(
                      title: Text(item.label),
                      subtitle: Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: item.topicId == _selectedTopicId
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () => Navigator.of(context).pop(item.topicId),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      _selectComposerTopic(selected);
    }
  }

  Widget _mediaSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '添加附件',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '当前稳定路径是先保存草稿，再继续发布。可添加图片、视频或 PDF/文档；若当前还没保存草稿，会先提示补齐内容并在保存后继续上传。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (_hasPendingMediaSelection &&
            !_canAutoStartPendingMedia) ...<Widget>[
          const SizedBox(height: 12),
          _mediaSectionNotice(
            context,
            icon: Icons.info_outline_rounded,
            message: '附件已选中，请先填写分类、标题和正文，再点击“保存草稿”，系统会继续上传。',
          ),
        ],
        if (_hasFailedMedia) ...<Widget>[
          const SizedBox(height: 12),
          _mediaSectionNotice(
            context,
            icon: Icons.error_outline_rounded,
            message:
                _firstFailedMediaMessage() ?? '仍有附件未完成上传，可以点“重新上传”，也可以先移除后再继续。',
            tone: theme.colorScheme.errorContainer,
            iconColor: theme.colorScheme.error,
          ),
        ] else if (_hasConfirmedUnboundMedia) ...<Widget>[
          const SizedBox(height: 12),
          _mediaSectionNotice(
            context,
            icon: Icons.verified_rounded,
            message: '附件上传确认已完成，请先保存草稿，避免发布时因为附件未承接被拦住。',
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (_saving || _publishing || _hasActiveMediaTransfer)
                    ? null
                    : () => _pickMedia(ForumPublishMediaType.image),
                icon: const Icon(Icons.photo_outlined),
                label: const Text('添加图片'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (_saving || _publishing || _hasActiveMediaTransfer)
                    ? null
                    : () => _pickMedia(ForumPublishMediaType.video),
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('添加视频'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: (_saving || _publishing || _hasActiveMediaTransfer)
                ? null
                : () => _pickMedia(ForumPublishMediaType.file),
            icon: const Icon(Icons.description_outlined),
            label: const Text('添加文件'),
          ),
        ),
        if (_mediaItems.isEmpty) ...<Widget>[
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.perm_media_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '暂未添加附件',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String? _firstFailedMediaMessage() {
    for (final item in _mediaItems) {
      if (item.stage != _ForumComposerMediaStage.uploadFailed) {
        continue;
      }
      final message = item.statusMessage?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  List<_ForumComposerMediaItem> get _inlineImageItems {
    return _mediaItems
        .where(
          (_ForumComposerMediaItem item) =>
              _forumIsImageMimeType(item.mimeType) && item.bytes.isNotEmpty,
        )
        .toList(growable: false);
  }

  List<_ForumComposerMediaItem> get _inlineFileItems {
    return _mediaItems
        .where(
          (_ForumComposerMediaItem item) =>
              !_forumIsImageMimeType(item.mimeType) || item.bytes.isEmpty,
        )
        .toList(growable: false);
  }

  Widget _inlineAttachmentList(
    BuildContext context,
    List<_ForumComposerMediaItem> items,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '附件',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map(
          (_ForumComposerMediaItem item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _mediaItemCard(context, item),
          ),
        ),
      ],
    );
  }

  Widget _mediaItemCard(BuildContext context, _ForumComposerMediaItem item) {
    final theme = Theme.of(context);
    final canRemove = !item.isTransferActive;
    final canUpload = item.canStartUpload && !_saving && !_publishing;
    final uploadLabel = item.stage == _ForumComposerMediaStage.uploadFailed
        ? '重新上传'
        : '开始上传';
    final statusText = item.statusMessage ?? _forumMediaStageLabel(item);
    final previewLabel =
        item.mimeType.startsWith('image/') && item.bytes.isNotEmpty
        ? '点名称预览'
        : null;
    final subtitle = previewLabel == null
        ? _forumAttachmentSummaryLabel(item)
        : '${_forumAttachmentSummaryLabel(item)} · $previewLabel';
    final titleRow = _compactMediaTitleRow(context, item, subtitle: subtitle);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            titleRow,
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                if (item.isTransferActive)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else
                  Icon(
                    item.stage == _ForumComposerMediaStage.uploadFailed
                        ? Icons.error_outline_rounded
                        : item.stage == _ForumComposerMediaStage.draftBound
                        ? Icons.task_alt_rounded
                        : item.stage == _ForumComposerMediaStage.confirmedReady
                        ? Icons.verified_rounded
                        : Icons.schedule_rounded,
                    size: 18,
                    color: item.stage == _ForumComposerMediaStage.uploadFailed
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: item.stage == _ForumComposerMediaStage.uploadFailed
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                if (canUpload)
                  OutlinedButton(
                    onPressed: () => _startMediaUpload(item.localId),
                    child: Text(uploadLabel),
                  )
                else
                  OutlinedButton(
                    onPressed: null,
                    child: Text(
                      item.isTransferActive
                          ? '上传中'
                          : _forumMediaStageLabel(item),
                    ),
                  ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: canRemove
                      ? () => _removeMedia(item.localId)
                      : null,
                  child: const Text('移除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactMediaTitleRow(
    BuildContext context,
    _ForumComposerMediaItem item, {
    required String subtitle,
  }) {
    if (item.mimeType.startsWith('image/') && item.bytes.isNotEmpty) {
      return _imagePreviewTriggerCard(context, item, subtitle: subtitle);
    }
    return _genericMediaPreviewTriggerCard(context, item, subtitle: subtitle);
  }

  Widget _imagePreviewTriggerCard(
    BuildContext context,
    _ForumComposerMediaItem item, {
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showImagePreviewDialog(context, item),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.photo_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_full_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImagePreviewDialog(
    BuildContext context,
    _ForumComposerMediaItem item,
  ) async {
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 720,
                    maxHeight: 520,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      child: Image.memory(
                        Uint8List.fromList(item.bytes),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => SizedBox(
                          height: 240,
                          child: Center(
                            child: Text(
                              '当前图片暂时无法预览',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _genericMediaPreviewTriggerCard(
    BuildContext context,
    _ForumComposerMediaItem item, {
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final icon = _forumAttachmentDisplayIcon(item.mimeType);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            _showGenericPreviewDialog(context, item, subtitle: subtitle),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      icon,
                      size: 24,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.open_in_full_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showGenericPreviewDialog(
    BuildContext context,
    _ForumComposerMediaItem item, {
    required String subtitle,
  }) async {
    final theme = Theme.of(context);
    final typeLabel = _forumAttachmentDisplayTypeLabel(item.mimeType);
    final previewText = _genericAttachmentPreviewText(item);
    final canOpenLocally = previewText == null && item.bytes.isNotEmpty;
    final localPreviewMessage = item.mimeType.startsWith('video/')
        ? '当前视频已选中，可在系统中直接预览；上传后也可继续按帖子附件链查看。'
        : previewText == null
        ? item.bytes.isEmpty
              ? '当前附件已承接到草稿，发布后可继续按帖子附件链查看。'
              : '当前文件已选中，可在系统中直接打开；上传后也可继续按帖子附件链查看。'
        : null;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$typeLabel · $subtitle',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                if (previewText != null)
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 320),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        previewText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          _forumAttachmentDisplayIcon(item.mimeType),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            localPreviewMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (canOpenLocally) ...<Widget>[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () async {
                        final navigator = Navigator.of(dialogContext);
                        final opened = await _openSelectedMediaLocally(item);
                        if (!mounted) {
                          return;
                        }
                        if (opened && navigator.canPop()) {
                          navigator.pop();
                        }
                      },
                      child: Text(
                        item.mimeType.startsWith('video/')
                            ? '在系统中预览视频'
                            : '在系统中打开文件',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _openSelectedMediaLocally(_ForumComposerMediaItem item) async {
    if (item.bytes.isEmpty) {
      _showActionFeedback('当前附件还没有本地内容可供打开', error: true);
      return false;
    }
    try {
      final file = await _writePreviewTempFile(item);
      final opened = await _openLocalPreviewFile(file.path);
      _showActionFeedback(
        opened
            ? (item.mimeType.startsWith('video/') ? '已在系统中打开视频预览' : '已在系统中打开文件')
            : '当前设备暂时不能直接打开这个附件，可先上传后继续按帖子附件链查看',
        error: !opened,
      );
      return opened;
    } catch (_) {
      _showActionFeedback('当前附件暂时打不开，请稍后再试', error: true);
      return false;
    }
  }

  Future<File> _writePreviewTempFile(_ForumComposerMediaItem item) async {
    final safeName = item.fileName.trim().replaceAll(
      RegExp(r'[\\/\u0000-\u001F]'),
      '_',
    );
    final resolvedName = safeName.isEmpty ? 'forum-attachment.bin' : safeName;
    final file = File(
      '${Directory.systemTemp.path}/forum-preview-${DateTime.now().microsecondsSinceEpoch}-$resolvedName',
    );
    await file.writeAsBytes(item.bytes, flush: true);
    return file;
  }

  Future<bool> _openLocalPreviewFile(String path) async {
    try {
      if (Platform.isMacOS) {
        final result = await Process.run('open', <String>[path]);
        return result.exitCode == 0;
      }
      if (Platform.isLinux) {
        final result = await Process.run('xdg-open', <String>[path]);
        return result.exitCode == 0;
      }
      if (Platform.isWindows) {
        final result = await Process.run('cmd', <String>[
          '/c',
          'start',
          '',
          path,
        ]);
        return result.exitCode == 0;
      }
    } on ProcessException {
      return false;
    }
    return false;
  }

  String? _genericAttachmentPreviewText(_ForumComposerMediaItem item) {
    if (item.bytes.isEmpty) {
      return null;
    }
    if (item.mimeType == 'text/plain') {
      final decoded = utf8.decode(item.bytes, allowMalformed: true).trim();
      if (decoded.isEmpty) {
        return '当前文本文件暂无可显示内容。';
      }
      return decoded;
    }
    return null;
  }

  Widget _mediaSectionNotice(
    BuildContext context, {
    required IconData icon,
    required String message,
    Color? tone,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            tone ?? theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 18, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _composerBottomBar(
    BuildContext context, {
    required bool canSaveDraft,
    required bool canPublish,
    required String? helperText,
  }) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (helperText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    helperText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: canSaveDraft ? _saveDraft : null,
                      child: Text(_saving ? '保存中' : '保存草稿'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: canPublish ? _publish : null,
                      child: Text(_publishing ? '发布中' : '发布'),
                    ),
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

class _ForumComposerTopicOption {
  const _ForumComposerTopicOption({
    required this.topicId,
    required this.label,
    required this.description,
  });

  final String topicId;
  final String label;
  final String description;
}
