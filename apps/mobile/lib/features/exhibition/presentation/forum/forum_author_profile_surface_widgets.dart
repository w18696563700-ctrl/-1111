part of 'forum_pages.dart';

class _ForumAuthorSummaryCard extends StatelessWidget {
  const _ForumAuthorSummaryCard({
    required this.visibleName,
    required this.avatarUrl,
    required this.organizationName,
    required this.publicPostCount,
    required this.publicCommentCount,
    required this.viewerFollowsAuthor,
    required this.followPending,
    required this.isCurrentActor,
    required this.onToggleFollow,
    required this.onOpenMessages,
    required this.onOpenMine,
  });

  final String visibleName;
  final String? avatarUrl;
  final String? organizationName;
  final int publicPostCount;
  final int publicCommentCount;
  final bool viewerFollowsAuthor;
  final bool followPending;
  final bool isCurrentActor;
  final VoidCallback onToggleFollow;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _ForumAuthorAvatar(
                  label: visibleName,
                  avatarUrl: avatarUrl,
                  radius: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        visibleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        organizationName ?? '当前未公开机构信息',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                if (isCurrentActor)
                  FilledButton.tonal(
                    onPressed: onOpenMine,
                    child: const Text('进入我的楼'),
                  )
                else ...<Widget>[
                  FilledButton.icon(
                    onPressed: followPending ? null : onToggleFollow,
                    icon: Icon(
                      followPending
                          ? Icons.hourglass_top_rounded
                          : viewerFollowsAuthor
                          ? Icons.how_to_reg_rounded
                          : Icons.person_add_alt_1_rounded,
                      size: 18,
                    ),
                    label: Text(
                      followPending
                          ? '处理中'
                          : viewerFollowsAuthor
                          ? '已关注'
                          : '关注',
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: onOpenMessages,
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                    ),
                    label: const Text('发消息'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ForumInfoPill(
                  label: '公开帖子 $publicPostCount',
                  highlighted: true,
                ),
                ForumInfoPill(label: '公开评论 $publicCommentCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ForumPublicPostCard extends StatelessWidget {
  _ForumPublicPostCard.fromFeed({required ForumFeedItemView item})
    : topicLabel = forumDisplayTopicLabel(
        rawLabel: item.topicLabel,
        topicId: item.topicId,
      ),
      title = item.title,
      excerpt = item.excerpt,
      postId = item.postId,
      publishedAt = item.publishedAt,
      author = item.author,
      replyCount = item.engagement.replyCount,
      likeCount = item.engagement.likeCount,
      viewCount = item.engagement.viewCount,
      showAuthor = true;

  _ForumPublicPostCard.fromAuthorPostCard({
    required ForumAuthorPostCardView item,
  }) : topicLabel = forumDisplayTopicLabel(
         rawLabel: item.topicTitle,
         topicId: item.topicId,
       ),
       title = item.title,
       excerpt = item.excerpt,
       postId = item.postId,
       publishedAt = item.publishedAt,
       author = null,
       replyCount = null,
       likeCount = null,
       viewCount = null,
       showAuthor = false;

  final String topicLabel;
  final String title;
  final String excerpt;
  final String postId;
  final String publishedAt;
  final ForumAuthorSummaryView? author;
  final int? replyCount;
  final int? likeCount;
  final int? viewCount;
  final bool showAuthor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final engagementLabel =
        replyCount == null || likeCount == null || viewCount == null
        ? null
        : '$replyCount 回复  $likeCount 赞  $viewCount 浏览';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(
          context,
        ).pushNamed(ExhibitionRoutes.forumPostWithPostId(postId)),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ForumInfoPill(label: '# $topicLabel', highlighted: true),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 8),
                if (showAuthor && author != null)
                  _ForumAuthorAnchorRow(
                    author: author!,
                    publishedAt: publishedAt,
                    onOpenAuthor: () =>
                        _openForumAuthorProfile(context, author!.authorId),
                  )
                else
                  Text(
                    '发布时间：${_compactPublishedAt(publishedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (engagementLabel != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    engagementLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForumAuthorAnchorRow extends StatelessWidget {
  const _ForumAuthorAnchorRow({
    required this.author,
    required this.publishedAt,
    required this.onOpenAuthor,
  });

  final ForumAuthorSummaryView author;
  final String publishedAt;
  final VoidCallback onOpenAuthor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleName = forumDisplayActorName(author.displayName);
    final organizationName = forumDisplayOrganizationName(
      author.organizationName,
    );
    final secondaryLabel = organizationName == null
        ? '论坛用户 · ${_compactPublishedAt(publishedAt)}'
        : '$organizationName · ${_compactPublishedAt(publishedAt)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpenAuthor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            children: <Widget>[
              _ForumAuthorAvatar(
                label: visibleName,
                avatarUrl: author.avatarUrl,
                radius: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        visibleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        secondaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForumAuthorAvatar extends StatelessWidget {
  const _ForumAuthorAvatar({
    required this.label,
    required this.avatarUrl,
    required this.radius,
  });

  final String label;
  final String? avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleAvatarUrl = avatarUrl?.trim();
    final foregroundImage = visibleAvatarUrl == null || visibleAvatarUrl.isEmpty
        ? null
        : NetworkImage(visibleAvatarUrl);
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      foregroundImage: foregroundImage,
      child: Text(
        _forumAuthorAvatarSeed(label),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _forumAuthorAvatarSeed(String rawName) {
  final trimmed = rawName.trim();
  if (trimmed.isEmpty) {
    return '坛';
  }
  return trimmed.characters.first;
}

void _noop() {}
