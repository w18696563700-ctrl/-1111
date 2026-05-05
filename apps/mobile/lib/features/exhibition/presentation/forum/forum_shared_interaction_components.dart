part of 'forum_shared_components.dart';

class ForumActionBar extends StatelessWidget {
  const ForumActionBar({
    super.key,
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
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onReply;
  final VoidCallback? onReport;
  final bool likePending;
  final bool bookmarkPending;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.cardBackground,
        borderRadius: AppVisualTokens.radiusLargeBorder,
        border: Border.all(color: AppVisualTokens.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _ForumActionPill(
                icon: likePending
                    ? Icons.hourglass_top_rounded
                    : viewerHasLiked
                    ? Icons.thumb_up_rounded
                    : Icons.thumb_up_alt_outlined,
                label: likePending
                    ? '处理中'
                    : viewerHasLiked
                    ? '已点赞 $likeCount'
                    : '点赞 $likeCount',
                selected: viewerHasLiked,
                onPressed: likePending ? null : onLike,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ForumActionPill(
                icon: Icons.mode_comment_outlined,
                label: replyCount > 0 ? '评论 $replyCount' : '评论',
                selected: true,
                onPressed: onReply,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ForumActionPill(
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
                selected: viewerHasBookmarked,
                onPressed: bookmarkPending ? null : onBookmark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ForumActionPill(
                icon: Icons.flag_outlined,
                label: '举报',
                onPressed: onReport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ForumCommentCard extends StatelessWidget {
  const ForumCommentCard({
    super.key,
    required this.author,
    required this.body,
    required this.publishedAtLabel,
    required this.replyCount,
    this.targetLabel,
    this.onOpenAuthor,
    this.onReport,
  });

  factory ForumCommentCard.fromItem({
    Key? key,
    required ForumCommentItemView item,
    String? targetLabel,
    VoidCallback? onOpenAuthor,
    VoidCallback? onReport,
  }) {
    return ForumCommentCard(
      key: key,
      author: item.author,
      body: item.body,
      publishedAtLabel: forumDisplayTimeLabel(item.publishedAt),
      replyCount: item.replyCount,
      targetLabel: targetLabel,
      onOpenAuthor: onOpenAuthor,
      onReport: onReport,
    );
  }

  final ForumAuthorSummaryView author;
  final String body;
  final String publishedAtLabel;
  final int? replyCount;
  final String? targetLabel;
  final VoidCallback? onOpenAuthor;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.cardBackground,
        borderRadius: AppVisualTokens.radiusLargeBorder,
        border: Border.all(color: AppVisualTokens.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ForumAuthorRow(
              author: author,
              onTap: onOpenAuthor,
              dense: true,
              trailing: targetLabel == null
                  ? null
                  : _ForumSoftBadge(label: targetLabel!),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppVisualTokens.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Text(
                  _commentFooterText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppVisualTokens.textSecondary,
                  ),
                ),
                const Spacer(),
                if (onReport != null)
                  TextButton.icon(
                    onPressed: onReport,
                    icon: const Icon(Icons.flag_outlined, size: 16),
                    label: const Text('举报'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppVisualTokens.textSecondary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _commentFooterText() {
    final parts = <String>[
      publishedAtLabel,
      if (replyCount != null) replyCount! > 0 ? '$replyCount 条后续回复' : '暂无后续回复',
    ];
    return parts.join(' · ');
  }
}

class ForumCommentInputBar extends StatelessWidget {
  const ForumCommentInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.submitting,
    required this.onSubmit,
    this.submitLabel = '发送',
    this.submittingLabel = '发送中',
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool submitting;
  final VoidCallback? onSubmit;
  final String submitLabel;
  final String submittingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.cardBackground,
        borderRadius: AppVisualTokens.radiusLargeBorder,
        border: Border.all(color: AppVisualTokens.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const ForumAuthorAvatar(label: '我', radius: 16),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '写下你的评论...',
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  border: OutlineInputBorder(
                    borderRadius: AppVisualTokens.radiusLargeBorder,
                    borderSide: const BorderSide(
                      color: AppVisualTokens.borderSoft,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppVisualTokens.radiusLargeBorder,
                    borderSide: const BorderSide(
                      color: AppVisualTokens.borderSoft,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppVisualTokens.radiusLargeBorder,
                    borderSide: const BorderSide(
                      color: AppVisualTokens.brandGold,
                    ),
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: submitting ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppVisualTokens.brandGold,
                foregroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: AppVisualTokens.radiusPillBorder,
                ),
              ),
              child: Text(submitting ? submittingLabel : submitLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForumActionPill extends StatelessWidget {
  const _ForumActionPill({
    required this.icon,
    required this.label,
    this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final backgroundColor = selected
        ? AppVisualTokens.brandGold
        : AppVisualTokens.brandGoldLight;
    final foregroundColor = selected && enabled
        ? Colors.white
        : AppVisualTokens.brandGoldDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppVisualTokens.radiusPillBorder,
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled ? backgroundColor : const Color(0xFFF0ECE7),
            borderRadius: AppVisualTokens.radiusPillBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 17, color: foregroundColor),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                    ),
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
