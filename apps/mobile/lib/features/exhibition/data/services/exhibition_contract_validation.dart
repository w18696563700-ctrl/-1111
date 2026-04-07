part of '../exhibition_consumer_layer.dart';

class _SuccessContractValidation {
  const _SuccessContractValidation({required this.payload}) : message = null;

  const _SuccessContractValidation.failure({
    this.payload,
    required String this.message,
  });

  final Object? payload;
  final String? message;

  bool get isValid => message == null;
}

typedef _EntityValidation =
    String? Function(Map<String, Object?> raw, String context);

_SuccessContractValidation _sanitizeAndValidateSuccessPayload(
  String canonicalPath,
  Object? payload,
) {
  if (canonicalPath == ExhibitionCanonicalPaths.myProjectList) {
    return _validateMyProjectListPayload(canonicalPath, payload);
  }
  if (ExhibitionCanonicalPaths.isMyProjectDetail(canonicalPath)) {
    return _validateMyProjectDetailPayload(canonicalPath, payload);
  }

  return switch (canonicalPath) {
    ExhibitionCanonicalPaths.exhibitionWorkbench =>
      _validateWorkbenchSummaryPayload(canonicalPath, payload),
    ExhibitionCanonicalPaths.projectList => _validateProjectListPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.projectCreate => _validateProjectCreatePayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.projectDetail => _validateProjectPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.bidSubmit => _validateBidSubmitPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.orderCreate => _validateOrderCreatePayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.orderDetail => _validateOrderPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.milestoneList => _validateMilestoneListPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.milestoneSubmit => _validateMilestoneSubmitPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.contractDetail ||
    ExhibitionCanonicalPaths.contractConfirm ||
    ExhibitionCanonicalPaths.contractAmend ||
    ExhibitionCanonicalPaths.inspectionDetail ||
    ExhibitionCanonicalPaths.inspectionSubmit ||
    ExhibitionCanonicalPaths.ratingEntry ||
    ExhibitionCanonicalPaths.ratingSubmit ||
    ExhibitionCanonicalPaths.disputeOpen => _sanitizeAndValidateEntryPayload(
      canonicalPath,
      payload,
    ),
    _ => _SuccessContractValidation(payload: payload),
  };
}

_SuccessContractValidation _validateProjectListPayload(
  String canonicalPath,
  Object? payload,
) => _validateItemListPayload(
  canonicalPath,
  payload,
  invalidObjectMessage: 'response must be an object containing items',
  sanitizedPayload: _sanitizeProjectListPayload(payload),
  itemValidator: _validateProjectEntity,
);

_SuccessContractValidation _validateProjectPayload(
  String canonicalPath,
  Object? payload,
) => _validateEntityPayload(
  canonicalPath,
  payload,
  sanitizedPayload: _sanitizeProjectPayload(payload),
  validator: _validateProjectEntity,
);

_SuccessContractValidation _validateProjectCreatePayload(
  String canonicalPath,
  Object? payload,
) => _validateSingleRequiredFieldPayload(
  canonicalPath,
  payload,
  field: 'projectId',
  sanitizedPayload: _sanitizeProjectCreatePayload(payload),
);

_SuccessContractValidation _validateBidSubmitPayload(
  String canonicalPath,
  Object? payload,
) => _validateSingleRequiredFieldPayload(
  canonicalPath,
  payload,
  field: 'bidId',
  sanitizedPayload: _sanitizeBidSubmitPayload(payload),
);

_SuccessContractValidation _validateOrderPayload(
  String canonicalPath,
  Object? payload,
) => _validateEntityPayload(
  canonicalPath,
  payload,
  sanitizedPayload: _sanitizeOrderPayload(payload),
  validator: _validateOrderEntity,
);

_SuccessContractValidation _validateOrderCreatePayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final sanitized = _sanitizeOrderCreatePayload(payload);
  final orderIdMessage = _requireStringField(raw, 'orderId', canonicalPath);
  if (orderIdMessage != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      orderIdMessage,
      payload: sanitized,
    );
  }

  final rawMilestones = raw['milestones'];
  if (rawMilestones == null) {
    return _SuccessContractValidation(payload: sanitized);
  }
  if (rawMilestones is! List) {
    return _invalidSuccessPayload(
      canonicalPath,
      'missing required field "milestones"',
      payload: sanitized,
    );
  }
  if (rawMilestones.isEmpty) {
    return _SuccessContractValidation(payload: sanitized);
  }

  final firstMilestone = rawMilestones.first;
  if (firstMilestone is! Map) {
    return _invalidSuccessPayload(
      canonicalPath,
      'milestones[0] must be an object',
      payload: sanitized,
    );
  }

  final message = _requireStringField(
    firstMilestone.map((Object? key, Object? value) => MapEntry('$key', value)),
    'milestoneId',
    '$canonicalPath milestones[0]',
  );
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateMilestoneListPayload(
  String canonicalPath,
  Object? payload,
) => _validateItemListPayload(
  canonicalPath,
  payload,
  invalidObjectMessage: 'response must be an object',
  sanitizedPayload: _sanitizeMilestoneListPayload(payload),
  itemValidator: _validateMilestoneEntity,
);

_SuccessContractValidation _validateMilestoneSubmitPayload(
  String canonicalPath,
  Object? payload,
) => _validateSingleRequiredFieldPayload(
  canonicalPath,
  payload,
  field: 'milestoneId',
  sanitizedPayload: _sanitizeMilestoneSubmitPayload(payload),
);

_SuccessContractValidation _validateItemListPayload(
  String canonicalPath,
  Object? payload, {
  required String invalidObjectMessage,
  required Object? sanitizedPayload,
  required _EntityValidation itemValidator,
}) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, invalidObjectMessage);
  }

  final items = raw['items'];
  if (items is! List) {
    return _invalidSuccessPayload(
      canonicalPath,
      'response is missing required field "items"',
      payload: sanitizedPayload,
    );
  }

  for (var index = 0; index < items.length; index += 1) {
    final item = items[index];
    if (item is! Map) {
      return _invalidSuccessPayload(
        canonicalPath,
        'items[$index] must be an object',
        payload: sanitizedPayload,
      );
    }
    final message = itemValidator(
      item.map((Object? key, Object? value) => MapEntry('$key', value)),
      '$canonicalPath items[$index]',
    );
    if (message != null) {
      return _invalidSuccessPayload(
        canonicalPath,
        message,
        payload: sanitizedPayload,
      );
    }
  }

  return _SuccessContractValidation(payload: sanitizedPayload);
}

_SuccessContractValidation _validateEntityPayload(
  String canonicalPath,
  Object? payload, {
  required Object? sanitizedPayload,
  required _EntityValidation validator,
}) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = validator(raw, canonicalPath);
  if (message != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      message,
      payload: sanitizedPayload,
    );
  }

  return _SuccessContractValidation(payload: sanitizedPayload);
}

_SuccessContractValidation _validateSingleRequiredFieldPayload(
  String canonicalPath,
  Object? payload, {
  required String field,
  required Object? sanitizedPayload,
}) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _requireStringField(raw, field, canonicalPath);
  if (message != null) {
    return _invalidSuccessPayload(
      canonicalPath,
      message,
      payload: sanitizedPayload,
    );
  }

  return _SuccessContractValidation(payload: sanitizedPayload);
}

String? _validateProjectEntity(Map<String, Object?> raw, String context) {
  return _firstValidationError(<String?>[
    _requireStringField(raw, 'projectId', context),
    _requireStringField(raw, 'projectNo', context),
    _requireStringField(raw, 'title', context),
    _requireStringField(raw, 'buildingType', context),
    _requireNumberField(raw, 'budgetAmount', context),
    _requireStateField(raw, 'state', _stableProjectStates, context),
    _requireMapField(raw, 'summary', context),
  ]);
}

String? _validateOrderEntity(Map<String, Object?> raw, String context) {
  final itemsMessage = _requireListField(raw, 'milestones', context);
  if (itemsMessage != null) {
    return itemsMessage;
  }

  final milestones = raw['milestones']! as List;
  for (var index = 0; index < milestones.length; index += 1) {
    final item = milestones[index];
    if (item is! Map) {
      return 'contract drift at $context: milestones[$index] must be an object';
    }
    final message = _validateMilestoneEntity(
      item.map((Object? key, Object? value) => MapEntry('$key', value)),
      '$context milestones[$index]',
    );
    if (message != null) {
      return message;
    }
  }

  return _firstValidationError(<String?>[
    _requireStringField(raw, 'orderId', context),
    _requireStringField(raw, 'orderNo', context),
    _requireStringField(raw, 'projectId', context),
    _requireStringField(raw, 'bidId', context),
    _requireStateField(raw, 'state', _stableOrderStates, context),
    _requireMapField(raw, 'summary', context),
  ]);
}

String? _validateMilestoneEntity(Map<String, Object?> raw, String context) {
  return _firstValidationError(<String?>[
    _requireStringField(raw, 'milestoneId', context),
    _requireStringField(raw, 'orderId', context),
    _requireStringField(raw, 'title', context),
    _requireNumberField(raw, 'amount', context),
    _requireStateField(raw, 'state', _stableMilestoneStates, context),
    _requireMapField(raw, 'summary', context),
  ]);
}
