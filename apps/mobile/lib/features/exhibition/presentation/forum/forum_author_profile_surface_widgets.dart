part of 'forum_pages.dart';

class _ForumAuthorSummaryCard extends StatelessWidget {
  const _ForumAuthorSummaryCard({
    required this.visibleName,
    required this.avatarUrl,
    required this.organizationName,
    required this.publicPostCount,
    required this.publicCommentCount,
  });

  final String visibleName;
  final String? avatarUrl;
  final String? organizationName;
  final int publicPostCount;
  final int publicCommentCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ForumSectionCard(
      eyebrow: '公开资料',
      title: visibleName,
      summary: organizationName == null
          ? '当前只展示作者的公开资料投影和公开帖子。'
          : '机构：$organizationName',
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ForumInfoPill(label: '公开帖子 $publicPostCount', highlighted: true),
            ForumInfoPill(label: '公开评论 $publicCommentCount'),
          ],
        ),
      ],
    );
  }
}

class _ForumBlockRelationControlCard extends StatelessWidget {
  const _ForumBlockRelationControlCard({
    required this.result,
    required this.actionPending,
    required this.onRetry,
    required this.onToggle,
    this.actionMessage,
  });

  final ForumReadResult<ForumBlockRelationStatusView>? result;
  final bool actionPending;
  final String? actionMessage;
  final VoidCallback onRetry;
  final ValueChanged<ForumBlockRelationStatusView> onToggle;

  @override
  Widget build(BuildContext context) {
    final status = result?.data;
    if (result == null) {
      return ForumSlimStatePanel(
        loading: true,
        state: AppPageState.loading,
        emptyMessage: '正在读取拉黑关系状态',
        onRetry: onRetry,
      );
    }
    if (result?.state != AppPageState.content || status == null) {
      return ForumSlimStatePanel(
        loading: false,
        state: result?.state,
        emptyMessage: '拉黑关系状态暂时不可用',
        onRetry: onRetry,
        message: result?.message,
      );
    }

    final theme = Theme.of(context);
    final isBlocked = status.isBlocked;
    final actionLabel = isBlocked ? '解除拉黑' : '拉黑作者';
    final actionIcon = isBlocked
        ? Icons.person_add_alt_1_outlined
        : Icons.person_off_outlined;

    return ForumSectionCard(
      eyebrow: '关系状态',
      title: isBlocked ? '已拉黑该作者' : '未拉黑该作者',
      summary: '这里只读取你与该作者的 CS-018 拉黑关系状态，不改变当前公开内容展示。',
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ForumInfoPill(
              label: isBlocked ? '关系状态：已拉黑' : '关系状态：未拉黑',
              highlighted: true,
            ),
            ForumInfoPill(label: '单目标状态读取'),
          ],
        ),
        if (actionMessage != null && actionMessage!.trim().isNotEmpty)
          Text(
            actionMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: actionPending ? null : () => onToggle(status),
            icon: Icon(actionIcon, size: 18),
            label: Text(actionPending ? '处理中' : actionLabel),
          ),
        ),
      ],
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

  _ForumPublicPostCard.fromPostCard({required ForumPostCardView item})
    : topicLabel = forumDisplayTopicLabel(
        rawLabel: item.topicTitle,
        topicId: item.topicId,
      ),
      title = forumDisplayTopicLabel(
        rawLabel: item.topicTitle,
        topicId: item.topicId,
      ),
      excerpt = item.excerpt,
      postId = item.postId,
      publishedAt = item.publishedAt,
      author = item.author,
      replyCount = null,
      likeCount = null,
      viewCount = null,
      showAuthor = false;

  final String topicLabel;
  final String title;
  final String excerpt;
  final String postId;
  final String publishedAt;
  final ForumAuthorSummaryView author;
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
                if (showAuthor)
                  _ForumAuthorAnchorRow(
                    author: author,
                    publishedAt: publishedAt,
                    onOpenAuthor: () =>
                        _openForumAuthorProfile(context, author.authorId),
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
    this.avatarUrl,
  });

  final ForumAuthorSummaryView author;
  final String publishedAt;
  final VoidCallback onOpenAuthor;
  final String? avatarUrl;

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

    return Row(
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onOpenAuthor,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: _ForumAuthorAvatar(
              label: visibleName,
              avatarUrl: avatarUrl,
              radius: 16,
            ),
          ),
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
      ],
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
