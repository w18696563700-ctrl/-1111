part of '../exhibition_trade_pages.dart';

final class _WorkbenchSourceFile {
  const _WorkbenchSourceFile({
    required this.title,
    required this.subtitle,
    required this.fileAssetId,
  });

  final String title;
  final String subtitle;
  final String fileAssetId;
}

class _ProjectCommunicationMaterialReviewDetailPage extends StatefulWidget {
  const _ProjectCommunicationMaterialReviewDetailPage({
    required this.entry,
    required this.onConfirm,
    required this.onFeedback,
    this.onOpenPublisherSupplement,
    this.onOpenBidMaterialSupplement,
  });

  final ProjectCommunicationWorkbenchEntryView entry;
  final Future<bool> Function(ProjectCommunicationWorkbenchEntryView entry)
  onConfirm;
  final Future<bool> Function(
    ProjectCommunicationWorkbenchEntryView entry,
    String feedbackText,
  )
  onFeedback;
  final ValueChanged<ProjectCommunicationWorkbenchEntryView>?
  onOpenPublisherSupplement;
  final ValueChanged<ProjectCommunicationWorkbenchEntryView>?
  onOpenBidMaterialSupplement;

  @override
  State<_ProjectCommunicationMaterialReviewDetailPage> createState() =>
      _ProjectCommunicationMaterialReviewDetailPageState();
}

class _ProjectCommunicationMaterialReviewDetailPageState
    extends State<_ProjectCommunicationMaterialReviewDetailPage> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _loadingFiles = true;
  bool _submitting = false;
  List<_WorkbenchSourceFile> _files = const <_WorkbenchSourceFile>[];
  String? _fileMessage;
  final Map<String, ProjectCommunicationFilePreviewAccessView> _previewCache =
      <String, ProjectCommunicationFilePreviewAccessView>{};
  final Set<String> _loadingPreviewFileIds = <String>{};
  final Set<String> _previewedFileIds = <String>{};

  @override
  void initState() {
    super.initState();
    unawaited(_loadFiles());
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    final entry = widget.entry;
    if (entry.sourceFiles.isNotEmpty) {
      setState(() {
        _loadingFiles = false;
        _files = entry.sourceFiles
            .map(
              (item) => _WorkbenchSourceFile(
                title: item.fileName,
                subtitle: item.mimeType,
                fileAssetId: item.fileAssetId,
              ),
            )
            .toList(growable: false);
      });
      return;
    }
    if (entry.group == 'publisher_materials') {
      final result = await ExhibitionConsumerLayer.instance
          .loadProjectBidMaterials(projectId: entry.projectId);
      if (!mounted) return;
      if (result.state != AppPageState.content) {
        setState(() {
          _loadingFiles = false;
          _fileMessage = result.message ?? '资料暂不可读';
        });
        return;
      }
      final list = ProjectBidMaterialListReadModel.fromPayload(result.payload);
      setState(() {
        _loadingFiles = false;
        _files = list.attachments
            .where(
              (item) => item.attachmentKind == entry.truthAnchor.materialKind,
            )
            .map(
              (item) => _WorkbenchSourceFile(
                title: item.fileName,
                subtitle: item.mimeType,
                fileAssetId: item.fileAssetId,
              ),
            )
            .toList(growable: false);
      });
      return;
    }
    if (entry.group == 'bid_materials') {
      final result = await TradingImConsumerLayer.instance
          .loadBidSubmissionSnapshot(
            projectId: entry.projectId,
            bidId: entry.bidId,
          );
      if (!mounted) return;
      if (result.state != AppPageState.content || result.data == null) {
        setState(() {
          _loadingFiles = false;
          _fileMessage = result.message ?? '竞标资料暂不可读';
        });
        return;
      }
      setState(() {
        _loadingFiles = false;
        _files = result.data!.attachments
            .where((item) => item.slotKey == entry.truthAnchor.bidMaterialSlot)
            .map(
              (item) => _WorkbenchSourceFile(
                title: item.slotLabel,
                subtitle: item.mimeType,
                fileAssetId: item.fileAssetId,
              ),
            )
            .toList(growable: false);
      });
      return;
    }
    setState(() {
      _loadingFiles = false;
      _fileMessage = '合同与最终金额确认入口暂不触发扣费，待后续门禁开启。';
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Scaffold(
      appBar: AppBar(title: Text(entry.label)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: <Widget>[
          _WorkbenchStatusHeader(entry: entry),
          const SizedBox(height: 16),
          _sourceSection(context),
          const SizedBox(height: 16),
          if (entry.latestFeedbackText != null)
            _InfoBand(
              icon: Icons.error_outline_rounded,
              text: '最近反馈：${entry.latestFeedbackText}',
              isError: true,
            ),
          if (_shouldShowPublisherSupplementAction) ...<Widget>[
            const SizedBox(height: 16),
            const _InfoBand(
              icon: Icons.lock_outline,
              text: '当前项目沟通仍处于锁定状态，请从真实项目资料页补充对应资料；补充成功后系统会通知竞标方重新确认。',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  widget.onOpenPublisherSupplement?.call(widget.entry),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('去补充该资料'),
            ),
          ],
          if (_shouldShowBidMaterialSupplementAction) ...<Widget>[
            const SizedBox(height: 16),
            const _InfoBand(
              icon: Icons.lock_outline,
              text: '当前项目沟通仍处于锁定状态，请回到竞标提交页补充项目理解、报价表或进度安排；补充成功后发布方可重新确认。',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () =>
                  widget.onOpenBidMaterialSupplement?.call(widget.entry),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('去补充竞标资料'),
            ),
          ],
          if (_canSubmitCurrentReview) ...<Widget>[
            const SizedBox(height: 16),
            if (!_allFilesPreviewed)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _InfoBand(
                  icon: Icons.visibility_outlined,
                  text: '请先预览当前资料，确认内容无误后再提交确认。',
                ),
              ),
            FilledButton.icon(
              onPressed: _submitting || !_allFilesPreviewed ? null : _confirm,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                _submitting
                    ? '提交中...'
                    : _allFilesPreviewed
                    ? '确认无误'
                    : '预览后确认',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '意见反馈',
                hintText: '例如：缺少正视图、俯视图或材料品牌说明',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _submitting ? null : _feedback,
              icon: const Icon(Icons.report_gmailerrorred_outlined),
              label: const Text('需要补充'),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 16),
            _InfoBand(icon: Icons.lock_outline, text: _readonlyReviewMessage),
          ],
        ],
      ),
    );
  }

  String get _readonlyReviewMessage {
    final entry = widget.entry;
    if (entry.availabilityState == 'unsubmitted') {
      return '当前资料尚未提交，不能确认。';
    }
    if (_shouldShowBidMaterialSupplementAction) {
      return '请先补充竞标资料，补充成功后等待发布方重新确认。';
    }
    if (_shouldShowPublisherSupplementAction) {
      return '请先补充该资料，补充成功后等待对方重新确认。';
    }
    return '当前账号只能查看该资料审阅结果。';
  }

  bool get _canSubmitCurrentReview {
    return widget.entry.canSubmitReview &&
        !_shouldShowPublisherSupplementAction &&
        !_shouldShowBidMaterialSupplementAction;
  }

  bool get _shouldShowPublisherSupplementAction {
    return widget.entry.group == 'publisher_materials' &&
        widget.entry.viewerRole == 'publisher' &&
        widget.entry.subjectOwnerRole == 'publisher' &&
        widget.entry.reviewState == 'needs_supplement' &&
        widget.onOpenPublisherSupplement != null;
  }

  bool get _shouldShowBidMaterialSupplementAction {
    return widget.entry.group == 'bid_materials' &&
        widget.entry.viewerRole == 'bidder' &&
        widget.entry.subjectOwnerRole == 'bidder' &&
        widget.entry.reviewState == 'needs_supplement' &&
        widget.onOpenBidMaterialSupplement != null;
  }

  Widget _sourceSection(BuildContext context) {
    final theme = Theme.of(context);
    if (_loadingFiles) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_fileMessage != null) {
      return _InfoBand(icon: Icons.info_outline, text: _fileMessage!);
    }
    if (_files.isEmpty) {
      return const _InfoBand(icon: Icons.info_outline, text: '当前资料尚未提交');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          _sourceSectionTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < _files.length; index += 1) ...<Widget>[
          if (index > 0) const SizedBox(height: 10),
          _WorkbenchSourceFileCard(
            file: _files[index],
            previewed: _previewedFileIds.contains(_files[index].fileAssetId),
            loading: _loadingPreviewFileIds.contains(_files[index].fileAssetId),
            onPreview: () => _openFilePreview(_files[index]),
          ),
        ],
      ],
    );
  }

  String get _sourceSectionTitle {
    return switch (widget.entry.group) {
      'publisher_materials' => '发布方上传资料',
      'bid_materials' => '竞标方提交资料',
      _ => '资料文件',
    };
  }

  Future<void> _openFilePreview(_WorkbenchSourceFile file) async {
    var access = _previewCache[file.fileAssetId];
    if (access == null) {
      setState(() => _loadingPreviewFileIds.add(file.fileAssetId));
      final result = await CounterpartConversationConsumerLayer.instance
          .loadProjectCommunicationFilePreviewAccess(
            projectId: widget.entry.projectId,
            threadId: widget.entry.threadId,
            fileAssetId: file.fileAssetId,
          );
      if (!mounted) return;
      setState(() => _loadingPreviewFileIds.remove(file.fileAssetId));
      access = result.data;
      if (result.state != AppPageState.content || access == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message ?? '当前资料暂不可预览。')));
        return;
      }
      _previewCache[file.fileAssetId] = access;
    }
    final accessUrl = access.accessUrl?.trim();
    var previewSucceeded = false;
    if (access.canPreview &&
        access.previewType == 'image' &&
        accessUrl != null &&
        accessUrl.isNotEmpty) {
      setState(() => _loadingPreviewFileIds.add(file.fileAssetId));
      final imageBytes = await _loadProjectAttachmentRemoteImageBytes(
        accessUrl,
      );
      if (!mounted) return;
      setState(() => _loadingPreviewFileIds.remove(file.fileAssetId));
      if (imageBytes == null || imageBytes.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('当前图片资料暂时无法预览，请稍后再试。')));
        return;
      }
      final decodable = await _canDecodeProjectAttachmentImagePreviewBytes(
        imageBytes,
      );
      if (!mounted) return;
      if (!decodable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('当前图片资料暂时无法解析，请联系对方重新上传。')),
        );
        return;
      }
      await _showProjectAttachmentLocalImagePreviewDialog(
        context,
        fileName: access.fileName ?? file.title,
        bytes: imageBytes,
      );
      previewSucceeded = true;
    } else {
      if (accessUrl == null || accessUrl.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('当前资料暂时没有可用预览链接，请刷新后重试。')));
        return;
      }
      if (access.previewType == 'pdf') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF 内嵌预览能力暂未接入，当前不能确认该资料。')),
        );
        return;
      }
      setState(() => _loadingPreviewFileIds.add(file.fileAssetId));
      final bytes = await _loadProjectAttachmentRemoteBytes(
        accessUrl,
        maxBytes: _projectAttachmentRemoteFilePreviewMaxBytes,
      );
      if (!mounted) return;
      setState(() => _loadingPreviewFileIds.remove(file.fileAssetId));
      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('当前资料暂时无法载入，请稍后再试。')));
        return;
      }
      previewSucceeded = await _showProjectCommunicationInAppFilePreviewDialog(
        context,
        preview: access,
        bytes: bytes,
      );
      if (!mounted) return;
      if (!previewSucceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('当前资料暂无法在 App 内预览，不能提交确认。')),
        );
      }
    }

    if (!mounted) return;
    if (previewSucceeded && !_previewedFileIds.contains(file.fileAssetId)) {
      setState(() => _previewedFileIds.add(file.fileAssetId));
    }
  }

  bool get _allFilesPreviewed {
    if (_files.isEmpty) {
      return false;
    }
    return _files.every((file) => _previewedFileIds.contains(file.fileAssetId));
  }

  Future<void> _confirm() async {
    setState(() => _submitting = true);
    final ok = await widget.onConfirm(widget.entry);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop();
  }

  Future<void> _feedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先填写需要补充的内容。')));
      return;
    }
    setState(() => _submitting = true);
    final ok = await widget.onFeedback(widget.entry, text);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) Navigator.of(context).pop();
  }
}

class _InfoBand extends StatelessWidget {
  const _InfoBand({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isError
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isError
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.28)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? theme.colorScheme.error
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Icon(icon, color: foreground),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foreground,
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
