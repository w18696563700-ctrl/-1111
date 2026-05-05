part of 'forum_pages.dart';

bool _isOwnedForumPost(BuildContext context, ForumAuthorSummaryView author) {
  final shellUserId = AppShellScope.of(
    context,
  ).snapshot.shellContext.userId?.trim();
  final authorId = author.authorId.trim();
  return shellUserId != null &&
      shellUserId.isNotEmpty &&
      authorId.isNotEmpty &&
      shellUserId == authorId;
}

Future<bool> _confirmForumPostDelete(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('删除帖子'),
        content: const Text('删除后，这篇帖子会从公开列表中移除，并按受控删除结果处理。是否继续？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('暂不删除'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认删除'),
          ),
        ],
      );
    },
  );
  return result == true;
}

Widget _buildForumCommentPreview({
  required BuildContext context,
  required ForumPostDetailView detail,
  required List<ForumCommentItemView> comments,
  required bool loading,
  required ForumReadResult<ForumPagedCollectionView<ForumCommentItemView>>?
  commentResult,
  required bool loadingMore,
  required VoidCallback onRetry,
  required VoidCallback onLoadMore,
}) {
  final showCommentState =
      loading ||
      (commentResult?.state != null &&
          commentResult?.state != AppPageState.content);
  final hasMore = commentResult?.data?.page.hasMore == true;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const _ForumDetailSectionHeading(
        title: '评论区',
        summary: '先看看大家怎么说，再决定是否继续回复。',
      ),
      const SizedBox(height: 12),
      if (showCommentState)
        ForumSlimStatePanel(
          loading: loading,
          state: commentResult?.state,
          emptyMessage: '当前帖子还没有评论',
          onRetry: onRetry,
          message: commentResult?.message,
        )
      else if (comments.isNotEmpty)
        ...comments.map(
          (ForumCommentItemView item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ForumCommentCard.fromItem(
              item: item,
              targetLabel: item.parentCommentId == null ? '回复主帖' : '回复评论',
              onOpenAuthor: () =>
                  _openForumAuthorProfile(context, item.author.authorId),
              onReport: () => _showForumReportSheet(
                context,
                target: _ForumReportTarget(
                  targetType: 'comment',
                  targetId: item.commentId,
                  sheetTitle: '举报评论',
                ),
              ),
            ),
          ),
        ),
      if (!showCommentState && comments.isEmpty)
        const ForumSlimStatePanel(
          loading: false,
          state: AppPageState.empty,
          emptyMessage: '当前帖子还没有评论',
          onRetry: _noop,
        ),
      if (hasMore) ...<Widget>[
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: loadingMore ? null : onLoadMore,
            icon: Icon(
              loadingMore
                  ? Icons.hourglass_top_rounded
                  : Icons.expand_more_rounded,
            ),
            label: Text(loadingMore ? '加载中' : '查看更多评论'),
          ),
        ),
      ],
    ],
  );
}
