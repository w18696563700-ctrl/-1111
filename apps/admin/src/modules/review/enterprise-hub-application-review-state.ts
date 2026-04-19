import {
  AdminApiError,
  EnterpriseHubApplicationBoardType,
  EnterpriseHubApplicationReviewDetailResponse,
  EnterpriseHubApplicationReviewListItem,
  EnterpriseHubApplicationReviewStatus,
  fetchEnterpriseHubApplicationReview,
  fetchEnterpriseHubApplicationReviews,
} from '../../core/server/admin-api-client';

type EnterpriseHubApplicationReviewClient = {
  fetchList: typeof fetchEnterpriseHubApplicationReviews;
  fetchDetail: typeof fetchEnterpriseHubApplicationReview;
};

export type EnterpriseHubApplicationReviewStatusSummary = {
  label: string;
  description: string;
  canReview: boolean;
};

export type EnterpriseHubApplicationReviewShellState = {
  items: EnterpriseHubApplicationReviewListItem[];
  detail: EnterpriseHubApplicationReviewDetailResponse | null;
  total: number;
  error: string | null;
  statusSummary: EnterpriseHubApplicationReviewStatusSummary | null;
};

const DEFAULT_CLIENT: EnterpriseHubApplicationReviewClient = {
  fetchList: fetchEnterpriseHubApplicationReviews,
  fetchDetail: fetchEnterpriseHubApplicationReview,
};

const STATUS_OPTIONS: EnterpriseHubApplicationReviewStatus[] = [
  'draft',
  'submitted',
  'under_review',
  'revision_required',
  'approved',
  'rejected',
];

const BOARD_OPTIONS: EnterpriseHubApplicationBoardType[] = [
  'company',
  'factory',
  'supplier',
];

export async function loadEnterpriseHubApplicationReviewState(
  input: {
    selectedApplicationId?: string;
    applicationStatus?: string;
    boardType?: string;
  },
  client: EnterpriseHubApplicationReviewClient = DEFAULT_CLIENT,
): Promise<EnterpriseHubApplicationReviewShellState> {
  try {
    const list = await client.fetchList({
      page: 1,
      pageSize: 20,
      applicationStatus: readApplicationStatus(input.applicationStatus),
      boardType: readBoardType(input.boardType),
    });
    const applicationId =
      input.selectedApplicationId ?? list.items[0]?.applicationId;
    if (!applicationId) {
      return {
        items: list.items,
        detail: null,
        total: list.pagination.total,
        error: null,
        statusSummary: null,
      };
    }

    try {
      const detail = await client.fetchDetail(applicationId);
      return {
        items: list.items,
        detail,
        total: list.pagination.total,
        error: null,
        statusSummary: describeEnterpriseHubApplicationReviewStatus(
          detail.application.applicationStatus,
        ),
      };
    } catch (error) {
      return {
        items: list.items,
        detail: null,
        total: list.pagination.total,
        error: toEnterpriseHubApplicationReviewLoadError(error),
        statusSummary: null,
      };
    }
  } catch (error) {
    return {
      items: [],
      detail: null,
      total: 0,
      error: toEnterpriseHubApplicationReviewLoadError(error),
      statusSummary: null,
    };
  }
}

export function readApplicationStatus(value: string | undefined) {
  if (!value) {
    return undefined;
  }
  return STATUS_OPTIONS.includes(value as EnterpriseHubApplicationReviewStatus)
    ? (value as EnterpriseHubApplicationReviewStatus)
    : undefined;
}

export function readBoardType(value: string | undefined) {
  if (!value) {
    return undefined;
  }
  return BOARD_OPTIONS.includes(value as EnterpriseHubApplicationBoardType)
    ? (value as EnterpriseHubApplicationBoardType)
    : undefined;
}

export function describeEnterpriseHubApplicationReviewStatus(
  status: EnterpriseHubApplicationReviewStatus,
): EnterpriseHubApplicationReviewStatusSummary {
  switch (status) {
    case 'submitted':
      return {
        label: '已提交，待审核',
        description:
          '当前 application 已提交到服务端审核面。这里可以发出 approved、revision_required、rejected 三类 review 命令，但不会在 Admin 侧额外推进 under_review。',
        canReview: true,
      };
    case 'under_review':
      return {
        label: '审核中',
        description:
          '当前 application 已处于 under_review。这里继续只消费服务端真相，不在 Admin desk 本地推导第二状态机。',
        canReview: true,
      };
    case 'approved':
      return {
        label: '已通过',
        description:
          '当前 application 已审核通过。这里不再开放 review 动作，也不会把 approved 扩写成其他治理语义。',
        canReview: false,
      };
    case 'revision_required':
      return {
        label: '已退回修改',
        description:
          '当前 application 已退回修改。这里展示服务端返回的 reject reason 和 reviewNote，不开放继续 review。',
        canReview: false,
      };
    case 'rejected':
      return {
        label: '已驳回',
        description:
          '当前 application 已驳回。这里展示 reject reason 和 reviewNote，不开放继续 review。',
        canReview: false,
      };
    default:
      return {
        label: '草稿中',
        description:
          'draft application 不是当前 Admin review desk 的目标对象。这里不会把 app-side 草稿态扩成可审核对象。',
        canReview: false,
      };
  }
}

export function toEnterpriseHubApplicationReviewLoadError(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error
    ? error.message
    : '无法从服务端管理接口加载企业入驻审核台。';
}
