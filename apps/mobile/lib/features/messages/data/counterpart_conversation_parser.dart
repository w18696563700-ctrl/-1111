import 'package:mobile/features/messages/data/counterpart_conversation_models.dart';
import 'package:mobile/features/messages/data/messages_interaction_models.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';

const String _missingProjectContextMessage = '无法进入项目沟通，缺少项目上下文，请返回项目列表重新进入。';

CounterpartConversationDetailView parseCounterpartConversationDetail(
  Object? payload,
) {
  final map = _requiredMap(payload, 'counterpart conversation detail');
  final rawGroups = _requiredList(map, 'projectGroups');
  final conversationUnreadCount = _optionalNonNegativeInt(
    map['conversationUnreadCount'],
    'conversationUnreadCount',
  );
  return CounterpartConversationDetailView(
    conversationId: _requiredString(map, 'conversationId'),
    counterpart: _parseCounterpart(map['counterpart']),
    summary: _parseSummary(map['summary']),
    focusProjectId: _requiredString(map, 'focusProjectId'),
    latestActivityAt: _requiredString(map, 'latestActivityAt'),
    conversationUnreadCount: conversationUnreadCount,
    hasUnread:
        _optionalBool(map['hasUnread'], 'hasUnread') ??
        conversationUnreadCount > 0,
    latestUnreadMessageAt: _nullableString(map['latestUnreadMessageAt']),
    myPublishedUnreadCount: _optionalNonNegativeInt(
      map['myPublishedUnreadCount'],
      'myPublishedUnreadCount',
    ),
    myBidUnreadCount: _optionalNonNegativeInt(
      map['myBidUnreadCount'],
      'myBidUnreadCount',
    ),
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
    chatAvailability: _parseOptionalChatAvailability(map['chatAvailability']),
    threadState: _requiredString(map, 'threadState'),
    lastMessageId: _nullableString(map['lastMessageId']),
    lastMessageAt: _nullableString(map['lastMessageAt']),
    createdAt: _requiredString(map, 'createdAt'),
    updatedAt: _requiredString(map, 'updatedAt'),
  );
}

ProjectCommunicationBusinessTodoSummaryView _parseBusinessTodoSummary(
  Object? payload,
) {
  final map = _requiredMap(payload, 'project communication business todo');
  return ProjectCommunicationBusinessTodoSummaryView(
    bidParticipationReviewPendingCount: _nonNegativeInt(
      map['bidParticipationReviewPendingCount'],
      'bidParticipationReviewPendingCount',
    ),
    publisherMaterialReviewPendingCount: _nonNegativeInt(
      map['publisherMaterialReviewPendingCount'],
      'publisherMaterialReviewPendingCount',
    ),
    bidMaterialReviewPendingCount: _nonNegativeInt(
      map['bidMaterialReviewPendingCount'],
      'bidMaterialReviewPendingCount',
    ),
    dealConfirmationPendingCount: _nonNegativeInt(
      map['dealConfirmationPendingCount'],
      'dealConfirmationPendingCount',
    ),
    totalPendingCount: _nonNegativeInt(
      map['totalPendingCount'],
      'totalPendingCount',
    ),
  );
}

ProjectCommunicationBusinessTodoSummaryView _parseOptionalBusinessTodoSummary(
  Object? payload,
) {
  if (payload == null) {
    return const ProjectCommunicationBusinessTodoSummaryView(
      bidParticipationReviewPendingCount: 0,
      publisherMaterialReviewPendingCount: 0,
      bidMaterialReviewPendingCount: 0,
      dealConfirmationPendingCount: 0,
      totalPendingCount: 0,
    );
  }
  return _parseBusinessTodoSummary(payload);
}

ProjectCommunicationChatAvailabilityView _parseChatAvailability(
  Object? payload,
) {
  final map = _requiredMap(payload, 'project communication chat availability');
  final rawLockReasonCode = _nullableString(map['lockReasonCode']);
  return ProjectCommunicationChatAvailabilityView(
    canSendMessage: _requiredBool(map, 'canSendMessage'),
    lockReasonCode: rawLockReasonCode == null
        ? null
        : _enumValue(rawLockReasonCode, const <String>{
            'bid_participation_review_pending',
            'publisher_material_confirmation_pending',
            'bid_submission_pending',
            'bid_material_confirmation_pending',
            'service_fee_authorization_pending',
            'deal_confirmation_pending',
          }, 'lockReasonCode'),
    lockReasonText: _nullableString(map['lockReasonText']),
    requiredNextAction:
        _enumValue(_requiredString(map, 'requiredNextAction'), const <String>{
          'review_bid_participation',
          'confirm_publisher_materials',
          'submit_bid_materials',
          'confirm_bid_materials',
          'complete_service_fee_authorization',
          'open_deal_confirmation',
          'none',
        }, 'requiredNextAction'),
  );
}

ProjectCommunicationChatAvailabilityView _parseOptionalChatAvailability(
  Object? payload,
) {
  if (payload == null) {
    return const ProjectCommunicationChatAvailabilityView(
      canSendMessage: false,
      lockReasonCode: null,
      lockReasonText: '当前项目沟通状态正在同步，请稍后重试。',
      requiredNextAction: 'none',
    );
  }
  return _parseChatAvailability(payload);
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
    body: _requiredBodyString(map, 'body'),
    attachment: _parseProjectCommunicationAttachment(map['payload']),
    confirmation: _parseProjectCommunicationConfirmation(map['payload']),
    clientMessageId: _nullableString(map['clientMessageId']),
    messageState: _requiredString(map, 'messageState'),
    deliveryState: _enumValue(
      _nullableString(map['deliveryState']) ?? 'persisted',
      const <String>{'persisted'},
      'deliveryState',
    ),
    readState: _enumValue(
      _nullableString(map['readState']) ?? 'not_applicable',
      const <String>{
        'unread_by_counterpart',
        'read_by_counterpart',
        'not_applicable',
      },
      'readState',
    ),
    readByCounterpartAt: _nullableString(map['readByCounterpartAt']),
    createdAt: _requiredString(map, 'createdAt'),
  );
}

ProjectCommunicationAttachmentView? _parseProjectCommunicationAttachment(
  Object? payload,
) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(payload, 'project communication message payload');
  final attachment = map['attachment'];
  if (attachment == null) {
    return null;
  }
  final attachmentMap = _requiredMap(
    attachment,
    'project communication attachment payload',
  );
  return ProjectCommunicationAttachmentView(
    fileAssetId: _requiredString(attachmentMap, 'fileAssetId'),
    fileName: _requiredString(attachmentMap, 'fileName'),
    mimeType: _requiredString(attachmentMap, 'mimeType'),
    size: _requiredInt(attachmentMap, 'size'),
    category: _enumValue(_requiredString(attachmentMap, 'category'), const {
      'image',
      'file',
    }, 'category'),
  );
}

ProjectCommunicationConfirmationView? _parseProjectCommunicationConfirmation(
  Object? payload,
) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(payload, 'project communication message payload');
  final confirmation = map['confirmation'];
  if (confirmation == null) {
    return null;
  }
  final confirmationMap = _requiredMap(
    confirmation,
    'project communication confirmation payload',
  );
  return ProjectCommunicationConfirmationView(
    confirmationType: _enumValue(
      _requiredString(confirmationMap, 'confirmationType'),
      const {'quote', 'material_process', 'schedule'},
      'confirmationType',
    ),
    title: _requiredString(confirmationMap, 'title'),
    summary: _requiredString(confirmationMap, 'summary'),
    status: _enumValue(
      _nullableString(confirmationMap['status']) ?? 'proposed',
      const {'proposed'},
      'status',
    ),
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

ProjectCommunicationWorkbenchView parseProjectCommunicationWorkbench(
  Object? payload,
) {
  final map = _requiredMap(payload, 'project communication workbench');
  return ProjectCommunicationWorkbenchView(
    projectId: _requiredString(map, 'projectId'),
    threadId: _requiredString(map, 'threadId'),
    viewerRole: _enumValue(_requiredString(map, 'viewerRole'), const {
      'publisher',
      'bidder',
      'unknown',
    }, 'viewerRole'),
    businessTodoSummary: _parseOptionalBusinessTodoSummary(
      map['businessTodoSummary'],
    ),
    chatAvailability: _parseOptionalChatAvailability(map['chatAvailability']),
    entries: _requiredList(map, 'entries')
        .map<ProjectCommunicationWorkbenchEntryView>(
          parseProjectCommunicationWorkbenchEntry,
        )
        .toList(growable: false),
    generatedAt: _requiredString(map, 'generatedAt'),
  );
}

ProjectCommunicationMaterialReviewResponseView
parseProjectCommunicationMaterialReviewResponse(Object? payload) {
  final map = _requiredMap(payload, 'project communication material review');
  final rawEntries = map['entries'];
  return ProjectCommunicationMaterialReviewResponseView(
    entry: parseProjectCommunicationWorkbenchEntry(map['entry']),
    entries: rawEntries is List
        ? rawEntries
              .cast<Object?>()
              .map<ProjectCommunicationWorkbenchEntryView>(
                parseProjectCommunicationWorkbenchEntry,
              )
              .toList(growable: false)
        : null,
    projectId: _requiredString(map, 'projectId'),
    threadId: _requiredString(map, 'threadId'),
    viewerRole: _enumValue(_requiredString(map, 'viewerRole'), const {
      'publisher',
      'bidder',
      'unknown',
    }, 'viewerRole'),
    updatedAt: _requiredString(map, 'updatedAt'),
  );
}

ProjectCommunicationWorkbenchEntryView parseProjectCommunicationWorkbenchEntry(
  Object? payload,
) {
  final map = _requiredMap(payload, 'project communication workbench entry');
  final group = _enumValue(_requiredString(map, 'group'), const {
    'publisher_materials',
    'bid_materials',
    'deal_confirmation',
  }, 'group');
  final reviewState = _nullableString(map['reviewState']);
  if (group == 'deal_confirmation' && reviewState != null) {
    throw const FormatException('deal entries must not carry reviewState');
  }
  return ProjectCommunicationWorkbenchEntryView(
    entryKey: _enumValue(_requiredString(map, 'entryKey'), const {
      'publisher_effect_image_review',
      'publisher_construction_doc_review',
      'publisher_material_sample_review',
      'publisher_equipment_material_list_review',
      'publisher_service_list_review',
      'bid_project_understanding_review',
      'bid_quote_sheet_review',
      'bid_schedule_plan_review',
      'contract_confirmation',
      'final_confirmed_amount_confirmation',
    }, 'entryKey'),
    group: group,
    label: _requiredString(map, 'label'),
    summary: _nullableString(map['summary']),
    projectId: _requiredString(map, 'projectId'),
    threadId: _requiredString(map, 'threadId'),
    bidId: _nullableString(map['bidId']),
    viewerRole: _enumValue(_requiredString(map, 'viewerRole'), const {
      'publisher',
      'bidder',
      'unknown',
    }, 'entry.viewerRole'),
    subjectOwnerRole: _enumValue(
      _requiredString(map, 'subjectOwnerRole'),
      const {'publisher', 'bidder', 'platform'},
      'subjectOwnerRole',
    ),
    availabilityState: _enumValue(
      _requiredString(map, 'availabilityState'),
      const {'unsubmitted', 'readable', 'unavailable'},
      'availabilityState',
    ),
    reviewState: reviewState == null
        ? null
        : _enumValue(reviewState, const {
            'unsubmitted',
            'pending_review',
            'confirmed',
            'needs_supplement',
          }, 'reviewState'),
    actionState: _enumValue(_requiredString(map, 'actionState'), const {
      'enabled',
      'readonly',
      'blocked',
    }, 'actionState'),
    attachmentCount: _requiredInt(map, 'attachmentCount'),
    badgeCount: _optionalNonNegativeInt(map['badgeCount'], 'badgeCount'),
    disabledReason: _nullableString(map['disabledReason']),
    sourceFiles: _parseWorkbenchSourceFiles(map['sourceFiles']),
    latestFeedbackText: _nullableString(map['latestFeedbackText']),
    latestFeedbackAt: _nullableString(map['latestFeedbackAt']),
    reviewedAt: _nullableString(map['reviewedAt']),
    routeTarget: _parseWorkbenchRouteTarget(map['routeTarget']),
    truthAnchor: _parseWorkbenchTruthAnchor(map['truthAnchor']),
  );
}

List<ProjectCommunicationWorkbenchSourceFileView> _parseWorkbenchSourceFiles(
  Object? payload,
) {
  if (payload == null) {
    return const <ProjectCommunicationWorkbenchSourceFileView>[];
  }
  return _requiredList(<String, Object?>{'sourceFiles': payload}, 'sourceFiles')
      .map<ProjectCommunicationWorkbenchSourceFileView>((item) {
        final map = _requiredMap(
          item,
          'project communication workbench source file',
        );
        return ProjectCommunicationWorkbenchSourceFileView(
          fileAssetId: _requiredString(map, 'fileAssetId'),
          fileName: _requiredString(map, 'fileName'),
          mimeType: _requiredString(map, 'mimeType'),
          sortOrder: _requiredInt(map, 'sortOrder'),
        );
      })
      .toList(growable: false);
}

ProjectCommunicationWorkbenchRouteTargetView? _parseWorkbenchRouteTarget(
  Object? payload,
) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(payload, 'project communication workbench route');
  return ProjectCommunicationWorkbenchRouteTargetView(
    actionKey: _requiredString(map, 'actionKey'),
    canonicalPath: _requiredString(map, 'canonicalPath'),
    params: _stringMap(map['params']),
  );
}

ProjectCommunicationWorkbenchTruthAnchorView _parseWorkbenchTruthAnchor(
  Object? payload,
) {
  final map = _requiredMap(payload, 'project communication workbench truth');
  return ProjectCommunicationWorkbenchTruthAnchorView(
    truthOwner: _requiredString(map, 'truthOwner'),
    subjectType: _requiredString(map, 'subjectType'),
    projectId: _requiredString(map, 'projectId'),
    threadId: _requiredString(map, 'threadId'),
    bidId: _nullableString(map['bidId']),
    subjectOwnerOrganizationId: _nullableString(
      map['subjectOwnerOrganizationId'],
    ),
    reviewerOrganizationId: _nullableString(map['reviewerOrganizationId']),
    materialKind: _nullableString(map['materialKind']),
    bidMaterialSlot: _nullableString(map['bidMaterialSlot']),
    dealConfirmationId: _nullableString(map['dealConfirmationId']),
    sourceVersionToken: _nullableString(map['sourceVersionToken']),
  );
}

ProjectCommunicationFilePreviewAccessView
parseProjectCommunicationFilePreviewAccess(Object? payload) {
  final map = _requiredMap(
    payload,
    'project communication file preview access',
  );
  return ProjectCommunicationFilePreviewAccessView(
    fileAssetId: _requiredString(map, 'fileAssetId'),
    projectId: _requiredString(map, 'projectId'),
    threadId: _requiredString(map, 'threadId'),
    previewType: _enumValue(_requiredString(map, 'previewType'), const {
      'image',
      'pdf',
      'text',
      'unsupported',
    }, 'previewType'),
    canPreview: _requiredBool(map, 'canPreview'),
    fileName: _nullableString(map['fileName']),
    mimeType: _nullableString(map['mimeType']),
    accessUrl: _nullableString(map['accessUrl']),
    expiresAt: _nullableString(map['expiresAt']),
    contentLengthBytes: _nullableInt(map['contentLengthBytes']),
    downloadAvailable: map['downloadAvailable'] == true,
    fallbackReason: _nullableString(map['fallbackReason']),
  );
}

ProjectCommunicationConfirmationSoftLinkView
parseProjectCommunicationConfirmationSoftLink(Object? payload) {
  final map = _requiredMap(
    payload,
    'project communication confirmation softLink',
  );
  return ProjectCommunicationConfirmationSoftLinkView(
    projectId: _requiredString(map, 'projectId'),
    threadId: _requiredString(map, 'threadId'),
    messageId: _requiredString(map, 'messageId'),
    confirmationType: _enumValue(
      _requiredString(map, 'confirmationType'),
      const {'quote', 'material', 'material_process', 'schedule'},
      'confirmationType',
    ),
    status: _enumValue(_nullableString(map['status']) ?? 'pending', const {
      'pending',
      'recorded',
    }, 'status'),
    title: _nullableString(map['title']),
    summary: _nullableString(map['summary']),
    routeTarget: _parseOptionalSoftLinkRouteTarget(map['routeTarget']),
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
    projectRelation: _enumValue(
      _nullableString(map['projectRelation']) ?? 'unknown',
      const <String>{'my_published', 'my_bid', 'unknown'},
      'projectRelation',
    ),
    projectState: _nullableString(map['projectState']),
    projectPublishedAt: _nullableString(map['projectPublishedAt']),
    projectUpdatedAt: _nullableString(map['projectUpdatedAt']),
    latestActivityAt: _requiredString(map, 'latestActivityAt'),
    latestUnreadMessageAt: _nullableString(map['latestUnreadMessageAt']),
    projectUnreadCount: _optionalNonNegativeInt(
      map['projectUnreadCount'],
      'projectUnreadCount',
    ),
    hasProjectUnread:
        _optionalBool(map['hasProjectUnread'], 'hasProjectUnread') ?? false,
    businessTodoSummary: _parseOptionalBusinessTodoSummary(
      map['businessTodoSummary'],
    ),
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
    'bid_participation_request',
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
    requesterCompanyName: _nullableString(map['requesterCompanyName']),
    requesterOrganizationId: _nullableString(map['requesterOrganizationId']),
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
    nickname: _nullableString(map['nickname']),
    companyName:
        _nullableString(map['companyName']) ??
        _requiredString(map, 'displayName'),
    avatarUrl: _nullableString(map['avatarUrl']),
    role: _requiredString(map, 'role'),
    certificationSummary: _parseCertificationSummary(
      map['certificationSummary'],
    ),
  );
}

CounterpartCertificationSummaryView? _parseCertificationSummary(
  Object? payload,
) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(
    payload,
    'counterpart conversation certificationSummary',
  );
  return CounterpartCertificationSummaryView(
    certificationStatus: _requiredString(map, 'certificationStatus'),
    legalName: _requiredString(map, 'legalName'),
    usccMasked: _nullableString(map['usccMasked']),
    businessType: _nullableString(map['businessType']),
    address: _nullableString(map['address']),
    establishedAt: _nullableString(map['establishedAt']),
    reviewedAt: _nullableString(map['reviewedAt']),
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
      'bid_participation_request',
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

String _requiredBodyString(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is! String) {
    throw FormatException('field "$field" must be a string');
  }
  return value;
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

bool? _optionalBool(Object? value, String field) {
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  throw FormatException('field "$field" must be a bool');
}

int _optionalNonNegativeInt(Object? value, String field) {
  if (value == null) {
    return 0;
  }
  if (value is int && value >= 0) {
    return value;
  }
  throw FormatException('field "$field" must be a non-negative int');
}

int _nonNegativeInt(Object? value, String field) {
  if (value is int && value >= 0) {
    return value;
  }
  throw FormatException('field "$field" must be a non-negative int');
}

String _enumValue(String value, Set<String> allowed, String context) {
  if (!allowed.contains(value)) {
    throw FormatException('$context returned unsupported value "$value"');
  }
  return value;
}

Map<String, String> _stringMap(Object? payload) {
  if (payload is! Map) {
    throw const FormatException(_missingProjectContextMessage);
  }
  final result = <String, String>{};
  for (final MapEntry<Object?, Object?> entry in payload.entries) {
    final key = '${entry.key}'.trim();
    final value = entry.value;
    if (key.isEmpty || value is! String || value.trim().isEmpty) {
      throw const FormatException(_missingProjectContextMessage);
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

int? _nullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num && value == value.roundToDouble()) {
    return value.toInt();
  }
  return null;
}

MessageInteractionRouteTarget? _parseOptionalSoftLinkRouteTarget(
  Object? payload,
) {
  try {
    return _parseRouteTarget(payload);
  } on FormatException {
    return null;
  }
}
