final class TradingImCanonicalPaths {
  const TradingImCanonicalPaths._();

  static const String projectClarificationList =
      '/api/app/project/clarification/list';
  static const String projectClarificationCreate =
      '/api/app/project/clarification/create';
  static const String bidThreadDetail = '/api/app/bid/thread/detail';
  static const String bidThreadMessageSend = '/api/app/bid/thread/message/send';
  static const String bidThreadConfirmationCreate =
      '/api/app/bid/thread/confirmation/create';
  static const String bidSubmissionSnapshot =
      '/api/app/bid/submission/snapshot';
  static const String participantCard =
      '/api/app/exhibition/trading/participant-card';
}

class TradingImAvailabilityView {
  const TradingImAvailabilityView({
    required this.canSendMessage,
    required this.canCreateConfirmation,
    required this.reason,
  });

  final bool canSendMessage;
  final bool canCreateConfirmation;
  final String? reason;
}

class ProjectClarificationListView {
  const ProjectClarificationListView({
    required this.projectId,
    required this.items,
    required this.canCreate,
    required this.reason,
  });

  final String projectId;
  final List<ProjectClarificationItemView> items;
  final bool canCreate;
  final String? reason;
}

class ProjectClarificationItemView {
  const ProjectClarificationItemView({
    required this.clarificationId,
    required this.projectId,
    required this.authorRole,
    required this.body,
    required this.attachmentFileAssetIds,
    required this.state,
    required this.createdAt,
  });

  final String clarificationId;
  final String projectId;
  final String authorRole;
  final String body;
  final List<String> attachmentFileAssetIds;
  final String state;
  final String createdAt;
}

class BidThreadDetailView {
  const BidThreadDetailView({
    required this.threadId,
    required this.projectId,
    required this.bidId,
    required this.participants,
    required this.viewerParticipantRole,
    required this.state,
    required this.availability,
    required this.messages,
    required this.confirmationCards,
  });

  final String threadId;
  final String projectId;
  final String bidId;
  final List<BidThreadParticipantView> participants;
  final String? viewerParticipantRole;
  final String state;
  final TradingImAvailabilityView availability;
  final List<BidThreadMessageView> messages;
  final List<ConfirmationCardView> confirmationCards;
}

class BidThreadParticipantView {
  const BidThreadParticipantView({
    required this.participantRole,
    required this.organizationId,
  });

  final String participantRole;
  final String organizationId;
}

class BidThreadMessageView {
  const BidThreadMessageView({
    required this.messageId,
    required this.threadId,
    required this.projectId,
    required this.bidId,
    required this.senderRole,
    required this.messageKind,
    required this.body,
    required this.attachmentFileAssetIds,
    required this.createdAt,
    this.systemSeedType,
    this.systemSeedAction,
  });

  final String messageId;
  final String threadId;
  final String projectId;
  final String bidId;
  final String senderRole;
  final String messageKind;
  final String body;
  final List<String> attachmentFileAssetIds;
  final String createdAt;
  final String? systemSeedType;
  final BidThreadSystemSeedActionView? systemSeedAction;
}

class BidThreadSystemSeedActionView {
  const BidThreadSystemSeedActionView({
    required this.objectType,
    required this.actionKey,
    required this.canonicalPath,
    required this.params,
  });

  final String objectType;
  final String actionKey;
  final String? canonicalPath;
  final Map<String, String> params;
}

class ConfirmationCardView {
  const ConfirmationCardView({
    required this.confirmationId,
    required this.threadId,
    required this.projectId,
    required this.bidId,
    required this.confirmationType,
    required this.summary,
    required this.sourceMessageId,
    required this.createdAt,
  });

  final String confirmationId;
  final String threadId;
  final String projectId;
  final String bidId;
  final String confirmationType;
  final String summary;
  final String sourceMessageId;
  final String createdAt;
}

ProjectClarificationListView parseProjectClarificationList(Object? payload) {
  final body = _readMap(payload, 'project clarification list');
  final projectId = _requiredString(body, 'projectId');
  final rawItems = _requiredList(body, 'items');
  final availability = _optionalMap(body['availability']);
  return ProjectClarificationListView(
    projectId: projectId,
    items: rawItems.map(parseProjectClarificationItem).toList(growable: false),
    canCreate: _optionalBool(availability?['canCreate']) ?? false,
    reason: _optionalString(availability?['reason']),
  );
}

ProjectClarificationItemView parseProjectClarificationItem(Object? payload) {
  final body = _readMap(payload, 'project clarification item');
  final state = _enumValue(_requiredString(body, 'state'), const <String>{
    'active',
    'hidden',
    'archived',
  }, 'project clarification state');
  return ProjectClarificationItemView(
    clarificationId: _requiredString(body, 'clarificationId'),
    projectId: _requiredString(body, 'projectId'),
    authorRole: _participantRole(_requiredString(body, 'authorRole')),
    body: _requiredString(body, 'body'),
    attachmentFileAssetIds: _stringList(body['attachmentFileAssetIds']),
    state: state,
    createdAt: _requiredString(body, 'createdAt'),
  );
}

BidThreadDetailView parseBidThreadDetail(Object? payload) {
  final body = _readMap(payload, 'bid thread detail');
  final rawParticipants = _requiredList(body, 'participants');
  final rawMessages = _requiredList(body, 'messages');
  final rawCards = _requiredList(body, 'confirmationCards');
  return BidThreadDetailView(
    threadId: _requiredString(body, 'threadId'),
    projectId: _requiredString(body, 'projectId'),
    bidId: _requiredString(body, 'bidId'),
    participants: rawParticipants
        .map(_parseParticipant)
        .toList(growable: false),
    viewerParticipantRole: _optionalParticipantRole(
      _optionalString(body['viewerParticipantRole']),
    ),
    state: _enumValue(_requiredString(body, 'state'), const <String>{
      'open',
      'restricted',
      'archived',
    }, 'bid thread state'),
    availability: _parseAvailability(body['availability']),
    messages: rawMessages.map(parseBidThreadMessage).toList(growable: false),
    confirmationCards: rawCards
        .map(parseConfirmationCard)
        .toList(growable: false),
  );
}

BidThreadMessageView parseBidThreadMessage(Object? payload) {
  final body = _readMap(payload, 'bid thread message');
  final senderRole = _messageSenderRole(_requiredString(body, 'senderRole'));
  final messageKind = _messageKind(
    _optionalString(body['messageKind']) ??
        (senderRole == 'system_seed' ? 'system_seed' : 'actor_message'),
  );
  return BidThreadMessageView(
    messageId: _requiredString(body, 'messageId'),
    threadId: _requiredString(body, 'threadId'),
    projectId: _requiredString(body, 'projectId'),
    bidId: _requiredString(body, 'bidId'),
    senderRole: senderRole,
    messageKind: messageKind,
    body: _requiredString(body, 'body'),
    attachmentFileAssetIds: _stringList(body['attachmentFileAssetIds']),
    createdAt: _requiredString(body, 'createdAt'),
    systemSeedType: messageKind == 'system_seed'
        ? _enumValue(_requiredString(body, 'systemSeedType'), const <String>{
            'bid_submitted',
          }, 'system seed type')
        : null,
    systemSeedAction: messageKind == 'system_seed'
        ? _parseSystemSeedAction(body['systemSeedAction'])
        : null,
  );
}

ConfirmationCardView parseConfirmationCard(Object? payload) {
  final body = _readMap(payload, 'confirmation card');
  return ConfirmationCardView(
    confirmationId: _requiredString(body, 'confirmationId'),
    threadId: _requiredString(body, 'threadId'),
    projectId: _requiredString(body, 'projectId'),
    bidId: _requiredString(body, 'bidId'),
    confirmationType: _enumValue(
      _requiredString(body, 'confirmationType'),
      const <String>{'quote', 'craft_material', 'schedule'},
      'confirmation card type',
    ),
    summary: _requiredString(body, 'summary'),
    sourceMessageId: _requiredString(body, 'sourceMessageId'),
    createdAt: _requiredString(body, 'createdAt'),
  );
}

TradingImAvailabilityView _parseAvailability(Object? payload) {
  final body = _readMap(payload, 'bid thread availability');
  return TradingImAvailabilityView(
    canSendMessage: _requiredBool(body, 'canSendMessage'),
    canCreateConfirmation: _requiredBool(body, 'canCreateConfirmation'),
    reason: _optionalString(body['reason']),
  );
}

BidThreadParticipantView _parseParticipant(Object? payload) {
  final body = _readMap(payload, 'bid thread participant');
  return BidThreadParticipantView(
    participantRole: _participantRole(_requiredString(body, 'participantRole')),
    organizationId: _requiredString(body, 'organizationId'),
  );
}

String _participantRole(String value) => _enumValue(value, const <String>{
  'project_owner',
  'bidder',
}, 'trading IM participant role');

String _messageSenderRole(String value) => _enumValue(value, const <String>{
  'project_owner',
  'bidder',
  'system_seed',
}, 'trading IM message sender role');

String _messageKind(String value) => _enumValue(value, const <String>{
  'actor_message',
  'system_seed',
}, 'trading IM message kind');

String? _optionalParticipantRole(String? value) {
  if (value == null) {
    return null;
  }
  return _enumValue(value, const <String>{
    'project_owner',
    'bidder',
    'viewer',
  }, 'trading IM viewer role');
}

Map<String, Object?> _readMap(Object? payload, String context) {
  if (payload is! Map) {
    throw FormatException('$context response must be an object');
  }
  return payload.map((Object? key, Object? value) => MapEntry('$key', value));
}

Map<String, Object?>? _optionalMap(Object? payload) {
  if (payload == null) {
    return null;
  }
  if (payload is! Map) {
    throw const FormatException('optional object field has invalid shape');
  }
  return payload.map((Object? key, Object? value) => MapEntry('$key', value));
}

List<Object?> _requiredList(Map<String, Object?> body, String field) {
  final value = body[field];
  if (value is! List) {
    throw FormatException('field "$field" must be an array');
  }
  return value.cast<Object?>();
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    throw const FormatException('attachmentFileAssetIds must be an array');
  }
  return value
      .map((Object? item) {
        final text = '$item'.trim();
        if (text.isEmpty) {
          throw const FormatException(
            'attachmentFileAssetIds must be non-empty',
          );
        }
        return text;
      })
      .toList(growable: false);
}

String _requiredString(Map<String, Object?> body, String field) {
  final value = '${body[field] ?? ''}'.trim();
  if (value.isEmpty) {
    throw FormatException('field "$field" must be a non-empty string');
  }
  return value;
}

String? _optionalString(Object? value) {
  final text = '${value ?? ''}'.trim();
  return text.isEmpty ? null : text;
}

bool _requiredBool(Map<String, Object?> body, String field) {
  final value = body[field];
  if (value is! bool) {
    throw FormatException('field "$field" must be boolean');
  }
  return value;
}

num _requiredNumber(Map<String, Object?> body, String field) {
  final value = body[field];
  if (value is! num) {
    throw FormatException('field "$field" must be numeric');
  }
  return value;
}

bool? _optionalBool(Object? value) => value is bool ? value : null;

BidThreadSystemSeedActionView? _parseSystemSeedAction(Object? payload) {
  final body = _optionalMap(payload);
  if (body == null) {
    return null;
  }
  final actionKey = _enumValue(
    _requiredString(body, 'actionKey'),
    const <String>{'bid_submission_snapshot.open'},
    'system seed action key',
  );
  return BidThreadSystemSeedActionView(
    objectType: _enumValue(_requiredString(body, 'objectType'), const <String>{
      'bid_submission_snapshot',
    }, 'system seed action object type'),
    actionKey: actionKey,
    canonicalPath: _optionalString(body['canonicalPath']),
    params: _stringMap(body['params']),
  );
}

Map<String, String> _stringMap(Object? payload) {
  final body = _readMap(payload, 'string map');
  return body.map((String key, Object? value) {
    final text = '${value ?? ''}'.trim();
    if (text.isEmpty) {
      throw FormatException('field "$key" must be a non-empty string');
    }
    return MapEntry<String, String>(key, text);
  });
}

String _enumValue(String value, Set<String> allowed, String context) {
  if (!allowed.contains(value)) {
    throw FormatException('$context "$value" is outside frozen contract');
  }
  return value;
}
