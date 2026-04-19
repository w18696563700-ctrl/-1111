part of 'forum_consumer_layer.dart';

Object _parseMyReportTicketList(Map<String, Object?> body) {
  final items = _parseMyReportTicketItemList(body['items']);
  final page = body['page'] == null
      ? const ForumCursorPageInfoView(nextCursor: null, hasMore: false)
      : _parsePage(body['page']);
  if (items is String) {
    return items;
  }
  if (page is String) {
    return page;
  }
  return ForumPagedCollectionView<ForumMyReportTicketItemView>(
    items: items as List<ForumMyReportTicketItemView>,
    page: page as ForumCursorPageInfoView,
  );
}

Object _parseMyReportTicketDetail(Map<String, Object?> body) {
  final parsed = _parseMyReportTicket(body);
  if (parsed is String) {
    return parsed;
  }
  final item = parsed as ForumMyReportTicketItemView;
  return ForumMyReportTicketDetailView(
    reportTicketId: item.reportTicketId,
    targetType: item.targetType,
    targetId: item.targetId,
    reasonCode: item.reasonCode,
    reasonDetail: item.reasonDetail,
    status: item.status,
    targetSnapshot: item.targetSnapshot,
    submittedAt: item.submittedAt,
    updatedAt: item.updatedAt,
  );
}

Object _parseMyReportTicketItemList(Object? raw) {
  if (raw is! List) {
    return 'forum my report ticket items must be an array';
  }

  final items = <ForumMyReportTicketItemView>[];
  for (final item in raw) {
    final body = _readBodyMap(item);
    if (body == null) {
      return 'forum my report ticket item is missing required fields';
    }
    final parsed = _parseMyReportTicket(body);
    if (parsed is String) {
      return parsed;
    }
    items.add(parsed as ForumMyReportTicketItemView);
  }
  return List<ForumMyReportTicketItemView>.unmodifiable(items);
}

Object _parseMyReportTicket(Map<String, Object?> body) {
  final targetBody = _readBodyMap(body['target']);
  final reasonBody = _readBodyMap(body['reason']);
  final reportTicketId =
      _readRequiredString(body['reportTicketId']) ??
      _readRequiredString(body['ticketId']);
  final targetType =
      _readRequiredString(body['targetType']) ??
      _readRequiredString(targetBody?['targetType']);
  final targetId =
      _readRequiredString(body['targetId']) ??
      _readRequiredString(targetBody?['targetId']);
  final reasonCode =
      _readRequiredString(body['reasonCode']) ??
      _readRequiredString(reasonBody?['reasonCode']);
  final reasonDetail =
      _readOptionalString(body['reasonDetail']) ??
      _readOptionalString(reasonBody?['reasonDetail']);
  final status = _readRequiredString(body['status']);
  final submittedAt =
      _readRequiredString(body['submittedAt']) ??
      _readRequiredString(body['createdAt']);
  final updatedAt =
      _readRequiredString(body['updatedAt']) ??
      _readRequiredString(body['submittedAt']) ??
      _readRequiredString(body['createdAt']);

  if (reportTicketId == null ||
      targetType == null ||
      targetId == null ||
      reasonCode == null ||
      status == null ||
      submittedAt == null ||
      updatedAt == null) {
    return 'forum my report ticket is missing required fields';
  }

  return ForumMyReportTicketItemView(
    reportTicketId: reportTicketId,
    targetType: targetType,
    targetId: targetId,
    reasonCode: reasonCode,
    reasonDetail: reasonDetail,
    status: status,
    targetSnapshot: _parseMyReportTargetSnapshot(body['targetSnapshot']),
    submittedAt: submittedAt,
    updatedAt: updatedAt,
  );
}

ForumMyReportTargetSnapshotView _parseMyReportTargetSnapshot(Object? raw) {
  final body = _readBodyMap(raw) ?? const <String, Object?>{};
  return ForumMyReportTargetSnapshotView(
    title: _readOptionalString(body['title']),
    body: _readOptionalString(body['body']),
    excerpt: _readOptionalString(body['excerpt']),
    postId: _readOptionalString(body['postId']),
    commentId: _readOptionalString(body['commentId']),
    publishedAt: _readOptionalString(body['publishedAt']),
  );
}
