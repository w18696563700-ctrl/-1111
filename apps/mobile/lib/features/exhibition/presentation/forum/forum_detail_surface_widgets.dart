part of 'forum_pages.dart';

class _ForumDetailHero extends StatelessWidget {
  const _ForumDetailHero({
    required this.topicLabel,
    required this.author,
    required this.publishedAt,
    required this.viewerFollowsTopic,
    required this.onOpenAuthor,
  });

  final String topicLabel;
  final ForumAuthorSummaryView author;
  final String publishedAt;
  final bool viewerFollowsTopic;
  final VoidCallback onOpenAuthor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ForumInfoPill(label: '# $topicLabel', highlighted: true),
        const SizedBox(height: 14),
        Text(
          topicLabel,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: _ForumAuthorAnchorRow(
                author: author,
                publishedAt: publishedAt,
                onOpenAuthor: onOpenAuthor,
                avatarUrl: null,
              ),
            ),
            if (viewerFollowsTopic)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  child: Text(
                    '已关注',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ForumDetailBodySection extends StatelessWidget {
  const _ForumDetailBodySection({
    required this.content,
    required this.stateLabel,
  });

  final String content;
  final String stateLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paragraphs = content
        .split(RegExp(r'\n+'))
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
    final visibleParagraphs = paragraphs.isEmpty
        ? <String>[content.trim()]
        : paragraphs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '正文',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        for (
          var index = 0;
          index < visibleParagraphs.length;
          index += 1
        ) ...<Widget>[
          _ForumDetailParagraph(text: visibleParagraphs[index]),
          if (index < visibleParagraphs.length - 1) const SizedBox(height: 14),
        ],
        const SizedBox(height: 14),
        Text(
          '状态：$stateLabel',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ForumDetailParagraph extends StatelessWidget {
  const _ForumDetailParagraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
        ),
      ),
    );
  }
}

class _ForumDetailActionBar extends StatelessWidget {
  const _ForumDetailActionBar({
    required this.viewerHasLiked,
    required this.viewerHasBookmarked,
    required this.onLike,
    required this.onBookmark,
    required this.onReply,
    this.likePending = false,
    this.bookmarkPending = false,
  });

  final bool viewerHasLiked;
  final bool viewerHasBookmarked;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onReply;
  final bool likePending;
  final bool bookmarkPending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _ForumDetailActionButton(
                icon: likePending
                    ? Icons.hourglass_top_rounded
                    : viewerHasLiked
                    ? Icons.thumb_up_rounded
                    : Icons.thumb_up_alt_outlined,
                label: likePending
                    ? '处理中'
                    : viewerHasLiked
                    ? '已点赞'
                    : '点赞',
                onPressed: likePending ? null : onLike,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ForumDetailActionButton(
                icon: bookmarkPending
                    ? Icons.hourglass_top_rounded
                    : viewerHasBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                label: bookmarkPending
                    ? '处理中'
                    : viewerHasBookmarked
                    ? '已收藏'
                    : '收藏',
                onPressed: bookmarkPending ? null : onBookmark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ForumDetailActionButton(
                icon: Icons.mode_comment_outlined,
                label: '评论',
                emphasized: true,
                onPressed: onReply,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForumDetailActionButton extends StatelessWidget {
  const _ForumDetailActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: emphasized
              ? colorScheme.primary
              : onPressed == null
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primaryContainer.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: emphasized
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: emphasized
                      ? colorScheme.onPrimary
                      : colorScheme.onPrimaryContainer,
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

class _ForumDetailSectionHeading extends StatelessWidget {
  const _ForumDetailSectionHeading({required this.title, this.summary});

  final String title;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        if (summary != null && summary!.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            summary!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _ForumDetailAttachmentRow extends StatelessWidget {
  const _ForumDetailAttachmentRow({
    required this.item,
    required this.actionLabel,
    required this.loading,
    required this.onTap,
  });

  final ForumAttachmentRefView item;
  final String actionLabel;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: loading ? null : onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Icon(
                  _forumAttachmentDisplayIcon(item.mimeType),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _forumAttachmentDisplayTypeLabel(item.mimeType),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (loading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else
                  Text(
                    actionLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForumDetailCommentEmpty extends StatelessWidget {
  const _ForumDetailCommentEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '当前还没有评论',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '欢迎先说说你的看法，或者直接进入评论区继续互动。',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}
