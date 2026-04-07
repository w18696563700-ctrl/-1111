part of 'forum_consumer_layer.dart';

class ForumCommentAcceptedView {
  const ForumCommentAcceptedView({
    required this.commentId,
    required this.postId,
    required this.state,
    required this.publishedAt,
  });

  final String commentId;
  final String postId;
  final String state;
  final String publishedAt;
}

class ForumToggleAcceptedView {
  const ForumToggleAcceptedView({
    required this.targetId,
    required this.state,
    this.viewerHasLiked,
    this.viewerHasBookmarked,
    this.likeCount,
  });

  final String targetId;
  final String state;
  final bool? viewerHasLiked;
  final bool? viewerHasBookmarked;
  final int? likeCount;
}
