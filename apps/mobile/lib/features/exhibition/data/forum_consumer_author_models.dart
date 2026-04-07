part of 'forum_consumer_layer.dart';

class ForumAuthorProfileView {
  const ForumAuthorProfileView({
    required this.authorId,
    required this.displayName,
    required this.avatarUrl,
    required this.organizationName,
    required this.publicPostCount,
    required this.publicCommentCount,
  });

  final String authorId;
  final String displayName;
  final String? avatarUrl;
  final String? organizationName;
  final int publicPostCount;
  final int publicCommentCount;
}
