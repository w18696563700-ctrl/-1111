part of 'forum_pages.dart';

class _ForumPublishContinuationPlan {
  const _ForumPublishContinuationPlan({
    required this.routeName,
    required this.message,
  });

  final String routeName;
  final String message;
}

Future<_ForumPublishContinuationPlan> _resolveForumPublishContinuation(
  ForumPublishResultView publishResult,
) async {
  final postId = _trimmedOrNull(publishResult.postId);
  final topicId = _trimmedOrNull(publishResult.topicId);

  if (postId != null) {
    var detailResult = await ForumConsumerLayer.instance.loadPostDetail(
      postId: postId,
    );
    if (_shouldRetryPublishDetail(detailResult.state)) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      detailResult = await ForumConsumerLayer.instance.loadPostDetail(
        postId: postId,
      );
    }

    if (detailResult.state == AppPageState.content) {
      return _ForumPublishContinuationPlan(
        routeName: ExhibitionRoutes.forumPostWithPostId(postId),
        message: publishResult.message,
      );
    }
  }

  if (topicId != null) {
    await ForumConsumerLayer.instance.loadFeed(
      scope: _feedScopeKey(ForumFeedScope.square),
      topicId: topicId,
    );
    return _ForumPublishContinuationPlan(
      routeName: ExhibitionRoutes.forumSquareWithTopicId(topicId),
      message: '帖子已发布，详情仍在同步，先回到所属讨论区继续查看。',
    );
  }

  await ForumConsumerLayer.instance.loadFeed(
    scope: _feedScopeKey(ForumFeedScope.square),
  );
  return const _ForumPublishContinuationPlan(
    routeName: ExhibitionRoutes.forumSquare,
    message: '帖子已发布，详情仍在同步，先回到论坛广场继续查看。',
  );
}

bool _shouldRetryPublishDetail(AppPageState state) {
  return state == AppPageState.notFound ||
      state == AppPageState.errorRetryable ||
      state == AppPageState.errorNonRetryable;
}

String? _trimmedOrNull(String? raw) {
  final value = raw?.trim();
  return value == null || value.isEmpty ? null : value;
}
