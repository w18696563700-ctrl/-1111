export type ProjectNameAccessStatus = 'visible' | 'requestable' | 'pending' | 'rejected';

export type ProjectListNameAccessReadModel = {
  status: ProjectNameAccessStatus;
  canRequest: boolean;
};

export type ProjectDetailNameAccessReadModel = ProjectListNameAccessReadModel & {
  requestId: string | null;
};

const PROJECT_NAME_ACCESS_STATUSES = new Set<ProjectNameAccessStatus>([
  'visible',
  'requestable',
  'pending',
  'rejected',
]);

export function readProjectListDisplayState(record: Record<string, unknown>) {
  const displayState = readProjectDisplayState(record, false);
  return {
    displayTitle: displayState.displayTitle,
    nameAccess: displayState.nameAccess as ProjectListNameAccessReadModel,
  };
}

export function readProjectDetailDisplayState(record: Record<string, unknown>) {
  const displayState = readProjectDisplayState(record, true);
  return {
    displayTitle: displayState.displayTitle,
    nameAccess: displayState.nameAccess as ProjectDetailNameAccessReadModel,
  };
}

function readProjectDisplayState(
  record: Record<string, unknown>,
  includeRequestId: boolean,
): {
  displayTitle: string;
  nameAccess: ProjectListNameAccessReadModel | ProjectDetailNameAccessReadModel;
} {
  const rawNameAccess = asOptionalRecord(record.nameAccess);
  if (!rawNameAccess) {
    const legacyTitle = readRequiredString(
      record.title,
      'Project response is missing required title fields.',
    );
    return {
      displayTitle: readOptionalString(record.displayTitle) ?? legacyTitle,
      nameAccess: includeRequestId
        ? {
            status: 'visible',
            canRequest: false,
            requestId: null,
          }
        : {
            status: 'visible',
            canRequest: false,
          },
    };
  }

  const status = readNameAccessStatus(rawNameAccess.status);
  const canRequest = readRequiredBoolean(
    rawNameAccess.canRequest,
    'Project response is missing `nameAccess.canRequest`.',
  );
  const displayTitle =
    status === 'visible'
      ? readOptionalString(record.displayTitle) ?? readOptionalString(record.title)
      : readOptionalString(record.displayTitle);
  if (!displayTitle) {
    throw new Error('Project response is missing `displayTitle`.');
  }

  return {
    displayTitle,
    nameAccess: includeRequestId
      ? {
          status,
          canRequest,
          requestId: readNullableString(rawNameAccess.requestId),
        }
      : {
          status,
          canRequest,
        },
  };
}

function readNameAccessStatus(value: unknown): ProjectNameAccessStatus {
  const normalized = readRequiredString(value, 'Project response is missing `nameAccess.status`.');
  if (!PROJECT_NAME_ACCESS_STATUSES.has(normalized as ProjectNameAccessStatus)) {
    throw new Error('Project response returned an unsupported `nameAccess.status`.');
  }
  return normalized as ProjectNameAccessStatus;
}

function readRequiredBoolean(value: unknown, message: string) {
  if (typeof value === 'boolean') {
    return value;
  }
  throw new Error(message);
}

function asOptionalRecord(value: unknown) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return null;
}

function readRequiredString(value: unknown, message: string) {
  const normalized = readOptionalString(value);
  if (!normalized) {
    throw new Error(message);
  }
  return normalized;
}

function readOptionalString(value: unknown) {
  if (typeof value !== 'string') {
    return undefined;
  }
  const normalized = value.trim();
  return normalized.length > 0 ? normalized : undefined;
}

function readNullableString(value: unknown) {
  if (value == null) {
    return null;
  }
  if (typeof value !== 'string') {
    throw new Error('Project response returned a non-string nullable field.');
  }
  return value;
}
