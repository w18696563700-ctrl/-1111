part of '../exhibition_consumer_layer.dart';

Map<String, Object?>? _asMap(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return payload.map((Object? key, Object? value) => MapEntry('$key', value));
}

String? _firstValidationError(List<String?> candidates) {
  for (final candidate in candidates) {
    if (candidate != null) {
      return candidate;
    }
  }
  return null;
}

String? _requireStringField(
  Map<String, Object?> raw,
  String field,
  String context,
) {
  final value = raw[field];
  if (value is! String || value.trim().isEmpty) {
    return 'contract drift at $context: missing required field "$field"';
  }
  return null;
}

String? _requireNumberField(
  Map<String, Object?> raw,
  String field,
  String context,
) {
  if (raw[field] is! num) {
    return 'contract drift at $context: missing required field "$field"';
  }
  return null;
}

String? _requireBooleanField(
  Map<String, Object?> raw,
  String field,
  String context,
) {
  if (raw[field] is! bool) {
    return 'contract drift at $context: missing required field "$field"';
  }
  return null;
}

String? _requireMapField(
  Map<String, Object?> raw,
  String field,
  String context,
) {
  if (raw[field] is! Map) {
    return 'contract drift at $context: missing required field "$field"';
  }
  return null;
}

String? _requireListField(
  Map<String, Object?> raw,
  String field,
  String context,
) {
  if (raw[field] is! List) {
    return 'contract drift at $context: missing required field "$field"';
  }
  return null;
}

String? _requireNullableStringField(
  Map<String, Object?> raw,
  String field,
  String context,
) {
  if (!raw.containsKey(field)) {
    return 'contract drift at $context: missing required field "$field"';
  }

  final value = raw[field];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    return 'contract drift at $context: field "$field" must be string or null';
  }
  return null;
}

String? _requireStateField(
  Map<String, Object?> raw,
  String field,
  Set<String> allowed,
  String context,
) {
  final value = raw[field];
  if (value is! String || value.trim().isEmpty) {
    return 'contract drift at $context: missing required field "$field"';
  }
  if (!allowed.contains(value)) {
    return 'contract drift at $context: unsupported state "$value" for Phase 2.2';
  }
  return null;
}

_SuccessContractValidation _invalidSuccessPayload(
  String canonicalPath,
  String detail, {
  Object? payload,
}) {
  return _SuccessContractValidation.failure(
    payload: payload,
    message: 'contract drift on $canonicalPath: $detail',
  );
}

String _failureMessage(Object? payload, String fallbackMessage) {
  final rawCode = _rawErrorCode(payload);
  final message = _extractMessage(payload);
  if (rawCode != null && !_stableErrorCodes.contains(rawCode)) {
    if (message != null) {
      return 'unrecognized error code $rawCode from canonical path: $message';
    }
    return 'unrecognized error code $rawCode from canonical path';
  }
  return message ?? fallbackMessage;
}

String? _rawErrorCode(Object? payload) {
  if (payload is Map<String, Object?>) {
    final value = payload['code'] ?? payload['errorCode'];
    return value == null ? null : '$value';
  }
  return null;
}
