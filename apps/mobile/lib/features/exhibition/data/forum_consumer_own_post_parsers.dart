part of 'forum_consumer_layer.dart';

Object _parseMyPosts(Map<String, Object?> body) {
  final items = _parseMyPostItemList(body['items']);
  final page = _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumMyPostItemView>(
    items: items as List<ForumMyPostItemView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parsePostEditContinuation(Map<String, Object?> body) {
  final draftId = _readRequiredString(body['draftId']);
  final targetPostId = _readRequiredString(body['targetPostId']);
  final state = _readRequiredString(body['state']);
  final status = _readRequiredString(body['status']);
  final message = _readRequiredString(body['message']);
  if (draftId == null ||
      targetPostId == null ||
      state == null ||
      status == null ||
      message == null) {
    return 'forum post edit continuation is missing required fields';
  }

  return ForumPostEditContinuationView(
    draftId: draftId,
    targetPostId: targetPostId,
    state: state,
    status: status,
    message: message,
  );
}

Object _parsePostDeleteContinuation(Map<String, Object?> body) {
  final postId = _readRequiredString(body['postId']);
  final state = _readRequiredString(body['state']);
  final archivedAt = _readRequiredString(body['archivedAt']);
  final message = _readRequiredString(body['message']);
  if (postId == null ||
      state == null ||
      archivedAt == null ||
      message == null) {
    return 'forum post delete continuation is missing required fields';
  }

  return ForumPostDeleteContinuationView(
    postId: postId,
    state: state,
    archivedAt: archivedAt,
    message: message,
  );
}
