part of '../exhibition_consumer_layer.dart';

const Set<String> _stableProjectPublicResourceCategories = <String>{
  'contract_template',
  'process_guide',
  'other_resource',
};

const Set<String> _stableProjectPublicResourceVisibilities = <String>{
  'app_shared',
};

const Set<String> _stableProjectPublicResourceMimeTypes = <String>{
  'image/png',
  'image/jpeg',
  'image/webp',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
};

Map<String, Object?>? _sanitizeProjectPublicResourceListPayload(
  Object? payload,
) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  final resources = _sanitizeEntityList(
    map['resources'],
    _sanitizeProjectPublicResourceMap,
  );
  return <String, Object?>{'resources': resources};
}

Map<String, Object?> _sanitizeProjectPublicResourceMap(
  Map<String, Object?> payload,
) {
  return _compactMap(<String, Object?>{
    'resourceId': _normalize(payload['resourceId'] as String?),
    'resourceCategory': _sanitizeState(
      payload['resourceCategory'],
      _stableProjectPublicResourceCategories,
    ),
    'title': _normalize(payload['title'] as String?),
    'summary': payload.containsKey('summary')
        ? _normalize(payload['summary'] as String?)
        : null,
    'fileAssetId': _normalize(payload['fileAssetId'] as String?),
    'fileName': _normalize(payload['fileName'] as String?),
    'mimeType': _sanitizeProjectPublicResourceMimeType(payload['mimeType']),
    'visibility': _sanitizeState(
      payload['visibility'],
      _stableProjectPublicResourceVisibilities,
    ),
    'sortOrder': _sanitizeProjectPublicResourceSortOrder(payload['sortOrder']),
    'publishedAt': _normalize(payload['publishedAt'] as String?),
  });
}

Map<String, Object?>? _sanitizeProjectPublicResourceFileAccessPayload(
  Object? payload,
) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'fileAssetId': _normalize(map['fileAssetId'] as String?),
    'mode': _normalize(map['mode'] as String?),
    'accessUrl': _normalize(map['accessUrl'] as String?),
    'fileName': _normalize(map['fileName'] as String?),
    'mimeType': _sanitizeProjectPublicResourceMimeType(map['mimeType']),
    'expiresAt': _normalize(map['expiresAt'] as String?),
    'contentLengthBytes':
        map['contentLengthBytes'] is int &&
            (map['contentLengthBytes'] as int) >= 0
        ? map['contentLengthBytes'] as int
        : null,
  });
}

String? _sanitizeProjectPublicResourceMimeType(Object? value) {
  final normalized = value is String ? _normalize(value) : null;
  if (normalized == null) {
    return null;
  }
  return _stableProjectPublicResourceMimeTypes.contains(normalized)
      ? normalized
      : null;
}

int? _sanitizeProjectPublicResourceSortOrder(Object? value) {
  if (value is! int || value < 0) {
    return null;
  }
  return value;
}
