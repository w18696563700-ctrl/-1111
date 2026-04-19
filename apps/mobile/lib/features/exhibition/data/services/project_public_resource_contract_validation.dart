part of '../exhibition_consumer_layer.dart';

_SuccessContractValidation _validateProjectPublicResourceListPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeProjectPublicResourceListPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final resources = raw['resources'];
  if (resources is! List) {
    return _invalidSuccessPayload(
      canonicalPath,
      'response is missing required field "resources"',
      payload: sanitized,
    );
  }

  for (var index = 0; index < resources.length; index += 1) {
    final item = resources[index];
    if (item is! Map) {
      return _invalidSuccessPayload(
        canonicalPath,
        'resources[$index] must be an object',
        payload: sanitized,
      );
    }
    final message = _validateProjectPublicResourceEntity(
      item.map((Object? key, Object? value) => MapEntry('$key', value)),
      '$canonicalPath resources[$index]',
    );
    if (message != null) {
      return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
    }
  }

  return _SuccessContractValidation(payload: sanitized);
}

String? _validateProjectPublicResourceEntity(
  Map<String, Object?> raw,
  String context,
) {
  return _firstValidationError(<String?>[
    _requireStringField(raw, 'resourceId', context),
    _requireStateField(
      raw,
      'resourceCategory',
      _stableProjectPublicResourceCategories,
      context,
    ),
    _requireStringField(raw, 'title', context),
    _requireNullableStringField(raw, 'summary', context),
    _requireStringField(raw, 'fileAssetId', context),
    _requireStringField(raw, 'fileName', context),
    _requireStateField(
      raw,
      'mimeType',
      _stableProjectPublicResourceMimeTypes,
      context,
    ),
    _requireStateField(
      raw,
      'visibility',
      _stableProjectPublicResourceVisibilities,
      context,
    ),
    _requireNumberField(raw, 'sortOrder', context),
    _requireStringField(raw, 'publishedAt', context),
  ]);
}
