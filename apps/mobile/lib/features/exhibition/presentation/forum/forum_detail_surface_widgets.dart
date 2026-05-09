part of 'forum_pages.dart';

class _ForumDetailHero extends StatelessWidget {
  const _ForumDetailHero({
    required this.topicLabel,
    required this.title,
    required this.author,
    required this.publishedAt,
    required this.viewerFollowsTopic,
    required this.onOpenAuthor,
  });

  final String topicLabel;
  final String title;
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
        ForumCategoryBadge(label: topicLabel),
        const SizedBox(height: 14),
        Text(
          title,
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
              child: ForumAuthorRow(
                author: author,
                publishedAt: publishedAt,
                onTap: onOpenAuthor,
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
    required this.likeCount,
    required this.replyCount,
    required this.onLike,
    required this.onBookmark,
    required this.onReply,
    required this.onReport,
    this.likePending = false,
    this.bookmarkPending = false,
  });

  final bool viewerHasLiked;
  final bool viewerHasBookmarked;
  final int likeCount;
  final int replyCount;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onReply;
  final VoidCallback onReport;
  final bool likePending;
  final bool bookmarkPending;

  @override
  Widget build(BuildContext context) {
    return ForumActionBar(
      viewerHasLiked: viewerHasLiked,
      viewerHasBookmarked: viewerHasBookmarked,
      likeCount: likeCount,
      replyCount: replyCount,
      likePending: likePending,
      bookmarkPending: bookmarkPending,
      onLike: likePending ? null : onLike,
      onBookmark: bookmarkPending ? null : onBookmark,
      onReply: onReply,
      onReport: onReport,
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
