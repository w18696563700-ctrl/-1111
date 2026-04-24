part of 'forum_consumer_layer.dart';

Object _parseFeed(Map<String, Object?> body) {
  final items = _parseFeedItemList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumFeedView(
    items: items as List<ForumFeedItemView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseTopicMetadata(Map<String, Object?> body) {
  return _parseTopicMetadataList(body['items']);
}

Object _parseTopicCollection(Map<String, Object?> body) {
  final items = _parseTopicCardList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumTopicCardView>(
    items: items as List<ForumTopicCardView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseTopicDetail(Map<String, Object?> body) {
  final topicId = _readRequiredString(body['topicId']);
  final title = _readRequiredString(body['title']);
  final categoryKey = _readRequiredString(body['categoryKey']);
  final state = _readRequiredString(body['state']);
  final leadPostId = _readRequiredString(body['leadPostId']);
  final leadPostExcerpt = _readRequiredString(body['leadPostExcerpt']);
  final publishedAt = _readRequiredString(body['publishedAt']);
  final lastActiveAt = _readRequiredString(body['lastActiveAt']);
  final author = _parseAuthor(body['author']);
  final engagement = _parseEngagement(body['engagement']);

  if (topicId == null ||
      title == null ||
      categoryKey == null ||
      state == null ||
      leadPostId == null ||
      leadPostExcerpt == null ||
      publishedAt == null ||
      lastActiveAt == null) {
    return 'forum topic detail is missing required fields';
  }
  if (author is String || engagement is String) {
    return author is String ? author : engagement as String;
  }

  return ForumTopicDetailView(
    topicId: topicId,
    title: title,
    categoryKey: categoryKey,
    state: state,
    author: author as ForumAuthorSummaryView,
    engagement: engagement as ForumEngagementSummaryView,
    leadPostId: leadPostId,
    leadPostExcerpt: leadPostExcerpt,
    publishedAt: publishedAt,
    lastActiveAt: lastActiveAt,
  );
}

Object _parsePostDetail(Map<String, Object?> body) {
  final postId = _readRequiredString(body['postId']);
  final topicId = _readRequiredString(body['topicId']);
  final topicTitle = _readRequiredString(body['topicTitle']);
  final state = _readRequiredString(body['state']);
  final content = _readRequiredString(body['content']);
  final publishedAt = _readRequiredString(body['publishedAt']);
  final author = _parseAuthor(body['author']);
  final attachments = _parseAttachmentList(body['attachmentRefs']);
  final engagement = _parseEngagement(body['engagement']);

  if (postId == null ||
      topicId == null ||
      topicTitle == null ||
      state == null ||
      content == null ||
      publishedAt == null) {
    return 'forum post detail is missing required fields';
  }
  if (author is String || attachments is String || engagement is String) {
    if (author is String) {
      return author;
    }
    if (attachments is String) {
      return attachments;
    }
    return engagement as String;
  }

  return ForumPostDetailView(
    postId: postId,
    topicId: topicId,
    topicTitle: topicTitle,
    state: state,
    author: author as ForumAuthorSummaryView,
    content: content,
    attachmentRefs: attachments as List<ForumAttachmentRefView>,
    publishedAt: publishedAt,
    engagement: engagement as ForumEngagementSummaryView,
    viewerHasLiked: _readBool(body['viewerHasLiked']),
    viewerHasBookmarked: _readBool(body['viewerHasBookmarked']),
    viewerFollowsTopic: _readBool(body['viewerFollowsTopic']),
  );
}

Object _parseFileAccess(Map<String, Object?> body) {
  final fileAssetId = _readRequiredString(body['fileAssetId']);
  final mode = _readRequiredString(body['mode']);
  final accessUrl = _readRequiredString(body['accessUrl']);
  final fileName = _readRequiredString(body['fileName']);
  final mimeType = _readRequiredString(body['mimeType']);
  final expiresAt = _readRequiredString(body['expiresAt']);
  final contentLengthBytes = _readInt(body['contentLengthBytes']);

  if (fileAssetId == null ||
      mode == null ||
      accessUrl == null ||
      fileName == null ||
      mimeType == null ||
      expiresAt == null) {
    return 'forum file access is missing required fields';
  }
  if (mode != 'preview' && mode != 'download') {
    return 'forum file access mode is unsupported';
  }

  return ForumFileAccessView(
    fileAssetId: fileAssetId,
    mode: mode,
    accessUrl: accessUrl,
    fileName: fileName,
    mimeType: mimeType,
    expiresAt: expiresAt,
    contentLengthBytes: contentLengthBytes,
  );
}

Object _parseCommentCollection(Map<String, Object?> body) {
  final items = _parseCommentItemList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumCommentItemView>(
    items: items as List<ForumCommentItemView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseDraftList(Map<String, Object?> body) {
  final items = _parseDraftCardList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumDraftCardView>(
    items: items as List<ForumDraftCardView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseDraftSaved(Map<String, Object?> body) {
  final draftId = _readRequiredString(body['draftId']);
  final state = _readRequiredString(body['state']);
  final updatedAt = _readRequiredString(body['updatedAt']);
  if (draftId == null || state == null || updatedAt == null) {
    return 'forum draft save result is missing required fields';
  }

  return ForumDraftSavedView(
    draftId: draftId,
    state: state,
    updatedAt: updatedAt,
  );
}

Object _parseSearch(Map<String, Object?> body) {
  final items = _parseSearchResultList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumSearchView(
    items: items as List<ForumSearchResultItemView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseMeIndex(Map<String, Object?> body) {
  final memberId = _readRequiredString(body['memberId']);
  final summary = _parseMeSummary(body['summary']);
  final topics = _parseTopicCardList(body['recentTopics']);
  final posts = _parsePostCardList(body['recentPosts']);
  final drafts = _parseDraftCardList(body['recentDrafts']);

  if (memberId == null) {
    return 'forum me index is missing required field "memberId"';
  }
  if (summary is String ||
      topics is String ||
      posts is String ||
      drafts is String) {
    return summary is String
        ? summary
        : topics is String
        ? topics
        : posts is String
        ? posts
        : drafts as String;
  }

  return ForumMeIndexView(
    memberId: memberId,
    summary: summary as ForumMeSummaryView,
    recentTopics: topics as List<ForumTopicCardView>,
    recentPosts: posts as List<ForumPostCardView>,
    recentDrafts: drafts as List<ForumDraftCardView>,
  );
}

Object _parseMyComments(Map<String, Object?> body) {
  final items = _parseCommentAssetItemList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumCommentAssetItemView>(
    items: items as List<ForumCommentAssetItemView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseMyBookmarks(Map<String, Object?> body) {
  final items = _parseBookmarkAssetPostList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumPostCardView>(
    items: items as List<ForumPostCardView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseMyLikes(Map<String, Object?> body) {
  final items = _parseBookmarkAssetPostList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumPostCardView>(
    items: items as List<ForumPostCardView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseMyFollows(Map<String, Object?> body) {
  return _parseFollowedAuthorCollection(body);
}

Object _parseInteractionInbox(Map<String, Object?> body) {
  final items = _parseInteractionInboxList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumInteractionInboxItemView>(
    items: items as List<ForumInteractionInboxItemView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parsePage(Object? raw) {
  final body = _readBodyMap(raw);
  final hasMore = body?['hasMore'];
  if (body == null || hasMore is! bool) {
    return 'forum page info is missing required fields';
  }
  return ForumCursorPageInfoView(
    nextCursor: _readOptionalString(body['nextCursor']),
    hasMore: hasMore,
  );
}

Object _parseAuthor(Object? raw) {
  final body = _readBodyMap(raw);
  final authorId = _readRequiredString(body?['authorId']);
  final displayName = _readRequiredString(body?['displayName']);
  if (body == null || authorId == null || displayName == null) {
    return 'forum author summary is missing required fields';
  }
  return ForumAuthorSummaryView(
    authorId: authorId,
    displayName: displayName,
    avatarUrl: _readOptionalString(body['avatarUrl']),
    organizationName: _readOptionalString(body['organizationName']),
  );
}

Object _parseEngagement(Object? raw) {
  final body = _readBodyMap(raw);
  final replyCount = _readInt(body?['replyCount']);
  final likeCount = _readInt(body?['likeCount']);
  final viewCount = _readInt(body?['viewCount']);
  if (body == null ||
      replyCount == null ||
      likeCount == null ||
      viewCount == null) {
    return 'forum engagement summary is missing required fields';
  }
  return ForumEngagementSummaryView(
    replyCount: replyCount,
    likeCount: likeCount,
    viewCount: viewCount,
  );
}

Object _parseMeSummary(Object? raw) {
  final body = _readBodyMap(raw);
  final topicCount = _readInt(body?['topicCount']);
  final postCount = _readInt(body?['postCount']);
  final draftCount = _readInt(body?['draftCount']);
  final unreadReplyCount = _readInt(body?['unreadReplyCount']);
  if (body == null ||
      topicCount == null ||
      postCount == null ||
      draftCount == null ||
      unreadReplyCount == null) {
    return 'forum me summary is missing required fields';
  }
  return ForumMeSummaryView(
    topicCount: topicCount,
    postCount: postCount,
    draftCount: draftCount,
    unreadReplyCount: unreadReplyCount,
  );
}
