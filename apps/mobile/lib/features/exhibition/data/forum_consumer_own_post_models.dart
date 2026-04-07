part of 'forum_consumer_layer.dart';

class ForumMyPostItemView {
  const ForumMyPostItemView({
    required this.postId,
    required this.title,
    required this.topicId,
    required this.topicTitle,
    required this.excerpt,
    required this.state,
    required this.publishedAt,
    required this.updatedAt,
    required this.canEdit,
    required this.canDelete,
  });

  final String postId;
  final String title;
  final String topicId;
  final String topicTitle;
  final String excerpt;
  final String state;
  final String publishedAt;
  final String updatedAt;
  final bool canEdit;
  final bool canDelete;
}

class ForumPostEditContinuationView {
  const ForumPostEditContinuationView({
    required this.draftId,
    required this.targetPostId,
    required this.state,
    required this.status,
    required this.message,
  });

  final String draftId;
  final String targetPostId;
  final String state;
  final String status;
  final String message;
}

class ForumPostDeleteContinuationView {
  const ForumPostDeleteContinuationView({
    required this.postId,
    required this.state,
    required this.archivedAt,
    required this.message,
  });

  final String postId;
  final String state;
  final String archivedAt;
  final String message;
}
