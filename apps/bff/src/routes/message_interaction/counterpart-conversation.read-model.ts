import type { MessageInteractionRouteTarget } from "./message-interaction.read-model";

export type CounterpartConversationDetailReadModel = {
  conversationId: string;
  counterpart: {
    organizationId: string;
    displayName: string;
    nickname: string | null;
    companyName: string;
    avatarUrl: string | null;
    role: string;
    certificationSummary: CounterpartCertificationSummary | null;
  };
  summary: {
    focusProjectId: string;
    title: string;
    text: string;
    projectCount: number;
    latestCardType: string;
  };
  focusProjectId: string;
  latestActivityAt: string;
  projectGroups: Array<{
    projectId: string;
    projectDisplayTitle: string;
    titleVisibility: "masked" | "visible";
    projectRelation: "my_published" | "my_bid" | "unknown";
    projectState: string | null;
    latestActivityAt: string;
    pricingSummary?: Record<string, unknown>;
    orderSummary: {
      orderId: string;
      projectId: string | null;
      buyerOrganizationId: string | null;
      sellerOrganizationId: string | null;
      state: string | null;
      completionRequestState: string | null;
    } | null;
    ratingEntry: {
      orderId: string;
      projectId: string;
      rateeOrganizationId: string;
      canRate: boolean;
      reason: string | null;
      ratingState: string | null;
    } | null;
    cards: Array<{
      cardId: string;
      cardType: string;
      title: string;
      summary: string;
      status: string | null;
      updatedAt: string;
      truthAnchor: {
        truthType: string;
        projectId: string;
        requestId?: string;
        orderId?: string;
        bidId?: string;
        threadId?: string;
        clarificationId?: string;
        noticeId?: string;
      };
      detailRouteTarget: MessageInteractionRouteTarget | null;
      decisionAvailability: {
        canApprove: boolean;
        canReject: boolean;
      } | null;
    }>;
  }>;
};

type CounterpartCertificationSummary = {
  certificationStatus: string;
  legalName: string;
  usccMasked: string | null;
  businessType: string | null;
  address: string | null;
  establishedAt: string | null;
  reviewedAt: string | null;
};

const TITLE_VISIBILITY = new Set(["masked", "visible"]);
const PROJECT_RELATIONS = new Set(["my_published", "my_bid", "unknown"]);
const CARD_TYPES = new Set([
  "project_name_access_request",
  "bid_participation_request",
  "bid_thread",
  "project_clarification",
  "project_order",
  "system_notice",
]);
const TRUTH_TYPES = new Set([
  "project_name_access_request",
  "bid_participation_request",
  "bid_thread",
  "project_clarification",
  "project_order",
  "project_notice_event",
]);
const DETAIL_ACTION_KEYS = new Set([
  "project_name_access_thread.open",
  "bid_participation_request.open",
  "bid_service_fee_authorization.open",
  "bid_submit.open",
  "bid_thread.open",
  "project_clarification.open",
  "order_detail.open",
]);

export function readCounterpartConversationDetailReadModel(
  value: unknown,
): CounterpartConversationDetailReadModel {
  const record = requireRecord(
    value,
    "Counterpart conversation detail response must be an object.",
  );
  return {
    conversationId: readRequiredString(record.conversationId, "conversationId"),
    counterpart: readCounterpart(record.counterpart),
    summary: readSummary(record.summary),
    focusProjectId: readRequiredString(record.focusProjectId, "focusProjectId"),
    latestActivityAt: readRequiredString(
      record.latestActivityAt,
      "latestActivityAt",
    ),
    projectGroups: readRequiredArray(record.projectGroups, "projectGroups").map(
      readProjectGroup,
    ),
  };
}

function readProjectGroup(value: unknown) {
  const record = requireRecord(
    value,
    "Counterpart conversation project group must be an object.",
  );
  const titleVisibility = readRequiredString(
    record.titleVisibility,
    "projectGroup.titleVisibility",
  );
  if (!TITLE_VISIBILITY.has(titleVisibility)) {
    throw new Error(
      "Counterpart conversation project group returned an unsupported titleVisibility.",
    );
  }
  const projectId = readRequiredString(
    record.projectId,
    "projectGroup.projectId",
  );
  const latestActivityAt = readRequiredString(
    record.latestActivityAt,
    "projectGroup.latestActivityAt",
  );
  const orderSummary = readOrderSummary(
    record.orderSummary ??
      record.order ??
      (record.orderId == null ? null : record),
    projectId,
  );
  const cards = readRequiredArray(record.cards, "projectGroup.cards").map(
    readCard,
  ).filter((card) => card.cardType !== "project_name_access_request");
  const pricingSummary = readOptionalPricingSummary(record.pricingSummary);
  return {
    projectId,
    projectDisplayTitle: readRequiredString(
      record.projectDisplayTitle,
      "projectGroup.projectDisplayTitle",
    ),
    titleVisibility: titleVisibility as "masked" | "visible",
    projectRelation: readProjectRelation(record.projectRelation),
    projectState: readNullableString(record.projectState),
    latestActivityAt,
    ...(pricingSummary ? { pricingSummary } : {}),
    orderSummary,
    ratingEntry: readRatingEntry(record.ratingEntry),
    cards: withOrderBusinessCard(cards, orderSummary, latestActivityAt),
  };
}

function readOrderSummary(value: unknown, groupProjectId: string) {
  if (value == null) {
    return null;
  }
  const record = requireRecord(
    value,
    "Counterpart conversation orderSummary must be an object.",
  );
  const projectId = readNullableString(record.projectId);
  if (projectId != null && projectId !== groupProjectId) {
    throw new Error(
      "Counterpart conversation orderSummary.projectId must match projectGroup.projectId.",
    );
  }
  return {
    orderId: readRequiredString(record.orderId, "orderSummary.orderId"),
    projectId: projectId ?? groupProjectId,
    buyerOrganizationId: readNullableString(record.buyerOrganizationId),
    sellerOrganizationId:
      readNullableString(record.sellerOrganizationId) ??
      readNullableString(record.supplierOrganizationId),
    state: readNullableString(record.state),
    completionRequestState: readNullableString(record.completionRequestState),
  };
}

function withOrderBusinessCard(
  cards: ReturnType<typeof readCard>[],
  orderSummary: ReturnType<typeof readOrderSummary>,
  updatedAt: string,
) {
  if (
    orderSummary == null ||
    cards.some((card) => card.cardType === "project_order")
  ) {
    return cards;
  }
  const projectId = orderSummary.projectId;
  if (projectId == null) {
    return cards;
  }
  const status = orderSummary.completionRequestState ?? orderSummary.state;
  return [
    ...cards,
    {
      cardId: `project-order:${orderSummary.orderId}`,
      cardType: "project_order",
      title: "订单状态",
      summary: "当前项目已生成订单，点击查看订单详情与完工动作。",
      status,
      updatedAt,
      truthAnchor: {
        truthType: "project_order",
        projectId,
        orderId: orderSummary.orderId,
        requestId: undefined,
        bidId: undefined,
        threadId: undefined,
        clarificationId: undefined,
        noticeId: undefined,
      },
      detailRouteTarget: {
        objectType: "order",
        actionKey: "order_detail.open",
        canonicalPath: "/api/app/order/detail",
        params: {
          projectId,
          orderId: orderSummary.orderId,
        },
      },
      decisionAvailability: null,
    },
  ];
}

function readRatingEntry(value: unknown) {
  if (value == null) {
    return null;
  }
  const record = requireRecord(
    value,
    "Counterpart conversation ratingEntry must be an object.",
  );
  return {
    orderId: readRequiredString(record.orderId, "ratingEntry.orderId"),
    projectId: readRequiredString(record.projectId, "ratingEntry.projectId"),
    rateeOrganizationId: readRequiredString(
      record.rateeOrganizationId,
      "ratingEntry.rateeOrganizationId",
    ),
    canRate: readRequiredBoolean(record.canRate, "ratingEntry.canRate"),
    reason: readNullableString(record.reason),
    ratingState: readNullableString(record.ratingState),
  };
}

function readCard(value: unknown) {
  const record = requireRecord(
    value,
    "Counterpart conversation business card must be an object.",
  );
  const cardType = readRequiredString(record.cardType, "card.cardType");
  if (!CARD_TYPES.has(cardType)) {
    throw new Error(
      "Counterpart conversation business card returned an unsupported cardType.",
    );
  }
  const truthAnchor = readTruthAnchor(record.truthAnchor);
  const detailRouteTarget = normalizePricingGateRouteTarget({
    cardType,
    status: readNullableString(record.status),
    truthAnchor,
    detailRouteTarget: readDetailRouteTarget(record.detailRouteTarget),
    pricingGateRequired: record.pricingGateRequired,
  });
  validateBusinessCardTruth({
    cardType,
    truthAnchor,
    detailRouteTarget,
  });
  return {
    cardId: readRequiredString(record.cardId, "card.cardId"),
    cardType,
    title: readRequiredString(record.title, "card.title"),
    summary: readRequiredString(record.summary, "card.summary"),
    status: readNullableString(record.status),
    updatedAt: readRequiredString(record.updatedAt, "card.updatedAt"),
    truthAnchor,
    detailRouteTarget,
    decisionAvailability: readDecisionAvailability(record.decisionAvailability),
  };
}

function readOptionalPricingSummary(value: unknown) {
  if (value == null) {
    return undefined;
  }
  const record = requireRecord(
    value,
    "Counterpart conversation pricingSummary must be an object.",
  );
  const messageDisplaySummary = record.messageDisplaySummary == null
    ? null
    : requireRecord(
        record.messageDisplaySummary,
        "Counterpart conversation pricingSummary.messageDisplaySummary must be an object.",
      );
  const readOnly = record.readOnly ?? messageDisplaySummary?.readOnly;
  if (readOnly !== true) {
    throw new Error("Counterpart conversation pricingSummary must be read-only.");
  }
  return record;
}

function normalizePricingGateRouteTarget(input: {
  cardType: string;
  status: string | null;
  truthAnchor: ReturnType<typeof readTruthAnchor>;
  detailRouteTarget: MessageInteractionRouteTarget | null;
  pricingGateRequired: unknown;
}) {
  const shouldGate =
    input.cardType === "bid_participation_request" &&
    input.status === "approved" &&
    input.detailRouteTarget?.actionKey === "bid_submit.open" &&
    input.pricingGateRequired !== false;
  if (!shouldGate) {
    return input.detailRouteTarget;
  }
  const requestId = input.truthAnchor.requestId;
  if (!requestId) {
    throw new Error(
      "Counterpart conversation bid participation pricing gate requires requestId.",
    );
  }
  return {
    objectType: "bid_service_fee_authorization",
    actionKey: "bid_service_fee_authorization.open",
    canonicalPath: `/api/app/project/${input.truthAnchor.projectId}/bid-service-fee-authorizations`,
    params: {
      projectId: input.truthAnchor.projectId,
      bidParticipationRequestId: requestId,
    },
  };
}

function readTruthAnchor(value: unknown) {
  const record = requireRecord(
    value,
    "Counterpart conversation truthAnchor must be an object.",
  );
  const truthType = readRequiredString(
    record.truthType,
    "truthAnchor.truthType",
  );
  if (!TRUTH_TYPES.has(truthType)) {
    throw new Error(
      "Counterpart conversation truthAnchor returned an unsupported truthType.",
    );
  }
  return {
    truthType,
    projectId: readRequiredString(record.projectId, "truthAnchor.projectId"),
    requestId: readOptionalString(record.requestId),
    orderId: readOptionalString(record.orderId),
    bidId: readOptionalString(record.bidId),
    threadId: readOptionalString(record.threadId),
    clarificationId: readOptionalString(record.clarificationId),
    noticeId: readOptionalString(record.noticeId),
  };
}

function readDetailRouteTarget(value: unknown) {
  if (value == null) {
    return null;
  }
  const record = requireRecord(
    value,
    "Counterpart conversation detailRouteTarget must be an object.",
  );
  const actionKey = readRequiredString(
    record.actionKey,
    "detailRouteTarget.actionKey",
  );
  if (!DETAIL_ACTION_KEYS.has(actionKey)) {
    throw new Error(
      "Counterpart conversation detailRouteTarget returned an unsupported actionKey.",
    );
  }
  const objectType = readRequiredString(
    record.objectType,
    "detailRouteTarget.objectType",
  );
  const canonicalPath = readRequiredString(
    record.canonicalPath,
    "detailRouteTarget.canonicalPath",
  );
  const params = requireStringMap(record.params, "detailRouteTarget.params");
  validateDetailRouteTarget({ objectType, actionKey, canonicalPath, params });
  return {
    objectType,
    actionKey,
    canonicalPath,
    params,
  };
}

function validateDetailRouteTarget(input: {
  objectType: string;
  actionKey: string;
  canonicalPath: string;
  params: Record<string, unknown>;
}) {
  if (input.actionKey !== "order_detail.open") {
    return;
  }
  if (
    input.objectType !== "order" ||
    input.canonicalPath !== "/api/app/order/detail" ||
    typeof input.params.projectId !== "string" ||
    typeof input.params.orderId !== "string"
  ) {
    throw new Error(
      "Counterpart conversation order detailRouteTarget must include order object, canonical path, projectId, and orderId.",
    );
  }
}

function validateBusinessCardTruth(input: {
  cardType: string;
  truthAnchor: ReturnType<typeof readTruthAnchor>;
  detailRouteTarget: MessageInteractionRouteTarget | null;
}) {
  if (
    input.cardType !== "project_order" &&
    input.truthAnchor.truthType !== "project_order"
  ) {
    return;
  }
  if (
    input.cardType !== "project_order" ||
    input.truthAnchor.truthType !== "project_order"
  ) {
    throw new Error(
      "Counterpart conversation ProjectOrder card must use matching project_order cardType and truthType.",
    );
  }
  const orderId = input.truthAnchor.orderId;
  const target = input.detailRouteTarget;
  if (
    !orderId ||
    target == null ||
    target.actionKey !== "order_detail.open" ||
    target.params.projectId !== input.truthAnchor.projectId ||
    target.params.orderId !== orderId
  ) {
    throw new Error(
      "Counterpart conversation ProjectOrder card must carry matching projectId and orderId.",
    );
  }
}

function readDecisionAvailability(value: unknown) {
  if (value == null) {
    return null;
  }
  const record = requireRecord(
    value,
    "Counterpart conversation decisionAvailability must be an object.",
  );
  return {
    canApprove: readRequiredBoolean(
      record.canApprove,
      "decisionAvailability.canApprove",
    ),
    canReject: readRequiredBoolean(
      record.canReject,
      "decisionAvailability.canReject",
    ),
  };
}

function readCounterpart(value: unknown) {
  const record = requireRecord(
    value,
    "Counterpart conversation counterpart must be an object.",
  );
  return {
    organizationId: readRequiredString(
      record.organizationId,
      "counterpart.organizationId",
    ),
    displayName: readRequiredString(
      record.displayName,
      "counterpart.displayName",
    ),
    nickname: readNullableString(record.nickname),
    companyName:
      readNullableString(record.companyName) ??
      readRequiredString(record.displayName, "counterpart.displayName"),
    avatarUrl: readNullableString(record.avatarUrl),
    role: readRequiredString(record.role, "counterpart.role"),
    certificationSummary: readCertificationSummary(record.certificationSummary),
  };
}

function readProjectRelation(value: unknown) {
  const relation = readNullableString(value) ?? "unknown";
  if (!PROJECT_RELATIONS.has(relation)) {
    throw new Error(
      "Counterpart conversation project group returned an unsupported projectRelation.",
    );
  }
  return relation as "my_published" | "my_bid" | "unknown";
}

function readCertificationSummary(value: unknown): CounterpartCertificationSummary | null {
  if (value == null) {
    return null;
  }
  const record = requireRecord(
    value,
    "Counterpart conversation counterpart.certificationSummary must be an object.",
  );
  return {
    certificationStatus: readRequiredString(
      record.certificationStatus,
      "counterpart.certificationSummary.certificationStatus",
    ),
    legalName: readRequiredString(
      record.legalName,
      "counterpart.certificationSummary.legalName",
    ),
    usccMasked: readNullableString(record.usccMasked),
    businessType: readNullableString(record.businessType),
    address: readNullableString(record.address),
    establishedAt: readNullableString(record.establishedAt),
    reviewedAt: readNullableString(record.reviewedAt),
  };
}

function readSummary(value: unknown) {
  const record = requireRecord(
    value,
    "Counterpart conversation summary must be an object.",
  );
  const latestCardType = readRequiredString(
    record.latestCardType,
    "summary.latestCardType",
  );
  if (!CARD_TYPES.has(latestCardType)) {
    throw new Error(
      "Counterpart conversation summary returned an unsupported latestCardType.",
    );
  }
  return {
    focusProjectId: readRequiredString(
      record.focusProjectId,
      "summary.focusProjectId",
    ),
    title: readRequiredString(record.title, "summary.title"),
    text: readRequiredString(record.text, "summary.text"),
    projectCount: readRequiredNumber(
      record.projectCount,
      "summary.projectCount",
    ),
    latestCardType,
  };
}

function requireStringMap(value: unknown, fieldName: string) {
  const record = requireRecord(
    value,
    `Counterpart conversation ${fieldName} must be an object.`,
  );
  const result: Record<string, unknown> = {};
  for (const [key, rawValue] of Object.entries(record)) {
    result[key] = readRequiredString(rawValue, `${fieldName}.${key}`);
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
    throw new Error(
      `Counterpart conversation response is missing \`${fieldName}\`.`,
    );
  }
  return value;
}

function readRequiredString(value: unknown, fieldName: string) {
  if (typeof value !== "string") {
    throw new Error(
      `Counterpart conversation response is missing \`${fieldName}\`.`,
    );
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(
      `Counterpart conversation response is missing \`${fieldName}\`.`,
    );
  }
  return normalized;
}

function readRequiredNumber(value: unknown, fieldName: string) {
  if (typeof value !== "number" || Number.isNaN(value)) {
    throw new Error(
      `Counterpart conversation response is missing \`${fieldName}\`.`,
    );
  }
  return value;
}

function readRequiredBoolean(value: unknown, fieldName: string) {
  if (typeof value !== "boolean") {
    throw new Error(
      `Counterpart conversation response is missing \`${fieldName}\`.`,
    );
  }
  return value;
}

function readNullableString(value: unknown) {
  if (value == null) {
    return null;
  }
  if (typeof value !== "string") {
    throw new Error(
      "Counterpart conversation response returned a non-string nullable field.",
    );
  }
  return value;
}

function readOptionalString(value: unknown) {
  if (value == null) {
    return undefined;
  }
  return readRequiredString(value, "optional-field");
}
