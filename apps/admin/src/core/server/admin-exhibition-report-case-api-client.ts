import { adminJsonRequest, toQueryString } from './admin-api-runtime';

export type ExhibitionReportTargetType =
  | 'project'
  | 'project_profile'
  | 'bid'
  | 'contract'
  | 'inspection';
export type ExhibitionReportReasonCode =
  | 'fabricated_project'
  | 'unauthorized_project_material'
  | 'false_budget_or_schedule'
  | 'fake_organization_or_contact'
  | 'fraudulent_collection_attempt'
  | 'other';
export type ExhibitionReportCaseStatus =
  | 'submitted'
  | 'under_review'
  | 'explanation_requested'
  | 'escalated'
  | 'decided'
  | 'closed';
export type ExhibitionTemporaryRestrictionState =
  | 'not_applied'
  | 'active'
  | 'lifted';
export type ExhibitionReportAdjudicationResult =
  | 'not_established'
  | 'partially_established'
  | 'materially_established';

export type AdminExhibitionReportCaseListItem = {
  reportCaseId: string;
  targetType: ExhibitionReportTargetType;
  targetId: string;
  reasonCode: ExhibitionReportReasonCode;
  status: ExhibitionReportCaseStatus;
  temporaryRestrictionState: ExhibitionTemporaryRestrictionState;
  submittedAt: string | null;
};

export type AdminExhibitionReportCaseDetail = {
  reportCaseId: string;
  targetType: ExhibitionReportTargetType;
  targetId: string;
  targetTitle?: string | null;
  reasonCode: ExhibitionReportReasonCode;
  reasonDetail: string | null;
  status: ExhibitionReportCaseStatus;
  temporaryRestrictionState: ExhibitionTemporaryRestrictionState;
  reviewTaskId: string | null;
  governanceTicketId: string | null;
  reporter?: {
    actorId: string;
    organizationId: string | null;
  };
  evidenceFileAssetIds?: string[] | null;
  submittedAt: string | null;
  explanationRequestedAt: string | null;
  explanationReceivedAt: string | null;
  adjudicationResult: ExhibitionReportAdjudicationResult | null;
  decidedAt: string | null;
  decisionNote: string | null;
};

export type AdminExhibitionReportCaseListResponse = {
  items: AdminExhibitionReportCaseListItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore: boolean;
  };
};

export type RequestExhibitionReportExplanationPayload = {
  question: string;
  dueAt?: string | null;
};

export type DecideExhibitionReportCasePayload = {
  adjudicationResult: ExhibitionReportAdjudicationResult;
  decisionNote?: string | null;
};

export type EscalateExhibitionReportCasePayload = {
  reason: string;
};

export async function fetchExhibitionReportCases(query: {
  page?: number;
  pageSize?: number;
  status?: ExhibitionReportCaseStatus;
  targetType?: ExhibitionReportTargetType;
  keyword?: string;
} = {}) {
  return adminJsonRequest<AdminExhibitionReportCaseListResponse>(
    `/exhibition/report-cases${toQueryString(query)}`
  );
}

export async function fetchExhibitionReportCase(reportCaseId: string) {
  return adminJsonRequest<AdminExhibitionReportCaseDetail>(
    `/exhibition/report-cases/${encodeURIComponent(reportCaseId)}`
  );
}

export async function requestExhibitionReportExplanation(
  reportCaseId: string,
  payload: RequestExhibitionReportExplanationPayload
) {
  return adminJsonRequest<Record<string, unknown>>(
    `/exhibition/report-cases/${encodeURIComponent(reportCaseId)}/request-explanation`,
    {
      method: 'POST',
      body: payload
    }
  );
}

export async function decideExhibitionReportCase(
  reportCaseId: string,
  payload: DecideExhibitionReportCasePayload
) {
  return adminJsonRequest<Record<string, unknown>>(
    `/exhibition/report-cases/${encodeURIComponent(reportCaseId)}/decide`,
    {
      method: 'POST',
      body: payload
    }
  );
}

export async function escalateExhibitionReportCase(
  reportCaseId: string,
  payload: EscalateExhibitionReportCasePayload
) {
  return adminJsonRequest<Record<string, unknown>>(
    `/exhibition/report-cases/${encodeURIComponent(reportCaseId)}/escalate`,
    {
      method: 'POST',
      body: payload
    }
  );
}
