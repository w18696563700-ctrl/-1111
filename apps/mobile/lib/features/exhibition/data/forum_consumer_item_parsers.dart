part of 'forum_consumer_layer.dart';

Object _parseFeedItemList(Object? raw) {
  if (raw is! List) {
    return 'forum feed items must be an array';
  }

  final items = <ForumFeedItemView>[];
  for (final item in raw) {
    final parsed = _parseFeedItem(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumFeedItemView);
  }
  return List<ForumFeedItemView>.unmodifiable(items);
}

Object _parseTopicMetadataList(Object? raw) {
  if (raw is! List) {
    return 'forum topic metadata items must be an array';
  }

  final items = <ForumTopicMetadataItemView>[];
  for (final item in raw) {
    final parsed = _parseTopicMetadataItem(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumTopicMetadataItemView);
  }
  return List<ForumTopicMetadataItemView>.unmodifiable(items);
}

Object _parseTopicCardList(Object? raw) {
  if (raw is! List) {
    return 'forum topic items must be an array';
  }

  final items = <ForumTopicCardView>[];
  for (final item in raw) {
    final parsed = _parseTopicCard(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumTopicCardView);
  }
  return List<ForumTopicCardView>.unmodifiable(items);
}

Object _parsePostCardList(Object? raw) {
  if (raw is! List) {
    return 'forum post items must be an array';
  }

  final items = <ForumPostCardView>[];
  for (final item in raw) {
    final parsed = _parsePostCard(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumPostCardView);
  }
  return List<ForumPostCardView>.unmodifiable(items);
}

Object _parseMyPostItemList(Object? raw) {
  if (raw is! List) {
    return 'forum my post items must be an array';
  }

  final items = <ForumMyPostItemView>[];
  for (final item in raw) {
    final parsed = _parseMyPostItem(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumMyPostItemView);
  }
  return List<ForumMyPostItemView>.unmodifiable(items);
}

Object _parseCommentItemList(Object? raw) {
  if (raw is! List) {
    return 'forum comment items must be an array';
  }

  final items = <ForumCommentItemView>[];
  for (final item in raw) {
    final parsed = _parseCommentItem(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumCommentItemView);
  }
  return List<ForumCommentItemView>.unmodifiable(items);
}

Object _parseCommentAssetItemList(Object? raw) {
  if (raw is! List) {
    return 'forum comment asset items must be an array';
  }

  final items = <ForumCommentAssetItemView>[];
  for (final item in raw) {
    final parsed = _parseCommentAssetItem(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumCommentAssetItemView);
  }
  return List<ForumCommentAssetItemView>.unmodifiable(items);
}

Object _parseBookmarkAssetPostList(Object? raw) {
  if (raw is! List) {
    return 'forum bookmark asset items must be an array';
  }

  final items = <ForumPostCardView>[];
  for (final item in raw) {
    final parsed = _parseBookmarkAssetPost(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumPostCardView);
  }
  return List<ForumPostCardView>.unmodifiable(items);
}

Object _parseDraftCardList(Object? raw) {
  if (raw is! List) {
    return 'forum draft items must be an array';
  }

  final items = <ForumDraftCardView>[];
  for (final item in raw) {
    final parsed = _parseDraftCard(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumDraftCardView);
  }
  return List<ForumDraftCardView>.unmodifiable(items);
}

Object _parseSearchResultList(Object? raw) {
  if (raw is! List) {
    return 'forum search items must be an array';
  }

  final items = <ForumSearchResultItemView>[];
  for (final item in raw) {
    final parsed = _parseSearchResult(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumSearchResultItemView);
  }
  return List<ForumSearchResultItemView>.unmodifiable(items);
}

Object _parseInteractionInboxList(Object? raw) {
  if (raw is! List) {
    return 'forum interaction inbox items must be an array';
  }

  final items = <ForumInteractionInboxItemView>[];
  for (final item in raw) {
    final parsed = _parseInteractionInboxItem(item);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumInteractionInboxItemView);
  }
  return List<ForumInteractionInboxItemView>.unmodifiable(items);
}

Object _parseFeedItem(Object? raw) {
  final body = _readBodyMap(raw);
  final postId = _readRequiredString(body?['postId']);
  final topicId = _readRequiredString(body?['topicId']);
  final topicLabel = _readRequiredString(body?['topicLabel']);
  final title = _readRequiredString(body?['title']);
  final excerpt = _readRequiredString(body?['excerpt']);
  final state = _readRequiredString(body?['state']);
  final publishedAt = _readRequiredString(body?['publishedAt']);
  final viewerHasLiked = _readBool(body?['viewerHasLiked']);
  final viewerHasBookmarked = _readBool(body?['viewerHasBookmarked']);
  final viewerFollowsTopic = _readBool(body?['viewerFollowsTopic']);
  final author = _parseAuthor(body?['author']);
  final engagement = _parseEngagement(body?['engagement']);

  if (body == null ||
      postId == null ||
      topicId == null ||
      topicLabel == null ||
      title == null ||
      excerpt == null ||
      state == null ||
      publishedAt == null ||
      viewerHasLiked == null ||
      viewerHasBookmarked == null ||
      viewerFollowsTopic == null) {
    return 'forum feed item is missing required fields';
  }
  if (author is String || engagement is String) {
    return author is String ? author : engagement as String;
  }

  return ForumFeedItemView(
    postId: postId,
    topicId: topicId,
    topicLabel: topicLabel,
    title: title,
    excerpt: excerpt,
    state: state,
    author: author as ForumAuthorSummaryView,
    engagement: engagement as ForumEngagementSummaryView,
    publishedAt: publishedAt,
    viewerHasLiked: viewerHasLiked,
    viewerHasBookmarked: viewerHasBookmarked,
    viewerFollowsTopic: viewerFollowsTopic,
  );
}

Object _parseTopicMetadataItem(Object? raw) {
  final body = _readBodyMap(raw);
  final topicId = _readRequiredString(body?['topicId']);
  final title = _readRequiredString(body?['title']);
  if (body == null || topicId == null || title == null) {
    return 'forum topic metadata item is missing required fields';
  }

  return ForumTopicMetadataItemView(
    topicId: topicId,
    title: title,
    description: _readOptionalString(body['description']),
    selected: _readBool(body['selected']),
  );
}

Object _parseTopicCard(Object? raw) {
  final body = _readBodyMap(raw);
  final topicId = _readRequiredString(body?['topicId']);
  final title = _readRequiredString(body?['title']);
  final excerpt = _readRequiredString(body?['excerpt']);
  final categoryKey = _readRequiredString(body?['categoryKey']);
  final state = _readRequiredString(body?['state']);
  final lastActiveAt = _readRequiredString(body?['lastActiveAt']);
  final author = _parseAuthor(body?['author']);
  final engagement = _parseEngagement(body?['engagement']);

  if (body == null ||
      topicId == null ||
      title == null ||
      excerpt == null ||
      categoryKey == null ||
      state == null ||
      lastActiveAt == null) {
    return 'forum topic card is missing required fields';
  }
  if (author is String || engagement is String) {
    return author is String ? author : engagement as String;
  }

  return ForumTopicCardView(
    topicId: topicId,
    title: title,
    excerpt: excerpt,
    categoryKey: categoryKey,
    state: state,
    author: author as ForumAuthorSummaryView,
    engagement: engagement as ForumEngagementSummaryView,
    lastActiveAt: lastActiveAt,
    highlightedPostId: _readOptionalString(body['highlightedPostId']),
  );
}

Object _parsePostCard(Object? raw) {
  final body = _readBodyMap(raw);
  final postId = _readRequiredString(body?['postId']);
  final topicId = _readRequiredString(body?['topicId']);
  final topicTitle = _readRequiredString(body?['topicTitle']);
  final excerpt = _readRequiredString(body?['excerpt']);
  final state = _readRequiredString(body?['state']);
  final publishedAt = _readRequiredString(body?['publishedAt']);
  final author = _parseAuthor(body?['author']);

  if (body == null ||
      postId == null ||
      topicId == null ||
      topicTitle == null ||
      excerpt == null ||
      state == null ||
      publishedAt == null) {
    return 'forum post card is missing required fields';
  }
  if (author is String) {
    return author;
  }

  return ForumPostCardView(
    postId: postId,
    topicId: topicId,
    topicTitle: topicTitle,
    excerpt: excerpt,
    state: state,
    author: author as ForumAuthorSummaryView,
    publishedAt: publishedAt,
  );
}

Object _parseMyPostItem(Object? raw) {
  final body = _readBodyMap(raw);
  final postId = _readRequiredString(body?['postId']);
  final title = _readRequiredString(body?['title']);
  final topicId = _readRequiredString(body?['topicId']);
  final topicTitle = _readRequiredString(body?['topicTitle']);
  final excerpt = _readRequiredString(body?['excerpt']);
  final state = _readRequiredString(body?['state']);
  final publishedAt = _readRequiredString(body?['publishedAt']);
  final updatedAt = _readRequiredString(body?['updatedAt']);
  final canEdit = _readBool(body?['canEdit']);
  final canDelete = _readBool(body?['canDelete']);

  if (body == null ||
      postId == null ||
      title == null ||
      topicId == null ||
      topicTitle == null ||
      excerpt == null ||
      state == null ||
      publishedAt == null ||
      updatedAt == null ||
      canEdit == null ||
      canDelete == null) {
    return 'forum my post item is missing required fields';
  }

  return ForumMyPostItemView(
    postId: postId,
    title: title,
    topicId: topicId,
    topicTitle: topicTitle,
    excerpt: excerpt,
    state: state,
    publishedAt: publishedAt,
    updatedAt: updatedAt,
    canEdit: canEdit,
    canDelete: canDelete,
  );
}

Object _parseCommentItem(Object? raw) {
  final body = _readBodyMap(raw);
  final commentId = _readRequiredString(body?['commentId']);
  final postId = _readRequiredString(body?['postId']);
  final bodyText = _readRequiredString(body?['body']);
  final state = _readRequiredString(body?['state']);
  final publishedAt = _readRequiredString(body?['publishedAt']);
  final replyCount = _readInt(body?['replyCount']);
  final author = _parseAuthor(body?['author']);

  if (body == null ||
      commentId == null ||
      postId == null ||
      bodyText == null ||
      state == null ||
      publishedAt == null ||
      replyCount == null) {
    return 'forum comment item is missing required fields';
  }
  if (author is String) {
    return author;
  }

  return ForumCommentItemView(
    commentId: commentId,
    postId: postId,
    parentCommentId: _readOptionalString(body['parentCommentId']),
    author: author as ForumAuthorSummaryView,
    body: bodyText,
    state: state,
    publishedAt: publishedAt,
    replyCount: replyCount,
  );
}

Object _parseCommentAssetItem(Object? raw) {
  final body = _readBodyMap(raw);
  final postAnchor = _readBodyMap(body?['post']);
  final commentBody = _readBodyMap(body?['comment']) ?? body;
  final postId =
      _readRequiredString(body?['postId']) ??
      _readRequiredString(postAnchor?['postId']);
  final postTitle =
      _readRequiredString(body?['postTitle']) ??
      _readRequiredString(postAnchor?['title']);
  final topicId =
      _readRequiredString(body?['topicId']) ??
      _readRequiredString(postAnchor?['topicId']);
  final topicLabel =
      _readRequiredString(body?['topicLabel']) ??
      _readRequiredString(postAnchor?['topicLabel']) ??
      _readRequiredString(body?['topicTitle']) ??
      _readRequiredString(postAnchor?['topicTitle']);
  final commentId = _readRequiredString(commentBody?['commentId']);
  final parentCommentId = _readOptionalString(commentBody?['parentCommentId']);
  final bodyText = _readRequiredString(commentBody?['body']);
  final state = _readRequiredString(commentBody?['state']);
  final publishedAt = _readRequiredString(commentBody?['publishedAt']);
  final replyCount =
      _readInt(commentBody?['replyCount']) ??
      _readInt(body?['replyCount']) ??
      0;
  final authorRaw = commentBody?['author'] ?? body?['author'];
  final parsedAuthor = authorRaw == null ? null : _parseAuthor(authorRaw);

  if (body == null ||
      postId == null ||
      postTitle == null ||
      topicId == null ||
      topicLabel == null ||
      commentId == null ||
      bodyText == null ||
      state == null ||
      publishedAt == null) {
    return 'forum comment asset item is missing required fields';
  }
  final author = parsedAuthor is ForumAuthorSummaryView
      ? parsedAuthor
      : const ForumAuthorSummaryView(
          authorId: 'self',
          displayName: '当前账号',
          avatarUrl: null,
          organizationName: null,
        );

  return ForumCommentAssetItemView(
    // `我的评论` 当前实口径可能返回紧凑 comment 结构，不再强依赖
    // post-comments full shape 里的 author/replyCount。
    comment: ForumCommentItemView(
      commentId: commentId,
      postId: postId,
      parentCommentId: parentCommentId,
      author: author,
      body: bodyText,
      state: state,
      publishedAt: publishedAt,
      replyCount: replyCount,
    ),
    postId: postId,
    postTitle: postTitle,
    topicId: topicId,
    topicLabel: topicLabel,
  );
}

Object _parseBookmarkAssetPost(Object? raw) {
  final body = _readBodyMap(raw);
  if (body == null) {
    return 'forum bookmark asset item is missing required fields';
  }

  final postAnchor = _readBodyMap(body['post']);
  final postBody = postAnchor ?? body;
  final postId =
      _readRequiredString(postBody['postId']) ??
      _readRequiredString(body['postId']);
  final topicId = _readRequiredString(postBody['topicId']);
  final title =
      _readRequiredString(postBody['title']) ??
      _readRequiredString(postBody['topicTitle']);
  final excerpt = _readRequiredString(postBody['excerpt']);
  final publishedAt = _readRequiredString(postBody['publishedAt']);
  final state =
      _readRequiredString(postBody['state']) ??
      _readRequiredString(body['state']) ??
      'published';
  final author = _parseAuthor(postBody['author']);

  if (postId == null ||
      topicId == null ||
      title == null ||
      excerpt == null ||
      publishedAt == null) {
    return 'forum bookmark asset item is missing required fields';
  }
  if (author is String) {
    return author;
  }

  return ForumPostCardView(
    postId: postId,
    topicId: topicId,
    topicTitle: title,
    excerpt: excerpt,
    state: state,
    author: author as ForumAuthorSummaryView,
    publishedAt: publishedAt,
  );
}

Object _parseDraftCard(Object? raw) {
  final body = _readBodyMap(raw);
  final draftId = _readRequiredString(body?['draftId']);
  final draftType = _readRequiredString(body?['draftType']);
  final title = _readRequiredString(body?['title']);
  final excerpt = _readRequiredString(body?['excerpt']);
  final state = _readRequiredString(body?['state']);
  final updatedAt = _readRequiredString(body?['updatedAt']);
  final attachments = _parseAttachmentList(body?['attachmentRefs']);

  if (body == null ||
      draftId == null ||
      draftType == null ||
      title == null ||
      excerpt == null ||
      state == null ||
      updatedAt == null) {
    return 'forum draft card is missing required fields';
  }
  if (attachments is String) {
    return attachments;
  }

  return ForumDraftCardView(
    draftId: draftId,
    draftType: draftType,
    topicId: _readOptionalString(body['topicId']),
    title: title,
    excerpt: excerpt,
    state: state,
    updatedAt: updatedAt,
    attachmentRefs: attachments as List<ForumAttachmentRefView>,
  );
}

Object _parseSearchResult(Object? raw) {
  final body = _readBodyMap(raw);
  final resultType = _readRequiredString(body?['resultType']);
  final topicId = _readRequiredString(body?['topicId']);
  final title = _readRequiredString(body?['title']);
  final excerpt = _readRequiredString(body?['excerpt']);
  final publishedAt = _readRequiredString(body?['publishedAt']);
  final author = _parseAuthor(body?['author']);

  if (body == null ||
      resultType == null ||
      topicId == null ||
      title == null ||
      excerpt == null ||
      publishedAt == null) {
    return 'forum search result is missing required fields';
  }
  if (author is String) {
    return author;
  }

  return ForumSearchResultItemView(
    resultType: resultType,
    topicId: topicId,
    postId: _readOptionalString(body['postId']),
    title: title,
    excerpt: excerpt,
    author: author as ForumAuthorSummaryView,
    publishedAt: publishedAt,
  );
}

Object _parseInteractionInboxItem(Object? raw) {
  final body = _readBodyMap(raw);
  final notificationId = _readRequiredString(body?['notificationId']);
  final tab = _readRequiredString(body?['tab']);
  final targetType = _readRequiredString(body?['targetType']);
  final targetId = _readRequiredString(body?['targetId']);
  final title = _readRequiredString(body?['title']);
  final createdAt = _readRequiredString(body?['createdAt']);
  final unread = _readBool(body?['unread']);
  final actor = _parseAuthor(body?['actor']);

  if (body == null ||
      notificationId == null ||
      tab == null ||
      targetType == null ||
      targetId == null ||
      title == null ||
      createdAt == null ||
      unread == null) {
    return 'forum interaction inbox item is missing required fields';
  }
  if (actor is String) {
    return actor;
  }

  return ForumInteractionInboxItemView(
    notificationId: notificationId,
    tab: tab,
    actor: actor as ForumAuthorSummaryView,
    targetType: targetType,
    targetId: targetId,
    title: title,
    preview: _readOptionalString(body['preview']),
    createdAt: createdAt,
    unread: unread,
    canQuickReply: _readBool(body['canQuickReply']),
  );
}
