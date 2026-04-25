export type ProjectCommunicationRealtimeEventReadModel = {
  eventId: string;
  eventType: 'project_communication.message.created';
  messageId: string;
  threadId: string;
  projectId: string;
  senderOrganizationId: string;
  messageKind: string;
  body: string;
  clientMessageId: string | null;
  createdAt: string;
};

export function readProjectCommunicationRealtimeEventListReadModel(value: unknown) {
  const source = readRecord(value, 'Project communication realtime event list must be an object.');
  const items = Array.isArray(source.items) ? source.items : [];
  return {
    items: items.map(readProjectCommunicationRealtimeEventReadModel)
  };
}

export function readProjectCommunicationRealtimeEventReadModel(
  value: unknown
): ProjectCommunicationRealtimeEventReadModel {
  const source = readRecord(value, 'Project communication realtime event must be an object.');
  const eventType = readString(source.eventType, 'eventType');
  if (eventType !== 'project_communication.message.created') {
    throw new FormatError('Project communication realtime eventType is unsupported.');
  }
  return {
    eventId: readString(source.eventId, 'eventId'),
    eventType,
    messageId: readString(source.messageId, 'messageId'),
    threadId: readString(source.threadId, 'threadId'),
    projectId: readString(source.projectId, 'projectId'),
    senderOrganizationId: readString(source.senderOrganizationId, 'senderOrganizationId'),
    messageKind: readString(source.messageKind, 'messageKind'),
    body: readString(source.body, 'body'),
    clientMessageId: readNullableString(source.clientMessageId, 'clientMessageId'),
    createdAt: readString(source.createdAt, 'createdAt')
  };
}

class FormatError extends Error {}

function readRecord(value: unknown, message: string) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw new FormatError(message);
  }
  return value as Record<string, unknown>;
}

function readString(value: unknown, field: string) {
  if (typeof value !== 'string' || !value.trim()) {
    throw new FormatError(`Project communication realtime field \`${field}\` is required.`);
  }
  return value.trim();
}

function readNullableString(value: unknown, field: string) {
  if (value === null || value === undefined) {
    return null;
  }
  if (typeof value !== 'string') {
    throw new FormatError(`Project communication realtime field \`${field}\` must be a string.`);
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}
