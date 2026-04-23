part of '../exhibition_consumer_layer.dart';

const Set<String> _myBidOutcomeStates = <String>{
  'submitted',
  'published',
  'bidding_closed',
  'awarded',
  'converted_to_order',
  'active',
  'won',
  'lost',
};

Map<String, Object?>? _sanitizeMyBidListPayload(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final map = payload.map(
    (Object? key, Object? value) => MapEntry('$key', value),
  );
  return <String, Object?>{'items': _sanitizeMyBidItemList(map['items'])};
}

List<Map<String, Object?>>? _sanitizeMyBidItemList(Object? rawList) {
  if (rawList is! List) {
    return null;
  }

  return rawList
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map(_sanitizeMyBidItem)
      .toList(growable: false);
}

Map<String, Object?> _sanitizeMyBidItem(Map<String, Object?> payload) {
  return _compactMap(<String, Object?>{
    'bidId': _sanitizeNullableText(payload['bidId']),
    'projectId': _sanitizeNullableText(payload['projectId']),
    'projectNo': _sanitizeNullableText(payload['projectNo']),
    'projectTitle': _sanitizeNullableText(payload['projectTitle']),
    'quoteAmount': _sanitizeNumber(payload['quoteAmount']),
    'proposalSummaryPreview': _sanitizeNullableText(
      payload['proposalSummaryPreview'],
    ),
    'submittedAt': _sanitizeNullableText(payload['submittedAt']),
    'outcomeState': _sanitizeState(
      payload['outcomeState'],
      _myBidOutcomeStates,
    ),
    'canOpenBidThread': _sanitizeBool(payload['canOpenBidThread']),
    'canOpenBidResult': _sanitizeBool(payload['canOpenBidResult']),
  });
}
