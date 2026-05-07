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
  });

  final ProjectCommunicationWorkbenchEntryView entry;
  final Future<bool> Function(ProjectCommunicationWorkbenchEntryView entry)
  onConfirm;
  final Future<bool> Function(
    ProjectCommunicationWorkbenchEntryView entry,
    String feedbackText,
  )
  onFeedback;

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
          if (entry.canSubmitReview) ...<Widget>[
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
              label: Text(_submitting ? '提交中...' : '确认无误'),
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
            _InfoBand(
              icon: Icons.lock_outline,
              text: entry.availabilityState == 'unsubmitted'
                  ? '当前资料尚未提交，不能确认。'
                  : '当前账号只能查看该资料审阅结果。',
            ),
          ],
        ],
      ),
    );
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
          '资料文件',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        for (final file in _files)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.insert_drive_file_outlined),
            title: Text(file.title),
            subtitle: Text(file.subtitle),
            trailing: _loadingPreviewFileIds.contains(file.fileAssetId)
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: () => _openFilePreview(file),
                    child: Text(
                      _previewedFileIds.contains(file.fileAssetId)
                          ? '已预览'
                          : '预览',
                    ),
                  ),
            onTap: _loadingPreviewFileIds.contains(file.fileAssetId)
                ? null
                : () => _openFilePreview(file),
          ),
      ],
    );
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
    if (mounted && !_previewedFileIds.contains(file.fileAssetId)) {
      setState(() => _previewedFileIds.add(file.fileAssetId));
    }

    final accessUrl = access.accessUrl?.trim();
    if (access.canPreview &&
        access.previewType == 'image' &&
        accessUrl != null &&
        accessUrl.isNotEmpty) {
      await _showProjectAttachmentNetworkImagePreviewDialog(
        context,
        fileName: access.fileName ?? file.title,
        imageUrl: accessUrl,
      );
      return;
    }
    await _showWorkbenchFilePreviewDialog(access);
  }

  bool get _allFilesPreviewed {
    if (_files.isEmpty) {
      return false;
    }
    return _files.every((file) => _previewedFileIds.contains(file.fileAssetId));
  }

  Future<void> _showWorkbenchFilePreviewDialog(
    ProjectCommunicationFilePreviewAccessView preview,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final accessUrl = preview.accessUrl?.trim();
        final canOpen =
            preview.canPreview && accessUrl != null && accessUrl.isNotEmpty;
        return AlertDialog(
          title: const Text('资料预览'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                preview.fileName ?? preview.fileAssetId,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                canOpen
                    ? '${_previewTypeLabel(preview.previewType)}预览链接已就绪。'
                    : preview.fallbackReason ?? '当前资料暂不支持在线预览。',
              ),
              if (preview.mimeType != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  preview.mimeType!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
            if (canOpen)
              FilledButton(
                onPressed: () {
                  unawaited(_openProjectAttachmentUrl(accessUrl));
                },
                child: const Text('打开预览'),
              ),
          ],
        );
      },
    );
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

class _WorkbenchStatusHeader extends StatelessWidget {
  const _WorkbenchStatusHeader({required this.entry});

  final ProjectCommunicationWorkbenchEntryView entry;

  @override
  Widget build(BuildContext context) {
    return _InfoBand(
      icon: entry.reviewState == 'needs_supplement'
          ? Icons.error_outline
          : Icons.assignment_turned_in_outlined,
      text: '${entry.label} · ${entry.reviewState ?? entry.availabilityState}',
      isError: entry.reviewState == 'needs_supplement',
    );
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
