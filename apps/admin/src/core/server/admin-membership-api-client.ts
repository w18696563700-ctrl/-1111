import { adminJsonRequest, toQueryString } from './admin-api-runtime';

export type AdminMembershipSkuSnapshot = {
  skuCode: string;
  skuName: string;
  membershipTier: string;
  durationMonths: number;
  serviceFeeDiscountSummary: string | null;
};

export type AdminMembershipOrderItem = {
  membershipOrderId: string;
  organizationId: string;
  createdByUserId: string;
  skuSnapshot: AdminMembershipSkuSnapshot;
  amountSummary: {
    payableAmount: number;
    currency: string;
  };
  orderStatus: string;
  paymentStatus: string;
  entitlementStatus: string;
  channelSummary: {
    paymentOrderId: string | null;
    payChannel: string | null;
    paymentReferenceId: string | null;
    callbackAwaiting: boolean;
  };
  effectiveAt: string | null;
  expiresAt: string | null;
  failureReasonCode: string | null;
  createdAt: string | null;
  updatedAt: string | null;
  governanceBoundary: {
    readOnly: boolean;
    manualOpenEnabled: boolean;
    refundEnabled: boolean;
    paymentStatusMutationEnabled: boolean;
  };
};

export type AdminMembershipStatus = {
  organizationId: string;
  paidMembershipTier: string | null;
  effectiveAt: string | null;
  expiresAt: string | null;
  sourceType: string | null;
  sourceRef: string | null;
};

export type AdminMembershipOrderListResponse = {
  items: AdminMembershipOrderItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    hasMore?: boolean;
  };
  readOnly: boolean;
  writeActionsEnabled: boolean;
};

export type AdminMembershipOrderDetailResponse = {
  order: AdminMembershipOrderItem;
  currentMembership: AdminMembershipStatus;
  readOnly: boolean;
  writeActionsEnabled: boolean;
};

export type AdminMembershipStatusResponse = {
  membershipStatus: AdminMembershipStatus;
  readOnly: boolean;
  writeActionsEnabled: boolean;
};

export async function fetchAdminMembershipOrders(query: {
  organizationId?: string;
  orderStatus?: string;
  paymentStatus?: string;
  entitlementStatus?: string;
  page?: number;
  pageSize?: number;
} = {}) {
  return adminJsonRequest<AdminMembershipOrderListResponse>(
    `/membership/orders${toQueryString(query)}`
  );
}

export async function fetchAdminMembershipOrder(membershipOrderId: string) {
  return adminJsonRequest<AdminMembershipOrderDetailResponse>(
    `/membership/orders/${encodeURIComponent(membershipOrderId)}`
  );
}

export async function fetchAdminMembershipStatus(organizationId: string) {
  return adminJsonRequest<AdminMembershipStatusResponse>(
    `/membership/organizations/${encodeURIComponent(organizationId)}/status`
  );
}
