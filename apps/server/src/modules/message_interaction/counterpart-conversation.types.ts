export type CounterpartConversationCardType =
  | 'project_name_access_request'
  | 'bid_participation_request'
  | 'bid_thread'
  | 'project_clarification'
  | 'system_notice';

export type CounterpartConversationTruthType =
  | 'project_name_access_request'
  | 'bid_participation_request'
  | 'bid_thread'
  | 'project_clarification'
  | 'project_notice_event';

export type CounterpartConversationRouteTarget = {
  objectType: string;
  actionKey: string;
  canonicalPath: string;
  params: Record<string, string>;
};

export type CounterpartConversationSummaryProjection = {
  focusProjectId: string;
  title: string;
  text: string;
  projectCount: number;
  latestCardType: CounterpartConversationCardType;
};

export type CounterpartConversationCertificationSummaryProjection = {
  certificationStatus: 'approved';
  legalName: string;
  usccMasked: string | null;
  businessType: string | null;
  address: string | null;
  establishedAt: string | null;
  reviewedAt: string | null;
};

export type CounterpartConversationCounterpartProjection = {
  organizationId: string;
  displayName: string;
  nickname: string | null;
  companyName: string;
  avatarUrl: string | null;
  role: 'counterpart';
  certificationSummary: CounterpartConversationCertificationSummaryProjection | null;
};

export type CounterpartConversationTruthAnchorProjection = {
  truthType: CounterpartConversationTruthType;
  projectId: string;
  requestId?: string;
  bidId?: string;
  threadId?: string;
  clarificationId?: string;
  noticeId?: string;
};

export type CounterpartConversationDecisionAvailabilityProjection = {
  canApprove: boolean;
  canReject: boolean;
};

export type CounterpartConversationBusinessCardProjection = {
  cardId: string;
  cardType: CounterpartConversationCardType;
  title: string;
  summary: string;
  status: string | null;
  updatedAt: string;
  requesterCompanyName: string | null;
  requesterOrganizationId: string | null;
  truthAnchor: CounterpartConversationTruthAnchorProjection;
  detailRouteTarget: CounterpartConversationRouteTarget | null;
  decisionAvailability: CounterpartConversationDecisionAvailabilityProjection | null;
};

export type CounterpartConversationProjectGroupProjection = {
  projectId: string;
  projectDisplayTitle: string;
  titleVisibility: 'masked' | 'visible';
  projectRelation: 'my_published' | 'my_bid' | 'unknown';
  projectState: string | null;
  projectPublishedAt: string | null;
  projectUpdatedAt: string | null;
  latestActivityAt: string;
  projectUnreadCount: number;
  hasProjectUnread: boolean;
  pricingSummary?: Record<string, unknown>;
  ratingEntry: CounterpartConversationRatingEntryProjection | null;
  cards: CounterpartConversationBusinessCardProjection[];
};

export type CounterpartConversationRatingEntryProjection = {
  orderId: string;
  projectId: string;
  rateeOrganizationId: string;
  canRate: boolean;
  reason: string | null;
  ratingState: string | null;
};

export type CounterpartConversationListItemProjection = {
  interactionId: string;
  interactionType: 'counterpart_conversation';
  conversationId: string;
  projectId: string;
  counterpart: CounterpartConversationCounterpartProjection;
  summary: CounterpartConversationSummaryProjection;
  pricingSummary?: Record<string, unknown>;
  updatedAt: string;
  routeTarget: CounterpartConversationRouteTarget;
};

export type CounterpartConversationDetailProjection = {
  conversationId: string;
  counterpart: CounterpartConversationCounterpartProjection;
  summary: CounterpartConversationSummaryProjection;
  focusProjectId: string;
  latestActivityAt: string;
  projectGroups: CounterpartConversationProjectGroupProjection[];
};
