import Link from 'next/link';
import type { AdminMembershipOrderItem } from '@/core/server/admin-api-client';
import { loadMembershipState } from './membership-state';

type MembershipShellProps = {
  membershipOrderId?: string;
  organizationId?: string;
  orderStatus?: string;
  paymentStatus?: string;
  entitlementStatus?: string;
  error?: string;
};

export async function MembershipShell(props: MembershipShellProps) {
  const state = await loadMembershipState(props);

  return (
    <section className="panel review-console governance-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">会员治理</p>
          <h1>会员订单状态与会员状态只读查询</h1>
        </div>
        <span className="badge">Admin read-only</span>
      </div>
      <p className="lead">
        `/membership` 当前只承接会员订单列表、订单详情、组织会员状态查询。
        不提供手工开通、退款、续费、取消、发票或支付状态修改。
      </p>
      <div className="notice-grid">
        {props.error ? <div className="notice danger">{props.error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
        {!state.writeActionsEnabled ? (
          <div className="notice">只读门禁已生效：Admin 不能修改会员或支付状态。</div>
        ) : null}
      </div>
      <MembershipFilters {...props} />
      <div className="review-grid governance-grid">
        <MembershipOrderList items={state.items} total={state.total} filters={props} />
        <MembershipDetailPanel detail={state.detail} status={state.status} />
      </div>
    </section>
  );
}

function MembershipFilters(props: MembershipShellProps) {
  return (
    <form className="filter-card" action="/membership">
      <label>
        organizationId
        <input name="organizationId" defaultValue={props.organizationId ?? ''} />
      </label>
      <label>
        orderStatus
        <input name="orderStatus" defaultValue={props.orderStatus ?? ''} />
      </label>
      <label>
        paymentStatus
        <input name="paymentStatus" defaultValue={props.paymentStatus ?? ''} />
      </label>
      <label>
        entitlementStatus
        <input name="entitlementStatus" defaultValue={props.entitlementStatus ?? ''} />
      </label>
      <button className="primary" type="submit">筛选会员订单</button>
    </form>
  );
}

function MembershipOrderList({
  items,
  total,
  filters
}: {
  items: AdminMembershipOrderItem[];
  total: number;
  filters: MembershipShellProps;
}) {
  if (!items.length) {
    return <div className="empty-card">当前没有服务端返回的会员订单。</div>;
  }

  return (
    <div className="review-list" aria-label="membership orders">
      <p className="eyebrow">共 {total} 条</p>
      {items.map((item) => (
        <Link
          className={item.membershipOrderId === filters.membershipOrderId ? 'task-card active' : 'task-card'}
          href={buildMembershipHref(item.membershipOrderId, filters)}
          key={item.membershipOrderId}
        >
          <span>{toTierLabel(item.skuSnapshot.membershipTier)} · {item.orderStatus}</span>
          <strong>{item.amountSummary.payableAmount} {item.amountSummary.currency}</strong>
          <small>org: {item.organizationId}</small>
          <small>payment: {item.paymentStatus} · entitlement: {item.entitlementStatus}</small>
        </Link>
      ))}
    </div>
  );
}

function MembershipDetailPanel({
  detail,
  status
}: {
  detail: Awaited<ReturnType<typeof loadMembershipState>>['detail'];
  status: Awaited<ReturnType<typeof loadMembershipState>>['status'];
}) {
  if (!detail) {
    return (
      <div className="review-detail empty-card">
        在拿到有效的服务端管理员会话载体后，可在此检视会员订单详情。
      </div>
    );
  }
  const order = detail.order;
  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">Membership Order</p>
          <h2>{order.membershipOrderId}</h2>
        </div>
        <span className="badge">只读</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>organizationId</dt><dd>{order.organizationId}</dd></div>
        <div><dt>tier</dt><dd>{toTierLabel(order.skuSnapshot.membershipTier)}</dd></div>
        <div><dt>amount</dt><dd>{order.amountSummary.payableAmount} {order.amountSummary.currency}</dd></div>
        <div><dt>orderStatus</dt><dd>{order.orderStatus}</dd></div>
        <div><dt>paymentStatus</dt><dd>{order.paymentStatus}</dd></div>
        <div><dt>entitlementStatus</dt><dd>{order.entitlementStatus}</dd></div>
        <div><dt>paymentReferenceId</dt><dd>{order.channelSummary.paymentReferenceId ?? '暂无'}</dd></div>
        <div><dt>currentMembership</dt><dd>{toTierLabel(status?.membershipStatus.paidMembershipTier ?? null)}</dd></div>
      </dl>
      <div className="value-compare single">
        <div>
          <span>governanceBoundary</span>
          <p>readOnly=true, manualOpen=false, refund=false, paymentMutation=false</p>
        </div>
      </div>
      <pre className="json-panel">{JSON.stringify(detail, null, 2)}</pre>
    </div>
  );
}

function buildMembershipHref(orderId: string, filters: MembershipShellProps) {
  const params = new URLSearchParams();
  params.set('membershipOrderId', orderId);
  for (const key of ['organizationId', 'orderStatus', 'paymentStatus', 'entitlementStatus'] as const) {
    const value = filters[key];
    if (value) params.set(key, value);
  }
  return `/membership?${params.toString()}`;
}

function toTierLabel(tier: string | null) {
  if (tier === 'standard') return '标准会员';
  if (tier === 'professional') return '专业会员';
  if (tier === 'free_certified') return '免费认证版';
  return tier ?? '暂无';
}
