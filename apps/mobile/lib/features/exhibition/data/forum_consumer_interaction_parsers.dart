part of 'forum_consumer_layer.dart';

Object _parseCommentAccepted(Map<String, Object?> body) {
  final commentId = _readRequiredString(body['commentId']);
  final postId = _readRequiredString(body['postId']);
  final state = _readRequiredString(body['state']);
  final publishedAt = _readRequiredString(body['publishedAt']);
  if (commentId == null ||
      postId == null ||
      state == null ||
      publishedAt == null) {
    return 'forum comment accepted result is missing required fields';
  }

  return ForumCommentAcceptedView(
    commentId: commentId,
    postId: postId,
    state: state,
    publishedAt: publishedAt,
  );
}

Object _parseToggleAccepted(Map<String, Object?> body) {
  final targetId =
      _readRequiredString(body['targetId']) ??
      _readRequiredString(body['postId']);
  final state = _readRequiredString(body['state']);
  if (targetId == null || state == null) {
    return 'forum toggle accepted result is missing required fields';
  }

  return ForumToggleAcceptedView(
    targetId: targetId,
    state: state,
    viewerHasLiked: _readBool(body['viewerHasLiked']),
    viewerHasBookmarked: _readBool(body['viewerHasBookmarked']),
    viewerFollowsAuthor: _readBool(body['viewerFollowsAuthor']),
    likeCount: _readInt(body['likeCount']),
  );
}
