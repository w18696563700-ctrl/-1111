part of '../exhibition_consumer_layer.dart';

const Set<String> _stableProjectStates = <String>{
  'published',
  'bidding_closed',
  'awarded',
  'converted_to_order',
};

const Set<String> _stableProjectViewerRelations = <String>{
  'owner',
  'non_owner',
};

const Set<String> _stableOrderStates = <String>{'active'};

const Set<String> _stableContractStates = <String>{
  'pending_confirm',
  'active',
  'amended',
};

const Set<String> _stableMilestoneStates = <String>{
  'pending_submission',
  'submitted',
};

const Set<String> _stableInspectionStates = <String>{
  'draft',
  'submitted',
  'rechecked',
};

const Set<String> _stableRatingStates = <String>{'draft', 'submitted'};

const Set<String> _stableDisputeStates = <String>{'opened', 'withdrawn'};

const Set<String> _stableWorkbenchRatingEntryStates = <String>{
  'controlled_unavailable',
  'extension_only',
};

const Set<String> _stableWorkbenchFrozenStates = <String>{'frozen'};

const Set<String> _stableErrorCodes = <String>{
  'AUTH_SESSION_INVALID',
  'PROJECT_CREATE_INVALID',
  'PROJECT_INVALID_STATE',
  'BID_SUBMIT_INVALID',
  'BID_DUPLICATE_SUBMISSION',
  'ORDER_INVALID_STATE',
  'CONTRACT_ENTRY_UNAVAILABLE',
  'CONTRACT_CONFIRM_INVALID',
  'CONTRACT_INVALID_STATE',
  'CONTRACT_AMEND_INVALID',
  'CONTRACT_AMEND_LIMIT_REACHED',
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
  'DISPUTE_OPEN_INVALID',
  'DISPUTE_WITHDRAW_INVALID',
  'DISPUTE_INVALID_STATE',
  'FILE_UPLOAD_CONFIRM_REQUIRED',
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

Map<String, Object?>? _sanitizeRatingPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return _sanitizeRatingMap(
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

Map<String, Object?>? _sanitizeProjectPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return _sanitizeProjectDetailMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeProjectCreatePayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'projectId': _normalize(map['projectId'] as String?),
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

Map<String, Object?>? _sanitizeOrderPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }
  return _sanitizeOrderMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeOrderCreatePayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'orderId': _normalize(map['orderId'] as String?),
    'milestones': _sanitizeFirstContinuationMilestone(map['milestones']),
  });
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
    'buildingType': _normalize(payload['buildingType'] as String?),
    'budgetAmount': _sanitizeNumber(payload['budgetAmount']),
    'areaSqm': _sanitizeNumber(payload['areaSqm']),
    'provinceCode': _normalize(payload['provinceCode'] as String?),
    'provinceName': _normalize(payload['provinceName'] as String?),
    'cityCode': _normalize(payload['cityCode'] as String?),
    'cityName': _normalize(payload['cityName'] as String?),
    'state': _sanitizeState(payload['state'], _stableProjectStates),
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
    'viewerProjectRelation': _sanitizeState(
      payload['viewerProjectRelation'],
      _stableProjectViewerRelations,
    ),
  });
}

Map<String, Object?> _sanitizeOrderMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'orderId': _normalize(payload['orderId'] as String?),
    'orderNo': _normalize(payload['orderNo'] as String?),
    'projectId': _normalize(payload['projectId'] as String?),
    'bidId': _normalize(payload['bidId'] as String?),
    'state': _sanitizeState(payload['state'], _stableOrderStates),
    'summary': _sanitizeSummary(payload['summary']),
    'milestones': _sanitizeEntityList(
      payload['milestones'],
      _sanitizeMilestoneMap,
    ),
  });
}

List<Map<String, Object?>>? _sanitizeFirstContinuationMilestone(
  Object? rawList,
) {
  if (rawList is! List || rawList.isEmpty) {
    return null;
  }

  final first = rawList.first;
  if (first is! Map) {
    return null;
  }

  final item = first.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  final sanitized = _compactMap(<String, Object?>{
    'milestoneId': _normalize(item['milestoneId'] as String?),
  });
  if (sanitized.isEmpty) {
    return null;
  }

  return <Map<String, Object?>>[sanitized];
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

Map<String, Object?> _sanitizeRatingMap(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'ratingId': _normalize(payload['ratingId'] as String?),
    'orderId': _normalize(payload['orderId'] as String?),
    'state': _sanitizeState(payload['state'], _stableRatingStates),
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
