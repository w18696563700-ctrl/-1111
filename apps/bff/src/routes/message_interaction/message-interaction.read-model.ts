export type MessageInteractionRouteTarget = {
  objectType: string;
  actionKey: string;
  canonicalPath: string;
  params: Record<string, unknown>;
};

export type MessageInteractionReadModel = {
  interactionId: string;
  interactionType: "counterpart_conversation";
  conversationId: string;
  projectId: string;
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
  pricingSummary?: Record<string, unknown>;
  updatedAt: string;
  conversationUnreadCount: number;
  hasUnread: boolean;
  latestUnreadMessageAt: string | null;
  routeTarget: MessageInteractionRouteTarget;
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

export type MessageInteractionListReadModel = {
  lane: string;
  items: MessageInteractionReadModel[];
};

const INTERACTION_LANES = new Set(["project_communication"]);
const INTERACTION_TYPES = new Set(["counterpart_conversation"]);
const ROUTE_ACTION_KEYS = new Set(["counterpart_conversation.open"]);
const CARD_TYPES = new Set([
  "project_name_access_request",
  "bid_participation_request",
  "bid_thread",
  "project_clarification",
  "project_order",
  "system_notice",
]);

export function readMessageInteractionListReadModel(
  value: unknown,
): MessageInteractionListReadModel {
  const record = requireRecord(
    value,
    "Message interactions response must be an object.",
  );
  const lane = readRequiredString(record.lane, "lane");
  if (!INTERACTION_LANES.has(lane)) {
    throw new Error(
      "Message interactions response returned an unsupported lane.",
    );
  }
  const items = readRequiredArray(record.items, "items").map(
    readMessageInteractionItem,
  );
  return { lane, items };
}

function readMessageInteractionItem(
  value: unknown,
): MessageInteractionReadModel {
  const record = requireRecord(
    value,
    "Message interaction item must be an object.",
  );
  const interactionType = readRequiredString(
    record.interactionType,
    "interactionType",
  );
  if (!INTERACTION_TYPES.has(interactionType)) {
    throw new Error(
      "Message interaction item returned an unsupported interactionType.",
    );
  }
  const routeTarget = readRouteTarget(record.routeTarget);
  const summary = readSummary(record.summary);
  const pricingSummary = readOptionalPricingSummary(record.pricingSummary);
  if (routeTarget.actionKey !== "counterpart_conversation.open") {
    throw new Error(
      "Message interaction counterpart_conversation item returned an unsupported routeTarget.actionKey.",
    );
  }

  return {
    interactionId: readRequiredString(record.interactionId, "interactionId"),
    interactionType: "counterpart_conversation",
    conversationId: readRequiredString(record.conversationId, "conversationId"),
    projectId: readRequiredString(record.projectId, "projectId"),
    counterpart: readCounterpart(record.counterpart),
    summary,
    ...(pricingSummary ? { pricingSummary } : {}),
    updatedAt: readRequiredString(record.updatedAt, "updatedAt"),
    conversationUnreadCount: readOptionalNonNegativeNumber(
      record.conversationUnreadCount,
      "conversationUnreadCount",
      0,
    ),
    hasUnread: readOptionalBoolean(record.hasUnread, false),
    latestUnreadMessageAt: readNullableString(record.latestUnreadMessageAt),
    routeTarget,
  };
}

function readOptionalPricingSummary(value: unknown) {
  if (value == null) {
    return undefined;
  }
  const record = requireRecord(
    value,
    "Message interaction pricingSummary must be an object.",
  );
  const messageDisplaySummary = record.messageDisplaySummary == null
    ? null
    : requireRecord(
        record.messageDisplaySummary,
        "Message interaction pricingSummary.messageDisplaySummary must be an object.",
      );
  const readOnly = record.readOnly ?? messageDisplaySummary?.readOnly;
  if (readOnly !== true) {
    throw new Error(
      "Message interaction pricingSummary must be read-only.",
    );
  }
  return record;
}

function readCounterpart(value: unknown) {
  const record = requireRecord(
    value,
    "Message interaction counterpart must be an object.",
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

function readCertificationSummary(value: unknown): CounterpartCertificationSummary | null {
  if (value == null) {
    return null;
  }
  const record = requireRecord(
    value,
    "Message interaction counterpart.certificationSummary must be an object.",
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
    "Message interaction summary must be an object.",
  );
  const latestCardType = readRequiredString(
    record.latestCardType,
    "summary.latestCardType",
  );
  if (!CARD_TYPES.has(latestCardType)) {
    throw new Error(
      "Message interaction item returned an unsupported summary.latestCardType.",
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

function readRouteTarget(value: unknown): MessageInteractionRouteTarget {
  const record = requireRecord(
    value,
    "Message interaction routeTarget must be an object.",
  );
  const actionKey = readRequiredString(
    record.actionKey,
    "routeTarget.actionKey",
  );
  if (!ROUTE_ACTION_KEYS.has(actionKey)) {
    throw new Error(
      "Message interaction item returned an unsupported routeTarget.actionKey.",
    );
  }
  const params = requireStringMap(record.params, "routeTarget.params");
  if (
    typeof params.conversationId !== "string" ||
    typeof params.projectId !== "string"
  ) {
    throw new Error(
      "Message interaction counterpart_conversation routeTarget.params must include conversationId and projectId.",
    );
  }
  return {
    objectType: readRequiredString(record.objectType, "routeTarget.objectType"),
    actionKey,
    canonicalPath: readRequiredString(
      record.canonicalPath,
      "routeTarget.canonicalPath",
    ),
    params,
  };
}

function requireStringMap(value: unknown, fieldName: string) {
  const record = requireRecord(
    value,
    `Message interaction ${fieldName} must be an object.`,
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
      `Message interactions response is missing \`${fieldName}\`.`,
    );
  }
  return value;
}

function readRequiredString(value: unknown, fieldName: string) {
  if (typeof value !== "string") {
    throw new Error(
      `Message interactions response is missing \`${fieldName}\`.`,
    );
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(
      `Message interactions response is missing \`${fieldName}\`.`,
    );
  }
  return normalized;
}

function readRequiredNumber(value: unknown, fieldName: string) {
  if (typeof value !== "number" || Number.isNaN(value)) {
    throw new Error(
      `Message interactions response is missing \`${fieldName}\`.`,
    );
  }
  return value;
}

function readOptionalNonNegativeNumber(
  value: unknown,
  fieldName: string,
  fallback: number,
) {
  if (value == null) {
    return fallback;
  }
  const parsed = readRequiredNumber(value, fieldName);
  if (parsed < 0) {
    throw new Error(
      `Message interactions response returned a negative \`${fieldName}\`.`,
    );
  }
  return parsed;
}

function readOptionalBoolean(value: unknown, fallback: boolean) {
  if (value == null) {
    return fallback;
  }
  if (typeof value !== "boolean") {
    throw new Error(
      "Message interactions response returned a non-boolean optional field.",
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
      "Message interactions response returned a non-string nullable field.",
    );
  }
  return value;
}
