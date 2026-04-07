part of 'forum_consumer_layer.dart';

Object _parseAuthorProfile(Map<String, Object?> body) {
  final authorId = _readRequiredString(body['authorId']);
  final displayName = _readRequiredString(body['displayName']);
  final publicPostCount = _readInt(body['publicPostCount']);
  final publicCommentCount = _readInt(body['publicCommentCount']);
  if (authorId == null ||
      displayName == null ||
      publicPostCount == null ||
      publicCommentCount == null) {
    return 'forum author profile is missing required fields';
  }

  return ForumAuthorProfileView(
    authorId: authorId,
    displayName: displayName,
    avatarUrl: _readOptionalString(body['avatarUrl']),
    organizationName: _readOptionalString(body['organizationName']),
    publicPostCount: publicPostCount,
    publicCommentCount: publicCommentCount,
  );
}

Object _parseAuthorPosts(Map<String, Object?> body) {
  return _parseMyPosts(body);
}
