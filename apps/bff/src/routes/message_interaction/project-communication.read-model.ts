type Payload = Record<string, unknown>;

export function readProjectCommunicationThreadReadModel(value: unknown) {
  const source = requireRecord(value, 'Project communication thread response is invalid.');
  return {
    threadId: readString(source.threadId, 'threadId'),
    projectId: readString(source.projectId, 'projectId'),
    ownerOrganizationId: readString(source.ownerOrganizationId, 'ownerOrganizationId'),
    counterpartOrganizationId: readString(source.counterpartOrganizationId, 'counterpartOrganizationId'),
    threadState: readString(source.threadState, 'threadState'),
    lastMessageId: readNullableString(source.lastMessageId),
    lastMessageAt: readNullableString(source.lastMessageAt),
    createdAt: readString(source.createdAt, 'createdAt'),
    updatedAt: readString(source.updatedAt, 'updatedAt')
  };
}

export function readProjectCommunicationMessageReadModel(value: unknown) {
  const source = requireRecord(value, 'Project communication message response is invalid.');
  return {
    messageId: readString(source.messageId, 'messageId'),
    threadId: readString(source.threadId, 'threadId'),
    projectId: readString(source.projectId, 'projectId'),
    senderUserId: readString(source.senderUserId, 'senderUserId'),
    senderActorId: readNullableString(source.senderActorId),
    senderOrganizationId: readString(source.senderOrganizationId, 'senderOrganizationId'),
    messageKind: readString(source.messageKind, 'messageKind'),
    body: readBodyString(source.body, 'body'),
    payload: readNullableRecord(source.payload),
    clientMessageId: readNullableString(source.clientMessageId),
    messageState: readString(source.messageState, 'messageState'),
    deliveryState: readDeliveryState(source.deliveryState),
    readState: readReadState(source.readState),
    readByCounterpartAt: readNullableString(source.readByCounterpartAt),
    createdAt: readString(source.createdAt, 'createdAt')
  };
}

export function readProjectCommunicationMessageListReadModel(value: unknown) {
  const source = requireRecord(value, 'Project communication message list response is invalid.');
  return {
    items: readArray(source.items).map((item) =>
      readProjectCommunicationMessageReadModel(item)
    ),
    nextCursor: readNullableString(source.nextCursor)
  };
}

export function readProjectCommunicationReadCursorReadModel(value: unknown) {
  const source = requireRecord(value, 'Project communication read cursor response is invalid.');
  return {
    threadId: readString(source.threadId, 'threadId'),
    projectId: readString(source.projectId, 'projectId'),
    organizationId: readString(source.organizationId, 'organizationId'),
    lastReadMessageId: readNullableString(source.lastReadMessageId),
    lastReadAt: readString(source.lastReadAt, 'lastReadAt'),
    updatedAt: readString(source.updatedAt, 'updatedAt')
  };
}

function requireRecord(value: unknown, message: string) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw new Error(message);
  }
  return value as Payload;
}

function readArray(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }
  return value;
}

function readString(value: unknown, field: string) {
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`Field \`${field}\` is required in project communication response.`);
  }
  return value.trim();
}

function readBodyString(value: unknown, field: string) {
  if (typeof value !== 'string') {
    throw new Error(`Field \`${field}\` is required in project communication response.`);
  }
  return value;
}

function readDeliveryState(value: unknown) {
  if (value == null) {
    return 'persisted';
  }
  const normalized = readString(value, 'deliveryState');
  if (normalized !== 'persisted') {
    throw new Error('Field `deliveryState` is unsupported in project communication response.');
  }
  return normalized;
}

function readReadState(value: unknown) {
  if (value == null) {
    return 'not_applicable';
  }
  const normalized = readString(value, 'readState');
  if (
    normalized !== 'unread_by_counterpart' &&
    normalized !== 'read_by_counterpart' &&
    normalized !== 'not_applicable'
  ) {
    throw new Error('Field `readState` is unsupported in project communication response.');
  }
  return normalized;
}

function readNullableString(value: unknown) {
  if (value === undefined || value === null) {
    return null;
  }
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

function readNullableRecord(value: unknown) {
  if (value === undefined || value === null) {
    return null;
  }
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw new Error('Field `payload` must be an object or null in project communication response.');
  }
  return value as Payload;
}
