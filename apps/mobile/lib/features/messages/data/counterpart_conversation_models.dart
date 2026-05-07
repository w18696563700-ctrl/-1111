import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/messages/data/messages_interaction_models.dart';

final class CounterpartConversationResult<T> {
  const CounterpartConversationResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final T? data;
  final String? message;
  final String? errorCode;
}

final class CounterpartConversationDecisionAvailabilityView {
  const CounterpartConversationDecisionAvailabilityView({
    required this.canApprove,
    required this.canReject,
  });

  final bool canApprove;
  final bool canReject;
}

final class CounterpartConversationTruthAnchorView {
  const CounterpartConversationTruthAnchorView({
    required this.truthType,
    required this.projectId,
    required this.requestId,
    required this.orderId,
    required this.bidId,
    required this.threadId,
    required this.clarificationId,
    required this.noticeId,
  });

  final String truthType;
  final String projectId;
  final String? requestId;
  final String? orderId;
  final String? bidId;
  final String? threadId;
  final String? clarificationId;
  final String? noticeId;
}

final class CounterpartConversationBusinessCardView {
  const CounterpartConversationBusinessCardView({
    required this.cardId,
    required this.cardType,
    required this.title,
    required this.summary,
    required this.status,
    required this.updatedAt,
    required this.requesterCompanyName,
    required this.requesterOrganizationId,
    required this.truthAnchor,
    required this.detailRouteTarget,
    required this.decisionAvailability,
  });

  final String cardId;
  final String cardType;
  final String title;
  final String summary;
  final String? status;
  final String updatedAt;
  final String? requesterCompanyName;
  final String? requesterOrganizationId;
  final CounterpartConversationTruthAnchorView truthAnchor;
  final MessageInteractionRouteTarget? detailRouteTarget;
  final CounterpartConversationDecisionAvailabilityView? decisionAvailability;
}

final class CounterpartConversationProjectGroupView {
  const CounterpartConversationProjectGroupView({
    required this.projectId,
    required this.projectDisplayTitle,
    required this.titleVisibility,
    required this.projectRelation,
    required this.projectState,
    required this.projectPublishedAt,
    required this.projectUpdatedAt,
    required this.latestActivityAt,
    required this.latestUnreadMessageAt,
    required this.projectUnreadCount,
    required this.hasProjectUnread,
    required this.businessTodoSummary,
    required this.orderSummary,
    required this.ratingEntry,
    required this.cards,
  });

  final String projectId;
  final String projectDisplayTitle;
  final String titleVisibility;
  final String projectRelation;
  final String? projectState;
  final String? projectPublishedAt;
  final String? projectUpdatedAt;
  final String latestActivityAt;
  final String? latestUnreadMessageAt;
  final int projectUnreadCount;
  final bool hasProjectUnread;
  final ProjectCommunicationBusinessTodoSummaryView businessTodoSummary;
  final CounterpartConversationOrderSummaryView? orderSummary;
  final CounterpartConversationRatingEntryView? ratingEntry;
  final List<CounterpartConversationBusinessCardView> cards;
}

final class ProjectCommunicationBusinessTodoSummaryView {
  const ProjectCommunicationBusinessTodoSummaryView({
    required this.bidParticipationReviewPendingCount,
    required this.publisherMaterialReviewPendingCount,
    required this.bidMaterialReviewPendingCount,
    required this.dealConfirmationPendingCount,
    required this.totalPendingCount,
  });

  final int bidParticipationReviewPendingCount;
  final int publisherMaterialReviewPendingCount;
  final int bidMaterialReviewPendingCount;
  final int dealConfirmationPendingCount;
  final int totalPendingCount;

  int get materialReviewPendingCount =>
      publisherMaterialReviewPendingCount + bidMaterialReviewPendingCount;
}

final class CounterpartConversationOrderSummaryView {
  const CounterpartConversationOrderSummaryView({
    required this.orderId,
    required this.projectId,
    required this.buyerOrganizationId,
    required this.sellerOrganizationId,
    required this.state,
    required this.completionRequestState,
    required this.exitGovernance,
  });

  final String orderId;
  final String? projectId;
  final String? buyerOrganizationId;
  final String? sellerOrganizationId;
  final String? state;
  final String? completionRequestState;
  final CounterpartConversationExitGovernanceView? exitGovernance;
}

final class CounterpartConversationExitGovernanceView {
  const CounterpartConversationExitGovernanceView({
    required this.exitCaseId,
    required this.exitType,
    required this.caseStatus,
    required this.breachParty,
    required this.counterpartyAction,
    required this.updatedAt,
  });

  final String? exitCaseId;
  final String? exitType;
  final String? caseStatus;
  final String? breachParty;
  final String? counterpartyAction;
  final String? updatedAt;
}

final class CounterpartConversationRatingEntryView {
  const CounterpartConversationRatingEntryView({
    required this.orderId,
    required this.projectId,
    required this.rateeOrganizationId,
    required this.canRate,
    required this.reason,
    required this.ratingState,
  });

  final String orderId;
  final String projectId;
  final String rateeOrganizationId;
  final bool canRate;
  final String? reason;
  final String? ratingState;
}

final class CounterpartConversationDetailView {
  const CounterpartConversationDetailView({
    required this.conversationId,
    required this.counterpart,
    required this.summary,
    required this.focusProjectId,
    required this.latestActivityAt,
    required this.conversationUnreadCount,
    required this.hasUnread,
    required this.latestUnreadMessageAt,
    required this.myPublishedUnreadCount,
    required this.myBidUnreadCount,
    required this.projectGroups,
  });

  final String conversationId;
  final MessageInteractionCounterpartView counterpart;
  final MessageInteractionSummaryView summary;
  final String focusProjectId;
  final String latestActivityAt;
  final int conversationUnreadCount;
  final bool hasUnread;
  final String? latestUnreadMessageAt;
  final int myPublishedUnreadCount;
  final int myBidUnreadCount;
  final List<CounterpartConversationProjectGroupView> projectGroups;
}

final class ProjectCommunicationThreadView {
  const ProjectCommunicationThreadView({
    required this.threadId,
    required this.projectId,
    required this.ownerOrganizationId,
    required this.counterpartOrganizationId,
    required this.chatAvailability,
    required this.threadState,
    required this.lastMessageId,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String threadId;
  final String projectId;
  final String ownerOrganizationId;
  final String counterpartOrganizationId;
  final ProjectCommunicationChatAvailabilityView chatAvailability;
  final String threadState;
  final String? lastMessageId;
  final String? lastMessageAt;
  final String createdAt;
  final String updatedAt;
}

final class ProjectCommunicationChatAvailabilityView {
  const ProjectCommunicationChatAvailabilityView({
    required this.canSendMessage,
    required this.lockReasonCode,
    required this.lockReasonText,
    required this.requiredNextAction,
  });

  final bool canSendMessage;
  final String? lockReasonCode;
  final String? lockReasonText;
  final String requiredNextAction;
}

final class ProjectCommunicationMessageView {
  const ProjectCommunicationMessageView({
    required this.messageId,
    required this.threadId,
    required this.projectId,
    required this.senderUserId,
    required this.senderActorId,
    required this.senderOrganizationId,
    required this.messageKind,
    required this.body,
    required this.attachment,
    required this.confirmation,
    required this.eventType,
    required this.sourceType,
    required this.sourceId,
    required this.requiredNextAction,
    required this.routeTarget,
    required this.clientMessageId,
    required this.messageState,
    required this.deliveryState,
    required this.readState,
    required this.readByCounterpartAt,
    required this.createdAt,
  });

  final String messageId;
  final String threadId;
  final String projectId;
  final String senderUserId;
  final String? senderActorId;
  final String senderOrganizationId;
  final String messageKind;
  final String body;
  final ProjectCommunicationAttachmentView? attachment;
  final ProjectCommunicationConfirmationView? confirmation;
  final String? eventType;
  final String? sourceType;
  final String? sourceId;
  final String? requiredNextAction;
  final MessageInteractionRouteTarget? routeTarget;
  final String? clientMessageId;
  final String messageState;
  final String deliveryState;
  final String readState;
  final String? readByCounterpartAt;
  final String createdAt;

  bool get isServiceFeeAuthorizationPrompt {
    return eventType ==
            'bid_materials_confirmed_service_fee_authorization_required' &&
        requiredNextAction == 'complete_service_fee_authorization';
  }
}

final class ProjectCommunicationAttachmentView {
  const ProjectCommunicationAttachmentView({
    required this.fileAssetId,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.category,
  });

  final String fileAssetId;
  final String fileName;
  final String mimeType;
  final int size;
  final String category;
}

final class ProjectCommunicationConfirmationView {
  const ProjectCommunicationConfirmationView({
    required this.confirmationType,
    required this.title,
    required this.summary,
    required this.status,
  });

  final String confirmationType;
  final String title;
  final String summary;
  final String status;
}

final class ProjectCommunicationFilePreviewAccessView {
  const ProjectCommunicationFilePreviewAccessView({
    required this.fileAssetId,
    required this.projectId,
    required this.threadId,
    required this.previewType,
    required this.canPreview,
    required this.fileName,
    required this.mimeType,
    required this.accessUrl,
    required this.expiresAt,
    required this.contentLengthBytes,
    required this.downloadAvailable,
    required this.fallbackReason,
  });

  final String fileAssetId;
  final String projectId;
  final String threadId;
  final String previewType;
  final bool canPreview;
  final String? fileName;
  final String? mimeType;
  final String? accessUrl;
  final String? expiresAt;
  final int? contentLengthBytes;
  final bool downloadAvailable;
  final String? fallbackReason;
}

final class ProjectCommunicationConfirmationSoftLinkView {
  const ProjectCommunicationConfirmationSoftLinkView({
    required this.projectId,
    required this.threadId,
    required this.messageId,
    required this.confirmationType,
    required this.status,
    required this.title,
    required this.summary,
    required this.routeTarget,
  });

  final String projectId;
  final String threadId;
  final String messageId;
  final String confirmationType;
  final String status;
  final String? title;
  final String? summary;
  final MessageInteractionRouteTarget? routeTarget;
}

final class ProjectCommunicationMessageListView {
  const ProjectCommunicationMessageListView({
    required this.items,
    required this.nextCursor,
  });

  final List<ProjectCommunicationMessageView> items;
  final String? nextCursor;
}

final class ProjectCommunicationReadCursorView {
  const ProjectCommunicationReadCursorView({
    required this.threadId,
    required this.projectId,
    required this.organizationId,
    required this.lastReadMessageId,
    required this.lastReadAt,
    required this.updatedAt,
  });

  final String threadId;
  final String projectId;
  final String organizationId;
  final String? lastReadMessageId;
  final String lastReadAt;
  final String updatedAt;
}

final class ProjectCommunicationWorkbenchView {
  const ProjectCommunicationWorkbenchView({
    required this.projectId,
    required this.threadId,
    required this.viewerRole,
    required this.businessTodoSummary,
    required this.chatAvailability,
    required this.entries,
    required this.generatedAt,
  });

  final String projectId;
  final String threadId;
  final String viewerRole;
  final ProjectCommunicationBusinessTodoSummaryView businessTodoSummary;
  final ProjectCommunicationChatAvailabilityView chatAvailability;
  final List<ProjectCommunicationWorkbenchEntryView> entries;
  final String generatedAt;
}

final class ProjectCommunicationWorkbenchEntryView {
  const ProjectCommunicationWorkbenchEntryView({
    required this.entryKey,
    required this.group,
    required this.label,
    required this.summary,
    required this.projectId,
    required this.threadId,
    required this.bidId,
    required this.viewerRole,
    required this.subjectOwnerRole,
    required this.availabilityState,
    required this.reviewState,
    required this.actionState,
    required this.attachmentCount,
    required this.badgeCount,
    required this.disabledReason,
    required this.sourceFiles,
    required this.latestFeedbackText,
    required this.latestFeedbackAt,
    required this.reviewedAt,
    required this.routeTarget,
    required this.truthAnchor,
  });

  final String entryKey;
  final String group;
  final String label;
  final String? summary;
  final String projectId;
  final String threadId;
  final String? bidId;
  final String viewerRole;
  final String subjectOwnerRole;
  final String availabilityState;
  final String? reviewState;
  final String actionState;
  final int attachmentCount;
  final int badgeCount;
  final String? disabledReason;
  final List<ProjectCommunicationWorkbenchSourceFileView> sourceFiles;
  final String? latestFeedbackText;
  final String? latestFeedbackAt;
  final String? reviewedAt;
  final ProjectCommunicationWorkbenchRouteTargetView? routeTarget;
  final ProjectCommunicationWorkbenchTruthAnchorView truthAnchor;

  bool get isMaterialEntry => group != 'deal_confirmation';

  bool get canSubmitReview =>
      isMaterialEntry &&
      actionState == 'enabled' &&
      availabilityState == 'readable';
}

final class ProjectCommunicationWorkbenchSourceFileView {
  const ProjectCommunicationWorkbenchSourceFileView({
    required this.fileAssetId,
    required this.fileName,
    required this.mimeType,
    required this.sortOrder,
  });

  final String fileAssetId;
  final String fileName;
  final String mimeType;
  final int sortOrder;
}

final class ProjectCommunicationWorkbenchRouteTargetView {
  const ProjectCommunicationWorkbenchRouteTargetView({
    required this.actionKey,
    required this.canonicalPath,
    required this.params,
  });

  final String actionKey;
  final String canonicalPath;
  final Map<String, String> params;
}

final class ProjectCommunicationWorkbenchTruthAnchorView {
  const ProjectCommunicationWorkbenchTruthAnchorView({
    required this.truthOwner,
    required this.subjectType,
    required this.projectId,
    required this.threadId,
    required this.bidId,
    required this.subjectOwnerOrganizationId,
    required this.reviewerOrganizationId,
    required this.materialKind,
    required this.bidMaterialSlot,
    required this.dealConfirmationId,
    required this.sourceVersionToken,
  });

  final String truthOwner;
  final String subjectType;
  final String projectId;
  final String threadId;
  final String? bidId;
  final String? subjectOwnerOrganizationId;
  final String? reviewerOrganizationId;
  final String? materialKind;
  final String? bidMaterialSlot;
  final String? dealConfirmationId;
  final String? sourceVersionToken;
}

final class ProjectCommunicationMaterialReviewResponseView {
  const ProjectCommunicationMaterialReviewResponseView({
    required this.entry,
    required this.entries,
    required this.projectId,
    required this.threadId,
    required this.viewerRole,
    required this.updatedAt,
  });

  final ProjectCommunicationWorkbenchEntryView entry;
  final List<ProjectCommunicationWorkbenchEntryView>? entries;
  final String projectId;
  final String threadId;
  final String viewerRole;
  final String updatedAt;
}

final class ProjectAlbumPhotoView {
  const ProjectAlbumPhotoView({
    required this.photoId,
    required this.projectId,
    required this.fileAssetId,
    required this.category,
    required this.caption,
    required this.mimeType,
    required this.sortOrder,
    required this.photoState,
    required this.uploadedByUserId,
    required this.uploadedByActorId,
    required this.uploadedByOrganizationId,
    required this.createdAt,
    required this.removedAt,
  });

  final String photoId;
  final String projectId;
  final String fileAssetId;
  final String category;
  final String? caption;
  final String mimeType;
  final int sortOrder;
  final String photoState;
  final String uploadedByUserId;
  final String? uploadedByActorId;
  final String uploadedByOrganizationId;
  final String createdAt;
  final String? removedAt;
}

final class ProjectAlbumPhotoListView {
  const ProjectAlbumPhotoListView({
    required this.projectId,
    required this.limit,
    required this.photoCount,
    required this.items,
  });

  final String projectId;
  final int limit;
  final int photoCount;
  final List<ProjectAlbumPhotoView> items;
}

final class ProjectCounterpartyRatingSubmitAcceptedView {
  const ProjectCounterpartyRatingSubmitAcceptedView({
    required this.ratingId,
    required this.orderId,
    required this.projectId,
    required this.raterOrganizationId,
    required this.rateeOrganizationId,
    required this.state,
    required this.ratingState,
    required this.scoreValue,
    required this.scoreLabel,
    required this.submittedAt,
  });

  final String ratingId;
  final String orderId;
  final String projectId;
  final String raterOrganizationId;
  final String rateeOrganizationId;
  final String state;
  final String ratingState;
  final int scoreValue;
  final String scoreLabel;
  final String submittedAt;
}
