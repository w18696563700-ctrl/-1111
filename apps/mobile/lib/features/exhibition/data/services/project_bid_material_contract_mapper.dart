part of '../exhibition_consumer_layer.dart';

Map<String, Object?>? _sanitizeProjectBidMaterialListPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  final attachments = _sanitizeEntityList(
    map['attachments'],
    _sanitizeProjectBidMaterialMap,
  );
  return <String, Object?>{
    'projectId': _normalize(map['projectId'] as String?),
    'attachments': attachments,
    'materialReview': _sanitizeProjectBidMaterialReviewPayload(
      map['materialReview'],
    ),
  };
}

Map<String, Object?> _sanitizeProjectBidMaterialMap(
  Map<String, Object?> payload,
) {
  return _compactMap(<String, Object?>{
    'attachmentId': _normalize(payload['attachmentId'] as String?),
    'projectId': _normalize(payload['projectId'] as String?),
    'fileAssetId': _normalize(payload['fileAssetId'] as String?),
    'fileName': _normalize(payload['fileName'] as String?),
    'attachmentKind': _sanitizeState(
      payload['attachmentKind'],
      _stableProjectBidMaterialKinds,
    ),
    'mimeType': _sanitizeProjectAttachmentMimeType(payload['mimeType']),
    'sortOrder': _sanitizeProjectAttachmentSortOrder(payload['sortOrder']),
    'createdAt': _normalize(payload['createdAt'] as String?),
  });
}

Map<String, Object?>? _sanitizeProjectBidMaterialReviewPayload(
  Object? payload,
) {
  if (payload is! Map) {
    return null;
  }
  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'projectId': _normalize(map['projectId'] as String?),
    'threadId': _normalize(map['threadId'] as String?),
    'viewerRole': _sanitizeState(map['viewerRole'], const <String>{
      'publisher',
      'bidder',
      'unknown',
    }),
    'chatAvailability': map['chatAvailability'],
    'entries': _sanitizeEntityList(
      map['entries'],
      _sanitizeProjectBidMaterialReviewEntry,
    ),
    'generatedAt': _normalize(map['generatedAt'] as String?),
  });
}

Map<String, Object?> _sanitizeProjectBidMaterialReviewEntry(
  Map<String, Object?> payload,
) {
  return _compactMap(<String, Object?>{
    'entryKey': _normalize(payload['entryKey'] as String?),
    'group': _normalize(payload['group'] as String?),
    'label': _normalize(payload['label'] as String?),
    'summary': _normalize(payload['summary'] as String?),
    'projectId': _normalize(payload['projectId'] as String?),
    'threadId': _normalize(payload['threadId'] as String?),
    'bidId': _normalize(payload['bidId'] as String?),
    'viewerRole': _normalize(payload['viewerRole'] as String?),
    'subjectOwnerRole': _normalize(payload['subjectOwnerRole'] as String?),
    'availabilityState': _normalize(payload['availabilityState'] as String?),
    'reviewState': _normalize(payload['reviewState'] as String?),
    'actionState': _normalize(payload['actionState'] as String?),
    'attachmentCount': _sanitizeNumber(payload['attachmentCount']),
    'badgeCount': _sanitizeNumber(payload['badgeCount']),
    'disabledReason': _normalize(payload['disabledReason'] as String?),
    'sourceFiles': _sanitizeEntityList(
      payload['sourceFiles'],
      _sanitizeProjectBidMaterialReviewSourceFile,
    ),
    'latestFeedbackText': _normalize(payload['latestFeedbackText'] as String?),
    'latestFeedbackAt': _normalize(payload['latestFeedbackAt'] as String?),
    'reviewedAt': _normalize(payload['reviewedAt'] as String?),
    'routeTarget': payload['routeTarget'],
    'truthAnchor': payload['truthAnchor'],
  });
}

Map<String, Object?> _sanitizeProjectBidMaterialReviewSourceFile(
  Map<String, Object?> payload,
) {
  return _compactMap(<String, Object?>{
    'fileAssetId': _normalize(payload['fileAssetId'] as String?),
    'fileName': _normalize(payload['fileName'] as String?),
    'mimeType': _normalize(payload['mimeType'] as String?),
    'sortOrder': _sanitizeNumber(payload['sortOrder']),
  });
}
