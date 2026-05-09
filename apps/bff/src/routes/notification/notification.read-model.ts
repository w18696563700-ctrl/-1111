type AppNotificationUnreadProjection = {
  total?: unknown;
  projectCommunication?: unknown;
  businessTodo?: unknown;
  bidParticipationRequest?: unknown;
  forumInteraction?: unknown;
  system?: unknown;
};

const NOTIFICATION_TYPES = new Set([
  'project_communication_message',
  'project_clarification',
  'project_key_reminder',
  'forum_interaction',
  'system_reminder',
  'bid_participation_request'
]);

const NOTIFICATION_SOURCES = new Set([
  'project_communication',
  'forum_interaction',
  'business_todo',
  'system',
  'bid_participation_request'
]);

const ROUTE_TARGET_AVAILABILITY_STATES = new Set([
  'available',
  'unavailable',
  'expired',
  'forbidden',
  'missing_context'
]);

const ROUTE_TARGET_FALLBACK_ACTIONS = new Set(['none', 'open_subject_list']);

type AppNotificationListPayload = {
  items?: unknown;
  page?: unknown;
  unread?: unknown;
};

export function readAppNotificationListReadModel(value: unknown) {
  const root = asRecord(value) as AppNotificationListPayload | null;
  if (!root) {
    return { items: [], page: { nextCursor: null, hasMore: false }, unread: emptyUnread() };
  }
  return {
    items: Array.isArray(root.items) ? root.items.map(readAppNotificationItemReadModel) : [],
    page: readPage(root.page),
    unread: readUnread(root.unread)
  };
}

export function readAppNotificationReadResultReadModel(value: unknown) {
  const root = asRecord(value);
  const ids = Array.isArray(root?.readNotificationIds)
    ? root.readNotificationIds.filter((item): item is string => typeof item === 'string')
    : [];
  return {
    readNotificationIds: ids,
    unread: readUnread(root?.unread)
  };
}

export function readDevicePushTokenRegisterReadModel(value: unknown) {
  const root = asRecord(value);
  return {
    registered: root?.registered === true,
    tokenId: readOptionalString(root?.tokenId),
    platform: readOptionalString(root?.platform),
    provider: readOptionalString(root?.provider)
  };
}

function readAppNotificationItemReadModel(value: unknown) {
  const root = asRecord(value) ?? {};
  const type = readRequiredAllowedString(root.type, NOTIFICATION_TYPES, 'notification.type');
  const source = readRequiredAllowedString(root.source, NOTIFICATION_SOURCES, 'notification.source');
  const routeTarget = readRouteTarget(root.routeTarget);
  const routeTargetAvailability = readRouteTargetAvailability(root.routeTargetAvailability);
  assertBidParticipationRouteTarget(type, source, routeTarget);
  return {
    notificationId: readRequiredString(root.notificationId, 'notification.notificationId'),
    type,
    source,
    title: readRequiredString(root.title, 'notification.title'),
    body: readOptionalString(root.body),
    projectId: readOptionalString(root.projectId),
    threadId: readOptionalString(root.threadId),
    routeTarget,
    routeTargetAvailability,
    createdAt: readOptionalString(root.createdAt),
    readAt: readOptionalString(root.readAt),
    unread: root.unread === true
  };
}

function readPage(value: unknown) {
  const page = asRecord(value);
  return {
    nextCursor: readOptionalString(page?.nextCursor),
    hasMore: page?.hasMore === true
  };
}

function readUnread(value: unknown) {
  const unread = asRecord(value) as AppNotificationUnreadProjection | null;
  return {
    total: readNumber(unread?.total),
    projectCommunication: readNumber(unread?.projectCommunication),
    businessTodo: readNumber(unread?.businessTodo),
    bidParticipationRequest: readNumber(unread?.bidParticipationRequest),
    forumInteraction: readNumber(unread?.forumInteraction),
    system: readNumber(unread?.system)
  };
}

function emptyUnread() {
  return {
    total: 0,
    projectCommunication: 0,
    businessTodo: 0,
    bidParticipationRequest: 0,
    forumInteraction: 0,
    system: 0
  };
}

function readRouteTarget(value: unknown) {
  const routeTarget = asRecord(value);
  return routeTarget && Object.keys(routeTarget).length > 0 ? routeTarget : null;
}

function readRouteTargetAvailability(value: unknown) {
  const root = asRecord(value);
  if (!root) {
    throw new Error('Invalid notification.routeTargetAvailability.');
  }
  const state = readRequiredAllowedString(
    root.state,
    ROUTE_TARGET_AVAILABILITY_STATES,
    'notification.routeTargetAvailability.state'
  );
  const fallbackAction = readRequiredAllowedString(
    root.fallbackAction,
    ROUTE_TARGET_FALLBACK_ACTIONS,
    'notification.routeTargetAvailability.fallbackAction'
  );
  return {
    state,
    reasonCode: readRequiredString(root.reasonCode, 'notification.routeTargetAvailability.reasonCode'),
    reasonText: readRequiredString(root.reasonText, 'notification.routeTargetAvailability.reasonText'),
    fallbackAction,
    fallbackRouteTarget: readRouteTarget(root.fallbackRouteTarget)
  };
}

function assertBidParticipationRouteTarget(
  type: string,
  source: string,
  routeTarget: Record<string, unknown> | null
) {
  if (type !== 'bid_participation_request' && source !== 'bid_participation_request') {
    return;
  }
  const routeParams = asRecord(routeTarget?.routeParams);
  if (
    routeTarget?.canonicalPath !== '/api/app/project/bid-participation/thread/detail' ||
    routeTarget.localEntryKey !== 'bid_participation_request.open' ||
    routeTarget.state !== 'enabled' ||
    typeof routeParams?.threadId !== 'string' ||
    typeof routeParams?.projectId !== 'string' ||
    typeof routeParams?.requestId !== 'string'
  ) {
    throw new Error('Invalid bid participation request notification routeTarget.');
  }
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return value && typeof value === 'object' && !Array.isArray(value) ? (value as Record<string, unknown>) : null;
}

function readOptionalString(value: unknown) {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function readRequiredString(value: unknown, fieldName: string) {
  const normalized = readOptionalString(value);
  if (!normalized) {
    throw new Error(`Invalid ${fieldName}.`);
  }
  return normalized;
}

function readRequiredAllowedString(value: unknown, allowed: Set<string>, fieldName: string) {
  const normalized = readRequiredString(value, fieldName);
  if (!allowed.has(normalized)) {
    throw new Error(`Unsupported ${fieldName}.`);
  }
  return normalized;
}

function readNumber(value: unknown) {
  const parsed = typeof value === 'number' ? value : Number(value ?? 0);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 0;
}
