import { adminJsonRequest, toQueryString } from './admin-api-runtime';

export type EnterpriseHubBoardType = 'company' | 'factory' | 'supplier';
export type EnterpriseHubChangeRequestStatus =
  | 'draft'
  | 'submitted'
  | 'under_review'
  | 'revision_required'
  | 'approved'
  | 'rejected'
  | 'applied';
export type EnterpriseHubAdminChangeReviewAction =
  | 'approved'
  | 'revision_required'
  | 'rejected';

export type EnterpriseHubAdminEnterpriseSummary = {
  enterpriseId: string;
  organizationId: string;
  name: string | null;
  primaryBoardType: EnterpriseHubBoardType;
  secondaryCapabilities: EnterpriseHubBoardType[];
  enterpriseStatus: string;
  displayStatus: string;
};

export type EnterpriseHubPublishedLiveSnapshot = {
  enterpriseStatus: string;
  displayStatus: string;
  publishedAt: string;
};

export type EnterpriseHubWorkbenchBasic = {
  name?: string | null;
  logoFileAssetId?: string | null;
  coverFileAssetId?: string | null;
  shortIntro?: string | null;
  fullIntro?: string | null;
  provinceCode?: string | null;
  provinceName?: string | null;
  cityCode?: string | null;
  cityName?: string | null;
  address?: string | null;
  foundedAt?: string | null;
  teamSizeRange?: string | null;
  cooperationModes?: string[];
  contactVisible?: boolean;
} | null;

export type EnterpriseHubWorkbenchContact = {
  contactName: string;
  mobile: string | null;
  wechat: string | null;
  phone: string | null;
  email: string | null;
  position: string | null;
  isPrimary: boolean;
  visibleToPublic: boolean;
} | null;

export type EnterpriseHubWorkbenchCaseItem = {
  caseId: string;
  boardType: EnterpriseHubBoardType;
  title: string;
  exhibitionType: string | null;
  city: string | null;
  eventTime: string | null;
  summary: string;
  caseCoverFileAssetId: string;
  caseMediaFileAssetIds: string[];
  isFeatured: boolean;
  caseStatus: string;
};

export type EnterpriseHubAdminChangeRequestListItem = {
  changeRequestId: string;
  enterpriseId: string;
  boardType: EnterpriseHubBoardType;
  enterpriseName: string | null;
  changeStatus: EnterpriseHubChangeRequestStatus;
  submittedAt: string | null;
  reviewedAt: string | null;
  appliedAt: string | null;
};

export type EnterpriseHubAdminChangeRequestState = {
  changeRequestId: string;
  enterpriseId: string;
  boardType: EnterpriseHubBoardType;
  changeStatus: EnterpriseHubChangeRequestStatus;
  submittedAt: string | null;
  reviewedAt: string | null;
  appliedAt: string | null;
  reviewNote: string | null;
};

export type EnterpriseHubAdminChangeRequestListResponse = {
  items: EnterpriseHubAdminChangeRequestListItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore: boolean;
  };
};

export type EnterpriseHubAdminChangeRequestDetailResponse = {
  changeRequest: EnterpriseHubAdminChangeRequestState;
  enterprise: EnterpriseHubAdminEnterpriseSummary;
  liveSnapshot: EnterpriseHubPublishedLiveSnapshot;
  basic: EnterpriseHubWorkbenchBasic;
  boardProfile: Record<string, unknown> | null;
  primaryContact: EnterpriseHubWorkbenchContact;
  cases: EnterpriseHubWorkbenchCaseItem[];
};

export type EnterpriseHubAdminChangeReviewRequest = {
  action: EnterpriseHubAdminChangeReviewAction;
  reviewNote?: string | null;
};

export type EnterpriseHubAdminChangeReviewResponse = {
  changeRequestId: string;
  changeStatus: EnterpriseHubChangeRequestStatus;
  reviewedAt: string | null;
};

export type EnterpriseHubAdminChangeApplyResponse = {
  changeRequestId: string;
  enterpriseId: string;
  changeStatus: EnterpriseHubChangeRequestStatus;
  appliedAt: string;
  enterpriseStatus: string;
  displayStatus: string;
};

export async function fetchEnterpriseHubChangeRequests(query: {
  page?: number;
  pageSize?: number;
} = {}) {
  return adminJsonRequest<EnterpriseHubAdminChangeRequestListResponse>(
    `/exhibition/enterprise-hub/change-requests${toQueryString(query)}`,
  );
}

export async function fetchEnterpriseHubChangeRequest(changeRequestId: string) {
  return adminJsonRequest<EnterpriseHubAdminChangeRequestDetailResponse>(
    `/exhibition/enterprise-hub/change-requests/${encodeURIComponent(changeRequestId)}`,
  );
}

export async function reviewEnterpriseHubChangeRequest(
  changeRequestId: string,
  payload: EnterpriseHubAdminChangeReviewRequest,
) {
  return adminJsonRequest<EnterpriseHubAdminChangeReviewResponse>(
    `/exhibition/enterprise-hub/change-requests/${encodeURIComponent(changeRequestId)}/review`,
    {
      method: 'POST',
      body: payload,
    },
  );
}

export async function applyEnterpriseHubChangeRequest(changeRequestId: string) {
  return adminJsonRequest<EnterpriseHubAdminChangeApplyResponse>(
    `/exhibition/enterprise-hub/change-requests/${encodeURIComponent(changeRequestId)}/apply`,
    {
      method: 'POST',
    },
  );
}
