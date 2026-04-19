type RawRecord = Record<string, unknown>;

export type BidAwardTruthState = 'awarded' | 'converted_to_order';

export type BidAwardTruthCarrier = {
  bidAwardId: string;
  projectId: string;
  winningBidId: string;
  winningOrganizationId: string;
  reasonCode: string;
  reasonText: string;
  state: BidAwardTruthState;
  orderId: string | null;
  contractId: string | null;
  decidedAt: string;
};

export function readBidAwardTruth(summary: unknown) {
  const container = asRecord(summary);
  const award = asRecord(container?.bidAward);
  if (!award) {
    return null;
  }

  const bidAwardId = readRequiredString(award.bidAwardId);
  const projectId = readRequiredString(award.projectId);
  const winningBidId = readRequiredString(award.winningBidId);
  const winningOrganizationId = readRequiredString(award.winningOrganizationId);
  const reasonCode = readRequiredString(award.reasonCode);
  const reasonText = readRequiredString(award.reasonText);
  const orderId = readOptionalString(award.orderId);
  const contractId = readOptionalString(award.contractId);
  const decidedAt = readRequiredString(award.decidedAt);
  const state = readRequiredString(award.state);
  if (
    !bidAwardId ||
    !projectId ||
    !winningBidId ||
    !winningOrganizationId ||
    !reasonCode ||
    !reasonText ||
    !decidedAt ||
    !isBidAwardTruthState(state)
  ) {
    return null;
  }

  return {
    bidAwardId,
    projectId,
    winningBidId,
    winningOrganizationId,
    reasonCode,
    reasonText,
    state,
    orderId,
    contractId,
    decidedAt
  } satisfies BidAwardTruthCarrier;
}

export function writeBidAwardTruth(summary: unknown, award: BidAwardTruthCarrier) {
  const nextSummary = asRecord(summary) ?? {};
  return {
    ...nextSummary,
    bidAward: {
      bidAwardId: award.bidAwardId,
      projectId: award.projectId,
      winningBidId: award.winningBidId,
      winningOrganizationId: award.winningOrganizationId,
      reasonCode: award.reasonCode,
      reasonText: award.reasonText,
      state: award.state,
      orderId: award.orderId,
      contractId: award.contractId,
      decidedAt: award.decidedAt
    }
  } satisfies RawRecord;
}

function asRecord(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    return null;
  }
  return value as RawRecord;
}

function readRequiredString(value: unknown) {
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

function readOptionalString(value: unknown) {
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

function isBidAwardTruthState(value: string): value is BidAwardTruthState {
  return value === 'awarded' || value === 'converted_to_order';
}
