import { adminJsonRequest, toQueryString } from './admin-api-runtime';

export type OrganizationCertificationStatus =
  | 'not_submitted'
  | 'pending_review'
  | 'approved'
  | 'rejected'
  | 'expired';

export type AdminOrganizationReviewListItem = {
  organizationId: string;
  name: string;
  organizationType: string;
  certificationStatus: OrganizationCertificationStatus;
  submittedAt: string | null;
};

export type AdminOrganizationReviewDetail = {
  organizationId: string;
  name: string;
  organizationType: string;
  certificationStatus: OrganizationCertificationStatus;
  legalName: string | null;
  uscc: string | null;
  licenseFileId: string | null;
  contactName: string | null;
  contactMobile: string | null;
  submittedAt: string | null;
  reviewedAt: string | null;
  rejectReason: string | null;
};

export type AdminOrganizationReviewListResponse = {
  items: AdminOrganizationReviewListItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore: boolean;
  };
};

export type AdminOrganizationReviewActionAck = {
  ok: boolean;
  traceId: string;
};

export type ApproveOrganizationReviewPayload = {
  note?: string | null;
};

export type RejectOrganizationReviewPayload = {
  reason: string;
  note?: string | null;
};

export async function fetchAdminOrganizationReviews(query: {
  page?: number;
  pageSize?: number;
  status?: OrganizationCertificationStatus;
  organizationId?: string;
  keyword?: string;
} = {}) {
  return adminJsonRequest<AdminOrganizationReviewListResponse>(
    `/reviews/organizations${toQueryString(query)}`
  );
}

export async function fetchAdminOrganizationReview(organizationId: string) {
  return adminJsonRequest<AdminOrganizationReviewDetail>(
    `/reviews/organizations/${encodeURIComponent(organizationId)}`
  );
}

export async function approveAdminOrganizationReview(
  organizationId: string,
  payload: ApproveOrganizationReviewPayload
) {
  return adminJsonRequest<AdminOrganizationReviewActionAck>(
    `/reviews/organizations/${encodeURIComponent(organizationId)}/approve`,
    {
      method: 'POST',
      body: payload
    }
  );
}

export async function rejectAdminOrganizationReview(
  organizationId: string,
  payload: RejectOrganizationReviewPayload
) {
  return adminJsonRequest<AdminOrganizationReviewActionAck>(
    `/reviews/organizations/${encodeURIComponent(organizationId)}/reject`,
    {
      method: 'POST',
      body: payload
    }
  );
}
