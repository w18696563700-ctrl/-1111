import {
  AdminApiError,
  AdminMembershipOrderDetailResponse,
  AdminMembershipOrderItem,
  AdminMembershipStatusResponse,
  fetchAdminMembershipOrder,
  fetchAdminMembershipOrders,
  fetchAdminMembershipStatus
} from '../../core/server/admin-api-client';

type MembershipClient = {
  fetchList: typeof fetchAdminMembershipOrders;
  fetchDetail: typeof fetchAdminMembershipOrder;
  fetchStatus: typeof fetchAdminMembershipStatus;
};

export type MembershipShellState = {
  items: AdminMembershipOrderItem[];
  detail: AdminMembershipOrderDetailResponse | null;
  status: AdminMembershipStatusResponse | null;
  total: number;
  readOnly: boolean;
  writeActionsEnabled: boolean;
  error: string | null;
};

const DEFAULT_CLIENT: MembershipClient = {
  fetchList: fetchAdminMembershipOrders,
  fetchDetail: fetchAdminMembershipOrder,
  fetchStatus: fetchAdminMembershipStatus
};

export async function loadMembershipState(
  input: {
    membershipOrderId?: string;
    organizationId?: string;
    orderStatus?: string;
    paymentStatus?: string;
    entitlementStatus?: string;
  },
  client: MembershipClient = DEFAULT_CLIENT
): Promise<MembershipShellState> {
  try {
    const list = await client.fetchList({
      organizationId: readOptional(input.organizationId),
      orderStatus: readOptional(input.orderStatus),
      paymentStatus: readOptional(input.paymentStatus),
      entitlementStatus: readOptional(input.entitlementStatus),
      page: 1,
      pageSize: 20
    });
    const selectedOrderId = input.membershipOrderId ?? list.items[0]?.membershipOrderId;
    const detail = selectedOrderId ? await client.fetchDetail(selectedOrderId) : null;
    const organizationId = input.organizationId ?? detail?.order.organizationId;
    const status = organizationId ? await client.fetchStatus(organizationId) : null;
    return {
      items: list.items,
      detail,
      status,
      total: list.pagination.total,
      readOnly: list.readOnly,
      writeActionsEnabled: list.writeActionsEnabled,
      error: null
    };
  } catch (error) {
    return {
      items: [],
      detail: null,
      status: null,
      total: 0,
      readOnly: true,
      writeActionsEnabled: false,
      error: toMembershipLoadError(error)
    };
  }
}

export function toMembershipLoadError(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error
    ? error.message
    : '无法从服务端管理接口加载会员订单与会员状态。';
}

function readOptional(value: string | undefined) {
  const normalized = value?.trim() ?? '';
  return normalized ? normalized : undefined;
}
