import { adminJsonRequest, toQueryString } from './admin-api-runtime';

export type GovernanceSubjectType = 'organization' | 'organization_member';
export type GovernancePenaltyType =
  | 'warning'
  | 'watchlist'
  | 'restrict_publish'
  | 'restrict_bid'
  | 'blacklist';
export type GovernancePenaltyStatus = 'active' | 'lifted' | 'expired';
export type GovernanceAppealStatus =
  | 'submitted'
  | 'under_review'
  | 'upheld'
  | 'modified'
  | 'revoked'
  | 'closed';
export type GovernanceAppealDecision = 'uphold' | 'modify' | 'revoke';

export type AdminGovernancePenaltyListItem = {
  penaltyId: string;
  subjectType: GovernanceSubjectType;
  subjectId: string;
  penaltyType: GovernancePenaltyType;
  status: GovernancePenaltyStatus;
  effectiveFrom: string | null;
  effectiveUntil: string | null;
};

export type AdminGovernancePenaltyDetail = AdminGovernancePenaltyListItem & {
  reasonCode: string;
  reasonSummary: string | null;
  evidenceFileAssetIds: string[] | null;
  createdAt: string | null;
  createdBy: string | null;
};

export type AdminGovernancePenaltyListResponse = {
  items: AdminGovernancePenaltyListItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore: boolean;
  };
};

export type AdminGovernanceAppealListItem = {
  appealCaseId: string;
  penaltyId: string;
  status: GovernanceAppealStatus;
  submittedAt: string | null;
};

export type AdminGovernanceAppealDetail = {
  appealCaseId: string;
  penaltyId: string;
  status: GovernanceAppealStatus;
  reason: string;
  evidenceFileAssetIds: string[] | null;
  submittedAt: string | null;
  decidedAt: string | null;
  decisionNote: string | null;
};

export type AdminGovernanceAppealListResponse = {
  items: AdminGovernanceAppealListItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore: boolean;
  };
};

export type ApplyGovernancePenaltyPayload = {
  subjectType: GovernanceSubjectType;
  subjectId: string;
  penaltyType: GovernancePenaltyType;
  reasonCode: string;
  reasonSummary?: string | null;
  effectiveUntil?: string | null;
  evidenceFileAssetIds?: string[] | null;
};

export async function fetchGovernancePenalties(query: {
  page?: number;
  pageSize?: number;
  status?: GovernancePenaltyStatus;
  keyword?: string;
} = {}) {
  return adminJsonRequest<AdminGovernancePenaltyListResponse>(
    `/governance/penalties${toQueryString(query)}`
  );
}

export async function fetchGovernancePenalty(penaltyId: string) {
  return adminJsonRequest<AdminGovernancePenaltyDetail>(
    `/governance/penalties/${encodeURIComponent(penaltyId)}`
  );
}

export async function applyGovernancePenalty(payload: ApplyGovernancePenaltyPayload) {
  return adminJsonRequest<Record<string, unknown>>('/governance/penalties', {
    method: 'POST',
    body: payload
  });
}

export async function fetchGovernanceAppeals(query: {
  page?: number;
  pageSize?: number;
  status?: GovernanceAppealStatus;
  keyword?: string;
} = {}) {
  return adminJsonRequest<AdminGovernanceAppealListResponse>(
    `/governance/appeals${toQueryString(query)}`
  );
}

export async function fetchGovernanceAppeal(appealCaseId: string) {
  return adminJsonRequest<AdminGovernanceAppealDetail>(
    `/governance/appeals/${encodeURIComponent(appealCaseId)}`
  );
}

export async function decideGovernanceAppeal(
  appealCaseId: string,
  payload: { decision: GovernanceAppealDecision; decisionNote?: string | null }
) {
  return adminJsonRequest<Record<string, unknown>>(
    `/governance/appeals/${encodeURIComponent(appealCaseId)}/decide`,
    {
      method: 'POST',
      body: payload
    }
  );
}
