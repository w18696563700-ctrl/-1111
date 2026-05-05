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
                ForumAuthorAvatar(
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

void _noop() {}
