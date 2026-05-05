part of '../exhibition_trade_pages.dart';

const String _projectAlbumFileKind = 'project_album_photo';
const int _projectAlbumLimit = 50;

class _ProjectAlbumCategoryOption {
  const _ProjectAlbumCategoryOption({
    required this.value,
    required this.label,
    required this.summary,
  });

  final String value;
  final String label;
  final String summary;
}

const List<_ProjectAlbumCategoryOption> _projectAlbumCategories =
    <_ProjectAlbumCategoryOption>[
      _ProjectAlbumCategoryOption(
        value: 'contract',
        label: '合同照片',
        summary: '合同、确认单、项目边界类照片。',
      ),
      _ProjectAlbumCategoryOption(
        value: 'progress',
        label: '进度照片',
        summary: '施工过程、现场进度类照片。',
      ),
      _ProjectAlbumCategoryOption(
        value: 'final',
        label: '最终呈现',
        summary: '完工后最终呈现照片。',
      ),
      _ProjectAlbumCategoryOption(
        value: 'defect',
        label: '项目瑕疵',
        summary: '瑕疵、整改、争议辅助照片。',
      ),
    ];

class _ProjectAlbumSection extends StatefulWidget {
  const _ProjectAlbumSection({required this.projectId, this.threadId});

  final String projectId;
  final String? threadId;

  @override
  State<_ProjectAlbumSection> createState() => _ProjectAlbumSectionState();
}

class _ProjectAlbumSectionState extends State<_ProjectAlbumSection> {
  String _selectedCategory = 'progress';
  CounterpartConversationResult<ProjectAlbumPhotoListView>? _result;
  bool _loading = false;
  bool _uploading = false;
  String? _feedback;
  final Set<String> _deletingPhotoIds = <String>{};
  final Set<String> _loadingPreviewPhotoIds = <String>{};
  final Map<String, ProjectCommunicationFilePreviewAccessView> _previewCache =
      <String, ProjectCommunicationFilePreviewAccessView>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _ProjectAlbumSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      _result = null;
      _feedback = null;
      _deletingPhotoIds.clear();
      _load();
    }
  }

  List<ProjectAlbumPhotoView> get _photos {
    return _result?.data?.items ?? const <ProjectAlbumPhotoView>[];
  }

  List<ProjectAlbumPhotoView> get _selectedPhotos {
    return _photos
        .where(
          (ProjectAlbumPhotoView photo) => photo.category == _selectedCategory,
        )
        .toList(growable: false);
  }

  Future<void> _load({String? feedback}) async {
    setState(() {
      _loading = true;
      _feedback = feedback;
    });
    final result = await CounterpartConversationConsumerLayer.instance
        .loadProjectAlbumPhotos(projectId: widget.projectId);
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Future<void> _selectAndUpload() async {
    if (_uploading) {
      return;
    }
    if (_photos.length >= _projectAlbumLimit) {
      setState(() => _feedback = '当前项目相册最多 50 张，已达到上限。');
      return;
    }
    setState(() {
      _uploading = true;
      _feedback = '正在选择项目相册图片。';
    });
    final draft = await _pickProjectAttachmentDraft(imageOnly: true);
    if (!mounted) {
      return;
    }
    if (draft == null) {
      setState(() {
        _uploading = false;
        _feedback = '未选择图片。';
      });
      return;
    }
    final resolved = _resolveProjectAttachmentDraft(draft);
    if (resolved == null || !resolved.mimeType.startsWith('image/')) {
      setState(() {
        _uploading = false;
        _feedback = '项目相册只支持 PNG、JPEG、WEBP 图片。';
      });
      return;
    }
    await _uploadResolvedPhoto(resolved);
  }

  Future<void> _uploadResolvedPhoto(
    _ResolvedProjectAttachmentDraft draft,
  ) async {
    setState(() => _feedback = '正在申请相册图片上传。');
    final init = await ExhibitionConsumerLayer.instance.uploadInit(
      UploadInitCommand(
        businessType: _projectAttachmentBusinessType,
        businessId: widget.projectId,
        fileKind: _projectAlbumFileKind,
        mimeType: draft.mimeType,
        size: draft.sizeInBytes,
        checksum: draft.checksum,
      ),
    );
    if (!mounted) {
      return;
    }
    final directive = init.directive;
    if (init.state != AppUploadState.signedReady || directive == null) {
      setState(() {
        _uploading = false;
        _feedback = init.message ?? '相册图片上传初始化失败。';
      });
      return;
    }

    setState(() => _feedback = '正在直传相册图片。');
    final direct = await ExhibitionConsumerLayer.instance.directUpload(
      directive: directive,
      bodyBytes: draft.bytes,
    );
    if (!mounted) {
      return;
    }
    if (direct.state != AppUploadState.uploadConfirming) {
      setState(() {
        _uploading = false;
        _feedback = direct.message ?? '相册图片直传失败。';
      });
      return;
    }

    setState(() => _feedback = '正在确认相册图片上传。');
    final confirm = await ExhibitionConsumerLayer.instance.uploadConfirm(
      directive: directive,
    );
    if (!mounted) {
      return;
    }
    final fileAssetId = confirm.fileAssetId?.trim();
    if (confirm.state != AppUploadState.uploadBound ||
        fileAssetId == null ||
        fileAssetId.isEmpty) {
      setState(() {
        _uploading = false;
        _feedback = confirm.message ?? '相册图片确认失败。';
      });
      return;
    }

    setState(() => _feedback = '正在绑定项目相册照片。');
    final bind = await CounterpartConversationConsumerLayer.instance
        .bindProjectAlbumPhoto(
          projectId: widget.projectId,
          fileAssetId: fileAssetId,
          category: _selectedCategory,
          caption: draft.fileName,
          sortOrder: _photos.length,
        );
    if (!mounted) {
      return;
    }
    if (bind.state != AppPageState.content) {
      setState(() {
        _uploading = false;
        _feedback = bind.message ?? '项目相册绑定失败。';
      });
      return;
    }
    setState(() => _uploading = false);
    await _load(feedback: '${draft.fileName} 已进入项目相册。');
  }

  Future<void> _deletePhoto(ProjectAlbumPhotoView photo) async {
    if (_deletingPhotoIds.contains(photo.photoId)) {
      return;
    }
    setState(() => _deletingPhotoIds.add(photo.photoId));
    final result = await CounterpartConversationConsumerLayer.instance
        .deleteProjectAlbumPhoto(
          projectId: widget.projectId,
          photoId: photo.photoId,
        );
    if (!mounted) {
      return;
    }
    setState(() => _deletingPhotoIds.remove(photo.photoId));
    if (result.state != AppPageState.content) {
      setState(() => _feedback = result.message ?? '项目相册照片删除失败。');
      return;
    }
    await _load(feedback: '已删除相册照片。');
  }

  Future<void> _previewPhoto(ProjectAlbumPhotoView photo) async {
    final threadId = widget.threadId?.trim();
    if (threadId == null || threadId.isEmpty) {
      _showPhotoFallbackDialog(photo, '当前相册缺少项目沟通 threadId，请从项目沟通页进入后再预览真实图片。');
      return;
    }
    var access = _previewCache[photo.fileAssetId];
    if (access == null) {
      setState(() => _loadingPreviewPhotoIds.add(photo.photoId));
      final result = await CounterpartConversationConsumerLayer.instance
          .loadProjectCommunicationFilePreviewAccess(
            projectId: widget.projectId,
            threadId: threadId,
            fileAssetId: photo.fileAssetId,
          );
      if (!mounted) {
        return;
      }
      setState(() => _loadingPreviewPhotoIds.remove(photo.photoId));
      access = result.data;
      if (result.state != AppPageState.content || access == null) {
        _showPhotoFallbackDialog(photo, result.message ?? '当前照片暂不可预览。');
        return;
      }
      _previewCache[photo.fileAssetId] = access;
    }
    final accessUrl = access.accessUrl?.trim();
    if (access.canPreview &&
        access.previewType == 'image' &&
        accessUrl != null &&
        accessUrl.isNotEmpty) {
      await _showProjectAttachmentNetworkImagePreviewDialog(
        context,
        fileName: access.fileName ?? photo.caption ?? photo.fileAssetId,
        imageUrl: accessUrl,
      );
      return;
    }
    _showPhotoFallbackDialog(photo, access.fallbackReason ?? '当前照片暂不支持在线预览。');
  }

  void _showPhotoFallbackDialog(ProjectAlbumPhotoView photo, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('照片预览'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _DetailLine(label: 'FileAsset', value: photo.fileAssetId),
            _DetailLine(
              label: '分类',
              value: _projectAlbumCategoryLabel(photo.category),
            ),
            _DetailLine(label: '类型', value: photo.mimeType),
            if (photo.caption != null)
              _DetailLine(label: '说明', value: photo.caption!),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final selectedOption = _projectAlbumCategories.firstWhere(
      (_ProjectAlbumCategoryOption item) => item.value == _selectedCategory,
    );
    return _ActionCard(
      title: '项目相册',
      summary: '照片锚定当前 projectId，最多 50 张；相册照片不是聊天消息。',
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _projectAlbumCategories
              .map((_ProjectAlbumCategoryOption item) {
                final count = _photos
                    .where(
                      (ProjectAlbumPhotoView photo) =>
                          photo.category == item.value,
                    )
                    .length;
                return ChoiceChip(
                  label: Text('${item.label} $count'),
                  selected: item.value == _selectedCategory,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = item.value),
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 10),
        _StateMessage(
          title: selectedOption.label,
          body: selectedOption.summary,
        ),
        const SizedBox(height: 10),
        _DetailLine(
          label: '当前数量',
          value: '${_photos.length} / $_projectAlbumLimit',
          highlight: _photos.length < _projectAlbumLimit,
        ),
        if (_feedback != null) _DetailLine(label: '状态', value: _feedback!),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            FilledButton.icon(
              onPressed: _uploading || _photos.length >= _projectAlbumLimit
                  ? null
                  : _selectAndUpload,
              icon: _uploading
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(_uploading ? '上传中' : '上传图片'),
            ),
            OutlinedButton.icon(
              onPressed: _loading ? null : () => _load(feedback: '已刷新项目相册。'),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('刷新相册'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const _StateMessage(title: '正在读取项目相册', body: '请稍候片刻。')
        else if (result != null && result.state != AppPageState.content)
          _StateMessage(
            title: '相册读取失败',
            body: result.message ?? result.state.contractName,
          )
        else if (_selectedPhotos.isEmpty)
          const _StateMessage(title: '当前分类暂无照片', body: '可以上传一张图片形成项目相册照片。')
        else
          ..._selectedPhotos.map(
            (ProjectAlbumPhotoView photo) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ProjectAlbumPhotoTile(
                photo: photo,
                deleting: _deletingPhotoIds.contains(photo.photoId),
                loadingPreview: _loadingPreviewPhotoIds.contains(photo.photoId),
                onPreview: () => unawaited(_previewPhoto(photo)),
                onDelete: () => _deletePhoto(photo),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProjectAlbumPhotoTile extends StatelessWidget {
  const _ProjectAlbumPhotoTile({
    required this.photo,
    required this.deleting,
    required this.loadingPreview,
    required this.onPreview,
    required this.onDelete,
  });

  final ProjectAlbumPhotoView photo;
  final bool deleting;
  final bool loadingPreview;
  final VoidCallback onPreview;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              photo.caption ?? photo.fileAssetId,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            _DetailLine(
              label: '分类',
              value: _projectAlbumCategoryLabel(photo.category),
            ),
            _DetailLine(label: 'FileAsset', value: photo.fileAssetId),
            _DetailLine(label: '类型', value: photo.mimeType),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: loadingPreview ? null : onPreview,
                  icon: loadingPreview
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.visibility_outlined),
                  label: Text(loadingPreview ? '预览中' : '预览'),
                ),
                OutlinedButton.icon(
                  onPressed: deleting ? null : onDelete,
                  icon: deleting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline_rounded),
                  label: Text(deleting ? '删除中' : '删除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _projectAlbumCategoryLabel(String category) {
  return switch (category) {
    'contract' => '合同照片',
    'progress' => '进度照片',
    'final' => '最终呈现',
    'defect' => '项目瑕疵',
    _ => category,
  };
}
