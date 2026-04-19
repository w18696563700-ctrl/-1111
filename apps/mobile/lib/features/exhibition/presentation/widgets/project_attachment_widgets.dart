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
  });

  final String? projectId;
  final String title;
  final String? summary;
  final String emptyMessage;
  final bool autoloadFormalList;
  final bool showIntroCopy;
  final bool compactKindHints;

  @override
  State<_ProjectAttachmentSection> createState() =>
      _ProjectAttachmentSectionState();
}

class _ProjectAttachmentSectionState extends State<_ProjectAttachmentSection> {
  String _selectedAttachmentKind = _projectAttachmentKindEffectImage;
  final List<_ResolvedProjectAttachmentDraft> _selectedDrafts =
      <_ResolvedProjectAttachmentDraft>[];
  _ProjectAttachmentUploadUiStatus _uploadStatus =
      _ProjectAttachmentUploadUiStatus.idle;
  String? _uploadMessage;
  UploadDirective? _uploadDirective;
  String? _confirmedFileAssetId;
  _ResolvedProjectAttachmentDraft? _retryDraft;
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

    _selectedDrafts.clear();
    _uploadDirective = null;
    _confirmedFileAssetId = null;
    _retryDraft = null;
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

  bool _containsDraft(_ResolvedProjectAttachmentDraft draft) {
    final targetKey = _draftKey(draft);
    return _selectedDrafts.any(
      (_ResolvedProjectAttachmentDraft item) => _draftKey(item) == targetKey,
    );
  }

  void _removeDraft(_ResolvedProjectAttachmentDraft draft) {
    final targetKey = _draftKey(draft);
    _selectedDrafts.removeWhere(
      (_ResolvedProjectAttachmentDraft item) => _draftKey(item) == targetKey,
    );
    _openingSelectedDraftIds.remove(targetKey);
  }

  _ResolvedProjectAttachmentDraft? get _firstSelectedDraft {
    if (_selectedDrafts.isEmpty) {
      return null;
    }
    return _selectedDrafts.first;
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
  }

  Future<void> _selectAttachment({bool append = false}) async {
    setState(() {
      _uploadStatus = _ProjectAttachmentUploadUiStatus.selecting;
      _uploadMessage = append ? '正在继续选择项目附件' : '正在选择项目附件';
    });

    final draft = await _pickProjectAttachmentDraft();
    if (!mounted) {
      return;
    }
    if (draft == null) {
      setState(() {
        _uploadStatus = _selectedDrafts.isEmpty
            ? _ProjectAttachmentUploadUiStatus.idle
            : _ProjectAttachmentUploadUiStatus.selectedReady;
        _uploadMessage = _selectedDrafts.isEmpty
            ? '当前没有选择新附件，可稍后重新选择。'
            : '当前没有继续添加新附件，已选中的 ${_selectedDrafts.length} 个附件仍可继续上传。';
      });
      return;
    }

    final resolved = _resolveProjectAttachmentDraft(draft);
    if (resolved == null) {
      setState(() {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.unsupportedType;
        _uploadMessage = '当前只支持图片、PDF、DOC、DOCX 文件。';
      });
      return;
    }

    if (!_projectAttachmentKindMatchesMimeType(
      _selectedAttachmentKind,
      resolved.mimeType,
    )) {
      setState(() {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.unsupportedType;
        _uploadMessage = _projectAttachmentUnsupportedTypeMessage(
          _selectedAttachmentKind,
        );
      });
      return;
    }

    if (_containsDraft(resolved)) {
      setState(() {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.selectedReady;
        _uploadMessage = '${resolved.fileName} 已在待上传列表中，无需重复添加。';
      });
      return;
    }

    setState(() {
      _selectedDrafts.add(resolved);
      _uploadDirective = null;
      _confirmedFileAssetId = null;
      _retryDraft = null;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.selectedReady;
      _uploadMessage = _selectedDrafts.length == 1
          ? '已选中 ${resolved.fileName}，可以继续上传并形成正式附件。'
          : '已加入 ${resolved.fileName}。当前共 ${_selectedDrafts.length} 个附件，可以继续添加后一次上传。';
    });
  }

  Future<void> _uploadSelectedAttachment() async {
    final projectId = widget.projectId;
    final queuedDrafts = List<_ResolvedProjectAttachmentDraft>.from(
      _selectedDrafts,
    );
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
    for (final _ResolvedProjectAttachmentDraft draft in queuedDrafts) {
      final succeeded = await _uploadDraft(
        projectId: projectId,
        draft: draft,
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
                ? '${successNames.first} 已进入项目文书列表。'
                : '已回读 ${successNames.length} 个新文书。',
          );
        }
        return;
      }
      setState(() {
        _removeDraft(draft);
      });
      successNames.add(draft.fileName);
      nextSortOrder += 1;
    }

    setState(() {
      _uploadDirective = null;
      _confirmedFileAssetId = null;
      _retryDraft = null;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.bindSucceeded;
      _uploadMessage = successNames.length == 1
          ? '${successNames.first} 已形成项目文书。最终列表以后端项目文书读侧回读为准。'
          : '已形成 ${successNames.length} 个项目文书。最终列表以后端项目文书读侧回读为准。';
    });
    ExhibitionConsumerLayer.instance.invalidateProjectAttachments(
      projectId: projectId,
    );
    await _loadFormalAttachments(
      forceRefresh: true,
      feedbackMessage: successNames.length == 1
          ? '${successNames.first} 已进入项目文书列表。'
          : '已回读 ${successNames.length} 个新文书。',
    );
  }

  Future<bool> _uploadDraft({
    required String projectId,
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
      draft: draft,
      draftIndex: draftIndex,
      totalDraftCount: totalDraftCount,
      sortOrder: sortOrder,
    );
  }

  Future<bool> _confirmCurrentAttachment(
    UploadDirective directive, {
    _ResolvedProjectAttachmentDraft? draft,
    int? draftIndex,
    int? totalDraftCount,
    int? sortOrder,
  }) async {
    final resolvedDraft = draft ?? _retryDraft ?? _firstSelectedDraft;
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
        _confirmedFileAssetId = null;
        _uploadStatus = _ProjectAttachmentUploadUiStatus.confirmFailed;
        _uploadMessage = '${resolvedDraft.fileName} 的确认结果未形成可绑定文件，请重新上传。';
      });
      return false;
    }

    _confirmedFileAssetId = fileAssetId;
    _retryDraft = resolvedDraft;
    return _bindConfirmedAttachment(
      fileAssetId: fileAssetId,
      draft: resolvedDraft,
      draftIndex: draftIndex,
      totalDraftCount: totalDraftCount,
      sortOrder: sortOrder,
    );
  }

  Future<bool> _bindConfirmedAttachment({
    required String fileAssetId,
    _ResolvedProjectAttachmentDraft? draft,
    int? draftIndex,
    int? totalDraftCount,
    int? sortOrder,
  }) async {
    final projectId = widget.projectId;
    final resolvedDraft = draft ?? _retryDraft ?? _firstSelectedDraft;
    if (projectId == null || resolvedDraft == null) {
      return false;
    }

    setState(() {
      _uploadStatus = _ProjectAttachmentUploadUiStatus.binding;
      _uploadMessage =
          totalDraftCount != null && totalDraftCount > 1 && draftIndex != null
          ? '正在绑定第 $draftIndex/$totalDraftCount 个附件：${resolvedDraft.fileName}'
          : '正在把已确认文件绑定成正式项目附件';
    });

    final result = await ExhibitionConsumerLayer.instance.bindProjectAttachment(
      projectId: projectId,
      command: ProjectAttachmentBindCommand(
        fileAssetId: fileAssetId,
        fileName: resolvedDraft.fileName,
        attachmentKind: _selectedAttachmentKind,
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
      feedbackMessage: '${attachment.fileName} 已从项目文书列表移除。',
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
      final opened = await _openProjectAttachmentLocalFile(file.path);
      if (!mounted) {
        return;
      }
      _showSectionMessage(
        opened ? '已在系统中打开当前附件。' : '当前设备暂时不能直接打开这个附件，请上传成功后再试远程预览。',
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

  void _removeSelectedDraftFromQueue(_ResolvedProjectAttachmentDraft draft) {
    setState(() {
      final targetKey = _draftKey(draft);
      _removeDraft(draft);
      if (_retryDraft != null && _draftKey(_retryDraft!) == targetKey) {
        _retryDraft = null;
        _uploadDirective = null;
        _confirmedFileAssetId = null;
      }
      if (_selectedDrafts.isEmpty) {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.idle;
        _uploadMessage = '当前待上传附件已清空，可重新选择。';
      } else {
        _uploadStatus = _ProjectAttachmentUploadUiStatus.selectedReady;
        _uploadMessage =
            '已移除 ${draft.fileName}。剩余 ${_selectedDrafts.length} 个待上传附件。';
      }
    });
  }

  Future<void> _retryConfirmCurrentAttachment() async {
    final draft = _retryDraft;
    final directive = _uploadDirective;
    if (draft == null || directive == null) {
      return;
    }
    final succeeded = await _confirmCurrentAttachment(directive, draft: draft);
    if (!mounted || !succeeded) {
      return;
    }
    setState(() {
      _removeDraft(draft);
      _retryDraft = null;
      _uploadDirective = null;
      _confirmedFileAssetId = null;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.bindSucceeded;
      _uploadMessage = '${draft.fileName} 已形成项目文书。最终列表以后端项目文书读侧回读为准。';
    });
    ExhibitionConsumerLayer.instance.invalidateProjectAttachments(
      projectId: widget.projectId,
    );
    await _loadFormalAttachments(
      forceRefresh: true,
      feedbackMessage: '${draft.fileName} 已进入项目文书列表。',
    );
  }

  Future<void> _retryBindCurrentAttachment() async {
    final draft = _retryDraft;
    final fileAssetId = _confirmedFileAssetId;
    if (draft == null || fileAssetId == null) {
      return;
    }
    final succeeded = await _bindConfirmedAttachment(
      fileAssetId: fileAssetId,
      draft: draft,
    );
    if (!mounted || !succeeded) {
      return;
    }
    setState(() {
      _removeDraft(draft);
      _retryDraft = null;
      _uploadDirective = null;
      _confirmedFileAssetId = null;
      _uploadStatus = _ProjectAttachmentUploadUiStatus.bindSucceeded;
      _uploadMessage = '${draft.fileName} 已形成项目文书。最终列表以后端项目文书读侧回读为准。';
    });
    ExhibitionConsumerLayer.instance.invalidateProjectAttachments(
      projectId: widget.projectId,
    );
    await _loadFormalAttachments(
      forceRefresh: true,
      feedbackMessage: '${draft.fileName} 已进入项目文书列表。',
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
      _showSectionMessage('当前文书预览结果暂不可用，请稍后再试。');
      return;
    }

    setState(() => _openingAttachmentIds.remove(attachment.attachmentId));
    if (_projectAttachmentIsImageMimeType(attachment.mimeType)) {
      await _showProjectAttachmentRemoteImagePreviewDialog(
        context,
        attachment: attachment,
        access: access,
      );
      return;
    }

    final opened = await _openProjectAttachmentUrl(access.accessUrl);
    if (!mounted) {
      return;
    }
    _showSectionMessage(opened ? '已打开文书预览。' : '预览链接已生成，但当前设备未能直接打开，请稍后再试。');
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
                '这是 owner-private 项目文书补充区。upload confirm 只确认 FileAsset，只有 bind 成功后才会进入项目文书列表。',
          ),
          const SizedBox(height: 12),
        ],
        _ProjectAttachmentKindPicker(
          selectedValue: _selectedAttachmentKind,
          onChanged: _canChooseAttachment
              ? (String value) {
                  setState(() {
                    _selectedAttachmentKind = value;
                    if (_selectedDrafts.any(
                      (_ResolvedProjectAttachmentDraft draft) =>
                          !_projectAttachmentKindMatchesMimeType(
                            value,
                            draft.mimeType,
                          ),
                    )) {
                      _selectedDrafts.clear();
                      _openingSelectedDraftIds.clear();
                      _retryDraft = null;
                      _uploadDirective = null;
                      _confirmedFileAssetId = null;
                      _uploadStatus = _ProjectAttachmentUploadUiStatus.idle;
                      _uploadMessage = null;
                    }
                  });
                }
              : null,
        ),
        const SizedBox(height: 12),
        _ProjectAttachmentKindHint(
          option: kindOption,
          compactCopy: widget.compactKindHints,
        ),
        if (_selectedDrafts.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            '待上传附件（${_selectedDrafts.length}）',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ..._selectedDrafts.asMap().entries.map((
            MapEntry<int, _ResolvedProjectAttachmentDraft> entry,
          ) {
            final draft = entry.value;
            final isLast = entry.key == _selectedDrafts.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: _SelectedProjectAttachmentCard(
                draft: draft,
                attachmentKind: _selectedAttachmentKind,
                onPreview: _projectAttachmentCanOpenLocally(draft.mimeType)
                    ? () => _previewSelectedDraft(draft)
                    : null,
                previewing: _openingSelectedDraftIds.contains(_draftKey(draft)),
                onRemove: _canChooseAttachment
                    ? () => _removeSelectedDraftFromQueue(draft)
                    : null,
              ),
            );
          }),
        ],
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final chooseButton = FilledButton.tonalIcon(
              onPressed: _canChooseAttachment
                  ? () => _selectAttachment()
                  : null,
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(
                _projectAttachmentChooseActionLabel(_selectedAttachmentKind),
                textAlign: TextAlign.center,
              ),
            );
            final continueButton = OutlinedButton.icon(
              onPressed: _canChooseAttachment
                  ? () => _selectAttachment(append: true)
                  : null,
              icon: const Icon(Icons.add_rounded),
              label: const Text('继续添加', textAlign: TextAlign.center),
            );
            final uploadButton = FilledButton(
              onPressed: _canUploadAttachment
                  ? _uploadSelectedAttachment
                  : null,
              child: const Text('上传并形成正式附件', textAlign: TextAlign.center),
            );

            // The published materials corridor intentionally keeps a queue-style
            // intake so owners can continue adding multiple files before one
            // controlled upload pass, with the upload CTA anchored on the right.
            if (_selectedDrafts.isEmpty) {
              return Align(
                alignment: Alignment.centerLeft,
                child: chooseButton,
              );
            }

            if (constraints.maxWidth < 340) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(child: chooseButton),
                      const SizedBox(width: 10),
                      Expanded(child: continueButton),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: uploadButton),
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(flex: 4, child: chooseButton),
                const SizedBox(width: 10),
                Expanded(flex: 3, child: continueButton),
                const SizedBox(width: 10),
                Expanded(flex: 5, child: uploadButton),
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
        const SizedBox(height: 12),
        _ProjectAttachmentStatePanel(
          status: _uploadStatus,
          message: _uploadMessage,
          selectedDraft: _firstSelectedDraft,
        ),
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
        ),
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
    return _selectedDrafts.isNotEmpty &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.initStarting &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.directUploading &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.confirming &&
        _uploadStatus != _ProjectAttachmentUploadUiStatus.binding;
  }
}
