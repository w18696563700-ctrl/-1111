type CounterpartyRatingEntry = {
  orderId: string;
  projectId: string;
  raterOrganizationId: string;
  rateeOrganizationId: string;
  canRate: boolean;
  reason: string | null;
  ratingState: string | null;
};

type CounterpartyRatingSubmitAccepted = {
  ratingId: string;
  orderId: string;
  projectId: string;
  raterOrganizationId: string;
  rateeOrganizationId: string;
  state: string;
  ratingState: string;
  scoreValue: number;
  scoreLabel: string;
  submittedAt: string;
};

export function readProjectCounterpartyRatingEntry(value: unknown): CounterpartyRatingEntry {
  const record = readRecord(value, 'Project counterparty rating entry must be an object.');
  return {
    orderId: readRequiredString(record.orderId, 'orderId'),
    projectId: readRequiredString(record.projectId, 'projectId'),
    raterOrganizationId: readRequiredString(record.raterOrganizationId, 'raterOrganizationId'),
    rateeOrganizationId: readRequiredString(record.rateeOrganizationId, 'rateeOrganizationId'),
    canRate: readRequiredBoolean(record.canRate, 'canRate'),
    reason: readNullableString(record.reason, 'reason'),
    ratingState: readNullableString(record.ratingState, 'ratingState')
  };
}

export function readProjectCounterpartyRatingSubmitAccepted(value: unknown): CounterpartyRatingSubmitAccepted {
  const record = readRecord(value, 'Project counterparty rating submit response must be an object.');
  return {
    ratingId: readRequiredString(record.ratingId, 'ratingId'),
    orderId: readRequiredString(record.orderId, 'orderId'),
    projectId: readRequiredString(record.projectId, 'projectId'),
    raterOrganizationId: readRequiredString(record.raterOrganizationId, 'raterOrganizationId'),
    rateeOrganizationId: readRequiredString(record.rateeOrganizationId, 'rateeOrganizationId'),
    state: readRequiredString(record.state, 'state'),
    ratingState: readRequiredString(record.ratingState, 'ratingState'),
    scoreValue: readRequiredNumber(record.scoreValue, 'scoreValue'),
    scoreLabel: readRequiredString(record.scoreLabel, 'scoreLabel'),
    submittedAt: readRequiredString(record.submittedAt, 'submittedAt')
  };
}

function readRecord(value: unknown, message: string) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error(message);
  }
  return value as Record<string, unknown>;
}

function readRequiredString(value: unknown, field: string) {
  if (typeof value !== 'string') {
    throw new Error(`Project counterparty rating response missing ${field}.`);
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`Project counterparty rating response missing ${field}.`);
  }
  return normalized;
}

function readNullableString(value: unknown, field: string) {
  if (value === undefined || value === null) {
    return null;
  }
  if (typeof value !== 'string') {
    throw new Error(`Project counterparty rating response field ${field} must be a string when provided.`);
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

function readRequiredBoolean(value: unknown, field: string) {
  if (typeof value !== 'boolean') {
    throw new Error(`Project counterparty rating response missing ${field}.`);
  }
  return value;
}

function readRequiredNumber(value: unknown, field: string) {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    throw new Error(`Project counterparty rating response missing ${field}.`);
  }
  return value;
}
