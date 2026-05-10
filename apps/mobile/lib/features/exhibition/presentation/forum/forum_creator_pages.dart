part of 'forum_pages.dart';

class ForumPublishPage extends StatefulWidget {
  const ForumPublishPage({super.key, this.initialDraftId});

  final String? initialDraftId;

  @override
  State<ForumPublishPage> createState() => _ForumPublishPageState();
}

class _ForumPublishPageState extends State<ForumPublishPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  ForumReadResult<List<ForumTopicMetadataItemView>>? _topicResult;
  ForumReadResult<ForumPagedCollectionView<ForumTopicCardView>>?
  _topicListResult;
  ForumReadResult<ForumDraftDetailView>? _draftDetailResult;
  List<_ForumComposerMediaItem> _mediaItems = <_ForumComposerMediaItem>[];
  _ForumDraftSnapshot? _lastSavedSnapshot;
  String? _composerDraftId;
  String? _selectedDraftId;
  String? _selectedTopicId;
  String? _draftTargetPostId;
  int _nextMediaLocalId = 0;
  bool _loading = true;
  bool _saving = false;
  final bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _selectedDraftId = widget.initialDraftId?.trim().isEmpty ?? true
        ? null
        : widget.initialDraftId?.trim();
    _composerDraftId = _selectedDraftId;
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>(<Future<Object>>[
      ForumConsumerLayer.instance.loadTopicMetadata(),
      ForumConsumerLayer.instance.loadTopicList(),
      if (_selectedDraftId != null)
        ForumConsumerLayer.instance.loadDraftDetail(draftId: _selectedDraftId),
    ]);
    if (!mounted) {
      return;
    }

    final topicResult =
        results[0] as ForumReadResult<List<ForumTopicMetadataItemView>>;
    final topicListResult =
        results[1]
            as ForumReadResult<ForumPagedCollectionView<ForumTopicCardView>>;
    final draftDetailResult = results.length > 2
        ? results[2] as ForumReadResult<ForumDraftDetailView>
        : null;

    setState(() {
      _topicResult = topicResult;
      _topicListResult = topicListResult;
      _draftDetailResult = draftDetailResult;
      if (draftDetailResult?.state == AppPageState.content &&
          draftDetailResult?.data != null) {
        _restoreDraftDetail(draftDetailResult!.data!);
      }
      _loading = false;
      final options = _topicOptions;
      final candidateTopicId = _selectedTopicId;
      _selectedTopicId =
          options.any(
            (_ForumComposerTopicOption item) =>
                item.topicId == candidateTopicId,
          )
          ? candidateTopicId
          : options.isNotEmpty
          ? options.first.topicId
          : null;
    });

    if (draftDetailResult != null &&
        draftDetailResult.state != AppPageState.content) {
      _showActionFeedback(
        draftDetailResult.message ?? '当前草稿暂时打不开，请稍后再试',
        error: true,
      );
    }
  }

  Future<void> _saveDraft() async {
    if (!RcReleaseFlags.forumPublishingEnabled) {
      _showActionFeedback('当前 RC 版本只保留论坛只读浏览，发帖与草稿写入暂未开放。');
      return;
    }
    final result = await _submitDraftSave(
      showFeedback: true,
      resumePendingUploadsOnSuccess: false,
    );
    if (result.isSuccess) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(ExhibitionRoutes.forumDrafts);
      return;
    }
  }

  Future<ForumActionResult<ForumDraftSavedView>> _submitDraftSave({
    required bool showFeedback,
    bool resumePendingUploadsOnSuccess = false,
  }) async {
    setState(() {
      _saving = true;
    });

    final result = await ForumConsumerLayer.instance.saveDraft(
      draftId: _activeDraftId,
      topicId: _selectedTopicId,
      title: _titleController.text,
      body: _bodyController.text,
      attachmentFileAssetIds: _confirmedAttachmentIds,
    );
    if (!mounted) {
      return result;
    }

    final pendingUploadIds = result.isSuccess && resumePendingUploadsOnSuccess
        ? _mediaItems
              .where(
                (_ForumComposerMediaItem item) =>
                    item.stage == _ForumComposerMediaStage.selectedPending,
              )
              .map((_ForumComposerMediaItem item) => item.localId)
              .toList(growable: false)
        : const <String>[];

    setState(() {
      _saving = false;
      if (result.isSuccess && result.data != null) {
        _composerDraftId = result.data!.draftId;
        _selectedDraftId = result.data!.draftId;
        _draftDetailResult = ForumReadResult<ForumDraftDetailView>(
          state: AppPageState.content,
          method: 'GET',
          path: ForumCanonicalPaths.draftDetail,
          data: ForumDraftDetailView(
            draftId: result.data!.draftId,
            draftType: _draftTargetPostId == null ? 'topic' : 'reply',
            targetPostId: _draftTargetPostId,
            topicId: _selectedTopicId,
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            attachmentFileAssetIds: _confirmedAttachmentIds,
            state: result.data!.state,
            updatedAt: result.data!.updatedAt,
          ),
        );
        _lastSavedSnapshot = _currentDraftSnapshot;
        _markConfirmedAttachmentsAsSaved(_confirmedAttachmentIds);
      }
    });

    if (showFeedback) {
      _showActionFeedback(
        result.isSuccess
            ? pendingUploadIds.isNotEmpty
                  ? '已保存到草稿，正在继续上传附件'
                  : _confirmedAttachmentIds.isEmpty
                  ? '已保存到草稿，正在进入草稿箱'
                  : '已保存到草稿，附件已承接，正在进入草稿箱'
            : result.message ?? '草稿暂未保存，请稍后重试',
        error: !result.isSuccess,
      );
    }

    for (final localId in pendingUploadIds) {
      unawaited(_startMediaUpload(localId));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final topicOptions = _topicOptions;
    final helperText = _composerHelperText;

    return Column(
      children: <Widget>[
        Expanded(
          child: _composerBody(
            context,
            topicOptions: topicOptions,
            canSaveDraft: _canSaveDraft,
          ),
        ),
        _composerBottomBar(
          context,
          canSaveDraft: _canSaveDraft,
          helperText: helperText,
        ),
      ],
    );
  }

  List<_ForumComposerTopicOption> get _topicOptions {
    final metadataItems =
        _topicResult?.data ?? const <ForumTopicMetadataItemView>[];
    if (_topicResult?.state == AppPageState.content &&
        metadataItems.isNotEmpty) {
      final seenLabels = <String>{};
      return metadataItems
          .map(
            (ForumTopicMetadataItemView item) => _ForumComposerTopicOption(
              topicId: item.topicId,
              label: forumDisplayTopicLabel(
                rawLabel: item.title,
                topicId: item.topicId,
                fallback: '发帖分类',
              ),
              description: forumDisplayTopicDescription(
                rawDescription: item.description,
                rawLabel: item.title,
                topicId: item.topicId,
              ),
            ),
          )
          .where((_ForumComposerTopicOption item) => seenLabels.add(item.label))
          .toList(growable: false);
    }

    final topicCards =
        _topicListResult?.data?.items ?? const <ForumTopicCardView>[];
    final seenIds = <String>{};
    final seenLabels = <String>{};
    final options = <_ForumComposerTopicOption>[];
    for (final item in topicCards) {
      if (seenIds.add(item.topicId)) {
        final option = _ForumComposerTopicOption(
          topicId: item.topicId,
          label: forumDisplayTopicLabel(
            rawLabel: item.title,
            topicId: item.topicId,
            categoryKey: item.categoryKey,
            fallback: '发帖分类',
          ),
          description: forumDisplayTopicDescription(
            rawDescription: item.excerpt,
            rawLabel: item.title,
            topicId: item.topicId,
            categoryKey: item.categoryKey,
          ),
        );
        if (seenLabels.add(option.label)) {
          options.add(option);
        }
      }
    }
    return options;
  }

  void _markComposerDirty() {
    setState(() {});
    _startPendingMediaUploadsWhenReady();
  }

  void _selectComposerTopic(String topicId) {
    setState(() => _selectedTopicId = topicId);
    _startPendingMediaUploadsWhenReady();
  }

  Future<void> _pickMedia(ForumPublishMediaType type) async {
    if (_saving || _publishing || _hasActiveMediaTransfer) {
      return;
    }

    List<ForumPublishMediaDraft> drafts;
    try {
      drafts = await _pickForumPublishMedia(type);
    } on ArgumentError {
      _showActionFeedback(_forumPickerOpenFailureMessage(type), error: true);
      return;
    } catch (_) {
      _showActionFeedback(_forumPickerOpenFailureMessage(type), error: true);
      return;
    }
    if (!mounted || drafts.isEmpty) {
      return;
    }

    String? errorMessage;
    final resolved = <_ForumResolvedMediaDraft>[];
    for (final draft in drafts) {
      final result = _resolveForumMediaDraft(draft, type);
      if (result.draft != null) {
        resolved.add(result.draft!);
        continue;
      }
      errorMessage ??= result.errorMessage;
    }

    if (resolved.isEmpty) {
      _showActionFeedback(
        errorMessage ?? _unsupportedForumAttachmentMessage(type),
        error: true,
      );
      return;
    }

    if (errorMessage != null) {
      _showActionFeedback(errorMessage, error: true);
    }

    final canAutoStartSelection = _canAutoStartPendingMedia;
    setState(() {
      _mediaItems = <_ForumComposerMediaItem>[
        ..._mediaItems,
        ...resolved.map(
          (_ForumResolvedMediaDraft draft) => _buildPendingMediaItem(
            draft,
            canAutoStart: canAutoStartSelection,
          ),
        ),
      ];
    });

    if (!canAutoStartSelection) {
      _showActionFeedback('已选中附件，请先填写分类、标题和正文，补齐后会自动上传');
      return;
    }

    _showActionFeedback(resolved.length == 1 ? '已选中附件，正在开始上传' : '已选中附件，正在依次上传');
    for (final item
        in _mediaItems
            .where((_ForumComposerMediaItem item) {
              return item.stage == _ForumComposerMediaStage.selectedPending;
            })
            .toList(growable: false)) {
      unawaited(_startMediaUpload(item.localId));
    }
  }

  Future<void> _startMediaUpload(String localId) async {
    final item = _mediaItemFor(localId);
    if (item == null || !item.canStartUpload || _saving || _publishing) {
      return;
    }

    if (_activeDraftId == null) {
      _updateMediaItem(
        localId,
        (_ForumComposerMediaItem current) => current.copyWith(
          stage: _ForumComposerMediaStage.initStarting,
          statusMessage: '正在准备草稿',
        ),
      );
      final ready = await _ensureDraftExistsForMedia();
      if (!mounted) {
        return;
      }
      if (!ready) {
        _updateMediaItem(
          localId,
          (_ForumComposerMediaItem current) => current.copyWith(
            stage: _ForumComposerMediaStage.selectedPending,
            statusMessage: '请先完善内容后再上传',
          ),
        );
        return;
      }
    }

    final draftId = _activeDraftId;
    if (draftId == null) {
      return;
    }

    _updateMediaItem(
      localId,
      (_ForumComposerMediaItem current) => current.copyWith(
        stage: _ForumComposerMediaStage.initStarting,
        statusMessage: '正在申请上传',
      ),
    );

    final initResult = await ExhibitionConsumerLayer.instance.uploadInit(
      UploadInitCommand(
        businessType: _forumAttachmentBusinessType,
        businessId: draftId,
        fileKind: _forumAttachmentFileKindForItem(item),
        mimeType: item.mimeType,
        size: item.sizeInBytes,
        checksum: item.checksum,
      ),
    );
    if (!mounted) {
      return;
    }

    final directive = initResult.directive;
    if (initResult.state != AppUploadState.signedReady || directive == null) {
      _updateMediaItem(
        localId,
        (_ForumComposerMediaItem current) => current.copyWith(
          stage: _ForumComposerMediaStage.uploadFailed,
          statusMessage: _visibleUploadFailureMessage(
            initResult,
            fallback: '当前附件上传初始化失败，请稍后再试',
          ),
        ),
      );
      return;
    }

    _updateMediaItem(
      localId,
      (_ForumComposerMediaItem current) => current.copyWith(
        stage: _ForumComposerMediaStage.uploading,
        directive: directive,
        statusMessage: '正在上传',
      ),
    );

    final uploadResult = await ExhibitionConsumerLayer.instance.directUpload(
      directive: directive,
      bodyBytes: item.bytes,
    );
    if (!mounted) {
      return;
    }

    if (uploadResult.state != AppUploadState.uploadConfirming) {
      _updateMediaItem(
        localId,
        (_ForumComposerMediaItem current) => current.copyWith(
          stage: _ForumComposerMediaStage.uploadFailed,
          statusMessage: _visibleUploadFailureMessage(
            uploadResult,
            fallback: '当前附件上传失败，请重新上传后再试',
          ),
        ),
      );
      return;
    }

    _updateMediaItem(
      localId,
      (_ForumComposerMediaItem current) => current.copyWith(
        stage: _ForumComposerMediaStage.confirming,
        statusMessage: '正在确认上传结果',
      ),
    );

    final confirmResult = await ExhibitionConsumerLayer.instance.uploadConfirm(
      directive: directive,
    );
    if (!mounted) {
      return;
    }

    final fileAssetId = confirmResult.fileAssetId?.trim();
    if (confirmResult.state != AppUploadState.uploadBound ||
        fileAssetId == null ||
        fileAssetId.isEmpty) {
      _updateMediaItem(
        localId,
        (_ForumComposerMediaItem current) => current.copyWith(
          stage: _ForumComposerMediaStage.uploadFailed,
          statusMessage: _visibleUploadFailureMessage(
            confirmResult,
            fallback: '当前附件上传确认失败，请重新上传后再试',
          ),
        ),
      );
      return;
    }

    _updateMediaItem(
      localId,
      (_ForumComposerMediaItem current) => current.copyWith(
        stage: _ForumComposerMediaStage.confirmedReady,
        fileAssetId: fileAssetId,
        statusMessage: '上传确认完成，等待保存草稿',
      ),
    );
    _showActionFeedback('附件已上传完成，保存草稿后会进入草稿箱');
  }

  void _startPendingMediaUploadsWhenReady() {
    if (!_canAutoStartPendingMedia ||
        _saving ||
        _publishing ||
        _hasActiveMediaTransfer) {
      return;
    }

    final pendingIds = _mediaItems
        .where(
          (_ForumComposerMediaItem item) =>
              item.stage == _ForumComposerMediaStage.selectedPending,
        )
        .map((_ForumComposerMediaItem item) => item.localId)
        .toList(growable: false);
    if (pendingIds.isEmpty) {
      return;
    }

    _showActionFeedback(
      pendingIds.length == 1 ? '内容已补齐，正在上传附件' : '内容已补齐，正在依次上传附件',
    );
    for (final localId in pendingIds) {
      unawaited(_startMediaUpload(localId));
    }
  }

  void _removeMedia(String localId) {
    final item = _mediaItemFor(localId);
    if (item == null || item.isTransferActive) {
      return;
    }

    setState(() {
      _mediaItems = _mediaItems
          .where(
            (_ForumComposerMediaItem mediaItem) => mediaItem.localId != localId,
          )
          .toList(growable: false);
    });

    _showActionFeedback(item.isBoundToDraft ? '已移除附件，请重新保存草稿' : '已移除当前附件');
  }

  bool get _hasRequiredContent =>
      _selectedTopicId != null &&
      _titleController.text.trim().isNotEmpty &&
      _bodyController.text.trim().isNotEmpty;

  bool get _hasActiveMediaTransfer =>
      _mediaItems.any((_ForumComposerMediaItem item) => item.isTransferActive);

  bool get _hasPendingMediaSelection => _mediaItems.any(
    (_ForumComposerMediaItem item) =>
        item.stage == _ForumComposerMediaStage.selectedPending,
  );

  bool get _hasFailedMedia => _mediaItems.any(
    (_ForumComposerMediaItem item) =>
        item.stage == _ForumComposerMediaStage.uploadFailed,
  );

  bool get _hasConfirmedUnboundMedia => _mediaItems.any(
    (_ForumComposerMediaItem item) =>
        item.stage == _ForumComposerMediaStage.confirmedReady,
  );

  bool get _canAutoStartPendingMedia =>
      _activeDraftId != null || _hasRequiredContent;

  bool get _canSaveDraft =>
      RcReleaseFlags.forumPublishingEnabled &&
      !_saving &&
      !_hasActiveMediaTransfer &&
      !_hasPendingMediaSelection &&
      !_hasFailedMedia &&
      _hasRequiredContent;

  bool get _hasUnsavedContent {
    final draftId = _selectedDraftId;
    final snapshot = _lastSavedSnapshot;
    if (draftId == null) {
      return _hasRequiredContent || _confirmedAttachmentIds.isNotEmpty;
    }
    if (snapshot == null) {
      return true;
    }
    return !_matchesSavedSnapshot(snapshot);
  }

  String? get _activeDraftId => _composerDraftId ?? _selectedDraftId;

  List<String> get _confirmedAttachmentIds => _mediaItems
      .map((_ForumComposerMediaItem item) => item.fileAssetId?.trim())
      .whereType<String>()
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);

  _ForumDraftSnapshot get _currentDraftSnapshot => _ForumDraftSnapshot(
    topicId: _selectedTopicId ?? '',
    title: _titleController.text.trim(),
    body: _bodyController.text.trim(),
    attachmentFileAssetIds: _confirmedAttachmentIds,
  );

  String? get _composerHelperText {
    if (!RcReleaseFlags.forumPublishingEnabled) {
      return '当前 RC 版本只保留论坛只读浏览，发帖与草稿写入暂未开放。';
    }
    if (_loading) {
      return _selectedDraftId == null ? '正在准备草稿编辑页' : '正在恢复草稿内容';
    }
    if (_selectedDraftId != null &&
        _draftDetailResult != null &&
        _draftDetailResult!.state != AppPageState.content) {
      return _draftDetailResult!.message ?? '当前草稿暂时打不开，请稍后再试';
    }
    if (_selectedTopicId == null) {
      return '当前分类暂不可用';
    }
    if (_hasActiveMediaTransfer) {
      return '附件正在上传或确认，请稍候';
    }
    if (_hasPendingMediaSelection) {
      return _canAutoStartPendingMedia ? '附件已选中，正在准备上传' : '附件已选中，请先填写分类、标题和正文';
    }
    if (_hasFailedMedia) {
      return '有附件上传失败，请重试或移除后再保存草稿';
    }
    if (_hasConfirmedUnboundMedia) {
      return '附件已确认，保存草稿后会进入草稿箱';
    }
    if (_selectedDraftId == null) {
      return '请先保存草稿；保存后会进入草稿箱，由草稿箱承接发布。';
    }
    if (_hasUnsavedContent) {
      return '当前内容有更新，请先保存草稿，再到草稿箱发布';
    }
    return '当前草稿已保存，可到草稿箱发布。';
  }

  void _restoreDraftDetail(ForumDraftDetailView detail) {
    _composerDraftId = detail.draftId;
    _selectedDraftId = detail.draftId;
    _draftTargetPostId = detail.targetPostId;
    _selectedTopicId = detail.topicId;
    _titleController.text = detail.title;
    _bodyController.text = detail.body;
    _mediaItems = _buildRestoredMediaItems(detail.attachmentFileAssetIds);
    _lastSavedSnapshot = _ForumDraftSnapshot(
      topicId: detail.topicId ?? '',
      title: detail.title,
      body: detail.body,
      attachmentFileAssetIds: detail.attachmentFileAssetIds,
    );
  }

  void _showActionFeedback(String message, {bool error = false}) {
    if (!mounted) {
      return;
    }
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = error
        ? colorScheme.onErrorContainer
        : colorScheme.onInverseSurface;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? colorScheme.errorContainer : null,
      ),
    );
  }

  _ForumComposerMediaItem _buildPendingMediaItem(
    _ForumResolvedMediaDraft draft, {
    required bool canAutoStart,
  }) {
    _nextMediaLocalId += 1;
    return _ForumComposerMediaItem(
      localId: 'forum-media-$_nextMediaLocalId',
      fileName: draft.fileName,
      mimeType: draft.mimeType,
      bytes: draft.bytes,
      checksum: draft.checksum,
      mediaType: draft.mediaType,
      stage: _ForumComposerMediaStage.selectedPending,
      statusMessage: canAutoStart ? '已选中，准备上传' : '已选中，请先填写内容后上传',
    );
  }

  List<_ForumComposerMediaItem> _buildRestoredMediaItems(
    List<String> attachmentFileAssetIds,
  ) {
    return attachmentFileAssetIds
        .asMap()
        .entries
        .map((entry) {
          _nextMediaLocalId += 1;
          final index = entry.key + 1;
          final fileAssetId = entry.value;
          return _ForumComposerMediaItem(
            localId: 'forum-media-restored-$_nextMediaLocalId',
            fileName: '已绑定附件 $index',
            mimeType: 'application/octet-stream',
            bytes: const <int>[],
            checksum: '',
            mediaType: ForumPublishMediaType.file,
            stage: _ForumComposerMediaStage.draftBound,
            fileAssetId: fileAssetId,
            statusMessage: '已从草稿恢复并承接',
          );
        })
        .toList(growable: false);
  }

  _ForumComposerMediaItem? _mediaItemFor(String localId) {
    for (final item in _mediaItems) {
      if (item.localId == localId) {
        return item;
      }
    }
    return null;
  }

  void _updateMediaItem(
    String localId,
    _ForumComposerMediaItem Function(_ForumComposerMediaItem current) update,
  ) {
    setState(() {
      _mediaItems = _mediaItems
          .map(
            (_ForumComposerMediaItem item) =>
                item.localId == localId ? update(item) : item,
          )
          .toList(growable: false);
    });
  }

  void _markConfirmedAttachmentsAsSaved(List<String> savedAttachmentIds) {
    final savedSet = savedAttachmentIds.toSet();
    _mediaItems = _mediaItems
        .map((_ForumComposerMediaItem item) {
          if (!item.isConfirmed || item.fileAssetId == null) {
            return item;
          }
          if (savedSet.contains(item.fileAssetId)) {
            return item.copyWith(
              stage: _ForumComposerMediaStage.draftBound,
              statusMessage: '已承接到当前草稿',
            );
          }
          return item.copyWith(
            stage: _ForumComposerMediaStage.confirmedReady,
            statusMessage: '上传确认完成，等待保存草稿',
          );
        })
        .toList(growable: false);
  }

  bool _matchesSavedSnapshot(_ForumDraftSnapshot snapshot) {
    final current = _currentDraftSnapshot;
    if (snapshot.topicId != current.topicId ||
        snapshot.title != current.title ||
        snapshot.body != current.body) {
      return false;
    }
    if (snapshot.attachmentFileAssetIds.length !=
        current.attachmentFileAssetIds.length) {
      return false;
    }
    for (
      var index = 0;
      index < snapshot.attachmentFileAssetIds.length;
      index += 1
    ) {
      if (snapshot.attachmentFileAssetIds[index] !=
          current.attachmentFileAssetIds[index]) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _ensureDraftExistsForMedia() async {
    if (_activeDraftId != null) {
      return true;
    }
    if (!_hasRequiredContent) {
      _showActionFeedback('请先填写分类、标题和正文，再添加附件', error: true);
      return false;
    }

    final result = await _submitDraftSave(showFeedback: false);
    if (!mounted) {
      return false;
    }
    if (!result.isSuccess || _activeDraftId == null) {
      _showActionFeedback(result.message ?? '请先保存草稿后再添加附件', error: true);
      return false;
    }

    _showActionFeedback('已先保存当前草稿，继续上传附件');
    return true;
  }

  String _visibleUploadFailureMessage(
    UploadFlowResult result, {
    required String fallback,
  }) {
    final message = result.message?.trim();
    if (message != null &&
        message.isNotEmpty &&
        RegExp(r'[\u4e00-\u9fff]').hasMatch(message) &&
        !_looksTechnicalUploadMessage(message) &&
        !_looksGenericUploadFailureMessage(message)) {
      return message;
    }
    return switch (result.errorCode) {
      'FILE_UPLOAD_CONFIRM_REQUIRED' => '当前附件上传确认未完成，请重新上传后再试',
      'FILE_UPLOAD_INIT_INVALID' => '当前附件上传参数无效，请重新选择后再试',
      _ => fallback,
    };
  }

  bool _looksTechnicalUploadMessage(String value) {
    final lower = value.toLowerCase();
    return lower.contains('objectkey') ||
        lower.contains('uploadsessionid') ||
        lower.contains('source=') ||
        lower.contains('cannot ') ||
        lower.contains('econnrefused') ||
        lower.contains('direct upload') ||
        value.contains('直传') ||
        lower.contains('upstream') ||
        lower.contains('transport');
  }

  bool _looksGenericUploadFailureMessage(String value) {
    final trimmed = value.trim();
    return trimmed == '上传失败' || trimmed == '请求失败' || trimmed == '网络错误';
  }
}

class _ForumDraftSnapshot {
  const _ForumDraftSnapshot({
    required this.topicId,
    required this.title,
    required this.body,
    required this.attachmentFileAssetIds,
  });

  final String topicId;
  final String title;
  final String body;
  final List<String> attachmentFileAssetIds;
}
