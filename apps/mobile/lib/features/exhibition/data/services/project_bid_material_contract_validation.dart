part of '../exhibition_consumer_layer.dart';

const Set<String> _stableProjectBidMaterialKinds = <String>{
  'effect_image',
  'construction_doc',
};

_SuccessContractValidation _validateProjectBidMaterialListPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeProjectBidMaterialListPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'projectId', canonicalPath),
    _requireListField(raw, 'attachments', canonicalPath),
  ]);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  final attachments = raw['attachments']! as List;
  for (var index = 0; index < attachments.length; index += 1) {
    final item = attachments[index];
    if (item is! Map) {
      return _invalidSuccessPayload(
        canonicalPath,
        'attachments[$index] must be an object',
        payload: sanitized,
      );
    }

    final itemMessage = _validateProjectBidMaterialEntity(
      item.map((Object? key, Object? value) => MapEntry('$key', value)),
      '$canonicalPath attachments[$index]',
    );
    if (itemMessage != null) {
      return _invalidSuccessPayload(
        canonicalPath,
        itemMessage,
        payload: sanitized,
      );
    }
  }

  return _SuccessContractValidation(payload: sanitized);
}

String? _validateProjectBidMaterialEntity(
  Map<String, Object?> raw,
  String context,
) {
  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'attachmentId', context),
    _requireStringField(raw, 'projectId', context),
    _requireStringField(raw, 'fileAssetId', context),
    _requireStringField(raw, 'fileName', context),
    _requireStateField(
      raw,
      'attachmentKind',
      _stableProjectBidMaterialKinds,
      context,
    ),
    _requireStringField(raw, 'mimeType', context),
    _requireNumberField(raw, 'sortOrder', context),
    _requireStringField(raw, 'createdAt', context),
  ]);
  if (message != null) {
    return message;
  }

  final sortOrder = raw['sortOrder'];
  if (sortOrder is! int || sortOrder < 0) {
    return 'contract drift at $context: sortOrder must be a non-negative integer';
  }

  final mimeType = raw['mimeType']! as String;
  if (!_stableProjectAttachmentMimeTypes.contains(mimeType)) {
    return 'contract drift at $context: unsupported attachment mime "$mimeType"';
  }

  final attachmentKind = raw['attachmentKind']! as String;
  if (!_projectAttachmentKindAllowsMimeType(attachmentKind, mimeType)) {
    return 'contract drift at $context: invalid attachment kind/mime combination';
  }

  return null;
}
