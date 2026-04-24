part of 'forum_consumer_layer.dart';

class ForumAuthorProfileView {
  const ForumAuthorProfileView({
    required this.authorId,
    required this.displayName,
    required this.avatarUrl,
    required this.organizationName,
    required this.publicPostCount,
    required this.publicCommentCount,
    required this.viewerFollowsAuthor,
  });

  final String authorId;
  final String displayName;
  final String? avatarUrl;
  final String? organizationName;
  final int publicPostCount;
  final int publicCommentCount;
  final bool viewerFollowsAuthor;
}

class ForumFollowedAuthorItemView {
  const ForumFollowedAuthorItemView({
    required this.authorId,
    required this.displayName,
    required this.avatarUrl,
    required this.organizationName,
    required this.followedAt,
    required this.publicPostCount,
    required this.publicCommentCount,
    required this.viewerFollowsAuthor,
  });

  final String authorId;
  final String displayName;
  final String? avatarUrl;
  final String? organizationName;
  final String followedAt;
  final int publicPostCount;
  final int publicCommentCount;
  final bool viewerFollowsAuthor;
}

class ForumAuthorPostCardView {
  const ForumAuthorPostCardView({
    required this.postId,
    required this.topicId,
    required this.topicTitle,
    required this.title,
    required this.excerpt,
    required this.state,
    required this.publishedAt,
    required this.updatedAt,
    required this.canEdit,
    required this.canDelete,
  });

  final String postId;
  final String topicId;
  final String topicTitle;
  final String title;
  final String excerpt;
  final String state;
  final String publishedAt;
  final String updatedAt;
  final bool canEdit;
  final bool canDelete;
}
