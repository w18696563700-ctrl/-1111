type AppNotificationUnreadProjection = {
  total?: unknown;
  projectCommunication?: unknown;
  forumInteraction?: unknown;
  system?: unknown;
};

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
  return {
    notificationId: readOptionalString(root.notificationId) ?? '',
    type: readOptionalString(root.type) ?? 'system_notice',
    source: readOptionalString(root.source) ?? 'system',
    title: readOptionalString(root.title) ?? '',
    body: readOptionalString(root.body),
    projectId: readOptionalString(root.projectId),
    threadId: readOptionalString(root.threadId),
    routeTarget: readRouteTarget(root.routeTarget),
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
    forumInteraction: readNumber(unread?.forumInteraction),
    system: readNumber(unread?.system)
  };
}

function emptyUnread() {
  return { total: 0, projectCommunication: 0, forumInteraction: 0, system: 0 };
}

function readRouteTarget(value: unknown) {
  const routeTarget = asRecord(value);
  return routeTarget && Object.keys(routeTarget).length > 0 ? routeTarget : null;
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return value && typeof value === 'object' && !Array.isArray(value) ? (value as Record<string, unknown>) : null;
}

function readOptionalString(value: unknown) {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function readNumber(value: unknown) {
  const parsed = typeof value === 'number' ? value : Number(value ?? 0);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 0;
}
