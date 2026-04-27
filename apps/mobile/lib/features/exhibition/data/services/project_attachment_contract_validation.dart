part of '../exhibition_consumer_layer.dart';

_SuccessContractValidation _validateProjectAttachmentListPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeProjectAttachmentListPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final rawAttachments = raw['attachments'] ?? raw['items'];
  final message = _firstValidationError(<String?>[
    raw.containsKey('projectId')
        ? _requireStringField(raw, 'projectId', canonicalPath)
        : null,
    rawAttachments is List
        ? null
        : 'contract drift at $canonicalPath: response.attachments must be a list',
  ]);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  final attachments = rawAttachments as List;
  for (var index = 0; index < attachments.length; index += 1) {
    final item = attachments[index];
    if (item is! Map) {
      return _invalidSuccessPayload(
        canonicalPath,
        'attachments[$index] must be an object',
        payload: sanitized,
      );
    }

    final itemMessage = _validateProjectAttachmentEntity(
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

_SuccessContractValidation _validateProjectAttachmentPayload(
  String canonicalPath,
  Object? payload,
) => _validateEntityPayload(
  canonicalPath,
  payload,
  sanitizedPayload: _sanitizeProjectAttachmentPayload(payload),
  validator: _validateProjectAttachmentEntity,
);

_SuccessContractValidation _validateProjectAttachmentDeleteAcceptedPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeProjectAttachmentDeleteAcceptedPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'attachmentId', canonicalPath),
    _requireStringField(raw, 'projectId', canonicalPath),
    _requireStateField(
      raw,
      'state',
      _stableProjectAttachmentDeleteStates,
      canonicalPath,
    ),
  ]);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

String? _validateProjectAttachmentEntity(
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
      _stableProjectAttachmentKinds,
      context,
    ),
    _requireStringField(raw, 'mimeType', context),
    _requireStateField(
      raw,
      'visibility',
      _stableProjectAttachmentVisibilities,
      context,
    ),
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

bool _projectAttachmentKindAllowsMimeType(String kind, String mimeType) {
  return switch (kind) {
    'effect_image' => _isProjectAttachmentImageMimeType(mimeType),
    'construction_doc' => _isProjectAttachmentDocumentMimeType(mimeType),
    'material_sample' =>
      _isProjectAttachmentImageMimeType(mimeType) ||
          _isProjectAttachmentDocumentMimeType(mimeType),
    'equipment_material_list' || 'service_list' =>
      _isProjectAttachmentDocumentMimeType(mimeType) ||
          _isProjectAttachmentSpreadsheetMimeType(mimeType),
    'other_material' =>
      _isProjectAttachmentImageMimeType(mimeType) ||
          _isProjectAttachmentDocumentMimeType(mimeType),
    _ => false,
  };
}
