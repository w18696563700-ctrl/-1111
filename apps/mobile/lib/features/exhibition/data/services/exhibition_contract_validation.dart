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
  String requestMethod,
  String canonicalPath,
  Object? payload,
) {
  if (canonicalPath == ExhibitionCanonicalPaths.myProjectList) {
    return _validateMyProjectListPayload(canonicalPath, payload);
  }
  if (canonicalPath == ExhibitionCanonicalPaths.myBidList) {
    return _validateMyBidListPayload(canonicalPath, payload);
  }
  if (ExhibitionCanonicalPaths.isMyProjectDetail(canonicalPath)) {
    return requestMethod == 'DELETE'
        ? _validateProjectDeleteAcceptedPayload(canonicalPath, payload)
        : _validateMyProjectDetailPayload(canonicalPath, payload);
  }
  if (ExhibitionCanonicalPaths.isMyProjectAttachmentDelete(canonicalPath)) {
    return _validateProjectAttachmentDeleteAcceptedPayload(
      canonicalPath,
      payload,
    );
  }
  if (canonicalPath == ExhibitionCanonicalPaths.projectPublicResources) {
    return _validateProjectPublicResourceListPayload(canonicalPath, payload);
  }
  if (canonicalPath == ExhibitionCanonicalPaths.projectBidMaterials) {
    return _validateProjectBidMaterialListPayload(canonicalPath, payload);
  }
  if (ExhibitionCanonicalPaths.isMyProjectAttachments(canonicalPath)) {
    return requestMethod == 'GET'
        ? _validateProjectAttachmentListPayload(canonicalPath, payload)
        : _validateProjectAttachmentPayload(canonicalPath, payload);
  }

  if (canonicalPath == _bidSeatLockPath) {
    return _validateBidSeatLockAcceptedPayload(canonicalPath, payload);
  }
  if (canonicalPath == _bidSeatReleasePath) {
    return _validateBidSeatReleaseAcceptedPayload(canonicalPath, payload);
  }
  if (canonicalPath == _bidSeatStatusPath) {
    return _validateBidSeatStatusPayload(canonicalPath, payload);
  }
  if (canonicalPath == _bidPackageCompletenessPath) {
    return _validateBidPackageCompletenessPayload(canonicalPath, payload);
  }

  return switch (canonicalPath) {
    ExhibitionCanonicalPaths.projectList => _validateProjectListPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.projectCreate => _validateProjectCreatePayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.projectSave ||
    ExhibitionCanonicalPaths.projectSubmit ||
    ExhibitionCanonicalPaths.projectPublish ||
    ExhibitionCanonicalPaths.projectWithdraw ||
    ExhibitionCanonicalPaths.projectArchive ||
    ExhibitionCanonicalPaths.projectClose ||
    ExhibitionCanonicalPaths.projectWithdrawPublished ||
    ExhibitionCanonicalPaths.projectDiscardSubmitted =>
      _validateProjectLifecycleAcceptedPayload(canonicalPath, payload),
    ExhibitionCanonicalPaths.projectCancellationRequest ||
    ExhibitionCanonicalPaths.projectCancellationRespond ||
    ExhibitionCanonicalPaths.projectPublisherBreachRecord ||
    ExhibitionCanonicalPaths.projectFactoryBreachRecord =>
      _validateProjectExitCaseAcceptedPayload(canonicalPath, payload),
    ExhibitionCanonicalPaths.projectEditDetail ||
    ExhibitionCanonicalPaths.projectDetail => _validateProjectPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.exhibitionReportSubmit =>
      _validateRequiredFieldsPayload(
        canonicalPath,
        payload,
        fields: const <String>[
          'reportCaseId',
          'targetType',
          'targetId',
          'status',
          'acceptMode',
        ],
        sanitizedPayload: payload,
      ),
    ExhibitionCanonicalPaths.bidAward ||
    ExhibitionCanonicalPaths.bidSelectAndCreateOrder =>
      _validateBidAwardAcceptedPayload(canonicalPath, payload),
    ExhibitionCanonicalPaths.bidSubmit => _validateBidSubmitPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.bidSubmissionSupplement =>
      _validateBidSubmissionSupplementPayload(canonicalPath, payload),
    ExhibitionCanonicalPaths.bidResult => _validateBidResultPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.orderDetail => _validateOrderPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.orderCompleteRequest ||
    ExhibitionCanonicalPaths.orderCompleteConfirm ||
    ExhibitionCanonicalPaths.orderCompleteReject =>
      _validateOrderCompletionAcceptedPayload(canonicalPath, payload),
    ExhibitionCanonicalPaths.ratingEntry ||
    ExhibitionCanonicalPaths.ratingSubmit => _sanitizeAndValidateEntryPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.projectCounterpartyRatingEntry =>
      _validateProjectCounterpartyRatingEntryPayload(canonicalPath, payload),
    ExhibitionCanonicalPaths.projectCounterpartyRatingSubmit =>
      _validateProjectCounterpartyRatingSubmitPayload(canonicalPath, payload),
    ExhibitionCanonicalPaths.milestoneList => _validateMilestoneListPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.milestoneSubmit => _validateMilestoneSubmitPayload(
      canonicalPath,
      payload,
    ),
    ExhibitionCanonicalPaths.contractConfirm ||
    ExhibitionCanonicalPaths.contractAmend ||
    ExhibitionCanonicalPaths.contractDetail ||
    ExhibitionCanonicalPaths.inspectionDetail ||
    ExhibitionCanonicalPaths.inspectionRecheck ||
    ExhibitionCanonicalPaths.inspectionSubmit ||
    ExhibitionCanonicalPaths.disputeOpen ||
    ExhibitionCanonicalPaths.disputeWithdraw =>
      _sanitizeAndValidateEntryPayload(canonicalPath, payload),
    _ => _SuccessContractValidation(payload: payload),
  };
}

_SuccessContractValidation _validateProjectDeleteAcceptedPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeProjectDeleteAcceptedPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'projectId', canonicalPath),
    _requireStateField(raw, 'state', _stableDeleteStates, canonicalPath),
  ]);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
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

_SuccessContractValidation _validateProjectLifecycleAcceptedPayload(
  String canonicalPath,
  Object? payload,
) => _validateRequiredFieldsPayload(
  canonicalPath,
  payload,
  fields: const <String>['projectId', 'state'],
  sanitizedPayload: _sanitizeProjectLifecycleAcceptedPayload(payload),
);

_SuccessContractValidation _validateProjectExitCaseAcceptedPayload(
  String canonicalPath,
  Object? payload,
) => _validateRequiredFieldsPayload(
  canonicalPath,
  payload,
  fields: const <String>[
    'projectId',
    'exitCaseId',
    'projectState',
    'caseStatus',
  ],
  sanitizedPayload: _sanitizeProjectExitCaseAcceptedPayload(payload),
);

_SuccessContractValidation _validateProjectCreatePayload(
  String canonicalPath,
  Object? payload,
) => _validateRequiredFieldsPayload(
  canonicalPath,
  payload,
  fields: const <String>['projectId', 'state'],
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

_SuccessContractValidation _validateBidSubmissionSupplementPayload(
  String canonicalPath,
  Object? payload,
) => _validateRequiredFieldsPayload(
  canonicalPath,
  payload,
  fields: const <String>['bidId', 'projectId', 'entryKey', 'reviewState'],
  sanitizedPayload: _sanitizeBidSubmissionSupplementPayload(payload),
);

_SuccessContractValidation _validateBidAwardAcceptedPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeBidAwardPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'bidAwardId', canonicalPath),
    _requireStringField(raw, 'projectId', canonicalPath),
    _requireStringField(raw, 'winningBidId', canonicalPath),
    _requireNullableStringField(raw, 'orderId', canonicalPath),
    _requireNullableStringField(raw, 'contractId', canonicalPath),
    _requireStateField(raw, 'state', _stableBidAwardStates, canonicalPath),
  ]);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateBidResultPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeBidResultPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'bidId', canonicalPath),
    _requireStringField(raw, 'projectId', canonicalPath),
    _requireStateField(raw, 'state', _stableBidResultStates, canonicalPath),
    _requireStateField(raw, 'result', _stableBidResultOutcomes, canonicalPath),
    _requireStringField(raw, 'reasonCode', canonicalPath),
    _requireStringField(raw, 'reasonText', canonicalPath),
    _requireStringField(raw, 'decidedAt', canonicalPath),
  ]);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateBidSeatLockAcceptedPayload(
  String canonicalPath,
  Object? payload,
) => _validateEntityPayload(
  canonicalPath,
  payload,
  sanitizedPayload: _sanitizeBidSeatPayload(payload),
  validator: _validateBidSeatLockAcceptedEntity,
);

_SuccessContractValidation _validateBidSeatReleaseAcceptedPayload(
  String canonicalPath,
  Object? payload,
) => _validateEntityPayload(
  canonicalPath,
  payload,
  sanitizedPayload: _sanitizeBidSeatPayload(payload),
  validator: _validateBidSeatReleaseAcceptedEntity,
);

_SuccessContractValidation _validateBidSeatStatusPayload(
  String canonicalPath,
  Object? payload,
) => _validateEntityPayload(
  canonicalPath,
  payload,
  sanitizedPayload: _sanitizeBidSeatStatusPayload(payload),
  validator: _validateBidSeatStatusEntity,
);

_SuccessContractValidation _validateBidPackageCompletenessPayload(
  String canonicalPath,
  Object? payload,
) => _validateEntityPayload(
  canonicalPath,
  payload,
  sanitizedPayload: _sanitizeBidPackageCompletenessPayload(payload),
  validator: _validateBidPackageCompletenessEntity,
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

_SuccessContractValidation _validateOrderCompletionAcceptedPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeOrderCompletionAcceptedPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'orderId', canonicalPath),
    _requireStringField(raw, 'projectId', canonicalPath),
    _requireStateField(raw, 'state', _stableOrderStates, canonicalPath),
    _requireStateField(
      raw,
      'completionRequestState',
      _stableOrderCompletionRequestStates,
      canonicalPath,
    ),
    _requireMapField(raw, 'summary', canonicalPath),
  ]);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateProjectCounterpartyRatingEntryPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeProjectCounterpartyRatingEntryPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'orderId', canonicalPath),
    _requireStringField(raw, 'projectId', canonicalPath),
    _requireStringField(raw, 'raterOrganizationId', canonicalPath),
    _requireStringField(raw, 'rateeOrganizationId', canonicalPath),
    _requireBooleanField(raw, 'canRate', canonicalPath),
    _requireNullableStringField(raw, 'reason', canonicalPath),
    _requireNullableStringField(raw, 'ratingState', canonicalPath),
  ]);
  if (message != null) {
    return _invalidSuccessPayload(canonicalPath, message, payload: sanitized);
  }

  return _SuccessContractValidation(payload: sanitized);
}

_SuccessContractValidation _validateProjectCounterpartyRatingSubmitPayload(
  String canonicalPath,
  Object? payload,
) {
  final raw = _asMap(payload);
  final sanitized = _sanitizeProjectCounterpartyRatingSubmitPayload(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  final message = _firstValidationError(<String?>[
    _requireStringField(raw, 'ratingId', canonicalPath),
    _requireStringField(raw, 'orderId', canonicalPath),
    _requireStringField(raw, 'projectId', canonicalPath),
    _requireStringField(raw, 'raterOrganizationId', canonicalPath),
    _requireStringField(raw, 'rateeOrganizationId', canonicalPath),
    _requireStringField(raw, 'state', canonicalPath),
    _requireStringField(raw, 'ratingState', canonicalPath),
    _requireNumberField(raw, 'scoreValue', canonicalPath),
    _requireStringField(raw, 'scoreLabel', canonicalPath),
    _requireStringField(raw, 'submittedAt', canonicalPath),
  ]);
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
  return _validateRequiredFieldsPayload(
    canonicalPath,
    payload,
    fields: <String>[field],
    sanitizedPayload: sanitizedPayload,
  );
}

_SuccessContractValidation _validateRequiredFieldsPayload(
  String canonicalPath,
  Object? payload, {
  required List<String> fields,
  required Object? sanitizedPayload,
}) {
  final raw = _asMap(payload);
  if (raw == null) {
    return _invalidSuccessPayload(canonicalPath, 'response must be an object');
  }

  for (final field in fields) {
    final message = field == 'state'
        ? _requireStateField(raw, field, _stableProjectStates, canonicalPath)
        : _requireStringField(raw, field, canonicalPath);
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

String? _validateBidSeatLockAcceptedEntity(
  Map<String, Object?> raw,
  String context,
) {
  return _firstValidationError(<String?>[
    _requireStringField(raw, 'seatId', context),
    _requireStringField(raw, 'projectId', context),
    _requireStringField(raw, 'bidId', context),
    _requireStateField(raw, 'state', _stableBidSeatStates, context),
    _requireNullableStringField(raw, 'expiresAt', context),
  ]);
}

String? _validateBidSeatReleaseAcceptedEntity(
  Map<String, Object?> raw,
  String context,
) {
  return _firstValidationError(<String?>[
    _requireStringField(raw, 'seatId', context),
    _requireStringField(raw, 'projectId', context),
    _requireStringField(raw, 'bidId', context),
    _requireStateField(raw, 'state', _stableBidSeatStates, context),
    _requireNullableStringField(raw, 'releasedAt', context),
  ]);
}

String? _validateBidSeatStatusEntity(Map<String, Object?> raw, String context) {
  final state = raw['state'] as String?;
  final seatIdMessage = state == 'available'
      ? _requireNullableStringField(raw, 'seatId', context)
      : _requireStringField(raw, 'seatId', context);
  return _firstValidationError(<String?>[
    seatIdMessage,
    _requireStringField(raw, 'projectId', context),
    _requireStringField(raw, 'bidId', context),
    _requireStateField(raw, 'state', _stableBidSeatStates, context),
    _requireNullableStringField(raw, 'expiresAt', context),
    _requireNullableStringField(raw, 'releasedAt', context),
  ]);
}

String? _validateBidPackageCompletenessEntity(
  Map<String, Object?> raw,
  String context,
) {
  final itemsMessage = _requireListField(raw, 'missingItems', context);
  if (itemsMessage != null) {
    return itemsMessage;
  }

  final missingItems = raw['missingItems']! as List;
  for (var index = 0; index < missingItems.length; index += 1) {
    if (missingItems[index] is! String) {
      return 'contract drift at $context: missingItems[$index] must be a string';
    }
  }

  return _firstValidationError(<String?>[
    _requireStringField(raw, 'bidId', context),
    _requireStringField(raw, 'projectId', context),
    _requireStateField(
      raw,
      'state',
      _stableBidPackageCompletenessStates,
      context,
    ),
    _requireBooleanField(raw, 'quoteAmountReady', context),
    _requireBooleanField(raw, 'proposalSummaryReady', context),
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
