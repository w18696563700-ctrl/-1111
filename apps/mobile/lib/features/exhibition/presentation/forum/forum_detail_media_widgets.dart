part of 'forum_pages.dart';

class _ForumDetailMediaSection extends StatelessWidget {
  const _ForumDetailMediaSection({
    required this.attachments,
    required this.imageAccessByAssetId,
    required this.imageAccessLoadingAssetIds,
    required this.imageAccessFailedAssetIds,
    required this.openingAttachmentAssetIds,
    required this.onOpenAttachment,
    required this.onRetryImageAccess,
  });

  final List<ForumAttachmentRefView> attachments;
  final Map<String, ForumFileAccessView> imageAccessByAssetId;
  final Set<String> imageAccessLoadingAssetIds;
  final Set<String> imageAccessFailedAssetIds;
  final Set<String> openingAttachmentAssetIds;
  final ValueChanged<ForumAttachmentRefView> onOpenAttachment;
  final ValueChanged<ForumAttachmentRefView> onRetryImageAccess;

  @override
  Widget build(BuildContext context) {
    final imageAttachments = attachments
        .where(
          (ForumAttachmentRefView item) => _forumIsImageMimeType(item.mimeType),
        )
        .toList(growable: false);
    final fileAttachments = attachments
        .where(
          (ForumAttachmentRefView item) =>
              !_forumIsImageMimeType(item.mimeType),
        )
        .toList(growable: false);
    if (imageAttachments.isEmpty && fileAttachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (imageAttachments.isNotEmpty) ...<Widget>[
          const _ForumDetailSectionHeading(
            title: '正文图片',
            summary: '图片来自当前帖子的真实附件，点击可在 App 内放大查看。',
          ),
          const SizedBox(height: 12),
          _ForumDetailImageGrid(
            items: imageAttachments,
            accessByAssetId: imageAccessByAssetId,
            loadingAssetIds: imageAccessLoadingAssetIds,
            failedAssetIds: imageAccessFailedAssetIds,
            onOpenAttachment: onOpenAttachment,
            onRetryImageAccess: onRetryImageAccess,
          ),
        ],
        if (fileAttachments.isNotEmpty) ...<Widget>[
          if (imageAttachments.isNotEmpty) const SizedBox(height: 22),
          const _ForumDetailSectionHeading(
            title: '附件',
            summary: '点击附件后在 App 内查看文件信息，再调用设备能力预览或打开。',
          ),
          const SizedBox(height: 12),
          ForumAttachmentPreview(
            attachments: fileAttachments,
            onOpenAttachment: onOpenAttachment,
          ),
        ],
        if (openingAttachmentAssetIds.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 3),
        ],
      ],
    );
  }
}

class _ForumDetailImageGrid extends StatelessWidget {
  const _ForumDetailImageGrid({
    required this.items,
    required this.accessByAssetId,
    required this.loadingAssetIds,
    required this.failedAssetIds,
    required this.onOpenAttachment,
    required this.onRetryImageAccess,
  });

  final List<ForumAttachmentRefView> items;
  final Map<String, ForumFileAccessView> accessByAssetId;
  final Set<String> loadingAssetIds;
  final Set<String> failedAssetIds;
  final ValueChanged<ForumAttachmentRefView> onOpenAttachment;
  final ValueChanged<ForumAttachmentRefView> onRetryImageAccess;

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.take(9).toList(growable: false);
    final hiddenCount = items.length - visibleItems.length;
    final columns = _gridColumnCount(visibleItems.length);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: visibleItems.length == 1 ? 1.62 : 1,
      ),
      itemCount: visibleItems.length,
      itemBuilder: (BuildContext context, int index) {
        final item = visibleItems[index];
        final overflowCount = index == 8 ? hiddenCount : 0;
        return _ForumDetailImageTile(
          key: ValueKey('forum-detail-image-tile-${item.fileAssetId}'),
          attachment: item,
          access: accessByAssetId[item.fileAssetId],
          loading: loadingAssetIds.contains(item.fileAssetId),
          failed: failedAssetIds.contains(item.fileAssetId),
          overflowCount: overflowCount,
          onOpen: () => onOpenAttachment(item),
          onRetry: () => onRetryImageAccess(item),
        );
      },
    );
  }

  int _gridColumnCount(int count) {
    if (count <= 1) {
      return 1;
    }
    if (count == 2) {
      return 2;
    }
    return 3;
  }
}

class _ForumDetailImageTile extends StatelessWidget {
  const _ForumDetailImageTile({
    super.key,
    required this.attachment,
    required this.access,
    required this.loading,
    required this.failed,
    required this.overflowCount,
    required this.onOpen,
    required this.onRetry,
  });

  final ForumAttachmentRefView attachment;
  final ForumFileAccessView? access;
  final bool loading;
  final bool failed;
  final int overflowCount;
  final VoidCallback onOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessUrl = access?.accessUrl.trim();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: accessUrl == null || accessUrl.isEmpty ? onRetry : onOpen,
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: _previewContent(theme, accessUrl)),
                if (overflowCount > 0)
                  _ForumDetailImageOverflowOverlay(count: overflowCount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewContent(ThemeData theme, String? accessUrl) {
    if (accessUrl != null && accessUrl.isNotEmpty) {
      return Image.network(
        accessUrl,
        fit: BoxFit.cover,
        frameBuilder:
            (
              BuildContext context,
              Widget child,
              int? frame,
              bool wasSynchronouslyLoaded,
            ) {
              if (wasSynchronouslyLoaded || frame != null) {
                return child;
              }
              return _loadingPlaceholder(theme);
            },
        loadingBuilder:
            (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }
              return _loadingPlaceholder(theme);
            },
        errorBuilder: (_, _, _) => _placeholder(theme, '点击重试', failed: true),
      );
    }
    if (loading) {
      return _loadingPlaceholder(theme);
    }
    return _placeholder(theme, failed ? '点击重试' : '点击加载');
  }

  Widget _loadingPlaceholder(ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(height: 8),
            Text(
              '图片读取中',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme, String label, {bool failed = false}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              failed ? Icons.broken_image_outlined : Icons.photo_outlined,
              color: failed
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: failed
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForumDetailImageOverflowOverlay extends StatelessWidget {
  const _ForumDetailImageOverflowOverlay({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.46)),
      child: Center(
        child: Text(
          '+$count',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
