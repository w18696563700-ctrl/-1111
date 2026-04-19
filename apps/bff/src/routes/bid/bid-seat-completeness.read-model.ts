export type BidSeatState = 'available' | 'locked' | 'released' | 'timed_out';
export type BidPackageCompletenessState = 'complete' | 'incomplete';

export type BidSeatReadModel = {
  seatId: string;
  projectId: string;
  bidId: string;
  state: BidSeatState;
  expiresAt: string | null;
  releasedAt: string | null;
};

export type BidSeatStatusReadModel = {
  seatId: string | null;
  projectId: string;
  bidId: string;
  state: BidSeatState;
  expiresAt: string | null;
  releasedAt: string | null;
};

export type BidPackageCompletenessReadModel = {
  bidId: string;
  projectId: string;
  state: BidPackageCompletenessState;
  missingItems: string[];
  quoteAmountReady: boolean;
  proposalSummaryReady: boolean;
};

const BID_SEAT_STATES = new Set<BidSeatState>(['available', 'locked', 'released', 'timed_out']);
const TIMED_OUT_SEAT_ALIASES = new Set(['timeout', 'timed_out', 'expired', 'stale_locked']);
const BID_PACKAGE_COMPLETENESS_STATES = new Set<BidPackageCompletenessState>([
  'complete',
  'incomplete',
]);

export function readBidSeatReadModel(value: unknown): BidSeatReadModel {
  const record = requireRecord(value, 'Bid seat response must be an object.');
  const seatId = readRequiredString(record.seatId, 'seatId');
  const projectId = readRequiredString(record.projectId, 'projectId');
  const bidId = readRequiredString(record.bidId, 'bidId');
  const state = normalizeSeatState(record.state);

  return {
    seatId,
    projectId,
    bidId,
    state,
    expiresAt: readNullableString(record.expiresAt),
    releasedAt: readNullableString(record.releasedAt),
  };
}

export function readBidSeatStatusReadModel(value: unknown): BidSeatStatusReadModel {
  const record = requireRecord(value, 'Bid seat response must be an object.');
  const projectId = readRequiredString(record.projectId, 'projectId');
  const bidId = readRequiredString(record.bidId, 'bidId');
  const state = normalizeSeatState(record.state);
  const seatId =
    state === 'available'
      ? readNullableStatusSeatId(record.seatId)
      : readRequiredString(record.seatId, 'seatId');

  return {
    seatId,
    projectId,
    bidId,
    state,
    expiresAt: readNullableString(record.expiresAt),
    releasedAt: readNullableString(record.releasedAt),
  };
}

export function readBidPackageCompletenessReadModel(
  value: unknown,
): BidPackageCompletenessReadModel {
  const record = requireRecord(value, 'Bid package completeness response must be an object.');
  const bidId = readRequiredString(record.bidId, 'bidId');
  const projectId = readRequiredString(record.projectId, 'projectId');
  const state = readRequiredString(record.state, 'state');

  if (!BID_PACKAGE_COMPLETENESS_STATES.has(state as BidPackageCompletenessState)) {
    throw new Error('Bid package completeness response returned an unsupported state.');
  }

  return {
    bidId,
    projectId,
    state: state as BidPackageCompletenessState,
    missingItems: readStringArray(record.missingItems, 'missingItems'),
    quoteAmountReady: readRequiredBoolean(record.quoteAmountReady, 'quoteAmountReady'),
    proposalSummaryReady: readRequiredBoolean(
      record.proposalSummaryReady,
      'proposalSummaryReady',
    ),
  };
}

function normalizeSeatState(value: unknown): BidSeatState {
  const state = readRequiredString(value, 'state');
  if (TIMED_OUT_SEAT_ALIASES.has(state)) {
    return 'timed_out';
  }
  if (BID_SEAT_STATES.has(state as BidSeatState)) {
    return state as BidSeatState;
  }
  throw new Error('Bid seat response returned an unsupported state.');
}

function requireRecord(value: unknown, message: string) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

function readRequiredString(value: unknown, fieldName: string) {
  if (typeof value !== 'string') {
    throw new Error(`Bid response is missing \`${fieldName}\`.`);
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`Bid response is missing \`${fieldName}\`.`);
  }
  return normalized;
}

function readNullableString(value: unknown) {
  if (value === null || value === undefined) {
    return null;
  }
  if (typeof value === 'string') {
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : null;
  }
  throw new Error('Bid response returned an invalid timestamp field.');
}

function readNullableStatusSeatId(value: unknown) {
  if (value === null || value === undefined) {
    return null;
  }
  return readRequiredString(value, 'seatId');
}

function readStringArray(value: unknown, fieldName: string) {
  if (!Array.isArray(value)) {
    throw new Error(`Bid response is missing \`${fieldName}\`.`);
  }
  return value.map((item) => readRequiredString(item, fieldName));
}

function readRequiredBoolean(value: unknown, fieldName: string) {
  if (typeof value !== 'boolean') {
    throw new Error(`Bid response is missing \`${fieldName}\`.`);
  }
  return value;
}
