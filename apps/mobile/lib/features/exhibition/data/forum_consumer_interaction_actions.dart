part of 'forum_consumer_layer.dart';

extension ForumConsumerLayerInteractionActions on ForumConsumerLayer {
  Future<ForumActionResult<ForumCommentAcceptedView>> submitComment({
    required String? postId,
    String? parentCommentId,
    required String? body,
  }) async {
    final resolvedPostId = _requiredRouteValue(postId);
    final resolvedBody = _requiredRouteValue(body);
    final resolvedParentCommentId = _requiredRouteValue(parentCommentId);
    if (resolvedPostId == null || resolvedBody == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.postComment,
        controlledState: AppPageState.errorNonRetryable,
        message: '请先输入回复内容',
      );
    }

    final requestBody = <String, Object?>{
      'postId': resolvedPostId,
      'body': resolvedBody,
    };
    if (resolvedParentCommentId != null) {
      requestBody['parentCommentId'] = resolvedParentCommentId;
    }

    return _postAction<ForumCommentAcceptedView>(
      path: ForumCanonicalPaths.postComment,
      body: requestBody,
      parser: _parseCommentAccepted,
      networkMessage: '回复暂时发送失败，请稍后再试',
      httpMessage: '回复暂时发送失败，请稍后再试',
      decodeMessage: '回复暂时发送失败，请稍后再试',
    );
  }

  Future<ForumActionResult<ForumToggleAcceptedView>> togglePostLike({
    required String? postId,
    required bool currentlyLiked,
  }) async {
    final resolvedPostId = _requiredRouteValue(postId);
    if (resolvedPostId == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.postLike,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前帖子暂不可用',
      );
    }

    return _postAction<ForumToggleAcceptedView>(
      path: ForumCanonicalPaths.postLike,
      body: <String, Object?>{
        'postId': resolvedPostId,
        'action': currentlyLiked ? 'unlike' : 'like',
      },
      parser: _parseToggleAccepted,
      networkMessage: '点赞暂时没有完成，请稍后再试',
      httpMessage: '点赞暂时没有完成，请稍后再试',
      decodeMessage: '点赞暂时没有完成，请稍后再试',
    );
  }

  Future<ForumActionResult<ForumToggleAcceptedView>> togglePostBookmark({
    required String? postId,
    required bool currentlyBookmarked,
  }) async {
    final resolvedPostId = _requiredRouteValue(postId);
    if (resolvedPostId == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.postBookmark,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前帖子暂不可用',
      );
    }

    return _postAction<ForumToggleAcceptedView>(
      path: ForumCanonicalPaths.postBookmark,
      body: <String, Object?>{
        'postId': resolvedPostId,
        'action': currentlyBookmarked ? 'remove' : 'add',
      },
      parser: _parseToggleAccepted,
      networkMessage: '收藏暂时没有完成，请稍后再试',
      httpMessage: '收藏暂时没有完成，请稍后再试',
      decodeMessage: '收藏暂时没有完成，请稍后再试',
    );
  }
}
