import { adminJsonRequest, toQueryString } from './admin-api-runtime';

export type EnterpriseHubApplicationBoardType = 'company' | 'factory' | 'supplier';
export type EnterpriseHubApplicationReviewStatus =
  | 'draft'
  | 'submitted'
  | 'under_review'
  | 'revision_required'
  | 'approved'
  | 'rejected';
export type EnterpriseHubApplicationReviewAction =
  | 'approved'
  | 'revision_required'
  | 'rejected';
export type EnterpriseHubApplicationReviewReason =
  | 'basic_info_incomplete'
  | 'profile_incomplete'
  | 'case_incomplete'
  | 'contact_incomplete'
  | 'certification_not_approved'
  | 'other';

export type EnterpriseHubApplicationReviewListItem = {
  applicationId: string;
  enterpriseId: string;
  boardType: EnterpriseHubApplicationBoardType;
  name: string;
  provinceName: string | null;
  cityName: string | null;
  applicationStatus: EnterpriseHubApplicationReviewStatus;
  submittedAt: string | null;
};

export type EnterpriseHubApplicationReviewListResponse = {
  items: EnterpriseHubApplicationReviewListItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore: boolean;
  };
};

export type EnterpriseHubApplicationReviewState = {
  applicationId: string;
  enterpriseId: string;
  applyBoardType: EnterpriseHubApplicationBoardType;
  applicationStatus: EnterpriseHubApplicationReviewStatus;
  rejectionReason: EnterpriseHubApplicationReviewReason | null;
  submittedAt: string | null;
  reviewedAt: string | null;
};

export type EnterpriseHubApplicationReviewEnterpriseSummary = {
  enterpriseId: string;
  organizationId: string;
  name: string | null;
  primaryBoardType: EnterpriseHubApplicationBoardType;
  secondaryCapabilities: EnterpriseHubApplicationBoardType[];
  enterpriseStatus: string;
  displayStatus: string;
};

export type EnterpriseHubApplicationReviewCaseItem = {
  id: string;
  title: string;
  summary: string | null;
  coverImageUrl: string | null;
  eventTime: string | null;
  caseStatus: string;
};

export type EnterpriseHubApplicationReviewCertificationItem = {
  type: string;
  name: string;
  status: string;
};

export type EnterpriseHubApplicationReviewContactItem = {
  contactName: string;
  mobile: string | null;
  wechat: string | null;
  phone: string | null;
  email: string | null;
  position: string | null;
};

export type EnterpriseHubApplicationReviewDetailResponse = {
  application: EnterpriseHubApplicationReviewState;
  enterprise: EnterpriseHubApplicationReviewEnterpriseSummary;
  profiles: {
    company: Record<string, unknown> | null;
    factory: Record<string, unknown> | null;
    supplier: Record<string, unknown> | null;
  };
  cases: EnterpriseHubApplicationReviewCaseItem[];
  certifications: EnterpriseHubApplicationReviewCertificationItem[];
  contacts: EnterpriseHubApplicationReviewContactItem[];
};

export type EnterpriseHubApplicationReviewRequest = {
  action: EnterpriseHubApplicationReviewAction;
  reason?: EnterpriseHubApplicationReviewReason | null;
  reviewNote?: string | null;
};

export type EnterpriseHubApplicationReviewActionAck = {
  ok: boolean;
  traceId: string;
};

export async function fetchEnterpriseHubApplicationReviews(query: {
  page?: number;
  pageSize?: number;
  applicationStatus?: EnterpriseHubApplicationReviewStatus;
  boardType?: EnterpriseHubApplicationBoardType;
} = {}) {
  return adminJsonRequest<EnterpriseHubApplicationReviewListResponse>(
    `/exhibition/enterprise-hub/applications${toQueryString(query)}`,
  );
}

export async function fetchEnterpriseHubApplicationReview(applicationId: string) {
  return adminJsonRequest<EnterpriseHubApplicationReviewDetailResponse>(
    `/exhibition/enterprise-hub/applications/${encodeURIComponent(applicationId)}`,
  );
}

export async function reviewEnterpriseHubApplication(
  applicationId: string,
  payload: EnterpriseHubApplicationReviewRequest,
) {
  return adminJsonRequest<EnterpriseHubApplicationReviewActionAck>(
    `/exhibition/enterprise-hub/applications/${encodeURIComponent(applicationId)}/review`,
    {
      method: 'POST',
      body: payload,
    },
  );
}
