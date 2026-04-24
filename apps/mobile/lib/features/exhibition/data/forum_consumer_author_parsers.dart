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
    viewerFollowsAuthor: _readBool(body['viewerFollowsAuthor']) ?? false,
  );
}

Object _parseFollowedAuthorCollection(Map<String, Object?> body) {
  final items = _parseFollowedAuthorItemList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumFollowedAuthorItemView>(
    items: items as List<ForumFollowedAuthorItemView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseFollowedAuthorItemList(Object? raw) {
  if (raw is! List) {
    return 'forum followed author items must be an array';
  }

  final items = <ForumFollowedAuthorItemView>[];
  for (final item in raw) {
    final parsed = _parseFollowedAuthorItem(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumFollowedAuthorItemView);
  }
  return List<ForumFollowedAuthorItemView>.unmodifiable(items);
}

Object _parseFollowedAuthorItem(Object? raw) {
  final body = _readBodyMap(raw);
  if (body == null) {
    return 'forum followed author item is missing required fields';
  }

  final authorId = _readRequiredString(body['authorId']);
  final displayName = _readRequiredString(body['displayName']);
  final followedAt =
      _readRequiredString(body['followedAt']) ??
      _readRequiredString(body['lastActiveAt']) ??
      _readRequiredString(body['publishedAt']) ??
      DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();
  if (authorId != null && displayName != null) {
    return ForumFollowedAuthorItemView(
      authorId: authorId,
      displayName: displayName,
      avatarUrl: _readOptionalString(body['avatarUrl']),
      organizationName: _readOptionalString(body['organizationName']),
      followedAt: followedAt,
      publicPostCount: _readInt(body['publicPostCount']) ?? 0,
      publicCommentCount: _readInt(body['publicCommentCount']) ?? 0,
      viewerFollowsAuthor: _readBool(body['viewerFollowsAuthor']) ?? true,
    );
  }

  final topic = _parseTopicCard(raw);
  if (topic is ForumTopicCardView) {
    return ForumFollowedAuthorItemView(
      authorId: topic.author.authorId,
      displayName: forumDisplayActorName(topic.author.displayName),
      avatarUrl: topic.author.avatarUrl,
      organizationName: topic.author.organizationName,
      followedAt: topic.lastActiveAt,
      publicPostCount: 0,
      publicCommentCount: topic.engagement.replyCount,
      viewerFollowsAuthor: true,
    );
  }

  return 'forum followed author item is missing required fields';
}

Object _parseAuthorPosts(Map<String, Object?> body) {
  final items = _parseAuthorPostCardList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumAuthorPostCardView>(
    items: items as List<ForumAuthorPostCardView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseAuthorPostCardList(Object? raw) {
  if (raw is! List) {
    return 'forum author posts items must be an array';
  }

  final items = <ForumAuthorPostCardView>[];
  for (final item in raw) {
    final parsed = _parseAuthorPostCard(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumAuthorPostCardView);
  }
  return List<ForumAuthorPostCardView>.unmodifiable(items);
}

Object _parseAuthorPostCard(Object? raw) {
  final body = _readBodyMap(raw);
  final postId = _readRequiredString(body?['postId']);
  final topicId = _readRequiredString(body?['topicId']);
  final topicTitle = _readRequiredString(body?['topicTitle']);
  final title = _readRequiredString(body?['title']);
  final excerpt = _readRequiredString(body?['excerpt']);
  final state = _readRequiredString(body?['state']);
  final publishedAt = _readRequiredString(body?['publishedAt']);
  final updatedAt = _readRequiredString(body?['updatedAt']);
  final canEdit = _readBool(body?['canEdit']);
  final canDelete = _readBool(body?['canDelete']);

  if (body == null ||
      postId == null ||
      topicId == null ||
      topicTitle == null ||
      title == null ||
      excerpt == null ||
      state == null ||
      publishedAt == null ||
      updatedAt == null ||
      canEdit == null ||
      canDelete == null) {
    return 'forum author post card is missing required fields';
  }

  return ForumAuthorPostCardView(
    postId: postId,
    topicId: topicId,
    topicTitle: topicTitle,
    title: title,
    excerpt: excerpt,
    state: state,
    publishedAt: publishedAt,
    updatedAt: updatedAt,
    canEdit: canEdit,
    canDelete: canDelete,
  );
}
