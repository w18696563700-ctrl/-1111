part of '../exhibition_consumer_layer.dart';

_SuccessContractValidation _sanitizeAndValidateEntryPayload(
  String canonicalPath,
  Object? payload,
) {
  return switch (canonicalPath) {
    ExhibitionCanonicalPaths.contractDetail => _validateContractPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.contractConfirm => _validateContractPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.contractAmend => _validateContractPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.inspectionDetail => _validateInspectionPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.inspectionSubmit => _validateInspectionPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.inspectionRecheck => _validateInspectionPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.ratingEntry => _validateRatingPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.ratingSubmit => _validateRatingSubmitPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.disputeOpen => _validateDisputePayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.disputeWithdraw => _validateDisputePayload(
      canonicalPath,
      payload,
    ),
    _ => _SuccessContractValidation(payload: payload),
  };
}

_SuccessContractValidation _validateContractPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'contractId', canonicalPath),
    _requireStringField(raw, 'orderId', canonicalPath),
    _requireStateField(raw, 'state', _stableContractStates, canonicalPath),
    _requireMapField(raw, 'summary', canonicalPath),
  ]);
  final sanitized = _sanitizeContractPayload(payload);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateInspectionPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'inspectionId', canonicalPath),
    _requireStringField(raw, 'milestoneId', canonicalPath),
    _requireStateField(raw, 'state', _stableInspectionStates, canonicalPath),
    _requireMapField(raw, 'summary', canonicalPath),
  ]);
  final sanitized = _sanitizeInspectionPayload(payload);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateRatingPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'orderId', canonicalPath),
    _requireStateField(raw, 'state', _stableRatingStates, canonicalPath),
    _requireMapField(raw, 'summary', canonicalPath),
  ]);
  final sanitized = _sanitizeRatingPayload(payload);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateRatingSubmitPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'ratingId', canonicalPath),
    _requireStringField(raw, 'orderId', canonicalPath),
    _requireStateField(raw, 'state', _stableRatingStates, canonicalPath),
    _requireMapField(raw, 'summary', canonicalPath),
  ]);
  final sanitized = _sanitizeRatingPayload(payload);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateDisputePayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'disputeId', canonicalPath),
    _requireStringField(raw, 'orderId', canonicalPath),
    _requireStateField(raw, 'state', _stableDisputeStates, canonicalPath),
    _requireMapField(raw, 'summary', canonicalPath),
  ]);
  final sanitized = _sanitizeDisputePayload(payload);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}
