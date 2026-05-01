part of '../exhibition_consumer_layer.dart';

const Set<String> _stableProjectStates = <String>{
  'draft',
  'submitted',
  'published',
  'bidding_closed',
  'awarded',
  'converted_to_order',
  'archived',
};

const Set<String> _stableProjectViewerRelations = <String>{
  'owner',
  'non_owner',
};

const Set<String> _stableProjectNameAccessStates = <String>{
  'visible',
  'requestable',
  'pending',
  'rejected',
};

const Set<String> _stableOrderStates = <String>{
  'active',
  'completed',
  'cancelled',
};

const Set<String> _stableOrderCompletionRequestStates = <String>{
  'none',
  'requested',
  'rejected',
  'dispute_reserved',
  'confirmed',
};

const Set<String> _stableContractStates = <String>{
  'pending_confirm',
  'active',
  'amended',
};

const Set<String> _stableMilestoneStates = <String>{
  'pending_submission',
  'submitted',
};

const Set<String> _stableBidAwardStates = <String>{'converted_to_order'};

const Set<String> _stableBidResultStates = <String>{'awarded', 'lost'};

const Set<String> _stableBidResultOutcomes = <String>{'won', 'lost'};

const Set<String> _stableBidSeatStates = <String>{
  'available',
  'locked',
  'released',
  'timed_out',
};

const Set<String> _stableBidPackageCompletenessStates = <String>{
  'complete',
  'incomplete',
};

const Set<String> _stableInspectionStates = <String>{
  'draft',
  'submitted',
  'rechecked',
};

const Set<String> _stableRatingStates = <String>{'eligible', 'submitted'};

const Set<String> _stableDisputeStates = <String>{
  'accepted',
  'opened',
  'withdrawn',
};

const Set<String> _stableDeleteStates = <String>{'deleted'};

const Set<String> _stableErrorCodes = <String>{
  'AUTH_SESSION_INVALID',
  'AUTH_PERMISSION_INSUFFICIENT',
  'AUTH_RESOURCE_UNAVAILABLE',
  'FILE_UPLOAD_INIT_INVALID',
  'FILE_UPLOAD_INIT_FAILED',
  'PROJECT_CREATE_INVALID',
  'PROJECT_INVALID_STATE',
  'PROJECT_EXIT_INVALID_STATE',
  'PROJECT_WITHDRAW_INVALID',
  'PROJECT_ARCHIVE_INVALID',
  'PROJECT_CLOSE_INVALID',
  'PROJECT_WITHDRAW_PUBLISHED_INVALID',
  'PROJECT_SUBMITTED_DISCARD_INVALID',
  'PROJECT_CANCELLATION_REQUEST_INVALID',
  'PROJECT_CANCELLATION_RESPONSE_INVALID',
  'PROJECT_BREACH_RECORD_INVALID',
  'BID_SUBMIT_INVALID',
  'BID_DUPLICATE_SUBMISSION',
  'BID_AWARD_INVALID',
  'BID_AWARD_INVALID_STATE',
  'BID_AWARD_DUPLICATE',
  'BID_AWARD_CONCURRENT_CONFLICT',
  'BID_RESULT_INVALID',
  'BID_RESULT_UNAVAILABLE',
  'BID_SEAT_INVALID',
  'BID_SEAT_INVALID_STATE',
  'BID_SEAT_CONFLICT',
  'BID_SEAT_TIMEOUT',
  'BID_PACKAGE_COMPLETENESS_INVALID',
  'BID_PACKAGE_COMPLETENESS_UNAVAILABLE',
  'ORDER_INVALID_STATE',
  'ORDER_CONVERSION_FAILED',
  'PROJECT_ORDER_COMPLETE_INVALID',
  'PROJECT_ORDER_COMPLETE_UNAVAILABLE',
  'PROJECT_ORDER_COMPLETE_INVALID_STATE',
  'CONTRACT_ENTRY_UNAVAILABLE',
  'CONTRACT_CONFIRM_INVALID',
  'CONTRACT_INVALID_STATE',
  'CONTRACT_AMEND_INVALID',
  'CONTRACT_AMEND_LIMIT_REACHED',
  'CONTRACT_SEED_FAILED',
  'MILESTONE_SUBMIT_INVALID',
  'MILESTONE_INVALID_STATE',
  'INSPECTION_ENTRY_UNAVAILABLE',
  'INSPECTION_SUBMIT_INVALID',
  'INSPECTION_INVALID_STATE',
  'INSPECTION_RECHECK_INVALID',
  'INSPECTION_RECHECK_LIMIT_REACHED',
  'RATING_ENTRY_UNAVAILABLE',
  'RATING_SUBMIT_INVALID',
  'RATING_INVALID_STATE',
  'PROJECT_COUNTERPARTY_RATING_INVALID',
  'PROJECT_COUNTERPARTY_RATING_FORBIDDEN',
  'PROJECT_COUNTERPARTY_RATING_UNAVAILABLE',
  'PROJECT_COUNTERPARTY_RATING_DUPLICATE',
  'DISPUTE_OPEN_INVALID',
  'DISPUTE_WITHDRAW_INVALID',
  'DISPUTE_INVALID_STATE',
  'FILE_UPLOAD_CONFIRM_REQUIRED',
  'PROJECT_ATTACHMENT_INVALID',
  'PROJECT_ATTACHMENT_UNAVAILABLE',
  'PROJECT_ATTACHMENT_NOT_FOUND',
  'PROJECT_ATTACHMENT_PERMISSION_DENIED',
  'PROJECT_ATTACHMENT_FILE_ASSET_NOT_CONFIRMED',
  'FILE_ACCESS_INVALID',
  'FILE_ACCESS_FAILED',
  'FILE_ACCESS_NOT_FOUND',
  'FILE_ACCESS_PERMISSION_DENIED',
  'FILE_ACCESS_UNAVAILABLE',
  'ORGANIZATION_CERTIFICATION_REQUIRED',
  'TRADE_TASK_CREATE_REJECTED',
  'TRADE_TASK_NOT_FOUND',
  'TRADE_TASK_INVALID_STATE',
  'TRADE_TASK_AUTHENTICITY_MATERIAL_REQUIRED',
  'TRADE_TASK_AUTHENTICITY_DECLARATION_REQUIRED',
  'FIXED_PRICE_BID_CREATE_REJECTED',
  'SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED',
  'SERVICE_FEE_AUTHORIZATION_INIT_REJECTED',
  'SERVICE_FEE_AUTHORIZATION_RESULT_UNAVAILABLE',
  'INQUIRY_DEPOSIT_ORDER_CREATE_REJECTED',
  'INQUIRY_DEPOSIT_PAY_INIT_REJECTED',
  'INQUIRY_DEPOSIT_RESULT_UNAVAILABLE',
  'INQUIRY_QUOTE_SEAT_FULL',
  'INQUIRY_QUOTATION_CREATE_REJECTED',
  'INQUIRY_RESULT_PROCESSING_REJECTED',
  'CONTRACT_CONFIRMATION_REJECTED',
  'P0_PAY_SUMMARY_UNAVAILABLE',
  'P0_PAY_INVALID',
  'P0_PAY_RESOURCE_UNAVAILABLE',
  'P0_PAY_PERMISSION_DENIED',
  'P0_PAY_STATE_CONFLICT',
  'P0_PAY_IDEMPOTENCY_CONFLICT',
  'PAYMENT_CHANNEL_UNAVAILABLE',
  'PAYMENT_CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION',
  'IDEMPOTENCY_KEY_CONFLICT',
};

Object? _sanitizeFailurePayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  final sanitized = <String, Object?>{};
  final code = _extractErrorCode(map);
  final message = _normalize('${map['message'] ?? ''}');
  final source = _normalize('${map['source'] ?? ''}');

  if (code != null) {
    sanitized['code'] = code;
  }
  if (message != null) {
    sanitized['message'] = message;
  }
  if (source != null) {
    sanitized['source'] = source;
  }

  return sanitized.isEmpty ? null : sanitized;
}

Map<String, Object?>? _sanitizeProjectListPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  final items = _sanitizeEntityList(map['items'], _sanitizeProjectMap);
  final sanitized = <String, Object?>{};
  if (items != null) {
    sanitized['items'] = items;
  }

  return sanitized;
}

Map<String, Object?>? _sanitizeMilestoneListPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  final sanitized = <String, Object?>{};
  final orderId = _normalize(map['orderId'] as String?);
  if (orderId != null) {
    sanitized['orderId'] = orderId;
  }
  final items = _sanitizeEntityList(map['items'], _sanitizeMilestoneMap);
  if (items != null) {
    sanitized['items'] = items;
  }
  final summary = _sanitizeSummary(map['summary']);
  if (summary != null) {
    sanitized['summary'] = summary;
  }

  return sanitized;
}

Map<String, Object?>? _sanitizeContractPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return _sanitizeContractMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeInspectionPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return _sanitizeInspectionMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeDisputePayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return _sanitizeDisputeMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeRatingPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return _sanitizeRatingMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeProjectPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return _sanitizeProjectDetailMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeProjectCreatePayload(Object? payload) {
  return _sanitizeProjectLifecycleAcceptedPayload(payload);
}

Map<String, Object?>? _sanitizeProjectDeleteAcceptedPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'projectId': _normalize(map['projectId'] as String?),
    'state': _sanitizeState(map['state'], _stableDeleteStates),
  });
}

Map<String, Object?>? _sanitizeProjectLifecycleAcceptedPayload(
  Object? payload,
) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'projectId': _normalize(map['projectId'] as String?),
    'state': _sanitizeState(map['state'], _stableProjectStates),
  });
}

Map<String, Object?>? _sanitizeProjectExitCaseAcceptedPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'projectId': _normalize(map['projectId'] as String?),
    'exitCaseId': _normalize(map['exitCaseId'] as String?),
    'projectState': _sanitizeState(map['projectState'], _stableProjectStates),
    'caseStatus': _normalize(map['caseStatus'] as String?),
    'action': _normalize(map['action'] as String?),
    'breachParty': _normalize(map['breachParty'] as String?),
    'creditImpactCandidate': map['creditImpactCandidate'] is bool
        ? map['creditImpactCandidate'] as bool
        : null,
  });
}

Map<String, Object?>? _sanitizeBidSubmitPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'bidId': _normalize(map['bidId'] as String?),
  });
}

Map<String, Object?>? _sanitizeBidAwardPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return <String, Object?>{
    'bidAwardId': _normalize(map['bidAwardId'] as String?),
    'projectId': _normalize(map['projectId'] as String?),
    'winningBidId': _normalize(map['winningBidId'] as String?),
    'orderId': _normalize(map['orderId'] as String?),
    'contractId': _normalize(map['contractId'] as String?),
    'state': _sanitizeState(map['state'], _stableBidAwardStates),
    'actionKey': _normalize(map['actionKey'] as String?),
    'routeTarget': _asMap(map['routeTarget']),
  };
}

Map<String, Object?>? _sanitizeOrderCompletionAcceptedPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'orderId': _normalize(map['orderId'] as String?),
    'projectId': _normalize(map['projectId'] as String?),
    'state': _sanitizeState(map['state'], _stableOrderStates),
    'completionRequestState': _sanitizeState(
      map['completionRequestState'],
      _stableOrderCompletionRequestStates,
    ),
    'summary': _asMap(map['summary']),
    'actionKey': _normalize(map['actionKey'] as String?),
    'routeTarget': _asMap(map['routeTarget']),
  });
}

Map<String, Object?>? _sanitizeBidResultPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'bidId': _normalize(map['bidId'] as String?),
    'projectId': _normalize(map['projectId'] as String?),
    'state': _sanitizeState(map['state'], _stableBidResultStates),
    'result': _sanitizeState(map['result'], _stableBidResultOutcomes),
    'reasonCode': _normalize(map['reasonCode'] as String?),
    'reasonText': _normalize(map['reasonText'] as String?),
    'decidedAt': _normalize(map['decidedAt'] as String?),
  });
}

Map<String, Object?>? _sanitizeBidSeatPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'seatId': _normalize(map['seatId'] as String?),
    'projectId': _normalize(map['projectId'] as String?),
    'bidId': _normalize(map['bidId'] as String?),
    'state': _sanitizeState(map['state'], _stableBidSeatStates),
    'expiresAt': _normalize(map['expiresAt'] as String?),
    'releasedAt': _normalize(map['releasedAt'] as String?),
  });
}

Map<String, Object?>? _sanitizeBidSeatStatusPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return <String, Object?>{
    'seatId': map.containsKey('seatId') ? map['seatId'] : null,
    'projectId': _normalize(map['projectId'] as String?),
    'bidId': _normalize(map['bidId'] as String?),
    'state': _sanitizeState(map['state'], _stableBidSeatStates),
    'expiresAt': _normalize(map['expiresAt'] as String?),
    'releasedAt': _normalize(map['releasedAt'] as String?),
  };
}

Map<String, Object?>? _sanitizeBidPackageCompletenessPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'bidId': _normalize(map['bidId'] as String?),
    'projectId': _normalize(map['projectId'] as String?),
    'state': _sanitizeState(map['state'], _stableBidPackageCompletenessStates),
    'missingItems': _sanitizeStringList(map['missingItems']),
    'quoteAmountReady': _sanitizeBool(map['quoteAmountReady']),
    'proposalSummaryReady': _sanitizeBool(map['proposalSummaryReady']),
  });
}

Map<String, Object?>? _sanitizeOrderPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return _sanitizeOrderMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeMilestoneSubmitPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'milestoneId': _normalize(map['milestoneId'] as String?),
  });
}

Map<String, Object?> _sanitizeProjectMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'projectId': _normalize(payload['projectId'] as String?),
    'projectNo': _normalize(payload['projectNo'] as String?),
    'title': _normalize(payload['title'] as String?),
    'displayTitle': _normalize(payload['displayTitle'] as String?),
    'exhibitionName': _normalize(payload['exhibitionName'] as String?),
    'brandName': _normalize(payload['brandName'] as String?),
    'buildingType': _normalize(payload['buildingType'] as String?),
    'budgetAmount': _sanitizeNumber(payload['budgetAmount']),
    'areaSqm': _sanitizeNumber(payload['areaSqm']),
    'provinceCode': _normalize(payload['provinceCode'] as String?),
    'provinceName': _normalize(payload['provinceName'] as String?),
    'cityCode': _normalize(payload['cityCode'] as String?),
    'cityName': _normalize(payload['cityName'] as String?),
    'plannedStartAt': _normalize(payload['plannedStartAt'] as String?),
    'plannedEndAt': _normalize(payload['plannedEndAt'] as String?),
    'publishedAt': _normalize(payload['publishedAt'] as String?),
    'state': _sanitizeState(payload['state'], _stableProjectStates),
    'nameAccess': _sanitizeProjectNameAccess(
      payload['nameAccess'],
      includeRequestId: false,
    ),
    'summary': _sanitizeSummary(payload['summary']),
  });
}

Map<String, Object?> _sanitizeProjectDetailMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    ..._sanitizeProjectMap(payload),
    'buildingTypeRemark': _normalize(payload['buildingTypeRemark'] as String?),
    'description': _normalize(payload['description'] as String?),
    'districtCode': _normalize(payload['districtCode'] as String?),
    'districtName': _normalize(payload['districtName'] as String?),
    'detailAddress': _normalize(payload['detailAddress'] as String?),
    'scopeSummary': _normalize(payload['scopeSummary'] as String?),
    'plannedStartAt': _normalize(payload['plannedStartAt'] as String?),
    'plannedEndAt': _normalize(payload['plannedEndAt'] as String?),
    'scheduleDetail': _normalize(payload['scheduleDetail'] as String?),
    'taskId': _normalize(payload['taskId'] as String?),
    'tradeTaskId': _normalize(payload['tradeTaskId'] as String?),
    'p0PaySummary': _asMap(payload['p0PaySummary']),
    'currentViewerBid': _sanitizeCurrentViewerBidMap(
      payload['currentViewerBid'],
    ),
    'bidCandidates': _sanitizeEntityList(
      payload['bidCandidates'] ?? payload['bids'],
      _sanitizeProjectBidCandidateMap,
    ),
    'bidSelection': _asMap(payload['bidSelection']),
    'orderSummary': _asMap(payload['orderSummary']),
    'order': _asMap(payload['order']),
    'orderId': _normalize(payload['orderId'] as String?),
    'nameAccess': _sanitizeProjectNameAccess(
      payload['nameAccess'],
      includeRequestId: true,
    ),
    'viewerProjectRelation': _sanitizeState(
      payload['viewerProjectRelation'],
      _stableProjectViewerRelations,
    ),
  });
}

Map<String, Object?>? _sanitizeCurrentViewerBidMap(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  final bidId = _normalize(map['bidId'] as String?);
  final state = _normalize(map['state'] as String?);
  if (bidId == null || state == null) {
    return null;
  }
  return <String, Object?>{'bidId': bidId, 'state': state};
}

Map<String, Object?> _sanitizeProjectBidCandidateMap(
  Map<String, Object?> payload,
) {
  return _compactMap(<String, Object?>{
    'bidId': _normalize(payload['bidId'] as String?),
    'bidNo': _normalize(payload['bidNo'] as String?),
    'bidderOrganizationId': _normalize(
      payload['bidderOrganizationId'] as String?,
    ),
    'bidderOrganizationName':
        _normalize(payload['bidderOrganizationName'] as String?) ??
        _normalize(payload['bidderName'] as String?) ??
        _normalize(payload['organizationName'] as String?) ??
        _normalize(payload['companyName'] as String?),
    'quoteAmount': _sanitizeNumber(payload['quoteAmount']),
    'proposalSummary':
        _normalize(payload['proposalSummary'] as String?) ??
        _normalize(payload['proposalSummaryPreview'] as String?),
    'state': _normalize(payload['state'] as String?),
    'submittedAt': _normalize(payload['submittedAt'] as String?),
  });
}

Map<String, Object?> _sanitizeOrderMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'orderId': _normalize(payload['orderId'] as String?),
    'orderNo': _normalize(payload['orderNo'] as String?),
    'projectId': _normalize(payload['projectId'] as String?),
    'bidId': _normalize(payload['bidId'] as String?),
    'buyerOrganizationId': _normalize(
      payload['buyerOrganizationId'] as String?,
    ),
    'sellerOrganizationId':
        _normalize(payload['sellerOrganizationId'] as String?) ??
        _normalize(payload['supplierOrganizationId'] as String?),
    'state': _sanitizeState(payload['state'], _stableOrderStates),
    'completionRequestState': _sanitizeState(
      payload['completionRequestState'],
      _stableOrderCompletionRequestStates,
    ),
    'completionRequestNote': _normalize(
      payload['completionRequestNote'] as String?,
    ),
    'completionRejectionReason': _normalize(
      payload['completionRejectionReason'] as String?,
    ),
    'exitGovernance': _sanitizeExitGovernanceMap(payload['exitGovernance']),
    'summary': _sanitizeSummary(payload['summary']),
    'milestones': _sanitizeEntityList(
      payload['milestones'],
      _sanitizeMilestoneMap,
    ),
  });
}

Map<String, Object?>? _sanitizeExitGovernanceMap(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'exitCaseId': _normalize(map['exitCaseId'] as String?),
    'exitType': _normalize(map['exitType'] as String?),
    'caseStatus': _normalize(map['caseStatus'] as String?),
    'breachParty': _normalize(map['breachParty'] as String?),
    'counterpartyAction':
        _normalize(map['counterpartyAction'] as String?) ??
        _normalize(map['actionHint'] as String?),
    'updatedAt': _normalize(map['updatedAt'] as String?),
  });
}

Map<String, Object?> _sanitizeContractMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'contractId': _normalize(payload['contractId'] as String?),
    'orderId': _normalize(payload['orderId'] as String?),
    'state': _sanitizeState(payload['state'], _stableContractStates),
    'summary': _sanitizeSummary(payload['summary']),
  });
}

Map<String, Object?> _sanitizeMilestoneMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'milestoneId': _normalize(payload['milestoneId'] as String?),
    'orderId': _normalize(payload['orderId'] as String?),
    'title': _normalize(payload['title'] as String?),
    'amount': _sanitizeNumber(payload['amount']),
    'state': _sanitizeState(payload['state'], _stableMilestoneStates),
    'summary': _sanitizeSummary(payload['summary']),
  });
}

Map<String, Object?> _sanitizeInspectionMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'inspectionId': _normalize(payload['inspectionId'] as String?),
    'milestoneId': _normalize(payload['milestoneId'] as String?),
    'state': _sanitizeState(payload['state'], _stableInspectionStates),
    'summary': _sanitizeSummary(payload['summary']),
  });
}

Map<String, Object?> _sanitizeDisputeMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'disputeId': _normalize(payload['disputeId'] as String?),
    'orderId': _normalize(payload['orderId'] as String?),
    'state': _sanitizeState(payload['state'], _stableDisputeStates),
    'summary': _sanitizeSummary(payload['summary']),
  });
}

Map<String, Object?> _sanitizeRatingMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'ratingId': _normalize(payload['ratingId'] as String?),
    'orderId': _normalize(payload['orderId'] as String?),
    'state': _sanitizeState(payload['state'], _stableRatingStates),
    'summary': _sanitizeSummary(payload['summary']),
  });
}

Map<String, Object?>? _sanitizeProjectCounterpartyRatingEntryPayload(
  Object? payload,
) {
  final map = _asMap(payload);
  if (map == null) {
    return null;
  }
  return _compactMap(<String, Object?>{
    'orderId': _normalize(map['orderId'] as String?),
    'projectId': _normalize(map['projectId'] as String?),
    'raterOrganizationId': _normalize(map['raterOrganizationId'] as String?),
    'rateeOrganizationId': _normalize(map['rateeOrganizationId'] as String?),
    'canRate': _sanitizeBool(map['canRate']),
    'reason': _normalize(map['reason'] as String?),
    'ratingState': _normalize(map['ratingState'] as String?),
  });
}

Map<String, Object?>? _sanitizeProjectCounterpartyRatingSubmitPayload(
  Object? payload,
) {
  final map = _asMap(payload);
  if (map == null) {
    return null;
  }
  return _compactMap(<String, Object?>{
    'ratingId': _normalize(map['ratingId'] as String?),
    'orderId': _normalize(map['orderId'] as String?),
    'projectId': _normalize(map['projectId'] as String?),
    'raterOrganizationId': _normalize(map['raterOrganizationId'] as String?),
    'rateeOrganizationId': _normalize(map['rateeOrganizationId'] as String?),
    'state': _normalize(map['state'] as String?),
    'ratingState': _normalize(map['ratingState'] as String?),
    'scoreValue': _sanitizeNumber(map['scoreValue']),
    'scoreLabel': _normalize(map['scoreLabel'] as String?),
    'submittedAt': _normalize(map['submittedAt'] as String?),
  });
}

Map<String, Object?>? _sanitizeProjectNameAccess(
  Object? payload, {
  required bool includeRequestId,
}) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'status': _sanitizeState(map['status'], _stableProjectNameAccessStates),
    'canRequest': _sanitizeBool(map['canRequest']),
    if (includeRequestId) 'requestId': _normalize(map['requestId'] as String?),
  });
}

List<Map<String, Object?>>? _sanitizeEntityList(
  Object? rawList,
  Map<String, Object?> Function(Map<String, Object?> payload) sanitizer,
) {
  if (rawList is! List) {
    return null;
  }

  return rawList
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map(sanitizer)
      .toList();
}

List<String>? _sanitizeStringList(Object? value) {
  if (value is! List) {
    return null;
  }

  final items = <String>[];
  for (final item in value) {
    if (item is! String) {
      return null;
    }
    final normalized = _normalize(item);
    if (normalized != null) {
      items.add(normalized);
    }
  }
  return items;
}

Map<String, Object?>? _sanitizeSummary(Object? value) {
  if (value is! Map) {
    return null;
  }
  return value.map((Object? key, Object? item) => MapEntry('$key', item));
}

num? _sanitizeNumber(Object? value) {
  return value is num ? value : null;
}

bool? _sanitizeBool(Object? value) {
  return value is bool ? value : null;
}

String? _sanitizeState(Object? value, Set<String> allowed) {
  if (value == null) {
    return null;
  }
  final state = '$value';
  return allowed.contains(state) ? state : null;
}

Map<String, Object?> _compactMap(Map<String, Object?> value) {
  return Map<String, Object?>.fromEntries(
    value.entries.where(
      (MapEntry<String, Object?> entry) => entry.value != null,
    ),
  );
}

String? _extractErrorCode(Object? payload) {
  if (payload is Map<String, Object?>) {
    final value = payload['code'] ?? payload['errorCode'];
    if (value == null) {
      return null;
    }
    final code = '$value';
    return _stableErrorCodes.contains(code) ? code : null;
  }

  return null;
}

String? _extractMessage(Object? payload) {
  if (payload is Map<String, Object?>) {
    final value = payload['message'];
    return value == null ? null : '$value';
  }

  return null;
}

bool _isEmptyPayload(Object? payload) {
  if (payload == null) {
    return true;
  }
  if (payload is List) {
    return payload.isEmpty;
  }
  if (payload is Map) {
    final items = payload['items'];
    if (items is List) {
      return items.isEmpty;
    }
    final attachments = payload['attachments'];
    if (attachments is List) {
      return attachments.isEmpty;
    }
    final resources = payload['resources'];
    if (resources is List) {
      return resources.isEmpty;
    }
    return payload.isEmpty;
  }
  if (payload is String) {
    return payload.trim().isEmpty;
  }
  return false;
}

String? _normalize(String? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
