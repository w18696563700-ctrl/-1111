import 'package:mobile/features/messages/data/counterpart_conversation_models.dart';
import 'package:mobile/features/messages/data/messages_interaction_models.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';

CounterpartConversationDetailView parseCounterpartConversationDetail(
  Object? payload,
) {
  final map = _requiredMap(payload, 'counterpart conversation detail');
  final rawGroups = _requiredList(map, 'projectGroups');
  return CounterpartConversationDetailView(
    conversationId: _requiredString(map, 'conversationId'),
    counterpart: _parseCounterpart(map['counterpart']),
    summary: _parseSummary(map['summary']),
    focusProjectId: _requiredString(map, 'focusProjectId'),
    latestActivityAt: _requiredString(map, 'latestActivityAt'),
    projectGroups: rawGroups
        .map<CounterpartConversationProjectGroupView>(_parseProjectGroup)
        .toList(growable: false),
  );
}

ProjectCommunicationThreadView parseProjectCommunicationThread(
  Object? payload,
) {
  final map = _requiredMap(payload, 'project communication thread');
  return ProjectCommunicationThreadView(
    threadId: _requiredString(map, 'threadId'),
    projectId: _requiredString(map, 'projectId'),
    ownerOrganizationId: _requiredString(map, 'ownerOrganizationId'),
    counterpartOrganizationId: _requiredString(
      map,
      'counterpartOrganizationId',
    ),
    threadState: _requiredString(map, 'threadState'),
    lastMessageId: _nullableString(map['lastMessageId']),
    lastMessageAt: _nullableString(map['lastMessageAt']),
    createdAt: _requiredString(map, 'createdAt'),
    updatedAt: _requiredString(map, 'updatedAt'),
  );
}

ProjectCommunicationMessageListView parseProjectCommunicationMessages(
  Object? payload,
) {
  final map = _requiredMap(payload, 'project communication message list');
  final rawItems = _requiredList(map, 'items');
  return ProjectCommunicationMessageListView(
    items: rawItems
        .map<ProjectCommunicationMessageView>(parseProjectCommunicationMessage)
        .toList(growable: false),
    nextCursor: _nullableString(map['nextCursor']),
  );
}

ProjectCommunicationMessageView parseProjectCommunicationMessage(
  Object? payload,
) {
  final map = _requiredMap(payload, 'project communication message');
  return ProjectCommunicationMessageView(
    messageId: _requiredString(map, 'messageId'),
    threadId: _requiredString(map, 'threadId'),
    projectId: _requiredString(map, 'projectId'),
    senderUserId: _requiredString(map, 'senderUserId'),
    senderActorId: _nullableString(map['senderActorId']),
    senderOrganizationId: _requiredString(map, 'senderOrganizationId'),
    messageKind: _requiredString(map, 'messageKind'),
    body: _requiredString(map, 'body'),
    clientMessageId: _nullableString(map['clientMessageId']),
    messageState: _requiredString(map, 'messageState'),
    createdAt: _requiredString(map, 'createdAt'),
  );
}

ProjectCommunicationReadCursorView parseProjectCommunicationReadCursor(
  Object? payload,
) {
  final map = _requiredMap(payload, 'project communication read cursor');
  return ProjectCommunicationReadCursorView(
    threadId: _requiredString(map, 'threadId'),
    projectId: _requiredString(map, 'projectId'),
    organizationId: _requiredString(map, 'organizationId'),
    lastReadMessageId: _nullableString(map['lastReadMessageId']),
    lastReadAt: _requiredString(map, 'lastReadAt'),
    updatedAt: _requiredString(map, 'updatedAt'),
  );
}

ProjectAlbumPhotoListView parseProjectAlbumPhotoList(Object? payload) {
  final map = _requiredMap(payload, 'project album photo list');
  final rawItems = _requiredList(map, 'items');
  return ProjectAlbumPhotoListView(
    projectId: _requiredString(map, 'projectId'),
    limit: _requiredInt(map, 'limit'),
    photoCount: _requiredInt(map, 'photoCount'),
    items: rawItems
        .map<ProjectAlbumPhotoView>(parseProjectAlbumPhoto)
        .toList(growable: false),
  );
}

ProjectAlbumPhotoView parseProjectAlbumPhoto(Object? payload) {
  final map = _requiredMap(payload, 'project album photo');
  return ProjectAlbumPhotoView(
    photoId: _requiredString(map, 'photoId'),
    projectId: _requiredString(map, 'projectId'),
    fileAssetId: _requiredString(map, 'fileAssetId'),
    category: _enumValue(_requiredString(map, 'category'), const <String>{
      'contract',
      'progress',
      'final',
      'defect',
    }, 'category'),
    caption: _nullableString(map['caption']),
    mimeType: _requiredString(map, 'mimeType'),
    sortOrder: _requiredInt(map, 'sortOrder'),
    photoState: _requiredString(map, 'photoState'),
    uploadedByUserId: _requiredString(map, 'uploadedByUserId'),
    uploadedByActorId: _nullableString(map['uploadedByActorId']),
    uploadedByOrganizationId: _requiredString(map, 'uploadedByOrganizationId'),
    createdAt: _requiredString(map, 'createdAt'),
    removedAt: _nullableString(map['removedAt']),
  );
}

ProjectCounterpartyRatingSubmitAcceptedView
parseProjectCounterpartyRatingSubmitAccepted(Object? payload) {
  final map = _requiredMap(payload, 'project counterparty rating submit');
  return ProjectCounterpartyRatingSubmitAcceptedView(
    ratingId: _requiredString(map, 'ratingId'),
    orderId: _requiredString(map, 'orderId'),
    projectId: _requiredString(map, 'projectId'),
    raterOrganizationId: _requiredString(map, 'raterOrganizationId'),
    rateeOrganizationId: _requiredString(map, 'rateeOrganizationId'),
    state: _requiredString(map, 'state'),
    ratingState: _requiredString(map, 'ratingState'),
    scoreValue: _requiredInt(map, 'scoreValue'),
    scoreLabel: _requiredString(map, 'scoreLabel'),
    submittedAt: _requiredString(map, 'submittedAt'),
  );
}

CounterpartConversationProjectGroupView _parseProjectGroup(Object? payload) {
  final map = _requiredMap(payload, 'counterpart conversation project group');
  final rawCards = _requiredList(map, 'cards');
  return CounterpartConversationProjectGroupView(
    projectId: _requiredString(map, 'projectId'),
    projectDisplayTitle: _requiredString(map, 'projectDisplayTitle'),
    titleVisibility: _enumValue(
      _requiredString(map, 'titleVisibility'),
      const <String>{'masked', 'visible'},
      'titleVisibility',
    ),
    projectState: _nullableString(map['projectState']),
    latestActivityAt: _requiredString(map, 'latestActivityAt'),
    orderSummary: _parseOrderSummary(
      map['orderSummary'] ??
          map['order'] ??
          (map['orderId'] == null ? null : map),
    ),
    ratingEntry: _parseRatingEntry(map['ratingEntry']),
    cards: rawCards
        .map<CounterpartConversationBusinessCardView>(_parseBusinessCard)
        .toList(growable: false),
  );
}

CounterpartConversationOrderSummaryView? _parseOrderSummary(Object? payload) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(payload, 'counterpart conversation orderSummary');
  return CounterpartConversationOrderSummaryView(
    orderId: _requiredString(map, 'orderId'),
    projectId: _nullableString(map['projectId']),
    buyerOrganizationId: _nullableString(map['buyerOrganizationId']),
    sellerOrganizationId:
        _nullableString(map['sellerOrganizationId']) ??
        _nullableString(map['supplierOrganizationId']),
    state: _nullableString(map['state']),
    completionRequestState: _nullableString(map['completionRequestState']),
    exitGovernance: _parseExitGovernance(map['exitGovernance']),
  );
}

CounterpartConversationExitGovernanceView? _parseExitGovernance(
  Object? payload,
) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(payload, 'counterpart conversation exitGovernance');
  return CounterpartConversationExitGovernanceView(
    exitCaseId: _nullableString(map['exitCaseId']),
    exitType: _nullableString(map['exitType']),
    caseStatus: _nullableString(map['caseStatus']),
    breachParty: _nullableString(map['breachParty']),
    counterpartyAction:
        _nullableString(map['counterpartyAction']) ??
        _nullableString(map['actionHint']),
    updatedAt: _nullableString(map['updatedAt']),
  );
}

CounterpartConversationRatingEntryView? _parseRatingEntry(Object? payload) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(payload, 'counterpart conversation ratingEntry');
  return CounterpartConversationRatingEntryView(
    orderId: _requiredString(map, 'orderId'),
    projectId: _requiredString(map, 'projectId'),
    rateeOrganizationId: _requiredString(map, 'rateeOrganizationId'),
    canRate: _requiredBool(map, 'canRate'),
    reason: _nullableString(map['reason']),
    ratingState: _nullableString(map['ratingState']),
  );
}

CounterpartConversationBusinessCardView _parseBusinessCard(Object? payload) {
  final map = _requiredMap(payload, 'counterpart conversation business card');
  final cardType = _enumValue(_requiredString(map, 'cardType'), const <String>{
    'project_name_access_request',
    'bid_thread',
    'project_clarification',
    'project_order',
    'system_notice',
  }, 'cardType');
  final truthAnchor = _parseTruthAnchor(map['truthAnchor']);
  final detailRouteTarget = _parseRouteTarget(map['detailRouteTarget']);
  _validateBusinessCardTruth(
    cardType: cardType,
    truthAnchor: truthAnchor,
    detailRouteTarget: detailRouteTarget,
  );
  return CounterpartConversationBusinessCardView(
    cardId: _requiredString(map, 'cardId'),
    cardType: cardType,
    title: _requiredString(map, 'title'),
    summary: _requiredString(map, 'summary'),
    status: _nullableString(map['status']),
    updatedAt: _requiredString(map, 'updatedAt'),
    truthAnchor: truthAnchor,
    detailRouteTarget: detailRouteTarget,
    decisionAvailability: _parseDecisionAvailability(
      map['decisionAvailability'],
    ),
  );
}

void _validateBusinessCardTruth({
  required String cardType,
  required CounterpartConversationTruthAnchorView truthAnchor,
  required MessageInteractionRouteTarget? detailRouteTarget,
}) {
  if (cardType != 'project_order' && truthAnchor.truthType != 'project_order') {
    return;
  }
  if (cardType != 'project_order' || truthAnchor.truthType != 'project_order') {
    throw const FormatException(
      'project_order cardType and truthType must match',
    );
  }
  final orderId = truthAnchor.orderId;
  if (orderId == null ||
      detailRouteTarget == null ||
      detailRouteTarget.actionKey != 'order_detail.open' ||
      detailRouteTarget.params['projectId'] != truthAnchor.projectId ||
      detailRouteTarget.params['orderId'] != orderId) {
    throw const FormatException(
      'project_order card must carry matching projectId and orderId',
    );
  }
}

MessageInteractionCounterpartView _parseCounterpart(Object? payload) {
  final map = _requiredMap(payload, 'counterpart conversation counterpart');
  return MessageInteractionCounterpartView(
    organizationId: _requiredString(map, 'organizationId'),
    displayName: _requiredString(map, 'displayName'),
    avatarUrl: _nullableString(map['avatarUrl']),
    role: _requiredString(map, 'role'),
  );
}

MessageInteractionSummaryView _parseSummary(Object? payload) {
  final map = _requiredMap(payload, 'counterpart conversation summary');
  return MessageInteractionSummaryView(
    focusProjectId: _requiredString(map, 'focusProjectId'),
    title: _requiredString(map, 'title'),
    text: _requiredString(map, 'text'),
    projectCount: _requiredInt(map, 'projectCount'),
    latestCardType: _requiredString(map, 'latestCardType'),
  );
}

CounterpartConversationTruthAnchorView _parseTruthAnchor(Object? payload) {
  final map = _requiredMap(payload, 'counterpart conversation truthAnchor');
  return CounterpartConversationTruthAnchorView(
    truthType: _enumValue(_requiredString(map, 'truthType'), const <String>{
      'project_name_access_request',
      'bid_thread',
      'project_clarification',
      'project_order',
      'project_notice_event',
    }, 'truthType'),
    projectId: _requiredString(map, 'projectId'),
    requestId: _nullableString(map['requestId']),
    orderId: _nullableString(map['orderId']),
    bidId: _nullableString(map['bidId']),
    threadId: _nullableString(map['threadId']),
    clarificationId: _nullableString(map['clarificationId']),
    noticeId: _nullableString(map['noticeId']),
  );
}

MessageInteractionRouteTarget? _parseRouteTarget(Object? payload) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(
    payload,
    'counterpart conversation detailRouteTarget',
  );
  final actionKey = _requiredString(map, 'actionKey');
  final objectType = _requiredString(map, 'objectType');
  final canonicalPath = _requiredString(map, 'canonicalPath');
  final params = _stringMap(map['params']);
  final definition = messagesRegisteredEntryByActionKey[actionKey];
  if (definition == null) {
    throw FormatException('unsupported detail actionKey "$actionKey"');
  }
  if (definition.objectType != objectType) {
    throw const FormatException('detail routeTarget objectType mismatch');
  }
  if (definition.canonicalPath != canonicalPath) {
    throw const FormatException('detail routeTarget canonicalPath mismatch');
  }
  final routeLocation = definition.buildRouteLocation(params);
  if (routeLocation == null || routeLocation.startsWith('routeTarget.')) {
    throw FormatException(routeLocation ?? 'detail routeTarget is invalid');
  }
  return MessageInteractionRouteTarget(
    objectType: objectType,
    actionKey: actionKey,
    canonicalPath: canonicalPath,
    params: params,
    routeLocation: routeLocation,
  );
}

CounterpartConversationDecisionAvailabilityView? _parseDecisionAvailability(
  Object? payload,
) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(
    payload,
    'counterpart conversation decisionAvailability',
  );
  return CounterpartConversationDecisionAvailabilityView(
    canApprove: _requiredBool(map, 'canApprove'),
    canReject: _requiredBool(map, 'canReject'),
  );
}

Map<String, Object?> _requiredMap(Object? payload, String context) {
  if (payload is! Map) {
    throw FormatException('$context response must be an object');
  }
  return payload.map((Object? key, Object? value) => MapEntry('$key', value));
}

List<Object?> _requiredList(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is! List) {
    throw FormatException('field "$field" must be an array');
  }
  return value.cast<Object?>();
}

String _requiredString(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is! String) {
    throw FormatException('field "$field" must be a string');
  }
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw FormatException('field "$field" must be a non-empty string');
  }
  return normalized;
}

int _requiredInt(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is int) {
    return value;
  }
  throw FormatException('field "$field" must be an int');
}

bool _requiredBool(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is bool) {
    return value;
  }
  throw FormatException('field "$field" must be a bool');
}

String _enumValue(String value, Set<String> allowed, String context) {
  if (!allowed.contains(value)) {
    throw FormatException('$context returned unsupported value "$value"');
  }
  return value;
}

Map<String, String> _stringMap(Object? payload) {
  if (payload is! Map) {
    throw const FormatException('route params must be an object');
  }
  final result = <String, String>{};
  for (final MapEntry<Object?, Object?> entry in payload.entries) {
    final key = '${entry.key}'.trim();
    final value = entry.value;
    if (key.isEmpty || value is! String || value.trim().isEmpty) {
      throw const FormatException(
        'route params must contain non-empty strings',
      );
    }
    result[key] = value.trim();
  }
  return result;
}

String? _nullableString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw const FormatException('nullable field must be a string');
  }
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
