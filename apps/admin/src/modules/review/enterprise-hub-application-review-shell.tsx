import Link from 'next/link';
import type {
  EnterpriseHubApplicationBoardType,
  EnterpriseHubApplicationReviewDetailResponse,
  EnterpriseHubApplicationReviewListItem,
  EnterpriseHubApplicationReviewStatus,
} from '@/core/server/admin-api-client';
import {
  approveEnterpriseHubApplicationReviewAction,
  rejectEnterpriseHubApplicationReviewAction,
  requestEnterpriseHubApplicationRevisionAction,
} from './enterprise-hub-application-review-actions';
import {
  ApproveEnterpriseHubApplicationReviewForm,
  ENTERPRISE_HUB_APPLICATION_REVIEW_REASON_OPTIONS,
  RejectEnterpriseHubApplicationReviewForm,
  RequestEnterpriseHubApplicationRevisionForm,
} from './enterprise-hub-application-review-form';
import {
  EnterpriseHubApplicationReviewStatusSummary,
  loadEnterpriseHubApplicationReviewState,
  readApplicationStatus,
  readBoardType,
} from './enterprise-hub-application-review-state';

type EnterpriseHubApplicationReviewShellProps = {
  selectedApplicationId?: string;
  notice?: string;
  error?: string;
  applicationStatus?: string;
  boardType?: string;
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

export async function EnterpriseHubApplicationReviewShell({
  selectedApplicationId,
  notice,
  error,
  applicationStatus,
  boardType,
}: EnterpriseHubApplicationReviewShellProps) {
  const state = await loadEnterpriseHubApplicationReviewState({
    selectedApplicationId,
    applicationStatus,
    boardType,
  });
  const activeApplicationId =
    selectedApplicationId ?? state.detail?.application.applicationId;

  return (
    <section className="panel review-console governance-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">企业入驻审核子座位</p>
          <h1>Enterprise Hub Application Review Desk</h1>
        </div>
        <span className="badge">只消费 Server Admin canonical surface</span>
      </div>
      <p className="lead">
        `/review/enterprise_hub_applications*` 当前只承接 enterprise onboarding review 的
        列表、详情和 review command。这里不复用 content-safety task、published change
        changeRequest、organization certification organizationId 语义，也不会在 Admin 侧制造第二真相层。
      </p>
      <div className="notice-grid">
        {notice ? <div className="notice">{toNoticeText(notice)}</div> : null}
        {error ? <div className="notice danger">{error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
      </div>
      <EnterpriseHubApplicationReviewFilters
        applicationStatus={applicationStatus}
        boardType={boardType}
      />
      <div className="review-grid governance-grid">
        <EnterpriseHubApplicationReviewList
          items={state.items}
          selectedApplicationId={activeApplicationId}
          total={state.total}
          applicationStatus={applicationStatus}
          boardType={boardType}
        />
        <div className="detail-stack">
          <EnterpriseHubApplicationReviewDetailPanel
            detail={state.detail}
            statusSummary={state.statusSummary}
          />
          <EnterpriseHubApplicationAllowedActionsCard
            detail={state.detail}
            statusSummary={state.statusSummary}
          />
          <ApproveEnterpriseHubApplicationReviewForm
            detail={state.detail}
            statusSummary={state.statusSummary}
            applicationStatus={applicationStatus}
            boardType={boardType}
            submitAction={approveEnterpriseHubApplicationReviewAction}
          />
          <RequestEnterpriseHubApplicationRevisionForm
            detail={state.detail}
            statusSummary={state.statusSummary}
            applicationStatus={applicationStatus}
            boardType={boardType}
            submitAction={requestEnterpriseHubApplicationRevisionAction}
          />
          <RejectEnterpriseHubApplicationReviewForm
            detail={state.detail}
            statusSummary={state.statusSummary}
            applicationStatus={applicationStatus}
            boardType={boardType}
            submitAction={rejectEnterpriseHubApplicationReviewAction}
          />
        </div>
      </div>
    </section>
  );
}

function EnterpriseHubApplicationReviewFilters({
  applicationStatus,
  boardType,
}: {
  applicationStatus?: string;
  boardType?: string;
}) {
  return (
    <form className="filter-card" action="/review/enterprise_hub_applications">
      <label>
        申请状态
        <select name="applicationStatus" defaultValue={applicationStatus ?? ''}>
          <option value="">全部状态</option>
          {STATUS_OPTIONS.map((item) => (
            <option key={item} value={item}>
              {toApplicationStatusLabel(item)}
            </option>
          ))}
        </select>
      </label>
      <label>
        申请板块
        <select name="boardType" defaultValue={boardType ?? ''}>
          <option value="">全部板块</option>
          {BOARD_OPTIONS.map((item) => (
            <option key={item} value={item}>
              {toBoardTypeLabel(item)}
            </option>
          ))}
        </select>
      </label>
      <button className="primary" type="submit">
        筛选企业入驻申请
      </button>
    </form>
  );
}

function EnterpriseHubApplicationReviewList({
  items,
  selectedApplicationId,
  total,
  applicationStatus,
  boardType,
}: {
  items: EnterpriseHubApplicationReviewListItem[];
  selectedApplicationId?: string;
  total: number;
  applicationStatus?: string;
  boardType?: string;
}) {
  if (!items.length) {
    return <div className="empty-card">当前没有服务端返回的企业入驻审核对象。</div>;
  }

  return (
    <div className="review-list" aria-label="enterprise hub application review queue">
      <p className="eyebrow">共 {total} 条</p>
      {items.map((item) => (
        <Link
          className={
            item.applicationId === selectedApplicationId ? 'task-card active' : 'task-card'
          }
          href={buildApplicationReviewDetailHref(item.applicationId, applicationStatus, boardType)}
          key={item.applicationId}
        >
          <span>{toApplicationStatusLabel(item.applicationStatus)}</span>
          <strong>{item.name || item.enterpriseId}</strong>
          <small>{toBoardTypeLabel(item.boardType)} · {item.applicationId}</small>
          <small>
            {joinDisplay(item.provinceName, item.cityName)} · submitted {formatDate(item.submittedAt)}
          </small>
        </Link>
      ))}
    </div>
  );
}

function EnterpriseHubApplicationReviewDetailPanel({
  detail,
  statusSummary,
}: {
  detail: EnterpriseHubApplicationReviewDetailResponse | null;
  statusSummary: EnterpriseHubApplicationReviewStatusSummary | null;
}) {
  if (!detail || !statusSummary) {
    return (
      <div className="review-detail empty-card">
        在拿到有效的服务端管理员会话载体后，可在此查看 enterprise application 的聚合详情并发出 review 命令。
      </div>
    );
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">Application Detail</p>
          <h2>{detail.application.applicationId}</h2>
        </div>
        <span className="badge">{statusSummary.label}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>applicationId</dt><dd>{detail.application.applicationId}</dd></div>
        <div><dt>enterpriseId</dt><dd>{detail.enterprise.enterpriseId}</dd></div>
        <div><dt>organizationId</dt><dd>{detail.enterprise.organizationId}</dd></div>
        <div><dt>enterpriseName</dt><dd>{detail.enterprise.name ?? '暂无'}</dd></div>
        <div><dt>applyBoardType</dt><dd>{toBoardTypeLabel(detail.application.applyBoardType)}</dd></div>
        <div><dt>primaryBoardType</dt><dd>{toBoardTypeLabel(detail.enterprise.primaryBoardType)}</dd></div>
        <div><dt>applicationStatus</dt><dd>{toApplicationStatusLabel(detail.application.applicationStatus)}</dd></div>
        <div><dt>enterpriseStatus</dt><dd>{detail.enterprise.enterpriseStatus}</dd></div>
        <div><dt>displayStatus</dt><dd>{detail.enterprise.displayStatus}</dd></div>
        <div><dt>submittedAt</dt><dd>{formatDate(detail.application.submittedAt)}</dd></div>
        <div><dt>reviewedAt</dt><dd>{formatDate(detail.application.reviewedAt)}</dd></div>
        <div><dt>rejectionReason</dt><dd>{toReasonLabel(detail.application.rejectionReason)}</dd></div>
      </dl>
      <div className="value-compare">
        <div>
          <span>当前审核状态</span>
          <p>{statusSummary.description}</p>
        </div>
        <div>
          <span>聚合载荷概览</span>
          <p>
            profiles {countProfiles(detail)} / cases {detail.cases.length} / certifications{' '}
            {detail.certifications.length} / contacts {detail.contacts.length}
          </p>
        </div>
      </div>
      <dl className="meta-grid compact">
        <div><dt>company profile</dt><dd>{detail.profiles.company ? '已提供' : '暂无'}</dd></div>
        <div><dt>factory profile</dt><dd>{detail.profiles.factory ? '已提供' : '暂无'}</dd></div>
        <div><dt>supplier profile</dt><dd>{detail.profiles.supplier ? '已提供' : '暂无'}</dd></div>
        <div><dt>cases</dt><dd>{detail.cases.length} 条</dd></div>
        <div><dt>certifications</dt><dd>{detail.certifications.length} 条</dd></div>
        <div><dt>contacts</dt><dd>{detail.contacts.length} 条</dd></div>
        <div><dt>secondaryCapabilities</dt><dd>{detail.enterprise.secondaryCapabilities.join(', ') || '暂无'}</dd></div>
        <div><dt>primaryContact</dt><dd>{detail.contacts[0]?.contactName ?? '暂无'}</dd></div>
      </dl>
      <pre className="json-panel">
        {JSON.stringify(
          {
            profiles: detail.profiles,
            cases: detail.cases,
            certifications: detail.certifications,
            contacts: detail.contacts,
          },
          null,
          2,
        )}
      </pre>
    </div>
  );
}

function EnterpriseHubApplicationAllowedActionsCard({
  detail,
  statusSummary,
}: {
  detail: EnterpriseHubApplicationReviewDetailResponse | null;
  statusSummary: EnterpriseHubApplicationReviewStatusSummary | null;
}) {
  if (!detail || !statusSummary) {
    return <div className="action-card empty-card">选中 application 后，才会显示允许动作。</div>;
  }

  return (
    <div className="action-card">
      <div>
        <p className="eyebrow">Allowed Actions</p>
        <h2>当前允许动作</h2>
      </div>
      <dl className="meta-grid compact">
        <div><dt>review</dt><dd>{statusSummary.canReview ? '允许' : '不允许'}</dd></div>
        <div><dt>currentStatus</dt><dd>{statusSummary.label}</dd></div>
        <div><dt>transport</dt><dd>/server/admin/exhibition/enterprise-hub/applications*</dd></div>
      </dl>
      <div className="notice warning">{statusSummary.description}</div>
      <div className="notice">
        当前 desk 只消费 <code>action + reason + reviewNote</code> 命令载荷，不提供 apply、
        audit、content-safety task 或 organization certification 动作。
      </div>
    </div>
  );
}

function buildApplicationReviewDetailHref(
  applicationId: string,
  applicationStatus?: string,
  boardType?: string,
) {
  const params = new URLSearchParams();
  if (readApplicationStatus(applicationStatus)) {
    params.set('applicationStatus', applicationStatus as string);
  }
  if (readBoardType(boardType)) {
    params.set('boardType', boardType as string);
  }
  const query = params.toString();
  return query
    ? `/review/enterprise_hub_applications/${encodeURIComponent(applicationId)}?${query}`
    : `/review/enterprise_hub_applications/${encodeURIComponent(applicationId)}`;
}

function countProfiles(detail: EnterpriseHubApplicationReviewDetailResponse) {
  return [detail.profiles.company, detail.profiles.factory, detail.profiles.supplier].filter(Boolean)
    .length;
}

function toNoticeText(value: string) {
  switch (value) {
    case 'enterprise_hub_application_approved':
      return '企业入驻申请已提交 approved 命令。';
    case 'enterprise_hub_application_revision_required':
      return '企业入驻申请已提交 revision_required 命令。';
    case 'enterprise_hub_application_rejected':
      return '企业入驻申请已提交 rejected 命令。';
    default:
      return value;
  }
}

function toApplicationStatusLabel(status: EnterpriseHubApplicationReviewStatus) {
  switch (status) {
    case 'submitted':
      return '已提交';
    case 'under_review':
      return '审核中';
    case 'approved':
      return '已通过';
    case 'revision_required':
      return '退回修改';
    case 'rejected':
      return '已驳回';
    default:
      return '草稿';
  }
}

function toBoardTypeLabel(boardType: EnterpriseHubApplicationBoardType) {
  switch (boardType) {
    case 'company':
      return '搭建公司';
    case 'factory':
      return '工厂';
    default:
      return '供应商';
  }
}

function toReasonLabel(reason: string | null) {
  if (!reason) {
    return '暂无';
  }
  const item = ENTERPRISE_HUB_APPLICATION_REVIEW_REASON_OPTIONS.find(
    (option) => option.value === reason,
  );
  return item?.label ?? reason;
}

function formatDate(value: string | null) {
  if (!value) {
    return '暂无';
  }
  return new Date(value).toLocaleString('zh-CN', {
    hour12: false,
  });
}

function joinDisplay(...values: Array<string | null | undefined>) {
  const items = values.filter((item) => Boolean(item?.trim()));
  return items.length ? items.join(' / ') : '暂无';
}
