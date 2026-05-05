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

class _ProjectAlbumSectionState extends State<_ProjectAlbumSection>
    with _ProjectAlbumUploadActions {
  String _selectedCategory = 'progress';
  CounterpartConversationResult<ProjectAlbumPhotoListView>? _result;
  bool _loading = false;
  bool _uploading = false;
  String? _feedback;
  final Set<String> _deletingPhotoIds = <String>{};
  final Set<String> _loadingPreviewPhotoIds = <String>{};
  final Set<String> _savingPhotoIds = <String>{};
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
      _savingPhotoIds.clear();
      _loadingPreviewPhotoIds.clear();
      _previewCache.clear();
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

  Future<ProjectCommunicationFilePreviewAccessView?> _loadPhotoAccess(
    ProjectAlbumPhotoView photo, {
    required ValueChanged<bool> onBusyChanged,
    required ValueChanged<String> onFailure,
  }) async {
    final threadId = widget.threadId?.trim();
    if (threadId == null || threadId.isEmpty) {
      onFailure('当前相册缺少项目沟通 threadId，请从项目沟通页进入后再操作真实图片。');
      return null;
    }
    var access = _previewCache[photo.fileAssetId];
    if (access == null) {
      onBusyChanged(true);
      final result = await CounterpartConversationConsumerLayer.instance
          .loadProjectCommunicationFilePreviewAccess(
            projectId: widget.projectId,
            threadId: threadId,
            fileAssetId: photo.fileAssetId,
          );
      if (!mounted) {
        return null;
      }
      onBusyChanged(false);
      access = result.data;
      if (result.state != AppPageState.content || access == null) {
        onFailure(result.message ?? '当前照片暂不可操作。');
        return null;
      }
      _previewCache[photo.fileAssetId] = access;
    }
    return access;
  }

  Future<void> _previewPhoto(ProjectAlbumPhotoView photo) async {
    final access = await _loadPhotoAccess(
      photo,
      onBusyChanged: (bool busy) {
        if (!mounted) {
          return;
        }
        setState(() {
          if (busy) {
            _loadingPreviewPhotoIds.add(photo.photoId);
          } else {
            _loadingPreviewPhotoIds.remove(photo.photoId);
          }
        });
      },
      onFailure: (String message) => _showPhotoFallbackDialog(message),
    );
    if (!mounted || access == null) {
      return;
    }
    final accessUrl = access.accessUrl?.trim();
    if (access.canPreview &&
        access.previewType == 'image' &&
        accessUrl != null &&
        accessUrl.isNotEmpty) {
      await _showProjectAttachmentNetworkImagePreviewDialog(
        context,
        fileName: '项目相册照片',
        imageUrl: accessUrl,
      );
      return;
    }
    _showPhotoFallbackDialog(access.fallbackReason ?? '当前照片暂不支持在线预览。');
  }

  Future<void> _savePhoto(ProjectAlbumPhotoView photo) async {
    if (_savingPhotoIds.contains(photo.photoId)) {
      return;
    }
    setState(() {
      _savingPhotoIds.add(photo.photoId);
      _feedback = '正在准备保存相册照片。';
    });
    final access = await _loadPhotoAccess(
      photo,
      onBusyChanged: (_) {},
      onFailure: (String message) {
        if (mounted) {
          setState(() => _feedback = message);
        }
      },
    );
    if (!mounted) {
      return;
    }
    if (access == null) {
      setState(() => _savingPhotoIds.remove(photo.photoId));
      return;
    }
    final accessUrl = access.accessUrl?.trim();
    if (accessUrl == null || accessUrl.isEmpty) {
      setState(() {
        _savingPhotoIds.remove(photo.photoId);
        _feedback = access.fallbackReason ?? '当前照片暂不可保存到本地。';
      });
      return;
    }
    final savedFile = await _downloadProjectAlbumPhotoToLocal(
      accessUrl: accessUrl,
      photo: photo,
      access: access,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _savingPhotoIds.remove(photo.photoId);
      _feedback = savedFile == null ? '当前照片保存失败，请稍后重试。' : '相册照片已保存到本地。';
    });
    if (savedFile != null) {
      await _showProjectAlbumSavedSheet(context, file: savedFile);
    }
  }

  void _showPhotoFallbackDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('照片预览'),
        content: Text(message),
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
    final theme = Theme.of(context);
    return _ActionCard(
      title: '项目相册',
      summary: '共 ${_photos.length} / $_projectAlbumLimit 张',
      titleTrailing: IconButton(
        onPressed: _loading ? null : () => _load(feedback: '已刷新项目相册。'),
        tooltip: '刷新相册',
        icon: _loading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh_rounded),
      ),
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
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                _projectAlbumCategorySummary(_selectedCategory),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 10),
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
          ],
        ),
        if (_feedback != null) ...<Widget>[
          const SizedBox(height: 10),
          _ProjectAlbumFeedbackBanner(message: _feedback!),
        ],
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
                saving: _savingPhotoIds.contains(photo.photoId),
                onPreview: () => unawaited(_previewPhoto(photo)),
                onSave: () => unawaited(_savePhoto(photo)),
                onDelete: () => unawaited(_deletePhoto(photo)),
              ),
            ),
          ),
      ],
    );
  }
}
