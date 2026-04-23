part of '../exhibition_consumer_layer.dart';

_SuccessContractValidation _validateMyBidListPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeMyBidListPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(
      canonicalPath,
      'response must be an object containing items',
    );
  }

  final itemsMessage = _requireListField(raw, 'items', canonicalPath);
  if (itemsMessage != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      itemsMessage,
      payload: sanitized,
    );
  }

  final items = raw['items']! as List;
  for (var index = 0; index < items.length; index += 1) {
    final item = items[index];
    if (item is! Map) {
      return _invalidSuccessPayload(
        canonicalPath,
        'items[$index] must be an object',
        payload: sanitized,
      );
    }
    final message = _validateMyBidItem(
      item.map((Object? key, Object? value) => MapEntry('$key', value)),
      '$canonicalPath items[$index]',
    );
    if (message != null) {
      return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
    }
  }

  return _SuccessContractValidation(payload: sanitized);
}

String? _validateMyBidItem(Map<String, Object?> raw, String context) {
  return _firstValidationError(<String?>[
    _requireStringField(raw, 'bidId', context),
    _requireStringField(raw, 'projectId', context),
    _requireStringField(raw, 'projectNo', context),
    _requireStringField(raw, 'projectTitle', context),
    _requireNumberField(raw, 'quoteAmount', context),
    _requireStringField(raw, 'proposalSummaryPreview', context),
    _requireStringField(raw, 'submittedAt', context),
    _requireStateField(raw, 'outcomeState', _myBidOutcomeStates, context),
    _requireBooleanField(raw, 'canOpenBidThread', context),
    _requireBooleanField(raw, 'canOpenBidResult', context),
  ]);
}
