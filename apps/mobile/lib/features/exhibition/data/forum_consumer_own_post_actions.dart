part of 'forum_consumer_layer.dart';

extension ForumConsumerLayerOwnPostActions on ForumConsumerLayer {
  Future<ForumActionResult<ForumPostEditContinuationView>> enterPostEdit({
    required String? postId,
  }) async {
    final resolvedPostId = _requiredRouteValue(postId);
    if (resolvedPostId == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.postEdit,
        controlledState: AppPageState.errorNonRetryable,
        message: '请先选择要编辑的帖子。',
      );
    }

    return _postAction<ForumPostEditContinuationView>(
      path: ForumCanonicalPaths.postEdit,
      body: <String, String>{'postId': resolvedPostId},
      parser: _parsePostEditContinuation,
      networkMessage: '当前暂时无法进入编辑草稿，请稍后再试',
      httpMessage: '当前暂时无法进入编辑草稿，请稍后再试',
      decodeMessage: '当前暂时无法进入编辑草稿，请稍后再试',
    );
  }

  Future<ForumActionResult<ForumPostDeleteContinuationView>> deletePost({
    required String? postId,
  }) async {
    final resolvedPostId = _requiredRouteValue(postId);
    if (resolvedPostId == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.postDelete,
        controlledState: AppPageState.errorNonRetryable,
        message: '请先选择要删除的帖子。',
      );
    }

    return _postAction<ForumPostDeleteContinuationView>(
      path: ForumCanonicalPaths.postDelete,
      body: <String, String>{'postId': resolvedPostId},
      parser: _parsePostDeleteContinuation,
      networkMessage: '当前暂时无法删除这篇帖子，请稍后再试',
      httpMessage: '当前暂时无法删除这篇帖子，请稍后再试',
      decodeMessage: '当前暂时无法删除这篇帖子，请稍后再试',
    );
  }
}
