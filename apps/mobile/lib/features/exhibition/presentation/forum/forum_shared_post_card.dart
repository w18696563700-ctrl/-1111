part of 'forum_shared_components.dart';

class ForumPostCard extends StatelessWidget {
  const ForumPostCard({
    super.key,
    required this.topicLabel,
    required this.title,
    required this.excerpt,
    this.author,
    this.publishedAt,
    this.stateLabel,
    this.replyCount,
    this.likeCount,
    this.viewCount,
    this.attachmentRefs = const <ForumAttachmentRefView>[],
    this.onTap,
    this.onOpenAuthor,
    this.onOpenAttachment,
    this.trailing,
    this.actionBar,
    this.compact = false,
    this.showChevron = true,
  });

  factory ForumPostCard.fromFeed({
    Key? key,
    required ForumFeedItemView item,
    VoidCallback? onTap,
    VoidCallback? onOpenAuthor,
    bool compact = false,
  }) {
    return ForumPostCard(
      key: key,
      topicLabel: forumDisplayTopicLabel(
        rawLabel: item.topicLabel,
        topicId: item.topicId,
      ),
      title: item.title,
      excerpt: item.excerpt,
      author: item.author,
      publishedAt: item.publishedAt,
      replyCount: item.engagement.replyCount,
      likeCount: item.engagement.likeCount,
      viewCount: item.engagement.viewCount,
      onTap: onTap,
      onOpenAuthor: onOpenAuthor,
      compact: compact,
    );
  }

  factory ForumPostCard.fromAuthorPost({
    Key? key,
    required ForumAuthorPostCardView item,
    VoidCallback? onTap,
    bool compact = false,
  }) {
    return ForumPostCard(
      key: key,
      topicLabel: forumDisplayTopicLabel(
        rawLabel: item.topicTitle,
        topicId: item.topicId,
      ),
      title: item.title,
      excerpt: item.excerpt,
      stateLabel: forumDisplayContentState(item.state),
      publishedAt: item.publishedAt,
      onTap: onTap,
      compact: compact,
      showChevron: onTap != null,
    );
  }

  final String topicLabel;
  final String title;
  final String excerpt;
  final ForumAuthorSummaryView? author;
  final String? publishedAt;
  final String? stateLabel;
  final int? replyCount;
  final int? likeCount;
  final int? viewCount;
  final List<ForumAttachmentRefView> attachmentRefs;
  final VoidCallback? onTap;
  final VoidCallback? onOpenAuthor;
  final ValueChanged<ForumAttachmentRefView>? onOpenAttachment;
  final Widget? trailing;
  final Widget? actionBar;
  final bool compact;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = compact
        ? AppVisualTokens.radiusLarge
        : AppVisualTokens.radiusXLarge;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.cardBackground,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppVisualTokens.borderSoft),
        boxShadow: AppVisualTokens.shadowSoft(opacity: compact ? 0.03 : 0.045),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 14 : 16,
          compact ? 12 : 15,
          compact ? 14 : 16,
          compact ? 12 : 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      ForumCategoryBadge(label: topicLabel, compact: true),
                      if (stateLabel != null && stateLabel!.trim().isNotEmpty)
                        _ForumSoftBadge(label: stateLabel!),
                    ],
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  const SizedBox(width: 10),
                  trailing!,
                ] else if (showChevron && onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppVisualTokens.textTertiary,
                  ),
              ],
            ),
            SizedBox(height: compact ? 8 : 10),
            Text(
              title,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style:
                  (compact
                          ? theme.textTheme.titleSmall
                          : AppTextTokens.cardTitle)
                      ?.copyWith(
                        color: AppVisualTokens.textPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1.22,
                      ),
            ),
            if (excerpt.trim().isNotEmpty) ...<Widget>[
              SizedBox(height: compact ? 5 : 7),
              Text(
                excerpt,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppVisualTokens.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
            if (attachmentRefs.isNotEmpty) ...<Widget>[
              SizedBox(height: compact ? 10 : 12),
              ForumAttachmentPreview(
                attachments: attachmentRefs,
                onOpenAttachment: onOpenAttachment,
                compact: compact,
              ),
            ],
            if (author != null || publishedAt != null) ...<Widget>[
              SizedBox(height: compact ? 10 : 12),
              if (author != null)
                ForumAuthorRow(
                  author: author!,
                  publishedAt: publishedAt,
                  onTap: onOpenAuthor,
                  dense: compact,
                  showChevron: false,
                )
              else if (publishedAt != null)
                Text(
                  '发布时间：${forumDisplayTimeLabel(publishedAt!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppVisualTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
            if (replyCount != null ||
                likeCount != null ||
                viewCount != null) ...<Widget>[
              SizedBox(height: compact ? 8 : 10),
              ForumStatsRow(
                replyCount: replyCount,
                likeCount: likeCount,
                viewCount: viewCount,
                compact: true,
              ),
            ],
            if (actionBar != null) ...<Widget>[
              const SizedBox(height: 12),
              actionBar!,
            ],
          ],
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
