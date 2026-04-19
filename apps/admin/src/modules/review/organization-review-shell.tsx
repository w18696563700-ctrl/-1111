import Link from 'next/link';
import type {
  AdminOrganizationReviewDetail,
  AdminOrganizationReviewListItem,
  OrganizationCertificationStatus
} from '@/core/server/admin-api-client';
import {
  approveOrganizationReviewAction,
  rejectOrganizationReviewAction
} from './organization-review-actions';
import { loadOrganizationReviewState } from './organization-review-state';

type OrganizationReviewShellProps = {
  selectedOrganizationId?: string;
  organizationId?: string;
  notice?: string;
  error?: string;
  status?: string;
  keyword?: string;
};

const STATUS_OPTIONS: OrganizationCertificationStatus[] = [
  'not_submitted',
  'pending_review',
  'approved',
  'rejected',
  'expired'
];

export async function OrganizationReviewShell({
  selectedOrganizationId,
  organizationId,
  notice,
  error,
  status,
  keyword
}: OrganizationReviewShellProps) {
  const state = await loadOrganizationReviewState({
    selectedOrganizationId,
    organizationId,
    status,
    keyword
  });
  const activeOrganizationId =
    selectedOrganizationId ?? organizationId ?? state.detail?.organizationId ?? state.items[0]?.organizationId;

  return (
    <section className="panel review-console governance-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">企业认证审核子座位</p>
          <h1>企业认证审核台</h1>
        </div>
        <span className="badge">仅调用服务端管理接口</span>
      </div>
      <p className="lead">
        `/review/organizations*` 当前只承接 organization certification review 的列表、详情和命令座位。
        `/review` 主座位继续归 content-safety review-tasks，不在这里混入 taskId、taskType 或 submissionId 语义。
      </p>
      <div className="notice-grid">
        {notice ? <div className="notice">{toNoticeText(notice)}</div> : null}
        {error ? <div className="notice danger">{error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
      </div>
      <OrganizationReviewFilters organizationId={organizationId} status={status} keyword={keyword} />
      <div className="review-grid governance-grid">
        <OrganizationReviewList
          items={state.items}
          selectedOrganizationId={activeOrganizationId}
          organizationId={organizationId}
          total={state.total}
          status={status}
          keyword={keyword}
        />
        <div className="detail-stack">
          <OrganizationReviewDetailPanel detail={state.detail} />
          <ApproveOrganizationReviewForm
            detail={state.detail}
            organizationId={organizationId}
            status={status}
            keyword={keyword}
          />
          <RejectOrganizationReviewForm
            detail={state.detail}
            organizationId={organizationId}
            status={status}
            keyword={keyword}
          />
        </div>
      </div>
    </section>
  );
}

function OrganizationReviewFilters({
  organizationId,
  status,
  keyword
}: {
  organizationId?: string;
  status?: string;
  keyword?: string;
}) {
  return (
    <form className="filter-card" action="/review/organizations">
      <label>
        认证状态
        <select name="status" defaultValue={status ?? ''}>
          <option value="">全部状态</option>
          {STATUS_OPTIONS.map((item) => (
            <option key={item} value={item}>{toCertificationStatusLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        关键词
        <input
          name="keyword"
          defaultValue={keyword ?? ''}
          placeholder="组织名、法人名称、统一社会信用代码"
        />
      </label>
      {organizationId ? <input name="organizationId" type="hidden" value={organizationId} /> : null}
      <button className="primary" type="submit">筛选审核对象</button>
    </form>
  );
}

function OrganizationReviewList({
  items,
  selectedOrganizationId,
  organizationId,
  total,
  status,
  keyword
}: {
  items: AdminOrganizationReviewListItem[];
  selectedOrganizationId?: string;
  organizationId?: string;
  total: number;
  status?: string;
  keyword?: string;
}) {
  if (!items.length) {
    return <div className="empty-card">当前没有服务端返回的企业认证审核对象。</div>;
  }

  return (
    <div className="review-list" aria-label="企业认证审核队列">
      <p className="eyebrow">共 {total} 条</p>
      {items.map((item) => (
        <Link
          className={item.organizationId === selectedOrganizationId ? 'task-card active' : 'task-card'}
          href={buildOrganizationReviewDetailHref(item.organizationId, organizationId, status, keyword)}
          key={item.organizationId}
        >
          <span>{toCertificationStatusLabel(item.certificationStatus)}</span>
          <strong>{item.name}</strong>
          <small>{item.organizationType}</small>
          <small>{formatDate(item.submittedAt)}</small>
        </Link>
      ))}
    </div>
  );
}

function OrganizationReviewDetailPanel({
  detail
}: {
  detail: AdminOrganizationReviewDetail | null;
}) {
  if (!detail) {
    return (
      <div className="review-detail empty-card">
        在拿到有效的服务端管理员会话载体后，可在此查看企业认证详情并执行有界 approve / reject。
      </div>
    );
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">认证详情</p>
          <h2>{detail.name}</h2>
        </div>
        <span className="badge">{toCertificationStatusLabel(detail.certificationStatus)}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>organizationId</dt><dd>{detail.organizationId}</dd></div>
        <div><dt>organizationType</dt><dd>{detail.organizationType}</dd></div>
        <div><dt>legalName</dt><dd>{detail.legalName ?? '暂无'}</dd></div>
        <div><dt>USCC</dt><dd>{detail.uscc ?? '暂无'}</dd></div>
        <div><dt>licenseFileId</dt><dd>{detail.licenseFileId ?? '暂无'}</dd></div>
        <div><dt>contactName</dt><dd>{detail.contactName ?? '暂无'}</dd></div>
        <div><dt>contactMobile</dt><dd>{detail.contactMobile ?? '暂无'}</dd></div>
        <div><dt>submittedAt</dt><dd>{formatDate(detail.submittedAt)}</dd></div>
        <div><dt>reviewedAt</dt><dd>{formatDate(detail.reviewedAt)}</dd></div>
        <div><dt>rejectReason</dt><dd>{detail.rejectReason ?? '暂无'}</dd></div>
      </dl>
    </div>
  );
}

function ApproveOrganizationReviewForm({
  detail,
  organizationId,
  status,
  keyword
}: {
  detail: AdminOrganizationReviewDetail | null;
  organizationId?: string;
  status?: string;
  keyword?: string;
}) {
  if (!detail) {
    return <div className="action-card empty-card">选中组织后，才会开放 approve 动作。</div>;
  }

  return (
    <form className="action-card" action={approveOrganizationReviewAction}>
      <input name="organizationId" type="hidden" value={detail.organizationId} />
      <HiddenRouteContext organizationId={organizationId} status={status} keyword={keyword} />
      <div>
        <p className="eyebrow">Approve</p>
        <h2>通过企业认证</h2>
      </div>
      <label>
        审核备注
        <textarea name="note" placeholder="可选，补充审核说明。" />
      </label>
      <button className="primary" type="submit">提交通过命令</button>
    </form>
  );
}

function RejectOrganizationReviewForm({
  detail,
  organizationId,
  status,
  keyword
}: {
  detail: AdminOrganizationReviewDetail | null;
  organizationId?: string;
  status?: string;
  keyword?: string;
}) {
  if (!detail) {
    return <div className="action-card empty-card">选中组织后，才会开放 reject 动作。</div>;
  }

  return (
    <form className="action-card danger-card" action={rejectOrganizationReviewAction}>
      <input name="organizationId" type="hidden" value={detail.organizationId} />
      <HiddenRouteContext organizationId={organizationId} status={status} keyword={keyword} />
      <div>
        <p className="eyebrow">Reject</p>
        <h2>驳回企业认证</h2>
      </div>
      <label>
        驳回原因
        <textarea name="reason" required placeholder="必填，请填写驳回原因。" />
      </label>
      <label>
        补充备注
        <textarea name="note" placeholder="可选，补充审核备注。" />
      </label>
      <button className="primary danger-button" type="submit">提交驳回命令</button>
    </form>
  );
}

function HiddenRouteContext({
  organizationId,
  status,
  keyword
}: {
  organizationId?: string;
  status?: string;
  keyword?: string;
}) {
  return (
    <>
      {organizationId ? <input name="filterOrganizationId" type="hidden" value={organizationId} /> : null}
      {status ? <input name="status" type="hidden" value={status} /> : null}
      {keyword ? <input name="keyword" type="hidden" value={keyword} /> : null}
    </>
  );
}

function buildOrganizationReviewDetailHref(
  organizationId: string,
  filterOrganizationId?: string,
  status?: string,
  keyword?: string
) {
  const params = new URLSearchParams();
  if (filterOrganizationId) {
    params.set('organizationId', filterOrganizationId);
  }
  if (status) {
    params.set('status', status);
  }
  if (keyword) {
    params.set('keyword', keyword);
  }
  const query = params.toString();
  return query
    ? `/review/organizations/${encodeURIComponent(organizationId)}?${query}`
    : `/review/organizations/${encodeURIComponent(organizationId)}`;
}

function toCertificationStatusLabel(status: OrganizationCertificationStatus) {
  if (status === 'not_submitted') {
    return '未提交';
  }
  if (status === 'pending_review') {
    return '待审核';
  }
  if (status === 'approved') {
    return '已通过';
  }
  if (status === 'rejected') {
    return '已驳回';
  }
  if (status === 'expired') {
    return '已过期';
  }
  return status;
}

function formatDate(value: string | null | undefined) {
  if (!value) {
    return '暂无';
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString('zh-CN', { hour12: false });
}

function toNoticeText(value: string) {
  if (value === 'organization_review_approved') {
    return '企业认证通过命令已提交到服务端。';
  }
  if (value === 'organization_review_rejected') {
    return '企业认证驳回命令已提交到服务端。';
  }
  return value;
}
