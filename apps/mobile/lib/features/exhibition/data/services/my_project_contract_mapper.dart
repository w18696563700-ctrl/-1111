part of '../exhibition_consumer_layer.dart';

const Set<String> _myProjectFormalCompletionStatuses = <String>{
  'not_formally_completed',
  'formally_completed',
};

const Set<String> _myProjectEvaluationStatuses = <String>{
  'not_eligible',
  'eligible',
  'submitted',
};

Map<String, Object?>? _sanitizeMyProjectListPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return <String, Object?>{
    'ongoingProjects': _sanitizeMyProjectItemList(map['ongoingProjects']),
    'historicalProjects': _sanitizeMyProjectItemList(map['historicalProjects']),
  };
}

Map<String, Object?>? _sanitizeMyProjectDetailPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return <String, Object?>{
    'publicProject': _sanitizeMyProjectPublicProjectDetail(
      map['publicProject'],
    ),
    'privateProgress': _sanitizeMyProjectPrivateProgressObject(
      map['privateProgress'],
    ),
  };
}

List<Map<String, Object?>>? _sanitizeMyProjectItemList(Object? rawList) {
  if (rawList is! List) {
    return null;
  }

  return rawList
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map(_sanitizeMyProjectListItem)
      .toList();
}

Map<String, Object?> _sanitizeMyProjectListItem(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'projectCreatedAt': _sanitizeNullableText(payload['projectCreatedAt']),
    'publicProject': _sanitizeMyProjectPublicProject(payload['publicProject']),
    'privateSummary': _sanitizeMyProjectPrivateProgressObject(
      payload['privateSummary'],
    ),
  });
}

Map<String, Object?>? _sanitizeMyProjectPublicProject(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  return _sanitizeProjectMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeMyProjectPublicProjectDetail(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  return _sanitizeProjectDetailMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?>? _sanitizeMyProjectPrivateProgressObject(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  return _sanitizeMyProjectPrivateProgressMap(
    payload.map((Object? key, Object? value) => MapEntry('$key', value)),
  );
}

Map<String, Object?> _sanitizeMyProjectPrivateProgressMap(
  Map<String, Object?> payload,
) {
  return <String, Object?>{
    'hasAcceptedOrder': _sanitizeBool(payload['hasAcceptedOrder']),
    'orderStatus': _sanitizeNullableText(payload['orderStatus']),
    'contractStatus': _sanitizeNullableText(payload['contractStatus']),
    'fulfillmentStatus': _sanitizeNullableText(payload['fulfillmentStatus']),
    'acceptanceStatus': _sanitizeNullableText(payload['acceptanceStatus']),
    'afterSalesOrDisputeStatus': _sanitizeNullableText(
      payload['afterSalesOrDisputeStatus'],
    ),
    'formalCompletionStatus': _sanitizeState(
      payload['formalCompletionStatus'],
      _myProjectFormalCompletionStatuses,
    ),
    'evaluationStatus': _sanitizeState(
      payload['evaluationStatus'],
      _myProjectEvaluationStatuses,
    ),
  };
}

String? _sanitizeNullableText(Object? value) {
  return value is String ? _normalize(value) : null;
}
