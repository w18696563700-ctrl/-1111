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
    required this.latestActivityAt,
    required this.orderSummary,
    required this.ratingEntry,
    required this.cards,
  });

  final String projectId;
  final String projectDisplayTitle;
  final String titleVisibility;
  final String projectRelation;
  final String? projectState;
  final String latestActivityAt;
  final CounterpartConversationOrderSummaryView? orderSummary;
  final CounterpartConversationRatingEntryView? ratingEntry;
  final List<CounterpartConversationBusinessCardView> cards;
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
    required this.projectGroups,
  });

  final String conversationId;
  final MessageInteractionCounterpartView counterpart;
  final MessageInteractionSummaryView summary;
  final String focusProjectId;
  final String latestActivityAt;
  final List<CounterpartConversationProjectGroupView> projectGroups;
}

final class ProjectCommunicationThreadView {
  const ProjectCommunicationThreadView({
    required this.threadId,
    required this.projectId,
    required this.ownerOrganizationId,
    required this.counterpartOrganizationId,
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
  final String threadState;
  final String? lastMessageId;
  final String? lastMessageAt;
  final String createdAt;
  final String updatedAt;
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
    required this.clientMessageId,
    required this.messageState,
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
  final String? clientMessageId;
  final String messageState;
  final String createdAt;
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
