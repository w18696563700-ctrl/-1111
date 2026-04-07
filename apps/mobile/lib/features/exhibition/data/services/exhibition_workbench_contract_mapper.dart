part of '../exhibition_consumer_layer.dart';

Map<String, Object?>? _sanitizeWorkbenchSummaryPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'project_chain': _sanitizeWorkbenchProjectChain(map['project_chain']),
    'order_chain': _sanitizeWorkbenchOrderChain(map['order_chain']),
    'fulfillment_chain': _sanitizeWorkbenchFulfillmentChain(
      map['fulfillment_chain'],
    ),
    'extension_boundary': _sanitizeWorkbenchExtensionBoundary(
      map['extension_boundary'],
    ),
  });
}

Map<String, Object?>? _sanitizeWorkbenchProjectChain(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'hasProjects': _sanitizeBool(map['hasProjects']),
    'recentProjectId': _normalize(map['recentProjectId'] as String?),
    'recentProjectTitle': _normalize(map['recentProjectTitle'] as String?),
    'canCreateProject': _sanitizeBool(map['canCreateProject']),
    'canOpenProjectPool': _sanitizeBool(map['canOpenProjectPool']),
  });
}

Map<String, Object?>? _sanitizeWorkbenchOrderChain(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'activeOrderId': _normalize(map['activeOrderId'] as String?),
    'activeOrderNo': _normalize(map['activeOrderNo'] as String?),
    'activeOrderState': _sanitizeState(
      map['activeOrderState'],
      _stableOrderStates,
    ),
    'canOpenOrderDetail': _sanitizeBool(map['canOpenOrderDetail']),
    'canOpenContractDetail': _sanitizeBool(map['canOpenContractDetail']),
    'canOpenDisputeOpen': _sanitizeBool(map['canOpenDisputeOpen']),
  });
}

Map<String, Object?>? _sanitizeWorkbenchFulfillmentChain(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'activeMilestoneId': _normalize(map['activeMilestoneId'] as String?),
    'activeMilestoneTitle': _normalize(map['activeMilestoneTitle'] as String?),
    'inspectionState': _sanitizeState(
      map['inspectionState'],
      _stableInspectionStates,
    ),
    'canOpenMilestoneList': _sanitizeBool(map['canOpenMilestoneList']),
    'canOpenMilestoneSubmit': _sanitizeBool(map['canOpenMilestoneSubmit']),
    'canOpenInspectionDetail': _sanitizeBool(map['canOpenInspectionDetail']),
    'canOpenInspectionSubmit': _sanitizeBool(map['canOpenInspectionSubmit']),
  });
}

Map<String, Object?>? _sanitizeWorkbenchExtensionBoundary(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return _compactMap(<String, Object?>{
    'canOpenContractDetail': _sanitizeBool(map['canOpenContractDetail']),
    'ratingEntryState': _sanitizeState(
      map['ratingEntryState'],
      _stableWorkbenchRatingEntryStates,
    ),
    'canOpenDisputeOpen': _sanitizeBool(map['canOpenDisputeOpen']),
    'disputeWithdrawState': _sanitizeState(
      map['disputeWithdrawState'],
      _stableWorkbenchFrozenStates,
    ),
  });
}
