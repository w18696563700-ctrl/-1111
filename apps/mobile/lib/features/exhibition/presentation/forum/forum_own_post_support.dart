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
  required VoidCallback onRetry,
}) {
  final showCommentState =
      loading ||
      (commentResult?.state != null &&
          commentResult?.state != AppPageState.content);

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
      else if (comments.isEmpty)
        const _ForumDetailCommentEmpty()
      else
        ...comments
            .take(2)
            .map(
              (ForumCommentItemView item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ForumThreadCommentCard(
                  author: item.author,
                  target: item.parentCommentId == null ? '回复主帖' : '回复评论',
                  content: item.body,
                  meta:
                      '${_compactPublishedAt(item.publishedAt)} · ${item.replyCount} 条后续回复',
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
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).pushNamed(ExhibitionRoutes.forumCommentsWithPostId(detail.postId)),
          icon: const Icon(Icons.forum_outlined),
          label: const Text('查看全部评论'),
        ),
      ),
    ],
  );
}
