part of '../exhibition_trade_pages.dart';

const String _projectAttachmentBusinessType = 'project';
const String _projectAttachmentFileKind = 'evidence';

class _ProjectAttachmentSection extends StatefulWidget {
  const _ProjectAttachmentSection({
    super.key,
    required this.projectId,
    required this.title,
    required this.summary,
    required this.emptyMessage,
    this.showDemoNotice = false,
  });

  final String? projectId;
  final String title;
  final String summary;
  final String emptyMessage;
  final bool showDemoNotice;

  @override
  State<_ProjectAttachmentSection> createState() =>
      _ProjectAttachmentSectionState();
}

class _ProjectAttachmentSectionState extends State<_ProjectAttachmentSection> {
  _ResolvedProjectAttachmentDraft? _selectedDraft;
  _ProjectAttachmentUiStatus _status = _ProjectAttachmentUiStatus.idle;
  String? _statusMessage;
  UploadDirective? _uploadDirective;

  Future<void> _selectAttachment() async {
    setState(() {
      _status = _ProjectAttachmentUiStatus.selecting;
      _statusMessage = '正在选择项目附件';
    });

    final draft = await _pickProjectAttachmentDraft();
    if (!mounted) {
      return;
    }
    if (draft == null) {
      setState(() {
        _selectedDraft = null;
        _status = _ProjectAttachmentUiStatus.idle;
        _statusMessage = '当前没有选择新附件，可稍后重新选择。';
      });
      return;
    }

    final resolved = _resolveProjectAttachmentDraft(draft);
    if (resolved == null) {
      setState(() {
        _selectedDraft = null;
        _status = _ProjectAttachmentUiStatus.unsupportedType;
        _statusMessage = '当前只支持 PDF、DOC、DOCX 附件。';
      });
      return;
    }

    setState(() {
      _selectedDraft = resolved;
      _status = _ProjectAttachmentUiStatus.selectedReady;
      _statusMessage = '已选中 ${resolved.fileName}，可以继续上传。';
    });
  }

  Future<void> _uploadSelectedAttachment() async {
    final projectId = widget.projectId;
    final draft = _selectedDraft;
    if (projectId == null || draft == null) {
      setState(() {
        _status = _ProjectAttachmentUiStatus.initFailed;
        _statusMessage = '请先承接项目实例，再继续上传当前附件。';
      });
      return;
    }

    setState(() {
      _status = _ProjectAttachmentUiStatus.initStarting;
      _statusMessage = '正在申请当前附件的上传策略';
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
      return;
    }

    final directive = initResult.directive;
    if (initResult.state != AppUploadState.signedReady || directive == null) {
      setState(() {
        _uploadDirective = null;
        _status = _ProjectAttachmentUiStatus.initFailed;
        _statusMessage = '当前附件上传初始化未完成，请稍后重试。';
      });
      return;
    }

    setState(() {
      _uploadDirective = directive;
      _status = _ProjectAttachmentUiStatus.directUploading;
      _statusMessage = '正在上传 ${draft.fileName}';
    });

    final uploadResult = await ExhibitionConsumerLayer.instance.directUpload(
      directive: directive,
      bodyBytes: draft.bytes,
    );

    if (!mounted) {
      return;
    }

    if (uploadResult.state != AppUploadState.uploadConfirming) {
      setState(() {
        _status = _ProjectAttachmentUiStatus.directUploadFailed;
        _statusMessage = '${draft.fileName} 上传未完成，请重新上传当前附件。';
      });
      return;
    }

    await _confirmCurrentAttachment(directive);
  }

  Future<void> _confirmCurrentAttachment(UploadDirective directive) async {
    setState(() {
      _status = _ProjectAttachmentUiStatus.confirming;
      _statusMessage = '正在确认当前附件上传结果';
    });

    final confirmResult = await ExhibitionConsumerLayer.instance.uploadConfirm(
      directive: directive,
    );

    if (!mounted) {
      return;
    }

    if (confirmResult.state != AppUploadState.uploadBound ||
        widget.projectId == null ||
        _selectedDraft == null) {
      setState(() {
        _status = _ProjectAttachmentUiStatus.confirmFailed;
        _statusMessage =
            '${_selectedDraft?.fileName ?? '当前附件'} 确认结果未完成，请再次确认或重新上传。';
      });
      return;
    }

    _ProjectAttachmentSessionStore.rememberConfirmAccepted(
      widget.projectId!,
      _selectedDraft!,
    );
    setState(() {
      _status = _ProjectAttachmentUiStatus.confirmAccepted;
      _statusMessage = '${_selectedDraft!.fileName} 已上传并完成绑定确认，等待项目附件结果返回。';
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = _projectAttachmentRecords();

    return _ActionCard(
      title: widget.title,
      summary: widget.summary,
      children: <Widget>[
        const _StateMessage(
          title: '当前支持范围',
          body:
              '当前只先开放 PDF、DOC、DOCX 附件，且仍严格走 init -> direct upload -> confirm 的正式三步链路。',
        ),
        if (widget.showDemoNotice) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前项目来自演示承接',
            message: '上传仍会尝试走正式链路；如果上游暂不接受当前项目实例，页面会给出受控失败提示，不会提前显示项目附件结果。',
          ),
        ],
        const SizedBox(height: 12),
        if (_selectedDraft != null)
          _SelectedProjectAttachmentCard(draft: _selectedDraft!),
        if (_selectedDraft != null) const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton.tonalIcon(
              onPressed: _canChooseAttachment ? _selectAttachment : null,
              icon: const Icon(Icons.attach_file_rounded),
              label: const Text('选择项目附件'),
            ),
            if (_selectedDraft != null)
              FilledButton(
                onPressed: _canUploadAttachment
                    ? _uploadSelectedAttachment
                    : null,
                child: const Text('上传当前附件'),
              ),
            if (_status == _ProjectAttachmentUiStatus.confirmFailed &&
                _uploadDirective != null)
              OutlinedButton(
                onPressed: () => _confirmCurrentAttachment(_uploadDirective!),
                child: const Text('再次确认上传结果'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _ProjectAttachmentStatePanel(
          status: _status,
          message: _statusMessage,
          selectedDraft: _selectedDraft,
        ),
        const SizedBox(height: 16),
        _ProjectAttachmentList(
          records: records,
          emptyMessage: widget.emptyMessage,
          canContinue: widget.projectId != null,
        ),
      ],
    );
  }

  bool get _canChooseAttachment {
    return _status != _ProjectAttachmentUiStatus.initStarting &&
        _status != _ProjectAttachmentUiStatus.directUploading &&
        _status != _ProjectAttachmentUiStatus.confirming;
  }

  bool get _canUploadAttachment {
    return _selectedDraft != null &&
        _status != _ProjectAttachmentUiStatus.initStarting &&
        _status != _ProjectAttachmentUiStatus.directUploading &&
        _status != _ProjectAttachmentUiStatus.confirming;
  }

  List<_ProjectAttachmentRecord> _projectAttachmentRecords() {
    final projectId = widget.projectId;
    if (projectId == null) {
      return const <_ProjectAttachmentRecord>[];
    }

    return _ProjectAttachmentSessionStore.read(projectId);
  }
}
