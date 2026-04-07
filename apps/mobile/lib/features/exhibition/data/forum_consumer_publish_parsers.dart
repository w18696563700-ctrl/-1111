part of 'forum_consumer_layer.dart';

Object _parseDraftDetail(Map<String, Object?> body) {
  final draftId = _readRequiredString(body['draftId']);
  final draftType = _readRequiredString(body['draftType']);
  final title = _readRequiredString(body['title']);
  final bodyText = _readRequiredString(body['body']);
  final state = _readRequiredString(body['state']);
  final updatedAt = _readRequiredString(body['updatedAt']);
  final attachmentIds = _parseStringList(body['attachmentFileAssetIds']);

  if (draftId == null ||
      draftType == null ||
      title == null ||
      bodyText == null ||
      state == null ||
      updatedAt == null) {
    return 'forum draft detail is missing required fields';
  }
  if (attachmentIds is String) {
    return attachmentIds;
  }

  return ForumDraftDetailView(
    draftId: draftId,
    draftType: draftType,
    targetPostId: _readOptionalString(body['targetPostId']),
    topicId: _readOptionalString(body['topicId']),
    title: title,
    body: bodyText,
    attachmentFileAssetIds: attachmentIds as List<String>,
    state: state,
    updatedAt: updatedAt,
  );
}

Object _parsePublishResult(Map<String, Object?> body) {
  final draftId = _readRequiredString(body['draftId']);
  final state = _readRequiredString(body['state']);
  final decisionRaw = _readRequiredString(body['decision']);
  final decision = ForumPublishDecisionView.fromWire(decisionRaw);
  final message = forumVisiblePublishDecisionMessage(
    decision: decisionRaw,
    rawMessage: _readOptionalString(body['message']),
  );

  if (draftId == null || state == null || decision == null || message == null) {
    return 'forum publish response is missing required fields';
  }

  if (decision == ForumPublishDecisionView.clear) {
    final topicId = _readRequiredString(body['topicId']);
    final postId = _readRequiredString(body['postId']);
    final summaryMap = _readBodyMap(body['summary']);
    final title = _readRequiredString(summaryMap?['title']);
    final publishedAt = _readRequiredString(summaryMap?['publishedAt']);

    if (state != 'published') {
      return 'forum publish clear result has unsupported state';
    }
    if (topicId == null ||
        postId == null ||
        title == null ||
        publishedAt == null) {
      return 'forum publish clear result is missing required fields';
    }

    return ForumPublishResultView(
      draftId: draftId,
      state: state,
      decision: decision,
      message: message,
      topicId: topicId,
      postId: postId,
      title: title,
      publishedAt: publishedAt,
    );
  }

  if (state != 'blocked') {
    return 'forum publish blocked result has unsupported state';
  }

  return ForumPublishResultView(
    draftId: draftId,
    state: state,
    decision: decision,
    message: message,
  );
}

Object _parseDraftDeleted(Map<String, Object?> body) {
  final draftId = _readRequiredString(body['draftId']);
  final state = _readRequiredString(body['state']);
  if (draftId == null || state == null) {
    return 'forum draft delete result is missing required fields';
  }

  return ForumDraftDeletedView(draftId: draftId, state: state);
}

Object _parseStringList(Object? raw) {
  if (raw is! List) {
    return 'forum string list must be an array';
  }
  final values = <String>[];
  for (final item in raw) {
    final value = _readRequiredString(item);
    if (value == null) {
      return 'forum string list item is invalid';
    }
    values.add(value);
  }
  return List<String>.unmodifiable(values);
}
