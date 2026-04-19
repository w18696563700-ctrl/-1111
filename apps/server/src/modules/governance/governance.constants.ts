export const GOVERNANCE_SUBJECT_TYPES = ['organization', 'organization_member'] as const;
export type GovernanceSubjectType = (typeof GOVERNANCE_SUBJECT_TYPES)[number];

export const GOVERNANCE_PENALTY_TYPES = [
  'warning',
  'watchlist',
  'restrict_publish',
  'restrict_bid',
  'blacklist'
] as const;
export type GovernancePenaltyType = (typeof GOVERNANCE_PENALTY_TYPES)[number];

export const GOVERNANCE_PENALTY_STATUSES = ['active', 'lifted', 'expired'] as const;
export type GovernancePenaltyStatus = (typeof GOVERNANCE_PENALTY_STATUSES)[number];

export const GOVERNANCE_APPEAL_STATUSES = [
  'submitted',
  'under_review',
  'upheld',
  'modified',
  'revoked',
  'closed'
] as const;
export type GovernanceAppealStatus = (typeof GOVERNANCE_APPEAL_STATUSES)[number];

export const GOVERNANCE_APPEAL_DECISIONS = ['uphold', 'modify', 'revoke'] as const;
export type GovernanceAppealDecision = (typeof GOVERNANCE_APPEAL_DECISIONS)[number];

export const GOVERNANCE_RESCAN_SCOPE_TYPES = ['forum_content'] as const;
export type GovernanceRescanScopeType = (typeof GOVERNANCE_RESCAN_SCOPE_TYPES)[number];

export const GOVERNANCE_RESCAN_STATUSES = [
  'queued',
  'running',
  'completed',
  'failed',
  'cancelled'
] as const;
export type GovernanceRescanStatus = (typeof GOVERNANCE_RESCAN_STATUSES)[number];
