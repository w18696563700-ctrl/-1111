export type CounterpartConversationCardType =
  | 'project_name_access_request'
  | 'bid_thread'
  | 'project_clarification'
  | 'system_notice';

export type CounterpartConversationTruthType =
  | 'project_name_access_request'
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
  truthAnchor: CounterpartConversationTruthAnchorProjection;
  detailRouteTarget: CounterpartConversationRouteTarget | null;
  decisionAvailability: CounterpartConversationDecisionAvailabilityProjection | null;
};

export type CounterpartConversationProjectGroupProjection = {
  projectId: string;
  projectDisplayTitle: string;
  titleVisibility: 'masked' | 'visible';
  projectState: string | null;
  latestActivityAt: string;
  p0PaySummary?: Record<string, unknown>;
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
  counterpart: {
    organizationId: string;
    displayName: string;
    avatarUrl: string | null;
    role: 'counterpart';
  };
  summary: CounterpartConversationSummaryProjection;
  p0PaySummary?: Record<string, unknown>;
  updatedAt: string;
  routeTarget: CounterpartConversationRouteTarget;
};

export type CounterpartConversationDetailProjection = {
  conversationId: string;
  counterpart: {
    organizationId: string;
    displayName: string;
    avatarUrl: string | null;
    role: 'counterpart';
  };
  summary: CounterpartConversationSummaryProjection;
  focusProjectId: string;
  latestActivityAt: string;
  projectGroups: CounterpartConversationProjectGroupProjection[];
};
