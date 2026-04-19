export type GovernanceStatusValue =
  | 'normal'
  | 'watchlisted'
  | 'restricted'
  | 'blacklisted'
  | 'permanently_banned';

export type WhitelistStatusValue = 'none' | 'active';
export type AppealEntryStateValue = 'not_available' | 'available' | 'pending';

export type CurrentPenaltyViewModel = {
  penaltyId: string;
  penaltyType: string;
  status: string;
  effectiveFrom: string;
  effectiveUntil: string | null;
  reasonSummary: string | null;
  appealAllowed: boolean;
};

export type GovernanceStatusViewModel = {
  organizationId: string | null;
  governanceStatus: GovernanceStatusValue;
  whitelistStatus: WhitelistStatusValue;
  appealEntryState: AppealEntryStateValue;
  currentPenalty: CurrentPenaltyViewModel | null;
  violationScoreSnapshot: number;
  violationScoreUpdatedAt: string | null;
};

const GOVERNANCE_STATUSES = new Set<GovernanceStatusValue>([
  'normal',
  'watchlisted',
  'restricted',
  'blacklisted',
  'permanently_banned',
]);
const WHITELIST_STATUSES = new Set<WhitelistStatusValue>(['none', 'active']);
const APPEAL_ENTRY_STATES = new Set<AppealEntryStateValue>(['not_available', 'available', 'pending']);

export function readGovernanceStatusViewModel(value: Record<string, unknown>): GovernanceStatusViewModel {
  return {
    organizationId: readNullableString(value.organizationId, 'organizationId must be a string or null.'),
    governanceStatus: readGovernanceStatus(value.governanceStatus),
    whitelistStatus: readWhitelistStatus(value.whitelistStatus),
    appealEntryState: readAppealEntryState(value.appealEntryState),
    currentPenalty: readNullablePenalty(value.currentPenalty),
    violationScoreSnapshot: readNumber(value.violationScoreSnapshot, 'violationScoreSnapshot must be a number.'),
    violationScoreUpdatedAt: readNullableString(
      value.violationScoreUpdatedAt,
      'violationScoreUpdatedAt must be a string or null.',
    ),
  };
}

function readGovernanceStatus(value: unknown): GovernanceStatusValue {
  if (typeof value === 'string' && GOVERNANCE_STATUSES.has(value as GovernanceStatusValue)) {
    return value as GovernanceStatusValue;
  }
  throw new Error('governanceStatus must be a supported status value.');
}

function readWhitelistStatus(value: unknown): WhitelistStatusValue {
  if (typeof value === 'string' && WHITELIST_STATUSES.has(value as WhitelistStatusValue)) {
    return value as WhitelistStatusValue;
  }
  throw new Error('whitelistStatus must be a supported status value.');
}

function readAppealEntryState(value: unknown): AppealEntryStateValue {
  if (typeof value === 'string' && APPEAL_ENTRY_STATES.has(value as AppealEntryStateValue)) {
    return value as AppealEntryStateValue;
  }
  throw new Error('appealEntryState must be a supported state value.');
}

function readNullablePenalty(value: unknown): CurrentPenaltyViewModel | null {
  if (value === null || value === undefined) {
    return null;
  }
  if (typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('currentPenalty must be an object or null.');
  }
  const record = value as Record<string, unknown>;
  return {
    penaltyId: readRequiredString(record.penaltyId, 'currentPenalty.penaltyId must be a string.'),
    penaltyType: readRequiredString(record.penaltyType, 'currentPenalty.penaltyType must be a string.'),
    status: readRequiredString(record.status, 'currentPenalty.status must be a string.'),
    effectiveFrom: readRequiredString(record.effectiveFrom, 'currentPenalty.effectiveFrom must be a string.'),
    effectiveUntil: readNullableString(record.effectiveUntil, 'currentPenalty.effectiveUntil must be a string or null.'),
    reasonSummary: readNullableString(record.reasonSummary, 'currentPenalty.reasonSummary must be a string or null.'),
    appealAllowed: readBoolean(record.appealAllowed, 'currentPenalty.appealAllowed must be a boolean.'),
  };
}

function readRequiredString(value: unknown, message: string): string {
  if (typeof value === 'string') {
    return value;
  }
  throw new Error(message);
}

function readNullableString(value: unknown, message: string): string | null {
  if (value === null || value === undefined) {
    return null;
  }
  if (typeof value === 'string') {
    return value;
  }
  throw new Error(message);
}

function readBoolean(value: unknown, message: string): boolean {
  if (typeof value === 'boolean') {
    return value;
  }
  throw new Error(message);
}

function readNumber(value: unknown, message: string): number {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  throw new Error(message);
}
