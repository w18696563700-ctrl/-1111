import {
  AdminApiError,
  EnterpriseHubAdminChangeRequestDetailResponse,
  EnterpriseHubAdminChangeRequestListItem,
  EnterpriseHubChangeRequestStatus,
  fetchEnterpriseHubChangeRequest,
  fetchEnterpriseHubChangeRequests,
} from '../../core/server/admin-api-client';

type PublishedChangeReviewClient = {
  fetchList: typeof fetchEnterpriseHubChangeRequests;
  fetchDetail: typeof fetchEnterpriseHubChangeRequest;
};

export type PublishedChangeStatusSummary = {
  label: string;
  description: string;
  canReview: boolean;
  canApply: boolean;
};

export type PublishedChangeReviewShellState = {
  items: EnterpriseHubAdminChangeRequestListItem[];
  detail: EnterpriseHubAdminChangeRequestDetailResponse | null;
  total: number;
  error: string | null;
  statusSummary: PublishedChangeStatusSummary | null;
};

const DEFAULT_CLIENT: PublishedChangeReviewClient = {
  fetchList: fetchEnterpriseHubChangeRequests,
  fetchDetail: fetchEnterpriseHubChangeRequest,
};

export async function loadPublishedChangeReviewState(
  input: {
    selectedChangeRequestId?: string;
  },
  client: PublishedChangeReviewClient = DEFAULT_CLIENT,
): Promise<PublishedChangeReviewShellState> {
  try {
    const list = await client.fetchList({
      page: 1,
      pageSize: 20,
    });
    const changeRequestId =
      input.selectedChangeRequestId ?? list.items[0]?.changeRequestId;
    if (!changeRequestId) {
      return {
        items: list.items,
        detail: null,
        total: list.pagination.total,
        error: null,
        statusSummary: null,
      };
    }

    try {
      const detail = await client.fetchDetail(changeRequestId);
      return {
        items: list.items,
        detail,
        total: list.pagination.total,
        error: null,
        statusSummary: describePublishedChangeStatus(
          detail.changeRequest.changeStatus,
        ),
      };
    } catch (error) {
      return {
        items: list.items,
        detail: null,
        total: list.pagination.total,
        error: toPublishedChangeLoadError(error),
        statusSummary: null,
      };
    }
  } catch (error) {
    return {
      items: [],
      detail: null,
      total: 0,
      error: toPublishedChangeLoadError(error),
      statusSummary: null,
    };
  }
}

export function describePublishedChangeStatus(
  status: EnterpriseHubChangeRequestStatus,
): PublishedChangeStatusSummary {
  switch (status) {
    case 'submitted':
      return {
        label: '已提交，待进入治理审核',
        description:
          '当前变更已提交到服务端治理队列。这里可以执行审核决策，但它还没有 apply 到 live listing。',
        canReview: true,
        canApply: false,
      };
    case 'under_review':
      return {
        label: '治理审核中',
        description:
          '当前 change request 已进入正式 review intake。这里仍只能做审核决策，不能直接视为已上线。',
        canReview: true,
        canApply: false,
      };
    case 'approved':
      return {
        label: '已审核通过，待 apply',
        description:
          '当前 change request 已审核通过，但尚未 apply 到 live listing。只有单独执行 apply 后，draft snapshot 才会写入 live listing。',
        canReview: false,
        canApply: true,
      };
    case 'applied':
      return {
        label: '已 apply 到 live listing',
        description:
          '当前 approved snapshot 已经写入 live listing。这个状态与 approved 明确分离。',
        canReview: false,
        canApply: false,
      };
    case 'revision_required':
      return {
        label: '已退回修改',
        description:
          '当前 change request 已退回到同一条单据等待重新修改和再次 submit。这里不开放 review/apply。',
        canReview: false,
        canApply: false,
      };
    case 'rejected':
      return {
        label: '已驳回',
        description:
          '当前 change request 已被驳回，不会写入 live listing。这里不开放 review/apply。',
        canReview: false,
        canApply: false,
      };
    default:
      return {
        label: '草稿中',
        description:
          'draft 状态仍在用户侧 current change carrier 内，不应在当前 Admin review/apply surface 执行治理动作。',
        canReview: false,
        canApply: false,
      };
  }
}

export function toPublishedChangeLoadError(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error
    ? error.message
    : '无法从服务端管理接口加载已发布展示变更审核台。';
}
