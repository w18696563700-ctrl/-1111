part of 'forum_pages.dart';

class _ForumComposerInlineImageGrid extends StatelessWidget {
  const _ForumComposerInlineImageGrid({
    required this.items,
    required this.onPreview,
    required this.onRemove,
    required this.onUpload,
    required this.saving,
    required this.publishing,
  });

  final List<_ForumComposerMediaItem> items;
  final ValueChanged<_ForumComposerMediaItem> onPreview;
  final ValueChanged<_ForumComposerMediaItem> onRemove;
  final ValueChanged<_ForumComposerMediaItem> onUpload;
  final bool saving;
  final bool publishing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '正文图片',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.78,
          ),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = items[index];
            return _ForumComposerInlineImageTile(
              item: item,
              onPreview: () => onPreview(item),
              onRemove: item.isTransferActive ? null : () => onRemove(item),
              onUpload: item.canStartUpload && !saving && !publishing
                  ? () => onUpload(item)
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class _ForumComposerInlineImageTile extends StatelessWidget {
  const _ForumComposerInlineImageTile({
    required this.item,
    required this.onPreview,
    required this.onRemove,
    required this.onUpload,
  });

  final _ForumComposerMediaItem item;
  final VoidCallback onPreview;
  final VoidCallback? onRemove;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = item.statusMessage ?? _forumMediaStageLabel(item);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPreview,
                  child: Image.memory(
                    Uint8List.fromList(item.bytes),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const _ForumMediaImagePlaceholder(label: '图片预览'),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 6,
              top: 6,
              child: _ForumMediaStatusBadge(label: statusLabel),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
                tooltip: '移除图片',
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 22, 8, 7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (onUpload != null) ...<Widget>[
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 26,
                          child: FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              textStyle: theme.textTheme.labelSmall,
                            ),
                            onPressed: onUpload,
                            child: Text(
                              item.stage ==
                                      _ForumComposerMediaStage.uploadFailed
                                  ? '重传'
                                  : '上传',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (item.isTransferActive)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
