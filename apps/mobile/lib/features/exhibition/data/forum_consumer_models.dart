part of 'forum_consumer_layer.dart';

class ForumReadResult<T> {
  const ForumReadResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final T? data;
  final String? message;
  final String? errorCode;
}

class ForumActionResult<T> {
  const ForumActionResult({
    required this.isSuccess,
    required this.method,
    required this.path,
    this.controlledState,
    this.data,
    this.message,
    this.errorCode,
  });

  final bool isSuccess;
  final String method;
  final String path;
  final AppPageState? controlledState;
  final T? data;
  final String? message;
  final String? errorCode;
}

class ForumCursorPageInfoView {
  const ForumCursorPageInfoView({
    required this.nextCursor,
    required this.hasMore,
  });

  final String? nextCursor;
  final bool hasMore;
}

class ForumPagedCollectionView<T> {
  const ForumPagedCollectionView({required this.items, required this.page});

  final List<T> items;
  final ForumCursorPageInfoView page;
}

class ForumAuthorSummaryView {
  const ForumAuthorSummaryView({
    required this.authorId,
    required this.displayName,
    required this.avatarUrl,
    required this.organizationName,
  });

  final String authorId;
  final String displayName;
  final String? avatarUrl;
  final String? organizationName;
}

class ForumEngagementSummaryView {
  const ForumEngagementSummaryView({
    required this.replyCount,
    required this.likeCount,
    required this.viewCount,
  });

  final int replyCount;
  final int likeCount;
  final int viewCount;
}

class ForumAttachmentRefView {
  const ForumAttachmentRefView({
    required this.fileAssetId,
    required this.fileName,
    required this.mimeType,
  });

  final String fileAssetId;
  final String fileName;
  final String mimeType;
}

class ForumFileAccessView {
  const ForumFileAccessView({
    required this.fileAssetId,
    required this.mode,
    required this.accessUrl,
    required this.fileName,
    required this.mimeType,
    required this.expiresAt,
    required this.contentLengthBytes,
  });

  final String fileAssetId;
  final String mode;
  final String accessUrl;
  final String fileName;
  final String mimeType;
  final String expiresAt;
  final int? contentLengthBytes;
}

class ForumTopicMetadataItemView {
  const ForumTopicMetadataItemView({
    required this.topicId,
    required this.title,
    required this.description,
    required this.selected,
  });

  final String topicId;
  final String title;
  final String? description;
  final bool? selected;
}

class ForumFeedItemView {
  const ForumFeedItemView({
    required this.postId,
    required this.topicId,
    required this.topicLabel,
    required this.title,
    required this.excerpt,
    required this.state,
    required this.author,
    required this.engagement,
    required this.publishedAt,
    required this.viewerHasLiked,
    required this.viewerHasBookmarked,
    required this.viewerFollowsTopic,
  });

  final String postId;
  final String topicId;
  final String topicLabel;
  final String title;
  final String excerpt;
  final String state;
  final ForumAuthorSummaryView author;
  final ForumEngagementSummaryView engagement;
  final String publishedAt;
  final bool viewerHasLiked;
  final bool viewerHasBookmarked;
  final bool viewerFollowsTopic;
}

class ForumTopicCardView {
  const ForumTopicCardView({
    required this.topicId,
    required this.title,
    required this.excerpt,
    required this.categoryKey,
    required this.state,
    required this.author,
    required this.engagement,
    required this.lastActiveAt,
    required this.highlightedPostId,
  });

  final String topicId;
  final String title;
  final String excerpt;
  final String categoryKey;
  final String state;
  final ForumAuthorSummaryView author;
  final ForumEngagementSummaryView engagement;
  final String lastActiveAt;
  final String? highlightedPostId;
}

class ForumPostCardView {
  const ForumPostCardView({
    required this.postId,
    required this.topicId,
    required this.topicTitle,
    required this.excerpt,
    required this.state,
    required this.author,
    required this.publishedAt,
  });

  final String postId;
  final String topicId;
  final String topicTitle;
  final String excerpt;
  final String state;
  final ForumAuthorSummaryView author;
  final String publishedAt;
}

class ForumCommentItemView {
  const ForumCommentItemView({
    required this.commentId,
    required this.postId,
    required this.parentCommentId,
    required this.author,
    required this.body,
    required this.state,
    required this.publishedAt,
    required this.replyCount,
  });

  final String commentId;
  final String postId;
  final String? parentCommentId;
  final ForumAuthorSummaryView author;
  final String body;
  final String state;
  final String publishedAt;
  final int replyCount;
}

class ForumCommentAssetItemView {
  const ForumCommentAssetItemView({
    required this.comment,
    required this.postId,
    required this.postTitle,
    required this.topicId,
    required this.topicLabel,
  });

  final ForumCommentItemView comment;
  final String postId;
  final String postTitle;
  final String topicId;
  final String topicLabel;
}

class ForumDraftCardView {
  const ForumDraftCardView({
    required this.draftId,
    required this.draftType,
    required this.topicId,
    required this.title,
    required this.excerpt,
    required this.state,
    required this.updatedAt,
    required this.attachmentRefs,
  });

  final String draftId;
  final String draftType;
  final String? topicId;
  final String title;
  final String excerpt;
  final String state;
  final String updatedAt;
  final List<ForumAttachmentRefView> attachmentRefs;
}

class ForumSearchResultItemView {
  const ForumSearchResultItemView({
    required this.resultType,
    required this.topicId,
    required this.postId,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.publishedAt,
  });

  final String resultType;
  final String topicId;
  final String? postId;
  final String title;
  final String excerpt;
  final ForumAuthorSummaryView author;
  final String publishedAt;
}

class ForumFeedView {
  const ForumFeedView({required this.items, required this.page});

  final List<ForumFeedItemView> items;
  final ForumCursorPageInfoView page;
}

class ForumTopicDetailView {
  const ForumTopicDetailView({
    required this.topicId,
    required this.title,
    required this.categoryKey,
    required this.state,
    required this.author,
    required this.engagement,
    required this.leadPostId,
    required this.leadPostExcerpt,
    required this.publishedAt,
    required this.lastActiveAt,
  });

  final String topicId;
  final String title;
  final String categoryKey;
  final String state;
  final ForumAuthorSummaryView author;
  final ForumEngagementSummaryView engagement;
  final String leadPostId;
  final String leadPostExcerpt;
  final String publishedAt;
  final String lastActiveAt;
}

class ForumPostDetailView {
  const ForumPostDetailView({
    required this.postId,
    required this.topicId,
    required this.topicTitle,
    required this.state,
    required this.author,
    required this.content,
    required this.attachmentRefs,
    required this.publishedAt,
    required this.engagement,
    required this.viewerHasLiked,
    required this.viewerHasBookmarked,
    required this.viewerFollowsTopic,
  });

  final String postId;
  final String topicId;
  final String topicTitle;
  final String state;
  final ForumAuthorSummaryView author;
  final String content;
  final List<ForumAttachmentRefView> attachmentRefs;
  final String publishedAt;
  final ForumEngagementSummaryView engagement;
  final bool? viewerHasLiked;
  final bool? viewerHasBookmarked;
  final bool? viewerFollowsTopic;
}

class ForumMeSummaryView {
  const ForumMeSummaryView({
    required this.topicCount,
    required this.postCount,
    required this.draftCount,
    required this.unreadReplyCount,
  });

  final int topicCount;
  final int postCount;
  final int draftCount;
  final int unreadReplyCount;
}

class ForumMeIndexView {
  const ForumMeIndexView({
    required this.memberId,
    required this.summary,
    required this.recentTopics,
    required this.recentPosts,
    required this.recentDrafts,
  });

  final String memberId;
  final ForumMeSummaryView summary;
  final List<ForumTopicCardView> recentTopics;
  final List<ForumPostCardView> recentPosts;
  final List<ForumDraftCardView> recentDrafts;
}

class ForumInteractionInboxItemView {
  const ForumInteractionInboxItemView({
    required this.notificationId,
    required this.tab,
    required this.actor,
    required this.targetType,
    required this.targetId,
    required this.title,
    required this.preview,
    required this.createdAt,
    required this.unread,
    required this.canQuickReply,
  });

  final String notificationId;
  final String tab;
  final ForumAuthorSummaryView actor;
  final String targetType;
  final String targetId;
  final String title;
  final String? preview;
  final String createdAt;
  final bool unread;
  final bool? canQuickReply;
}

class ForumSearchView {
  const ForumSearchView({required this.items, required this.page});

  final List<ForumSearchResultItemView> items;
  final ForumCursorPageInfoView page;
}

class ForumDraftSavedView {
  const ForumDraftSavedView({
    required this.draftId,
    required this.state,
    required this.updatedAt,
  });

  final String draftId;
  final String state;
  final String updatedAt;
}
