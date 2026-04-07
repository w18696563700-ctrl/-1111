part of '../exhibition_consumer_layer.dart';

_SuccessContractValidation _validateWorkbenchSummaryPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final sanitized = _sanitizeWorkbenchSummaryPayload(payload);
  final projectChain = _asMap(raw['project_chain']);
  if (projectChain == null) {
    return _invalidSuccessPayload(
      canonicalPath,
      'response is missing required field "project_chain"',
      payload: sanitized,
    );
  }

  final orderChain = _asMap(raw['order_chain']);
  if (orderChain == null) {
    return _invalidSuccessPayload(
      canonicalPath,
      'response is missing required field "order_chain"',
      payload: sanitized,
    );
  }

  final fulfillmentChain = _asMap(raw['fulfillment_chain']);
  if (fulfillmentChain == null) {
    return _invalidSuccessPayload(
      canonicalPath,
      'response is missing required field "fulfillment_chain"',
      payload: sanitized,
    );
  }

  final extensionBoundary = _asMap(raw['extension_boundary']);
  if (extensionBoundary == null) {
    return _invalidSuccessPayload(
      canonicalPath,
      'response is missing required field "extension_boundary"',
      payload: sanitized,
    );
  }

  final message = _firstValidationError(<String?>[
    _validateWorkbenchProjectChain(
      projectChain,
      '$canonicalPath project_chain',
    ),
    _validateWorkbenchOrderChain(orderChain, '$canonicalPath order_chain'),
    _validateWorkbenchFulfillmentChain(
      fulfillmentChain,
      '$canonicalPath fulfillment_chain',
    ),
    _validateWorkbenchExtensionBoundary(
      extensionBoundary,
      '$canonicalPath extension_boundary',
    ),
  ]);

  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

String? _validateWorkbenchProjectChain(
  Map<String, Object?> raw,
  String context,
) {
  return _firstValidationError(<String?>[
    _requireBooleanField(raw, 'hasProjects', context),
    _requireNullableStringField(raw, 'recentProjectId', context),
    _requireNullableStringField(raw, 'recentProjectTitle', context),
    _requireBooleanField(raw, 'canCreateProject', context),
    _requireBooleanField(raw, 'canOpenProjectPool', context),
  ]);
}

String? _validateWorkbenchOrderChain(Map<String, Object?> raw, String context) {
  return _firstValidationError(<String?>[
    _requireNullableStringField(raw, 'activeOrderId', context),
    _requireNullableStringField(raw, 'activeOrderNo', context),
    _requireNullableStateField(
      raw,
      'activeOrderState',
      _stableOrderStates,
      context,
    ),
    _requireBooleanField(raw, 'canOpenOrderDetail', context),
    _requireBooleanField(raw, 'canOpenContractDetail', context),
    _requireBooleanField(raw, 'canOpenDisputeOpen', context),
  ]);
}

String? _validateWorkbenchFulfillmentChain(
  Map<String, Object?> raw,
  String context,
) {
  return _firstValidationError(<String?>[
    _requireNullableStringField(raw, 'activeMilestoneId', context),
    _requireNullableStringField(raw, 'activeMilestoneTitle', context),
    _requireNullableStateField(
      raw,
      'inspectionState',
      _stableInspectionStates,
      context,
    ),
    _requireBooleanField(raw, 'canOpenMilestoneList', context),
    _requireBooleanField(raw, 'canOpenMilestoneSubmit', context),
    _requireBooleanField(raw, 'canOpenInspectionDetail', context),
    _requireBooleanField(raw, 'canOpenInspectionSubmit', context),
  ]);
}

String? _validateWorkbenchExtensionBoundary(
  Map<String, Object?> raw,
  String context,
) {
  return _firstValidationError(<String?>[
    _requireBooleanField(raw, 'canOpenContractDetail', context),
    _requireStateField(
      raw,
      'ratingEntryState',
      _stableWorkbenchRatingEntryStates,
      context,
    ),
    _requireBooleanField(raw, 'canOpenDisputeOpen', context),
    _requireStateField(
      raw,
      'disputeWithdrawState',
      _stableWorkbenchFrozenStates,
      context,
    ),
  ]);
}
