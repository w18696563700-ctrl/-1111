import {
  AdminApiError,
  AdminOrganizationReviewDetail,
  AdminOrganizationReviewListItem,
  OrganizationCertificationStatus,
  fetchAdminOrganizationReview,
  fetchAdminOrganizationReviews
} from '../../core/server/admin-api-client';

type OrganizationReviewClient = {
  fetchList: typeof fetchAdminOrganizationReviews;
  fetchDetail: typeof fetchAdminOrganizationReview;
};

export type OrganizationReviewShellState = {
  items: AdminOrganizationReviewListItem[];
  detail: AdminOrganizationReviewDetail | null;
  total: number;
  error: string | null;
};

const DEFAULT_CLIENT: OrganizationReviewClient = {
  fetchList: fetchAdminOrganizationReviews,
  fetchDetail: fetchAdminOrganizationReview
};

const STATUS_OPTIONS: OrganizationCertificationStatus[] = [
  'not_submitted',
  'pending_review',
  'approved',
  'rejected',
  'expired'
];

export async function loadOrganizationReviewState(
  input: {
    selectedOrganizationId?: string;
    organizationId?: string;
    status?: string;
    keyword?: string;
  },
  client: OrganizationReviewClient = DEFAULT_CLIENT
): Promise<OrganizationReviewShellState> {
  try {
    const organizationIdFilter = readOptionalFilter(input.organizationId);
    const list = await client.fetchList({
      page: 1,
      pageSize: 20,
      status: readOrganizationReviewStatus(input.status),
      organizationId: organizationIdFilter,
      keyword: readOptionalFilter(input.keyword)
    });
    const organizationId =
      input.selectedOrganizationId ?? organizationIdFilter ?? list.items[0]?.organizationId;
    const detail = organizationId ? await client.fetchDetail(organizationId) : null;
    return {
      items: list.items,
      detail,
      total: list.pagination.total,
      error: null
    };
  } catch (error) {
    return {
      items: [],
      detail: null,
      total: 0,
      error: toOrganizationReviewLoadError(error)
    };
  }
}

export function readOrganizationReviewStatus(value: string | undefined) {
  if (!value) {
    return undefined;
  }
  return STATUS_OPTIONS.includes(value as OrganizationCertificationStatus)
    ? (value as OrganizationCertificationStatus)
    : undefined;
}

export function toOrganizationReviewLoadError(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '无法从服务端管理接口加载企业认证审核台。';
}

function readOptionalFilter(value: string | undefined) {
  const normalized = value?.trim() ?? '';
  return normalized ? normalized : undefined;
}
