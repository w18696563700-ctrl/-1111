export type ProjectNameAccessRequestAcceptedResponse = {
  requestId: string;
  projectId: string;
  status: 'pending';
  threadId: string;
};

export type ProjectNameAccessPendingListReadModel = {
  projectId: string;
  items: ProjectNameAccessPendingItemReadModel[];
};

export type ProjectNameAccessPendingItemReadModel = {
  requestId: string;
  requesterOrganization: Record<string, unknown>;
  requestedAt: string;
  status: ProjectNameAccessReviewStatus;
  threadId: string;
};

export type ProjectNameAccessDecisionResponse = {
  requestId: string;
  projectId: string;
  status: 'approved' | 'rejected';
};

export type ProjectNameAccessThreadDetailReadModel = {
  threadId: string;
  threadType: 'project_name_access_review';
  projectId: string;
  requestId: string;
  requestStatus: ProjectNameAccessReviewStatus;
  displayTitle: string;
  items: ProjectNameAccessThreadItemReadModel[];
  primaryReviewAction: Record<string, unknown> | null;
};

export type ProjectNameAccessThreadItemReadModel = {
  itemId: string;
  itemKind: 'system_seed' | 'system_notice';
  title: string;
  summary: string;
  createdAt: string;
  action: {
    actionKey: 'project_name_access.review' | 'project_name_access.refresh';
    objectType: string | null;
    canonicalPath: string | null;
    label: string | null;
    params: Record<string, string>;
  } | null;
};

type ProjectNameAccessReviewStatus = 'pending' | 'approved' | 'rejected';
type ProjectNameAccessThreadItemActionReadModel = NonNullable<ProjectNameAccessThreadItemReadModel['action']>;

const REVIEW_STATUSES = new Set<ProjectNameAccessReviewStatus>([
  'pending',
  'approved',
  'rejected',
]);
const THREAD_TYPES = new Set(['project_name_access_review']);
const ITEM_KINDS = new Set(['system_seed', 'system_notice']);
const ITEM_ACTION_KEYS = new Set([
  'project_name_access.review',
  'project_name_access.refresh',
]);

export function readProjectNameAccessRequestAcceptedResponse(
  value: unknown,
): ProjectNameAccessRequestAcceptedResponse {
  const record = requireRecord(value, 'Project name access request response must be an object.');
  const status = readRequiredString(record.status, 'status');
  if (status !== 'pending') {
    throw new Error('Project name access request response returned an unsupported status.');
  }
  return {
    requestId: readRequiredString(record.requestId, 'requestId'),
    projectId: readRequiredString(record.projectId, 'projectId'),
    status: 'pending',
    threadId: readRequiredString(record.threadId, 'threadId'),
  };
}

export function readProjectNameAccessPendingListReadModel(
  value: unknown,
): ProjectNameAccessPendingListReadModel {
  const record = requireRecord(value, 'Project name access pending response must be an object.');
  return {
    projectId: readRequiredString(record.projectId, 'projectId'),
    items: readRequiredArray(record.items, 'items').map(readPendingItem),
  };
}

export function readProjectNameAccessDecisionResponse(
  value: unknown,
  expectedStatus: 'approved' | 'rejected',
): ProjectNameAccessDecisionResponse {
  const record = requireRecord(value, 'Project name access review response must be an object.');
  const status = readRequiredString(record.status, 'status');
  if (status !== expectedStatus) {
    throw new Error('Project name access review response returned an unsupported status.');
  }
  return {
    requestId: readRequiredString(record.requestId, 'requestId'),
    projectId: readRequiredString(record.projectId, 'projectId'),
    status: expectedStatus,
  };
}

export function readProjectNameAccessThreadDetailReadModel(
  value: unknown,
): ProjectNameAccessThreadDetailReadModel {
  const record = requireRecord(value, 'Project name access thread response must be an object.');
  const threadType = readRequiredString(record.threadType, 'threadType');
  if (!THREAD_TYPES.has(threadType)) {
    throw new Error('Project name access thread response returned an unsupported threadType.');
  }
  return {
    threadId: readRequiredString(record.threadId, 'threadId'),
    threadType: 'project_name_access_review',
    projectId: readRequiredString(record.projectId, 'projectId'),
    requestId: readRequiredString(record.requestId, 'requestId'),
    requestStatus: readReviewStatus(record.requestStatus),
    displayTitle: readRequiredString(record.displayTitle, 'displayTitle'),
    items: readRequiredArray(record.items, 'items').map(readThreadItem),
    primaryReviewAction: readOptionalRecord(record.primaryReviewAction),
  };
}

function readPendingItem(value: unknown): ProjectNameAccessPendingItemReadModel {
  const record = requireRecord(value, 'Project name access pending item must be an object.');
  return {
    requestId: readRequiredString(record.requestId, 'requestId'),
    requesterOrganization: requireRecord(
      record.requesterOrganization,
      'Project name access pending item is missing `requesterOrganization`.',
    ),
    requestedAt: readRequiredString(record.requestedAt, 'requestedAt'),
    status: readReviewStatus(record.status),
    threadId: readRequiredString(record.threadId, 'threadId'),
  };
}

function readThreadItem(value: unknown): ProjectNameAccessThreadItemReadModel {
  const record = requireRecord(value, 'Project name access thread item must be an object.');
  const itemKind = readRequiredString(record.itemKind, 'itemKind');
  if (!ITEM_KINDS.has(itemKind)) {
    throw new Error('Project name access thread item returned an unsupported itemKind.');
  }
  return {
    itemId: readRequiredString(record.itemId, 'itemId'),
    itemKind: itemKind as ProjectNameAccessThreadItemReadModel['itemKind'],
    title: readRequiredString(record.title, 'title'),
    summary: readRequiredString(record.summary, 'summary'),
    createdAt: readRequiredString(record.createdAt, 'createdAt'),
    action: readThreadItemAction(record.action),
  };
}

function readThreadItemAction(
  value: unknown,
): ProjectNameAccessThreadItemReadModel['action'] {
  if (value == null) {
    return null;
  }
  const record = requireRecord(value, 'Project name access thread item action must be an object.');
  const actionKey = readRequiredString(record.actionKey, 'action.actionKey');
  if (!ITEM_ACTION_KEYS.has(actionKey)) {
    throw new Error('Project name access thread item returned an unsupported actionKey.');
  }
  return {
    actionKey: actionKey as ProjectNameAccessThreadItemActionReadModel['actionKey'],
    objectType: readNullableString(record.objectType),
    canonicalPath: readNullableString(record.canonicalPath),
    label: readNullableString(record.label),
    params: readStringMap(record.params, 'action.params'),
  };
}

function readReviewStatus(value: unknown): ProjectNameAccessReviewStatus {
  const normalized = readRequiredString(value, 'status');
  if (!REVIEW_STATUSES.has(normalized as ProjectNameAccessReviewStatus)) {
    throw new Error('Project name access response returned an unsupported status.');
  }
  return normalized as ProjectNameAccessReviewStatus;
}

function readStringMap(value: unknown, fieldName: string) {
  if (value == null) {
    return {};
  }
  const record = requireRecord(value, `Project name access ${fieldName} must be an object.`);
  const result: Record<string, string> = {};
  for (const [key, rawValue] of Object.entries(record)) {
    result[key] = readRequiredString(rawValue, `${fieldName}.${key}`);
  }
  return result;
}

function readOptionalRecord(value: unknown) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return null;
}

function requireRecord(value: unknown, message: string) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

function readRequiredArray(value: unknown, fieldName: string) {
  if (!Array.isArray(value)) {
    throw new Error(`Project name access response is missing \`${fieldName}\`.`);
  }
  return value;
}

function readRequiredString(value: unknown, fieldName: string) {
  if (typeof value !== 'string') {
    throw new Error(`Project name access response is missing \`${fieldName}\`.`);
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`Project name access response is missing \`${fieldName}\`.`);
  }
  return normalized;
}

function readNullableString(value: unknown) {
  if (value == null) {
    return null;
  }
  if (typeof value !== 'string') {
    throw new Error('Project name access response returned a non-string nullable field.');
  }
  return value;
}
