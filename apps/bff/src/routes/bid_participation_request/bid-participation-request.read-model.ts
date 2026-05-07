export type BidParticipationRequestAcceptedResponse = {
  requestId: string;
  projectId: string;
  status: "pending";
  threadId: string;
};

export type BidParticipationPendingListReadModel = {
  projectId: string;
  items: BidParticipationPendingItemReadModel[];
};

export type BidParticipationRequesterOrganizationReadModel = {
  organizationId: string;
  displayName: string;
  avatarUrl: string | null;
  certificationStatus: string | null;
  legalName: string | null;
  uscc: string | null;
};

export type BidParticipationPendingItemReadModel = {
  requestId: string;
  requesterOrganization: BidParticipationRequesterOrganizationReadModel;
  requestedAt: string;
  status: BidParticipationReviewStatus;
  threadId: string;
};

export type BidParticipationDecisionResponse = {
  requestId: string;
  projectId: string;
  status: "approved" | "rejected";
};

export type BidParticipationThreadDetailReadModel = {
  threadId: string;
  threadType: "bid_participation_review";
  projectId: string;
  requestId: string;
  requestStatus: BidParticipationReviewStatus;
  displayTitle: string;
  requesterOrganization: BidParticipationRequesterOrganizationReadModel;
  items: BidParticipationThreadItemReadModel[];
  primaryReviewAction: {
    actionKey: "bid_participation.review";
    enabled: boolean;
    availableDecisions: Array<"approve" | "reject">;
  } | null;
  pricingGateRequired?: boolean;
  pricingGateType?: "none" | "bid_service_fee_authorization_required";
  pricingGateRouteTarget?: {
    actionKey: "bid_service_fee_authorization.open";
    objectType: "bid_service_fee_authorization";
    canonicalPath: string;
    label: string | null;
    params: Record<string, string>;
  } | null;
};

export type BidParticipationThreadItemReadModel = {
  itemId: string;
  itemKind: "system_seed" | "system_notice";
  title: string;
  summary: string;
  createdAt: string;
  action: {
    actionKey:
      | "bid_participation.review"
      | "bid_participation.refresh"
      | "bid_submit.open"
      | "bid_service_fee_authorization.open";
    objectType: "bid_participation_request" | "bid_submit" | "bid_service_fee_authorization" | null;
    canonicalPath: string | null;
    label: string | null;
    params: Record<string, string>;
  } | null;
};

type BidParticipationReviewStatus = "pending" | "approved" | "rejected";

const REVIEW_STATUSES = new Set<BidParticipationReviewStatus>([
  "pending",
  "approved",
  "rejected",
]);
const THREAD_TYPES = new Set(["bid_participation_review"]);
const THREAD_ITEM_ACTION_KEYS = new Set([
  "bid_participation.review",
  "bid_participation.refresh",
  "bid_submit.open",
  "bid_service_fee_authorization.open",
]);

export function readBidParticipationRequestAcceptedResponse(
  value: unknown,
): BidParticipationRequestAcceptedResponse {
  const record = requireRecord(value, "Bid participation accepted response must be an object.");
  const status = readReviewStatus(record.status);
  if (status !== "pending") {
    throw new Error("Bid participation request must start with pending status.");
  }
  return {
    requestId: readRequiredString(record.requestId, "requestId"),
    projectId: readRequiredString(record.projectId, "projectId"),
    status,
    threadId: readRequiredString(record.threadId, "threadId"),
  };
}

export function readBidParticipationPendingListReadModel(
  value: unknown,
): BidParticipationPendingListReadModel {
  const record = requireRecord(value, "Bid participation pending list must be an object.");
  return {
    projectId: readRequiredString(record.projectId, "projectId"),
    items: readRequiredArray(record.items, "items").map(readPendingItem),
  };
}

export function readBidParticipationDecisionResponse(
  value: unknown,
  expectedStatus: "approved" | "rejected",
): BidParticipationDecisionResponse {
  const record = requireRecord(value, "Bid participation decision response must be an object.");
  const status = readReviewStatus(record.status);
  if (status !== expectedStatus) {
    throw new Error("Bid participation decision response returned unexpected status.");
  }
  return {
    requestId: readRequiredString(record.requestId, "requestId"),
    projectId: readRequiredString(record.projectId, "projectId"),
    status,
  };
}

export function readBidParticipationThreadDetailReadModel(
  value: unknown,
): BidParticipationThreadDetailReadModel {
  const record = requireRecord(value, "Bid participation thread detail must be an object.");
  const threadType = readRequiredString(record.threadType, "threadType");
  if (!THREAD_TYPES.has(threadType)) {
    throw new Error("Bid participation thread returned unsupported threadType.");
  }
  const requestStatus = readReviewStatus(record.requestStatus);
  const pricingGate = readPricingGate(record, requestStatus);
  return {
    threadId: readRequiredString(record.threadId, "threadId"),
    threadType: "bid_participation_review",
    projectId: readRequiredString(record.projectId, "projectId"),
    requestId: readRequiredString(record.requestId, "requestId"),
    requestStatus,
    displayTitle: readRequiredString(record.displayTitle, "displayTitle"),
    requesterOrganization: readRequesterOrganization(record.requesterOrganization),
    items: readRequiredArray(record.items, "items").map((item) =>
      readThreadItem(item, {
        requestStatus,
        projectId: readRequiredString(record.projectId, "projectId"),
        requestId: readRequiredString(record.requestId, "requestId"),
        pricingGateRequired: pricingGate.pricingGateRequired,
      }),
    ),
    primaryReviewAction: readPrimaryReviewAction(record.primaryReviewAction),
    pricingGateRequired: pricingGate.pricingGateRequired,
    pricingGateType: pricingGate.pricingGateType,
    pricingGateRouteTarget: pricingGate.pricingGateRouteTarget,
  };
}

function readPendingItem(value: unknown): BidParticipationPendingItemReadModel {
  const record = requireRecord(value, "Bid participation pending item must be an object.");
  return {
    requestId: readRequiredString(record.requestId, "requestId"),
    requesterOrganization: readRequesterOrganization(record.requesterOrganization),
    requestedAt: readRequiredString(record.requestedAt, "requestedAt"),
    status: readReviewStatus(record.status),
    threadId: readRequiredString(record.threadId, "threadId"),
  };
}

function readThreadItem(
  value: unknown,
  context: {
    requestStatus: BidParticipationReviewStatus;
    projectId: string;
    requestId: string;
    pricingGateRequired: boolean;
  },
): BidParticipationThreadItemReadModel {
  const record = requireRecord(value, "Bid participation thread item must be an object.");
  const itemKind = readRequiredString(record.itemKind, "itemKind");
  if (itemKind !== "system_seed" && itemKind !== "system_notice") {
    throw new Error("Bid participation thread item returned unsupported itemKind.");
  }
  return {
    itemId: readRequiredString(record.itemId, "itemId"),
    itemKind,
    title: readRequiredString(record.title, "title"),
    summary: readRequiredString(record.summary, "summary"),
    createdAt: readRequiredString(record.createdAt, "createdAt"),
    action: readThreadItemAction(record.action, context),
  };
}

function readRequesterOrganization(value: unknown): BidParticipationRequesterOrganizationReadModel {
  const record = requireRecord(value, "Bid participation requester organization must be an object.");
  return {
    organizationId: readRequiredString(record.organizationId, "requesterOrganization.organizationId"),
    displayName: readRequiredString(record.displayName, "requesterOrganization.displayName"),
    avatarUrl: readNullableString(record.avatarUrl),
    certificationStatus: readNullableString(record.certificationStatus),
    legalName: readNullableString(record.legalName),
    uscc: readNullableString(record.uscc),
  };
}

function readThreadItemAction(
  value: unknown,
  context: {
    requestStatus: BidParticipationReviewStatus;
    projectId: string;
    requestId: string;
    pricingGateRequired: boolean;
  },
): BidParticipationThreadItemReadModel["action"] {
  if (value == null) {
    return null;
  }
  const record = requireRecord(value, "Bid participation thread action must be an object.");
  const actionKey = readRequiredString(record.actionKey, "action.actionKey");
  if (!THREAD_ITEM_ACTION_KEYS.has(actionKey)) {
    throw new Error("Bid participation thread returned unsupported actionKey.");
  }
  if (
    context.requestStatus === "approved" &&
    context.pricingGateRequired &&
    actionKey === "bid_submit.open"
  ) {
    return buildBidServiceFeeAuthorizationRouteTarget(context.projectId, context.requestId);
  }
  return {
    actionKey: actionKey as NonNullable<BidParticipationThreadItemReadModel["action"]>["actionKey"],
    objectType: readNullableString(record.objectType) as
      | "bid_participation_request"
      | "bid_submit"
      | "bid_service_fee_authorization"
      | null,
    canonicalPath: readNullableString(record.canonicalPath),
    label: readNullableString(record.label),
    params: readStringMap(record.params),
  };
}

function readPricingGate(
  record: Record<string, unknown>,
  _requestStatus: BidParticipationReviewStatus,
) {
  const pricingGateRequired =
    typeof record.pricingGateRequired === "boolean"
      ? record.pricingGateRequired
      : false;
  const pricingGateType = pricingGateRequired
    ? "bid_service_fee_authorization_required" as const
    : "none" as const;
  return {
    pricingGateRequired,
    pricingGateType,
    pricingGateRouteTarget: pricingGateRequired
      ? buildBidServiceFeeAuthorizationRouteTarget(
          readRequiredString(record.projectId, "projectId"),
          readRequiredString(record.requestId, "requestId"),
        )
      : null,
  };
}

function buildBidServiceFeeAuthorizationRouteTarget(projectId: string, requestId: string) {
  return {
    actionKey: "bid_service_fee_authorization.open" as const,
    objectType: "bid_service_fee_authorization" as const,
    canonicalPath: "/api/app/project/{projectId}/bid-service-fee-authorizations",
    label: "完成竞标服务费预授权额度",
    params: {
      projectId,
      bidParticipationRequestId: requestId,
    },
  };
}

function readPrimaryReviewAction(value: unknown): BidParticipationThreadDetailReadModel["primaryReviewAction"] {
  if (value == null) {
    return null;
  }
  const record = requireRecord(value, "Bid participation primaryReviewAction must be an object.");
  const actionKey = readRequiredString(record.actionKey, "primaryReviewAction.actionKey");
  if (actionKey !== "bid_participation.review") {
    throw new Error("Bid participation primaryReviewAction returned unsupported actionKey.");
  }
  const decisions = readRequiredArray(record.availableDecisions, "availableDecisions").map((item) => {
    const decision = readRequiredString(item, "availableDecisions.item");
    if (decision !== "approve" && decision !== "reject") {
      throw new Error("Bid participation primaryReviewAction returned unsupported decision.");
    }
    return decision;
  });
  return {
    actionKey: "bid_participation.review",
    enabled: readRequiredBoolean(record.enabled, "primaryReviewAction.enabled"),
    availableDecisions: decisions,
  };
}

function readReviewStatus(value: unknown): BidParticipationReviewStatus {
  const normalized = readRequiredString(value, "status");
  if (!REVIEW_STATUSES.has(normalized as BidParticipationReviewStatus)) {
    throw new Error("Bid participation response returned unsupported status.");
  }
  return normalized as BidParticipationReviewStatus;
}

function readStringMap(value: unknown) {
  if (value == null) {
    return {};
  }
  const record = requireRecord(value, "params must be an object.");
  const result: Record<string, string> = {};
  for (const [key, rawValue] of Object.entries(record)) {
    result[key] = readRequiredString(rawValue, `params.${key}`);
  }
  return result;
}

function requireRecord(value: unknown, message: string) {
  if (value !== null && typeof value === "object" && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

function readRequiredArray(value: unknown, fieldName: string) {
  if (!Array.isArray(value)) {
    throw new Error(`Bid participation response is missing \`${fieldName}\`.`);
  }
  return value;
}

function readRequiredString(value: unknown, fieldName: string) {
  if (typeof value !== "string") {
    throw new Error(`Bid participation response is missing \`${fieldName}\`.`);
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`Bid participation response field \`${fieldName}\` is empty.`);
  }
  return normalized;
}

function readNullableString(value: unknown) {
  if (value == null) {
    return null;
  }
  if (typeof value !== "string") {
    throw new Error("Bid participation nullable field must be a string.");
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

function readRequiredBoolean(value: unknown, fieldName: string) {
  if (typeof value !== "boolean") {
    throw new Error(`Bid participation response is missing \`${fieldName}\`.`);
  }
  return value;
}
