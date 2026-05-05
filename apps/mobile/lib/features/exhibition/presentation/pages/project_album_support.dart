part of '../exhibition_trade_pages.dart';

mixin _ProjectAlbumUploadActions on State<_ProjectAlbumSection> {
  _ProjectAlbumSectionState get _albumState =>
      this as _ProjectAlbumSectionState;

  Future<void> _selectAndUpload() async {
    final album = _albumState;
    if (album._uploading) {
      return;
    }
    if (album._photos.length >= _projectAlbumLimit) {
      setState(() => album._feedback = '当前项目相册最多 50 张，已达到上限。');
      return;
    }
    setState(() {
      album._uploading = true;
      album._feedback = '正在选择项目相册图片。';
    });
    final draft = await _pickProjectAttachmentDraft(imageOnly: true);
    if (!mounted) {
      return;
    }
    if (draft == null) {
      setState(() {
        album._uploading = false;
        album._feedback = '未选择图片。';
      });
      return;
    }
    final resolved = _resolveProjectAttachmentDraft(draft);
    if (resolved == null || !resolved.mimeType.startsWith('image/')) {
      setState(() {
        album._uploading = false;
        album._feedback = '项目相册只支持 PNG、JPEG、WEBP 图片。';
      });
      return;
    }
    await _uploadResolvedPhoto(resolved);
  }

  Future<void> _uploadResolvedPhoto(
    _ResolvedProjectAttachmentDraft draft,
  ) async {
    final album = _albumState;
    setState(() => album._feedback = '正在申请相册图片上传。');
    final init = await ExhibitionConsumerLayer.instance.uploadInit(
      UploadInitCommand(
        businessType: _projectAttachmentBusinessType,
        businessId: album.widget.projectId,
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
        album._uploading = false;
        album._feedback = init.message ?? '相册图片上传初始化失败。';
      });
      return;
    }

    setState(() => album._feedback = '正在直传相册图片。');
    final direct = await ExhibitionConsumerLayer.instance.directUpload(
      directive: directive,
      bodyBytes: draft.bytes,
    );
    if (!mounted) {
      return;
    }
    if (direct.state != AppUploadState.uploadConfirming) {
      setState(() {
        album._uploading = false;
        album._feedback = direct.message ?? '相册图片直传失败。';
      });
      return;
    }

    setState(() => album._feedback = '正在确认相册图片上传。');
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
        album._uploading = false;
        album._feedback = confirm.message ?? '相册图片确认失败。';
      });
      return;
    }

    setState(() => album._feedback = '正在绑定项目相册照片。');
    final bind = await CounterpartConversationConsumerLayer.instance
        .bindProjectAlbumPhoto(
          projectId: album.widget.projectId,
          fileAssetId: fileAssetId,
          category: album._selectedCategory,
          caption: draft.fileName,
          sortOrder: album._photos.length,
        );
    if (!mounted) {
      return;
    }
    if (bind.state != AppPageState.content) {
      setState(() {
        album._uploading = false;
        album._feedback = bind.message ?? '项目相册绑定失败。';
      });
      return;
    }
    setState(() => album._uploading = false);
    await album._load(feedback: '照片已进入项目相册。');
  }
}

class _ProjectAlbumFeedbackBanner extends StatelessWidget {
  const _ProjectAlbumFeedbackBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectAlbumPhotoTile extends StatelessWidget {
  const _ProjectAlbumPhotoTile({
    required this.photo,
    required this.deleting,
    required this.loadingPreview,
    required this.saving,
    required this.onPreview,
    required this.onSave,
    required this.onDelete,
  });

  final ProjectAlbumPhotoView photo;
  final bool deleting;
  final bool loadingPreview;
  final bool saving;
  final VoidCallback onPreview;
  final VoidCallback onSave;
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
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Row(
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.34,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.image_outlined,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '相册照片',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _projectAlbumCreatedAtLabel(photo.createdAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  onPressed: loadingPreview ? null : onPreview,
                  tooltip: '预览',
                  visualDensity: VisualDensity.compact,
                  icon: loadingPreview
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.visibility_outlined),
                ),
                IconButton(
                  onPressed: saving ? null : onSave,
                  tooltip: '保存到本地',
                  visualDensity: VisualDensity.compact,
                  icon: saving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                ),
                IconButton(
                  onPressed: deleting ? null : onDelete,
                  tooltip: '删除',
                  visualDensity: VisualDensity.compact,
                  icon: deleting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.delete_outline_rounded,
                          color: theme.colorScheme.error,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _projectAlbumCreatedAtLabel(String createdAt) {
  final parsed = DateTime.tryParse(createdAt);
  if (parsed == null) {
    return '已加入项目相册';
  }
  final local = parsed.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}

String _projectAlbumCategorySummary(String category) {
  return switch (category) {
    'contract' => '合同、确认单、边界照片',
    'progress' => '施工过程与现场进度',
    'final' => '完工后的最终呈现',
    'defect' => '瑕疵、整改、争议辅助',
    _ => '项目证据照片',
  };
}
