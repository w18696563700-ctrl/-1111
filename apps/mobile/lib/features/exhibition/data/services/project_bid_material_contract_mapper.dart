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
