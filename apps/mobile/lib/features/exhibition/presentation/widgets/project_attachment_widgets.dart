part of '../exhibition_trade_pages.dart';

class _ProjectAttachmentSection extends StatefulWidget {
  const _ProjectAttachmentSection({
    super.key,
    required this.projectId,
    required this.title,
    this.summary,
    required this.emptyMessage,
    this.autoloadFormalList = true,
    this.showIntroCopy = true,
    this.compactKindHints = false,
    this.showKindHint = true,
    this.showIdleUploadState = true,
    this.workbenchMode = false,
    this.autoUploadOnSelect = false,
    this.onListResultChanged,
  });

  final String? projectId;
  final String title;
  final String? summary;
  final String emptyMessage;
  final bool autoloadFormalList;
  final bool showIntroCopy;
  final bool compactKindHints;
  final bool showKindHint;
  final bool showIdleUploadState;
  final bool workbenchMode;
  final bool autoUploadOnSelect;
  final ValueChanged<ExhibitionLoadResult?>? onListResultChanged;

  @override
  State<_ProjectAttachmentSection> createState() =>
      _ProjectAttachmentSectionState();
}

class _PendingProjectAttachmentDraft {
  const _PendingProjectAttachmentDraft({
    required this.attachmentKind,
    required this.draft,
  });

  final String attachmentKind;
  final _ResolvedProjectAttachmentDraft draft;
}

class _ProjectAttachmentSectionState extends State<_ProjectAttachmentSection> {
  String _selectedAttachmentKind = _projectAttachmentKindEffectImage;
  final Map<String, List<_ResolvedProjectAttachmentDraft>>
  _selectedDraftsByKind = <String, List<_ResolvedProjectAttachmentDraft>>{};
  _ProjectAttachmentUploadUiStatus _uploadStatus =
      _ProjectAttachmentUploadUiStatus.idle;
  String? _uploadMessage;
  UploadDirective? _uploadDirective;
  String? _confirmedFileAssetId;
  _ResolvedProjectAttachmentDraft? _retryDraft;
  String? _retryAttachmentKind;
  ExhibitionLoadResult? _listResult;
  bool _loadingList = false;
  String? _listFeedbackMessage;
  final Set<String> _deletingAttachmentIds = <String>{};
  final Set<String> _openingAttachmentIds = <String>{};
  final Set<String> _openingSelectedDraftIds = <String>{};

  @override
  void initState() {
    super.initState();
    if (widget.autoloadFormalList) {
      _loadFormalAttachments();
    }
  }

  @override
  void didUpdateWidget(covariant _ProjectAttachmentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId == widget.projectId &&
        oldWidget.autoloadFormalList == widget.autoloadFormalList) {
      return;
    }

    _selectedDraftsByKind.clear();
    _uploadDirective = null;
    _confirmedFileAssetId = null;
    _retryDraft = null;
    _retryAttachmentKind = null;
    _uploadStatus = _ProjectAttachmentUploadUiStatus.idle;
    _uploadMessage = null;
    _listResult = null;
    _listFeedbackMessage = null;
    _deletingAttachmentIds.clear();
    _openingAttachmentIds.clear();
    _openingSelectedDraftIds.clear();
    if (widget.autoloadFormalList) {
      _loadFormalAttachments();
    }
  }

  String _draftKey(_ResolvedProjectAttachmentDraft draft) {
    return '${draft.checksum}:${draft.fileName.toLowerCase()}';
  }

  String _pendingDraftKey(
    String attachmentKind,
    _ResolvedProjectAttachmentDraft draft,
  ) {
    return '$attachmentKind:${_draftKey(draft)}';
  }

  bool _containsDraft(
    String attachmentKind,
    _ResolvedProjectAttachmentDraft draft,
  ) {
    final targetKey = _draftKey(draft);
    final drafts = _selectedDraftsByKind[attachmentKind];
    return drafts?.any(
          (_ResolvedProjectAttachmentDraft item) =>
              _draftKey(item) == targetKey,
        ) ??
        false;
  }

  void _removeDraft(
    String attachmentKind,
    _ResolvedProjectAttachmentDraft draft,
  ) {
    final targetKey = _draftKey(draft);
    final drafts = _selectedDraftsByKind[attachmentKind];
    if (drafts == null) {
      return;
    }
    drafts.removeWhere(
      (_ResolvedProjectAttachmentDraft item) => _draftKey(item) == targetKey,
    );
    if (drafts.isEmpty) {
      _selectedDraftsByKind.remove(attachmentKind);
    }
    _openingSelectedDraftIds.remove(_draftKey(draft));
  }

  _ResolvedProjectAttachmentDraft? get _firstSelectedDraft {
    final queuedDrafts = _queuedSelectedDrafts;
    if (queuedDrafts.isEmpty) {
      return null;
    }
    return queuedDrafts.first.draft;
  }

  int get _selectedDraftCount {
    var count = 0;
    for (final drafts in _selectedDraftsByKind.values) {
      count += drafts.length;
    }
    return count;
  }

  bool get _hasSelectedDrafts => _selectedDraftCount > 0;

  List<_PendingProjectAttachmentDraft> get _queuedSelectedDrafts {
    final queued = <_PendingProjectAttachmentDraft>[];
    for (final option in _projectAttachmentKindOptions) {
      final drafts = _selectedDraftsByKind[option.value];
      if (drafts == null || drafts.isEmpty) {
        continue;
      }
      for (final draft in drafts) {
        queued.add(
          _PendingProjectAttachmentDraft(
            attachmentKind: option.value,
            draft: draft,
          ),
        );
      }
    }
    return queued;
  }

  Future<void> _loadFormalAttachments({
    bool forceRefresh = false,
    String? feedbackMessage,
  }) async {
    final projectId = widget.projectId;
    if (projectId == null) {
      setState(() {
        _listResult = null;
        _loadingList = false;
        _listFeedbackMessage = feedbackMessage;
      });
      return;
    }

    setState(() {
      _loadingList = true;
      _listFeedbackMessage = feedbackMessage;
    });

    final result = await ExhibitionConsumerLayer.instance
        .loadProjectAttachments(
          projectId: projectId,
          forceRefresh: forceRefresh,
        );
    if (!mounted) {
      return;
    }

    setState(() {
      _listResult = result;
      _loadingList = false;
    });
    widget.onListResultChanged?.call(result);
  }

  Future<void> _selectAttachment({
    bool append = false,
    String? attachmentKind,
  }) async {
    final targetAttachmentKind = attachmentKind ?? _selectedAttachmentKind;
    setState(() {
      _selectedAttachmentKind = targetAttachmentKind;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.selecting;
      _uploadMessage = append ? '正在继续选择报价依据资料' : '正在选择报价依据资料';
    });

    final source = await _resolveProjectAttachmentPickSource(
      context: context,
      attachmentKind: targetAttachmentKind,
    );
    if (!mounted) {
      return;
    }
    if (source == null) {
      setState(() {
        _uploadStatus = !_hasSelectedDrafts
            ? _ProjectAttachmentUploadUiStatus.idle
            : _ProjectAttachmentUploadUiStatus.selectedReady;
        _uploadMessage = !_hasSelectedDrafts
            ? '当前没有选择新附件，可稍后重新选择。'
            : '当前没有继续添加新附件，已选中的 $_selectedDraftCount 个附件仍可继续上传。';
      });
      return;
    }

    final draft = await _pickProjectAttachmentDraft(
      imageOnly: source == ProjectAttachmentPickSource.photo,
    );
    if (!mounted) {
      return;
    }
    if (draft == null) {
      setState(() {
        _uploadStatus = !_hasSelectedDrafts
            ? _ProjectAttachmentUploadUiStatus.idle
            : _ProjectAttachmentUploadUiStatus.selectedReady;
        _uploadMessage = !_hasSelectedDrafts
            ? '当前没有选择新附件，可稍后重新选择。'
            : '当前没有继续添加新附件，已选中的 $_selectedDraftCount 个附件仍可继续上传。';
      });
      return;
    }

    final resolved = _resolveProjectAttachmentDraft(draft);
    if (resolved == null) {
      setState(() {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.unsupportedType;
        _uploadMessage = '请选择带有效文件名和扩展名的资料文件。';
      });
      return;
    }

    if (!_projectAttachmentKindMatchesMimeType(
      targetAttachmentKind,
      resolved.mimeType,
    )) {
      setState(() {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.unsupportedType;
        _uploadMessage = _projectAttachmentUnsupportedTypeMessage(
          targetAttachmentKind,
        );
      });
      return;
    }

    if (_containsDraft(targetAttachmentKind, resolved)) {
      setState(() {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.selectedReady;
        _uploadMessage = '${resolved.fileName} 已在待上传列表中，无需重复添加。';
      });
      return;
    }

    setState(() {
      final drafts = _selectedDraftsByKind.putIfAbsent(
        targetAttachmentKind,
        () => <_ResolvedProjectAttachmentDraft>[],
      );
      drafts.add(resolved);
      _uploadDirective = null;
      _confirmedFileAssetId = null;
      _retryDraft = null;
      _retryAttachmentKind = null;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.selectedReady;
      _uploadMessage = widget.autoUploadOnSelect
          ? '已选择 ${resolved.fileName}，正在自动上传并形成正式附件。'
          : _selectedDraftCount == 1
          ? '已选中 ${resolved.fileName}，可以继续上传并形成正式附件。'
          : '已加入 ${resolved.fileName}。当前共 $_selectedDraftCount 个附件，可以继续添加后一次上传。';
    });
    if (widget.autoUploadOnSelect && widget.projectId != null) {
      unawaited(_uploadSelectedAttachment());
    }
  }

  Future<void> _uploadSelectedAttachment() async {
    final projectId = widget.projectId;
    final queuedDrafts = _queuedSelectedDrafts;
    if (projectId == null || queuedDrafts.isEmpty) {
      setState(() {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.initFailed;
        _uploadMessage = '请先承接项目实例，再继续补充当前附件。';
      });
      return;
    }

    final successNames = <String>[];
    var nextSortOrder = _projectAttachmentNextSortOrder(_attachments);
    final totalDraftCount = queuedDrafts.length;
    for (final pendingDraft in queuedDrafts) {
      final succeeded = await _uploadDraft(
        projectId: projectId,
        attachmentKind: pendingDraft.attachmentKind,
        draft: pendingDraft.draft,
        draftIndex: successNames.length + 1,
        totalDraftCount: totalDraftCount,
        sortOrder: nextSortOrder,
      );
      if (!mounted) {
        return;
      }
      if (!succeeded) {
        if (successNames.isNotEmpty) {
          final currentMessage = _uploadMessage;
          setState(() {
            _uploadMessage = currentMessage == null || currentMessage.isEmpty
                ? '已成功形成 ${successNames.length} 个附件。'
                : '已成功形成 ${successNames.length} 个附件。 $currentMessage';
          });
          ExhibitionConsumerLayer.instance.invalidateProjectAttachments(
            projectId: projectId,
          );
          await _loadFormalAttachments(
            forceRefresh: true,
            feedbackMessage: successNames.length == 1
                ? '${successNames.first} 已进入报价依据资料列表。'
                : '已回读 ${successNames.length} 个新资料。',
          );
        }
        return;
      }
      setState(() {
        _removeDraft(pendingDraft.attachmentKind, pendingDraft.draft);
      });
      successNames.add(pendingDraft.draft.fileName);
      nextSortOrder += 1;
    }

    setState(() {
      _uploadDirective = null;
      _confirmedFileAssetId = null;
      _retryDraft = null;
      _retryAttachmentKind = null;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.bindSucceeded;
      _uploadMessage = successNames.length == 1
          ? '${successNames.first} 已形成报价依据资料。最终列表以后端资料读侧回读为准。'
          : '已形成 ${successNames.length} 个报价依据资料。最终列表以后端资料读侧回读为准。';
    });
    ExhibitionConsumerLayer.instance.invalidateProjectAttachments(
      projectId: projectId,
    );
    await _loadFormalAttachments(
      forceRefresh: true,
      feedbackMessage: successNames.length == 1
          ? '${successNames.first} 已进入报价依据资料列表。'
          : '已回读 ${successNames.length} 个新资料。',
    );
  }

  Future<bool> _uploadDraft({
    required String projectId,
    required String attachmentKind,
    required _ResolvedProjectAttachmentDraft draft,
    required int draftIndex,
    required int totalDraftCount,
    required int sortOrder,
  }) async {
    setState(() {
      _uploadStatus = _ProjectAttachmentUploadUiStatus.initStarting;
      _uploadMessage = totalDraftCount > 1
          ? '正在申请第 $draftIndex/$totalDraftCount 个附件的上传策略：${draft.fileName}'
          : '正在申请当前附件的上传策略';
      _uploadDirective = null;
      _confirmedFileAssetId = null;
      _retryDraft = draft;
      _retryAttachmentKind = attachmentKind;
    });

    final initResult = await ExhibitionConsumerLayer.instance.uploadInit(
      UploadInitCommand(
        businessType: _projectAttachmentBusinessType,
        businessId: projectId,
        fileKind: _projectAttachmentFileKind,
        mimeType: draft.mimeType,
        size: draft.sizeInBytes,
        checksum: draft.checksum,
      ),
    );

    if (!mounted) {
      return false;
    }

    final directive = initResult.directive;
    if (initResult.state != AppUploadState.signedReady || directive == null) {
      setState(() {
        _uploadDirective = null;
        _uploadStatus = _ProjectAttachmentUploadUiStatus.initFailed;
        _uploadMessage =
            initResult.message ?? '${draft.fileName} 上传初始化未完成，请稍后重试。';
      });
      return false;
    }

    setState(() {
      _uploadDirective = directive;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.directUploading;
      _uploadMessage = totalDraftCount > 1
          ? '正在上传第 $draftIndex/$totalDraftCount 个附件：${draft.fileName}'
          : '正在上传 ${draft.fileName}';
    });

    final uploadResult = await ExhibitionConsumerLayer.instance.directUpload(
      directive: directive,
      bodyBytes: draft.bytes,
    );

    if (!mounted) {
      return false;
    }

    if (uploadResult.state != AppUploadState.uploadConfirming) {
      setState(() {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.directUploadFailed;
        _uploadMessage = '${draft.fileName} 上传未完成，请重新上传当前附件。';
      });
      return false;
    }

    return _confirmCurrentAttachment(
      directive,
      attachmentKind: attachmentKind,
      draft: draft,
      draftIndex: draftIndex,
      totalDraftCount: totalDraftCount,
      sortOrder: sortOrder,
    );
  }

  Future<bool> _confirmCurrentAttachment(
    UploadDirective directive, {
    String? attachmentKind,
    _ResolvedProjectAttachmentDraft? draft,
    int? draftIndex,
    int? totalDraftCount,
    int? sortOrder,
  }) async {
    final resolvedDraft = draft ?? _retryDraft ?? _firstSelectedDraft;
    final resolvedAttachmentKind =
        attachmentKind ?? _retryAttachmentKind ?? _selectedAttachmentKind;
    if (resolvedDraft == null) {
      return false;
    }

    setState(() {
      _uploadStatus = _ProjectAttachmentUploadUiStatus.confirming;
      _uploadMessage =
          totalDraftCount != null && totalDraftCount > 1 && draftIndex != null
          ? '正在确认第 $draftIndex/$totalDraftCount 个附件：${resolvedDraft.fileName}'
          : '正在确认当前附件上传结果';
    });

    final confirmResult = await ExhibitionConsumerLayer.instance.uploadConfirm(
      directive: directive,
    );

    if (!mounted) {
      return false;
    }

    final fileAssetId = confirmResult.fileAssetId?.trim();
    if (confirmResult.state != AppUploadState.uploadBound ||
        fileAssetId == null ||
        fileAssetId.isEmpty) {
      setState(() {
        _uploadDirective = directive;
        _retryDraft = resolvedDraft;
        _retryAttachmentKind = resolvedAttachmentKind;
        _confirmedFileAssetId = null;
        _uploadStatus = _ProjectAttachmentUploadUiStatus.confirmFailed;
        _uploadMessage = '${resolvedDraft.fileName} 的确认结果未形成可绑定文件，请重新上传。';
      });
      return false;
    }

    _confirmedFileAssetId = fileAssetId;
    _retryDraft = resolvedDraft;
    _retryAttachmentKind = resolvedAttachmentKind;
    return _bindConfirmedAttachment(
      fileAssetId: fileAssetId,
      attachmentKind: resolvedAttachmentKind,
      draft: resolvedDraft,
      draftIndex: draftIndex,
      totalDraftCount: totalDraftCount,
      sortOrder: sortOrder,
    );
  }

  Future<bool> _bindConfirmedAttachment({
    required String fileAssetId,
    String? attachmentKind,
    _ResolvedProjectAttachmentDraft? draft,
    int? draftIndex,
    int? totalDraftCount,
    int? sortOrder,
  }) async {
    final projectId = widget.projectId;
    final resolvedDraft = draft ?? _retryDraft ?? _firstSelectedDraft;
    final resolvedAttachmentKind =
        attachmentKind ?? _retryAttachmentKind ?? _selectedAttachmentKind;
    if (projectId == null || resolvedDraft == null) {
      return false;
    }

    setState(() {
      _uploadStatus = _ProjectAttachmentUploadUiStatus.binding;
      _uploadMessage =
          totalDraftCount != null && totalDraftCount > 1 && draftIndex != null
          ? '正在绑定第 $draftIndex/$totalDraftCount 个报价依据资料：${resolvedDraft.fileName}'
          : '正在把已确认文件绑定成报价依据资料';
    });

    final result = await ExhibitionConsumerLayer.instance.bindProjectAttachment(
      projectId: projectId,
      command: ProjectAttachmentBindCommand(
        fileAssetId: fileAssetId,
        fileName: resolvedDraft.fileName,
        attachmentKind: resolvedAttachmentKind,
        mimeType: resolvedDraft.mimeType,
        sortOrder: sortOrder ?? _projectAttachmentNextSortOrder(_attachments),
      ),
    );

    if (!mounted) {
      return false;
    }

    if (!result.isSuccess) {
      setState(() {
        _retryDraft = resolvedDraft;
        _retryAttachmentKind = resolvedAttachmentKind;
        _confirmedFileAssetId = fileAssetId;
        _uploadStatus = _ProjectAttachmentUploadUiStatus.bindFailed;
        _uploadMessage = _projectAttachmentBindFailureMessage(
          result,
          fileName: resolvedDraft.fileName,
        );
      });
      return false;
    }
    return true;
  }

  Future<void> _deleteAttachment(ProjectAttachmentReadModel attachment) async {
    if (_deletingAttachmentIds.contains(attachment.attachmentId)) {
      return;
    }

    setState(() {
      _deletingAttachmentIds.add(attachment.attachmentId);
      _listFeedbackMessage = '正在删除 ${attachment.fileName}';
    });

    final result = await ExhibitionConsumerLayer.instance
        .deleteProjectAttachment(
          projectId: attachment.projectId,
          attachmentId: attachment.attachmentId,
        );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() {
        _deletingAttachmentIds.remove(attachment.attachmentId);
        _listFeedbackMessage = _projectAttachmentDeleteFailureMessage(result);
      });
      return;
    }

    ExhibitionConsumerLayer.instance.invalidateProjectAttachments(
      projectId: attachment.projectId,
    );
    setState(() {
      _deletingAttachmentIds.remove(attachment.attachmentId);
    });
    await _loadFormalAttachments(
      forceRefresh: true,
      feedbackMessage: '${attachment.fileName} 已从报价依据资料列表移除。',
    );
  }

  Future<void> _previewSelectedDraft(
    _ResolvedProjectAttachmentDraft draft,
  ) async {
    final draftId = _draftKey(draft);
    if (_openingSelectedDraftIds.contains(draftId)) {
      return;
    }

    if (_projectAttachmentIsImageMimeType(draft.mimeType)) {
      await _showProjectAttachmentLocalImagePreviewDialog(
        context,
        fileName: draft.fileName,
        bytes: draft.bytes,
      );
      return;
    }

    setState(() => _openingSelectedDraftIds.add(draftId));
    try {
      final file = await _writeProjectAttachmentPreviewTempFile(
        fileName: draft.fileName,
        bytes: draft.bytes,
      );
      final opened = await _openProjectAttachmentLocalFile(
        file.path,
        mimeType: draft.mimeType,
      );
      if (!mounted) {
        return;
      }
      _showSectionMessage(
        opened ? '已打开当前附件预览。' : '当前设备暂时不能直接打开这个附件，请上传成功后再试远程预览。',
      );
    } catch (_) {
      if (mounted) {
        _showSectionMessage('当前附件暂时无法打开，请稍后再试。');
      }
    } finally {
      if (mounted) {
        setState(() => _openingSelectedDraftIds.remove(draftId));
      }
    }
  }

  Future<void> _openSelectedDraft(_ResolvedProjectAttachmentDraft draft) async {
    final draftId = _draftKey(draft);
    if (_openingSelectedDraftIds.contains(draftId)) {
      return;
    }

    setState(() => _openingSelectedDraftIds.add(draftId));
    try {
      final file = await _writeProjectAttachmentPreviewTempFile(
        fileName: draft.fileName,
        bytes: draft.bytes,
      );
      final opened = await _openProjectAttachmentLocalFile(
        file.path,
        mimeType: draft.mimeType,
      );
      if (!mounted) {
        return;
      }
      _showSectionMessage(
        opened ? '已打开当前附件预览。' : '当前设备暂时不能直接打开这个附件，请上传成功后再试远程预览。',
      );
    } catch (_) {
      if (mounted) {
        _showSectionMessage('当前附件暂时无法打开，请稍后再试。');
      }
    } finally {
      if (mounted) {
        setState(() => _openingSelectedDraftIds.remove(draftId));
      }
    }
  }

  Future<String?> _showAttachmentKindSwitchSheet() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '更换资料类型',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ..._projectAttachmentKindOptions.map((
                  _ProjectAttachmentKindOption option,
                ) {
                  return ListTile(
                    leading: Icon(
                      option.value == _selectedAttachmentKind
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                    ),
                    title: Text(option.label),
                    onTap: () => Navigator.of(context).pop(option.value),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || selected == null) {
      return null;
    }
    setState(() => _selectedAttachmentKind = selected);
    return selected;
  }

  Future<void> _selectAttachmentFromKindSheet() async {
    final selected = await _showAttachmentKindSwitchSheet();
    if (!mounted || selected == null) {
      return;
    }
    await _selectAttachment(attachmentKind: selected);
  }

  void _removeSelectedDraftFromQueue(
    String attachmentKind,
    _ResolvedProjectAttachmentDraft draft,
  ) {
    setState(() {
      final targetKey = _pendingDraftKey(attachmentKind, draft);
      _removeDraft(attachmentKind, draft);
      if (_retryDraft != null &&
          _retryAttachmentKind != null &&
          _pendingDraftKey(_retryAttachmentKind!, _retryDraft!) == targetKey) {
        _retryDraft = null;
        _retryAttachmentKind = null;
        _uploadDirective = null;
        _confirmedFileAssetId = null;
      }
      if (!_hasSelectedDrafts) {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.idle;
        _uploadMessage = '当前待上传附件已清空，可重新选择。';
      } else {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.selectedReady;
        _uploadMessage =
            '已移除 ${draft.fileName}。剩余 $_selectedDraftCount 个待上传附件。';
      }
    });
  }

  Future<void> _retryConfirmCurrentAttachment() async {
    final draft = _retryDraft;
    final directive = _uploadDirective;
    final attachmentKind = _retryAttachmentKind;
    if (draft == null || directive == null || attachmentKind == null) {
      return;
    }
    final succeeded = await _confirmCurrentAttachment(
      directive,
      attachmentKind: attachmentKind,
      draft: draft,
    );
    if (!mounted || !succeeded) {
      return;
    }
    setState(() {
      _removeDraft(attachmentKind, draft);
      _retryDraft = null;
      _retryAttachmentKind = null;
      _uploadDirective = null;
      _confirmedFileAssetId = null;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.bindSucceeded;
      _uploadMessage = '${draft.fileName} 已形成报价依据资料。最终列表以后端资料读侧回读为准。';
    });
    ExhibitionConsumerLayer.instance.invalidateProjectAttachments(
      projectId: widget.projectId,
    );
    await _loadFormalAttachments(
      forceRefresh: true,
      feedbackMessage: '${draft.fileName} 已进入报价依据资料列表。',
    );
  }

  Future<void> _retryBindCurrentAttachment() async {
    final draft = _retryDraft;
    final attachmentKind = _retryAttachmentKind;
    final fileAssetId = _confirmedFileAssetId;
    if (draft == null || attachmentKind == null || fileAssetId == null) {
      return;
    }
    final succeeded = await _bindConfirmedAttachment(
      fileAssetId: fileAssetId,
      attachmentKind: attachmentKind,
      draft: draft,
    );
    if (!mounted || !succeeded) {
      return;
    }
    setState(() {
      _removeDraft(attachmentKind, draft);
      _retryDraft = null;
      _retryAttachmentKind = null;
      _uploadDirective = null;
      _confirmedFileAssetId = null;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.bindSucceeded;
      _uploadMessage = '${draft.fileName} 已形成报价依据资料。最终列表以后端资料读侧回读为准。';
    });
    ExhibitionConsumerLayer.instance.invalidateProjectAttachments(
      projectId: widget.projectId,
    );
    await _loadFormalAttachments(
      forceRefresh: true,
      feedbackMessage: '${draft.fileName} 已进入报价依据资料列表。',
    );
  }

  Future<void> _previewAttachment(ProjectAttachmentReadModel attachment) async {
    if (_openingAttachmentIds.contains(attachment.attachmentId)) {
      return;
    }

    setState(() => _openingAttachmentIds.add(attachment.attachmentId));
    final result = await ExhibitionConsumerLayer.instance
        .requestProjectAttachmentAccess(
          fileAssetId: attachment.fileAssetId,
          mode: _projectAttachmentAccessMode(attachment.mimeType),
        );
    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() => _openingAttachmentIds.remove(attachment.attachmentId));
      _showSectionMessage(_projectAttachmentFileAccessFailureMessage(result));
      return;
    }

    final access = _projectAttachmentFileAccessFromPayload(result.payload);
    if (access == null) {
      setState(() => _openingAttachmentIds.remove(attachment.attachmentId));
      _showSectionMessage('当前资料读取结果暂不可用，请稍后再试。');
      return;
    }

    if (_projectAttachmentIsImageMimeType(attachment.mimeType)) {
      final imageBytes = await _loadProjectAttachmentRemoteImageBytes(
        access.accessUrl,
      );
      if (!mounted) {
        return;
      }
      setState(() => _openingAttachmentIds.remove(attachment.attachmentId));
      if (imageBytes != null && imageBytes.isNotEmpty) {
        await _showProjectAttachmentLocalImagePreviewDialog(
          context,
          fileName: attachment.fileName,
          bytes: imageBytes,
        );
        return;
      }

      final opened = await _openProjectAttachmentUrl(access.accessUrl);
      if (!mounted) {
        return;
      }
      _showSectionMessage(
        opened ? '图片预览链接已打开；当前应用内图片暂时无法渲染。' : '当前图片暂时无法预览，请稍后再试。',
      );
      return;
    }

    final previewFile = await _downloadProjectAttachmentPreviewTempFile(
      accessUrl: access.accessUrl,
      fileName: attachment.fileName,
    );
    if (!mounted) {
      return;
    }
    if (previewFile != null) {
      final opened = await _openProjectAttachmentLocalFile(
        previewFile.path,
        mimeType: attachment.mimeType,
      );
      if (!mounted) {
        return;
      }
      if (opened) {
        setState(() => _openingAttachmentIds.remove(attachment.attachmentId));
        _showSectionMessage('已打开资料预览。');
        return;
      }
    }

    final opened = await _openProjectAttachmentUrl(access.accessUrl);
    if (!mounted) {
      return;
    }
    setState(() => _openingAttachmentIds.remove(attachment.attachmentId));
    _showSectionMessage(opened ? '资料链接已打开。' : '资料链接已生成，但当前设备未能直接打开，请稍后再试。');
  }

  void _showSectionMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final kindOption = _projectAttachmentKindOptions.firstWhere(
      (_ProjectAttachmentKindOption item) =>
          item.value == _selectedAttachmentKind,
      orElse: () => _projectAttachmentKindOptions.first,
    );

    return _ActionCard(
      title: widget.title,
      summary: widget.summary,
      children: <Widget>[
        if (widget.showIntroCopy) ...<Widget>[
          const _StateMessage(
            title: '当前说明',
            body:
                '这是 owner-private 报价依据资料补充区。upload confirm 只确认 FileAsset，只有 bind 成功后才会进入报价依据资料列表。',
          ),
          const SizedBox(height: 12),
        ],
        if (!widget.workbenchMode) ...<Widget>[
          _ProjectAttachmentKindPicker(
            selectedValue: _selectedAttachmentKind,
            onChanged: _canChooseAttachment
                ? (String value) {
                    setState(() => _selectedAttachmentKind = value);
                  }
                : null,
          ),
          const SizedBox(height: 12),
        ],
        _ProjectAttachmentRequirementPanel(
          attachments: _attachments,
          selectedDraftsByKind: _selectedDraftsByKind,
          selectedKind: _selectedAttachmentKind,
          openingAttachmentIds: _openingAttachmentIds,
          deletingAttachmentIds: _deletingAttachmentIds,
          onSelectKind: _canChooseAttachment
              ? (String value) {
                  setState(() => _selectedAttachmentKind = value);
                }
              : null,
          onAddKind: _canChooseAttachment
              ? (String value) => _selectAttachment(attachmentKind: value)
              : null,
          onPreviewDraft: (draft) => _previewSelectedDraft(draft),
          onOpenDraft: (draft) => _openSelectedDraft(draft),
          isDraftPreviewing: (draft) =>
              _openingSelectedDraftIds.contains(_draftKey(draft)),
          onRemoveDraft: _canChooseAttachment
              ? (attachmentKind, draft) =>
                    _removeSelectedDraftFromQueue(attachmentKind, draft)
              : null,
          onPreviewAttachment: _previewAttachment,
          onDeleteAttachment: _deleteAttachment,
          workbenchMode: widget.workbenchMode,
        ),
        if (widget.showKindHint) ...<Widget>[
          const SizedBox(height: 12),
          _ProjectAttachmentKindHint(
            option: kindOption,
            compactCopy: widget.compactKindHints,
          ),
        ],
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final chooseButton = FilledButton.tonalIcon(
              onPressed: _canChooseAttachment
                  ? widget.workbenchMode
                        ? _selectAttachmentFromKindSheet
                        : () => _selectAttachment()
                  : null,
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(
                widget.workbenchMode
                    ? '选择资料类型并上传'
                    : _projectAttachmentChooseActionLabel(
                        _selectedAttachmentKind,
                      ),
                textAlign: TextAlign.center,
              ),
            );
            final continueButton = OutlinedButton.icon(
              onPressed: _canChooseAttachment
                  ? () => _selectAttachment(append: true)
                  : null,
              icon: const Icon(Icons.add_rounded),
              label: const Text('继续添加附件', textAlign: TextAlign.center),
            );
            final switchKindButton = OutlinedButton.icon(
              onPressed: _canChooseAttachment
                  ? () {
                      unawaited(_showAttachmentKindSwitchSheet());
                    }
                  : null,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('更换资料类型', textAlign: TextAlign.center),
            );
            final uploadButton = FilledButton(
              onPressed: _canUploadAttachment
                  ? _uploadSelectedAttachment
                  : null,
              child: Text(
                widget.autoUploadOnSelect ? '重试上传' : '上传并形成正式附件',
                textAlign: TextAlign.center,
              ),
            );

            if (!_hasSelectedDrafts || widget.autoUploadOnSelect) {
              return Align(
                alignment: Alignment.centerLeft,
                child: chooseButton,
              );
            }

            if (constraints.maxWidth < 340) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: double.infinity, child: uploadButton),
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: continueButton),
                  const SizedBox(height: 10),
                  SizedBox(width: double.infinity, child: switchKindButton),
                ],
              );
            }

            return Column(
              children: <Widget>[
                SizedBox(width: double.infinity, child: uploadButton),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(child: continueButton),
                    const SizedBox(width: 10),
                    Expanded(child: switchKindButton),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            if (_uploadStatus ==
                    _ProjectAttachmentUploadUiStatus.confirmFailed &&
                _uploadDirective != null &&
                _retryDraft != null)
              OutlinedButton(
                onPressed: _retryConfirmCurrentAttachment,
                child: const Text('再次确认上传结果'),
              ),
            if (_uploadStatus == _ProjectAttachmentUploadUiStatus.bindFailed &&
                _confirmedFileAssetId != null &&
                _retryDraft != null)
              OutlinedButton(
                onPressed: _retryBindCurrentAttachment,
                child: const Text('再次绑定正式附件'),
              ),
            if (widget.projectId != null)
              OutlinedButton(
                onPressed: _loadingList
                    ? null
                    : () => _loadFormalAttachments(forceRefresh: true),
                child: const Text('刷新正式列表'),
              ),
          ],
        ),
        if (widget.workbenchMode) ...<Widget>[
          const SizedBox(height: 10),
          const _ProjectAttachmentAutoUploadNotice(),
        ],
        if (widget.showIdleUploadState ||
            _uploadStatus != _ProjectAttachmentUploadUiStatus.idle ||
            _hasSelectedDrafts) ...<Widget>[
          const SizedBox(height: 12),
          _ProjectAttachmentStatePanel(
            status: _uploadStatus,
            message: _uploadMessage,
            selectedDraft: _firstSelectedDraft,
          ),
        ],
        if (!widget.workbenchMode) ...<Widget>[
          const SizedBox(height: 16),
          _ProjectAttachmentFormalListPanel(
            loading: _loadingList,
            result: _listResult,
            attachments: _attachments,
            emptyMessage: widget.emptyMessage,
            canContinue: widget.projectId != null,
            feedbackMessage: _listFeedbackMessage,
            deletingAttachmentIds: _deletingAttachmentIds,
            onRetry: widget.projectId == null
                ? null
                : () => _loadFormalAttachments(forceRefresh: true),
            openingAttachmentIds: _openingAttachmentIds,
            onPreview: _previewAttachment,
            onDelete: _deleteAttachment,
            autoloaded: widget.autoloadFormalList || _listResult != null,
            showChecklist: false,
            lightEmptyNotice: widget.workbenchMode,
          ),
        ],
      ],
    );
  }

  List<ProjectAttachmentReadModel> get _attachments {
    final model = _projectAttachmentListFromPayload(_listResult?.payload);
    final items = model?.attachments ?? const <ProjectAttachmentReadModel>[];
    return List<ProjectAttachmentReadModel>.from(items)..sort(
      (ProjectAttachmentReadModel left, ProjectAttachmentReadModel right) =>
          right.sortOrder.compareTo(left.sortOrder),
    );
  }

  bool get _canChooseAttachment {
    return _uploadStatus != _ProjectAttachmentUploadUiStatus.initStarting &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.directUploading &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.confirming &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.binding;
  }

  bool get _canUploadAttachment {
    return _hasSelectedDrafts &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.initStarting &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.directUploading &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.confirming &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.binding;
  }
}
