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
    avatarUrl: string | null;
    role: string;
  };
  summary: {
    focusProjectId: string;
    title: string;
    text: string;
    projectCount: number;
    latestCardType: string;
  };
  p0PaySummary?: Record<string, unknown>;
  updatedAt: string;
  routeTarget: MessageInteractionRouteTarget;
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
  const p0PaySummary = readOptionalP0PaySummary(
    record.p0PaySummary ?? record.paymentStatusSummary,
  );
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
    ...(p0PaySummary ? { p0PaySummary } : {}),
    updatedAt: readRequiredString(record.updatedAt, "updatedAt"),
    routeTarget,
  };
}

function readOptionalP0PaySummary(value: unknown) {
  if (value == null) {
    return undefined;
  }
  const record = requireRecord(
    value,
    "Message interaction p0PaySummary must be an object.",
  );
  const messageDisplaySummary = record.messageDisplaySummary == null
    ? null
    : requireRecord(
        record.messageDisplaySummary,
        "Message interaction p0PaySummary.messageDisplaySummary must be an object.",
      );
  const readOnly = record.readOnly ?? messageDisplaySummary?.readOnly;
  if (readOnly !== true) {
    throw new Error(
      "Message interaction p0PaySummary must be read-only.",
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
    avatarUrl: readNullableString(record.avatarUrl),
    role: readRequiredString(record.role, "counterpart.role"),
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
