export type MessageInteractionRouteTarget = {
  objectType: string;
  actionKey: string;
  canonicalPath: string;
  params: Record<string, unknown>;
};

export type MessageInteractionReadModel = {
  interactionId: string;
  interactionType: string;
  threadId: string;
  projectId: string;
  bidId: string;
  counterpart: {
    organizationId: string;
    displayName: string;
    avatarUrl: string | null;
    role: string;
  };
  seedSummary: {
    seedType: string;
    title: string;
    summary: string;
    ctaLabel: string;
  };
  lastMessageSummary: {
    text: string;
    messageKind: string;
    createdAt: string | null;
  } | null;
  updatedAt: string;
  routeTarget: MessageInteractionRouteTarget;
};

export type MessageInteractionListReadModel = {
  lane: string;
  items: MessageInteractionReadModel[];
};

const INTERACTION_LANES = new Set(['project_communication']);
const ROUTE_ACTION_KEYS = new Set(['bid_thread.open']);
const SEED_TYPES = new Set(['bid_submitted']);

export function readMessageInteractionListReadModel(value: unknown): MessageInteractionListReadModel {
  const record = requireRecord(value, 'Message interactions response must be an object.');
  const lane = readRequiredString(record.lane, 'lane');
  if (!INTERACTION_LANES.has(lane)) {
    throw new Error('Message interactions response returned an unsupported lane.');
  }
  const items = readRequiredArray(record.items, 'items').map(readMessageInteractionItem);
  return { lane, items };
}

function readMessageInteractionItem(value: unknown): MessageInteractionReadModel {
  const record = requireRecord(value, 'Message interaction item must be an object.');
  return {
    interactionId: readRequiredString(record.interactionId, 'interactionId'),
    interactionType: readRequiredString(record.interactionType, 'interactionType'),
    threadId: readRequiredString(record.threadId, 'threadId'),
    projectId: readRequiredString(record.projectId, 'projectId'),
    bidId: readRequiredString(record.bidId, 'bidId'),
    counterpart: readCounterpart(record.counterpart),
    seedSummary: readSeedSummary(record.seedSummary),
    lastMessageSummary: readLastMessageSummary(record.lastMessageSummary),
    updatedAt: readRequiredString(record.updatedAt, 'updatedAt'),
    routeTarget: readRouteTarget(record.routeTarget),
  };
}

function readCounterpart(value: unknown) {
  const record = requireRecord(value, 'Message interaction counterpart must be an object.');
  return {
    organizationId: readRequiredString(record.organizationId, 'counterpart.organizationId'),
    displayName: readRequiredString(record.displayName, 'counterpart.displayName'),
    avatarUrl: readNullableString(record.avatarUrl),
    role: readRequiredString(record.role, 'counterpart.role'),
  };
}

function readSeedSummary(value: unknown) {
  const record = requireRecord(value, 'Message interaction seedSummary must be an object.');
  const seedType = readRequiredString(record.seedType, 'seedSummary.seedType');
  if (!SEED_TYPES.has(seedType)) {
    throw new Error('Message interaction item returned an unsupported seedSummary.seedType.');
  }
  return {
    seedType,
    title: readRequiredString(record.title, 'seedSummary.title'),
    summary: readRequiredString(record.summary, 'seedSummary.summary'),
    ctaLabel: readRequiredString(record.ctaLabel, 'seedSummary.ctaLabel'),
  };
}

function readLastMessageSummary(value: unknown) {
  if (value == null) {
    return null;
  }
  const record = requireRecord(value, 'Message interaction lastMessageSummary must be an object.');
  return {
    text: readRequiredString(record.text, 'lastMessageSummary.text'),
    messageKind: readRequiredString(record.messageKind, 'lastMessageSummary.messageKind'),
    createdAt: readNullableString(record.createdAt),
  };
}

function readRouteTarget(value: unknown): MessageInteractionRouteTarget {
  const record = requireRecord(value, 'Message interaction routeTarget must be an object.');
  const actionKey = readRequiredString(record.actionKey, 'routeTarget.actionKey');
  if (!ROUTE_ACTION_KEYS.has(actionKey)) {
    throw new Error('Message interaction item returned an unsupported routeTarget.actionKey.');
  }
  const params = requireStringMap(record.params, 'routeTarget.params');
  return {
    objectType: readRequiredString(record.objectType, 'routeTarget.objectType'),
    actionKey,
    canonicalPath: readRequiredString(record.canonicalPath, 'routeTarget.canonicalPath'),
    params,
  };
}

function requireStringMap(value: unknown, fieldName: string) {
  const record = requireRecord(value, `Message interaction ${fieldName} must be an object.`);
  const result: Record<string, unknown> = {};
  for (const [key, rawValue] of Object.entries(record)) {
    result[key] = readRequiredString(rawValue, `${fieldName}.${key}`);
  }
  return result;
}

function requireRecord(value: unknown, message: string) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

function readRequiredArray(value: unknown, fieldName: string) {
  if (!Array.isArray(value)) {
    throw new Error(`Message interactions response is missing \`${fieldName}\`.`);
  }
  return value;
}

function readRequiredString(value: unknown, fieldName: string) {
  if (typeof value !== 'string') {
    throw new Error(`Message interactions response is missing \`${fieldName}\`.`);
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`Message interactions response is missing \`${fieldName}\`.`);
  }
  return normalized;
}

function readNullableString(value: unknown) {
  if (value == null) {
    return null;
  }
  if (typeof value !== 'string') {
    throw new Error('Message interactions response returned a non-string nullable field.');
  }
  return value;
}
