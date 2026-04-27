part of '../exhibition_consumer_layer.dart';

const Set<String> _stableProjectAttachmentKinds = <String>{
  'effect_image',
  'construction_doc',
  'other_material',
};

const Set<String> _stableProjectAttachmentVisibilities = <String>{
  'owner_private',
};

const Set<String> _stableProjectAttachmentDeleteStates = <String>{'deleted'};

const Set<String> _stableProjectAttachmentMimeTypes = <String>{
  'image/png',
  'image/jpeg',
  'image/webp',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
};

Map<String, Object?>? _sanitizeProjectAttachmentListPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  final attachments = _sanitizeEntityList(
    map['attachments'] ?? map['items'],
    _sanitizeProjectAttachmentMap,
  );
  final derivedProjectId =
      _normalize(map['projectId'] as String?) ??
      _projectAttachmentProjectIdFromItems(attachments);
  return <String, Object?>{
    'projectId': derivedProjectId,
    'attachments': attachments,
  };
}

String? _projectAttachmentProjectIdFromItems(
  List<Map<String, Object?>>? attachments,
) {
  if (attachments == null || attachments.isEmpty) {
    return null;
  }
  final first = attachments.first['projectId'];
  return first is String ? _normalize(first) : null;
}

Map<String, Object?>? _sanitizeProjectAttachmentPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  return _sanitizeProjectAttachmentMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeProjectAttachmentDeleteAcceptedPayload(
  Object? payload,
) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'attachmentId': _normalize(map['attachmentId'] as String?),
    'projectId': _normalize(map['projectId'] as String?),
    'state': _sanitizeState(map['state'], _stableProjectAttachmentDeleteStates),
  });
}

Map<String, Object?> _sanitizeProjectAttachmentMap(
  Map<String, Object?> payload,
) {
  final mimeType = _sanitizeProjectAttachmentMimeType(payload['mimeType']);
  return _compactMap(<String, Object?>{
    'attachmentId': _normalize(payload['attachmentId'] as String?),
    'projectId': _normalize(payload['projectId'] as String?),
    'fileAssetId': _normalize(payload['fileAssetId'] as String?),
    'fileName': _normalize(payload['fileName'] as String?),
    'attachmentKind': _sanitizeState(
      payload['attachmentKind'],
      _stableProjectAttachmentKinds,
    ),
    'mimeType': mimeType,
    'visibility': _sanitizeState(
      payload['visibility'],
      _stableProjectAttachmentVisibilities,
    ),
    'sortOrder': _sanitizeProjectAttachmentSortOrder(payload['sortOrder']),
    'createdAt': _normalize(payload['createdAt'] as String?),
    'createdBy': _normalize(payload['createdBy'] as String?),
  });
}

String? _sanitizeProjectAttachmentMimeType(Object? value) {
  final normalized = value is String ? _normalize(value) : null;
  if (normalized == null) {
    return null;
  }
  return _stableProjectAttachmentMimeTypes.contains(normalized)
      ? normalized
      : null;
}

int? _sanitizeProjectAttachmentSortOrder(Object? value) {
  if (value is! int || value < 0) {
    return null;
  }
  return value;
}

bool _isProjectAttachmentImageMimeType(String mimeType) {
  return mimeType.startsWith('image/');
}

bool _isProjectAttachmentDocumentMimeType(String mimeType) {
  return mimeType == 'application/pdf' ||
      mimeType == 'application/msword' ||
      mimeType ==
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
}
