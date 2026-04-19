import Link from 'next/link';
import type {
  EnterpriseHubAdminChangeRequestDetailResponse,
  EnterpriseHubAdminChangeRequestListItem,
} from '@/core/server/admin-api-client';
import {
  applyEnterpriseHubChangeRequestAction,
  approveEnterpriseHubChangeRequestAction,
  rejectEnterpriseHubChangeRequestAction,
  requestEnterpriseHubChangeRevisionAction,
} from './published-change-review-actions';
import {
  PublishedChangeStatusSummary,
  describePublishedChangeStatus,
  loadPublishedChangeReviewState,
} from './published-change-review-state';

type PublishedChangeReviewShellProps = {
  selectedChangeRequestId?: string;
  notice?: string;
  error?: string;
};

export async function PublishedChangeReviewShell({
  selectedChangeRequestId,
  notice,
  error,
}: PublishedChangeReviewShellProps) {
  const state = await loadPublishedChangeReviewState({
    selectedChangeRequestId,
  });
  const activeChangeRequestId =
    selectedChangeRequestId ?? state.detail?.changeRequest.changeRequestId;

  return (
    <section className="panel review-console governance-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">Package B 已发布变更治理台</p>
          <h1>Enterprise Hub Published Change Review / Apply Desk</h1>
        </div>
        <span className="badge">只消费 Server Admin canonical carrier</span>
      </div>
      <p className="lead">
        当前页面只承接 published change corridor 的 review queue、detail、review action、apply action。
        这里不是治理真相 owner，也不会把 <code>approved</code> 伪装成 <code>applied</code>。
      </p>
      <div className="notice-grid">
        {notice ? <div className="notice">{toNoticeText(notice)}</div> : null}
        {error ? <div className="notice danger">{error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
      </div>
      <div className="review-grid governance-grid">
        <PublishedChangeRequestList
          items={state.items}
          selectedChangeRequestId={activeChangeRequestId}
          total={state.total}
        />
        <div className="detail-stack">
          <PublishedChangeRequestDetail
            detail={state.detail}
            statusSummary={state.statusSummary}
          />
          <PublishedChangeAllowedActionsCard
            detail={state.detail}
            statusSummary={state.statusSummary}
          />
          <ApproveChangeRequestForm
            detail={state.detail}
            statusSummary={state.statusSummary}
          />
          <RequestRevisionForm
            detail={state.detail}
            statusSummary={state.statusSummary}
          />
          <RejectChangeRequestForm
            detail={state.detail}
            statusSummary={state.statusSummary}
          />
          <ApplyChangeRequestForm
            detail={state.detail}
            statusSummary={state.statusSummary}
          />
        </div>
      </div>
    </section>
  );
}

function PublishedChangeRequestList({
  items,
  selectedChangeRequestId,
  total,
}: {
  items: EnterpriseHubAdminChangeRequestListItem[];
  selectedChangeRequestId?: string;
  total: number;
}) {
  if (!items.length) {
    return (
      <div className="empty-card">
        当前没有服务端返回的 published change request。
      </div>
    );
  }

  return (
    <div className="review-list" aria-label="published change review queue">
      <p className="eyebrow">共 {total} 条</p>
      {items.map((item) => (
        <Link
          className={
            item.changeRequestId === selectedChangeRequestId
              ? 'task-card active'
              : 'task-card'
          }
          href={`/review/change_requests/${encodeURIComponent(item.changeRequestId)}`}
          key={item.changeRequestId}
        >
          <span>{toChangeStatusLabel(item.changeStatus)}</span>
          <strong>{item.enterpriseName ?? item.enterpriseId}</strong>
          <small>{toBoardTypeLabel(item.boardType)} · {item.changeRequestId}</small>
          <small>
            submitted {formatDate(item.submittedAt)} · applied {formatDate(item.appliedAt)}
          </small>
        </Link>
      ))}
    </div>
  );
}

function PublishedChangeRequestDetail({
  detail,
  statusSummary,
}: {
  detail: EnterpriseHubAdminChangeRequestDetailResponse | null;
  statusSummary: PublishedChangeStatusSummary | null;
}) {
  if (!detail || !statusSummary) {
    return (
      <div className="review-detail empty-card">
        在拿到有效的服务端管理员会话载体后，可在此查看 published change request 的
        change snapshot、live snapshot 与治理状态。
      </div>
    );
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">Change Request Detail</p>
          <h2>{detail.changeRequest.changeRequestId}</h2>
        </div>
        <span className="badge">{statusSummary.label}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>enterpriseId</dt><dd>{detail.enterprise.enterpriseId}</dd></div>
        <div><dt>organizationId</dt><dd>{detail.enterprise.organizationId}</dd></div>
        <div><dt>enterpriseName</dt><dd>{detail.enterprise.name ?? '暂无'}</dd></div>
        <div><dt>boardType</dt><dd>{toBoardTypeLabel(detail.changeRequest.boardType)}</dd></div>
        <div><dt>changeStatus</dt><dd>{toChangeStatusLabel(detail.changeRequest.changeStatus)}</dd></div>
        <div><dt>submittedAt</dt><dd>{formatDate(detail.changeRequest.submittedAt)}</dd></div>
        <div><dt>reviewedAt</dt><dd>{formatDate(detail.changeRequest.reviewedAt)}</dd></div>
        <div><dt>appliedAt</dt><dd>{formatDate(detail.changeRequest.appliedAt)}</dd></div>
        <div><dt>enterpriseStatus</dt><dd>{detail.enterprise.enterpriseStatus}</dd></div>
        <div><dt>displayStatus</dt><dd>{detail.enterprise.displayStatus}</dd></div>
      </dl>
      <div className="value-compare">
        <div>
          <span>当前治理状态</span>
          <p>{statusSummary.description}</p>
        </div>
        <div>
          <span>live snapshot</span>
          <p>
            {detail.liveSnapshot.enterpriseStatus} / {detail.liveSnapshot.displayStatus}
            <br />
            publishedAt: {formatDate(detail.liveSnapshot.publishedAt)}
          </p>
        </div>
      </div>
      <dl className="meta-grid compact">
        <div><dt>basic.name</dt><dd>{detail.basic?.name ?? '暂无'}</dd></div>
        <div><dt>basic.shortIntro</dt><dd>{detail.basic?.shortIntro ?? '暂无'}</dd></div>
        <div><dt>basic.city</dt><dd>{joinDisplay(detail.basic?.provinceName, detail.basic?.cityName)}</dd></div>
        <div><dt>basic.contactVisible</dt><dd>{detail.basic?.contactVisible ? '是' : '否'}</dd></div>
        <div><dt>primaryContact</dt><dd>{detail.primaryContact?.contactName ?? '暂无'}</dd></div>
        <div><dt>contactMobile</dt><dd>{detail.primaryContact?.mobile ?? '暂无'}</dd></div>
        <div><dt>reviewNote</dt><dd>{detail.changeRequest.reviewNote ?? '暂无'}</dd></div>
        <div><dt>cases</dt><dd>{detail.cases.length} 条</dd></div>
      </dl>
      <div className="value-compare">
        <div>
          <span>change snapshot</span>
          <p>{detail.basic?.fullIntro ?? detail.basic?.shortIntro ?? '暂无'}</p>
        </div>
        <div>
          <span>board profile</span>
          <p>当前 detail 同时回显 board-specific snapshot，不把 workbench list 扩成第二真相。</p>
        </div>
      </div>
      <pre className="json-panel">
        {JSON.stringify(
          {
            boardProfile: detail.boardProfile ?? null,
            primaryContact: detail.primaryContact ?? null,
            cases: detail.cases,
          },
          null,
          2,
        )}
      </pre>
    </div>
  );
}

function PublishedChangeAllowedActionsCard({
  detail,
  statusSummary,
}: {
  detail: EnterpriseHubAdminChangeRequestDetailResponse | null;
  statusSummary: PublishedChangeStatusSummary | null;
}) {
  if (!detail || !statusSummary) {
    return <div className="action-card empty-card">选中 change request 后，才会显示允许动作。</div>;
  }

  return (
    <div className="action-card">
      <div>
        <p className="eyebrow">Allowed Actions</p>
        <h2>当前允许动作</h2>
      </div>
      <dl className="meta-grid compact">
        <div><dt>review</dt><dd>{statusSummary.canReview ? '允许' : '不允许'}</dd></div>
        <div><dt>apply</dt><dd>{statusSummary.canApply ? '允许' : '不允许'}</dd></div>
        <div><dt>currentStatus</dt><dd>{statusSummary.label}</dd></div>
      </dl>
      <div className="notice warning">
        {statusSummary.description}
      </div>
      <div className="notice">
        {detail.changeRequest.changeStatus === 'approved'
          ? '当前只是审核通过。只有点击 apply 后，live listing 才会更新。'
          : detail.changeRequest.changeStatus === 'applied'
            ? '当前 change request 已经写入 live listing，不再开放 apply。'
            : '当前页面只消费服务端治理真相，不在 Admin surface 本地推导第二状态机。'}
      </div>
    </div>
  );
}

function ApproveChangeRequestForm({
  detail,
  statusSummary,
}: {
  detail: EnterpriseHubAdminChangeRequestDetailResponse | null;
  statusSummary: PublishedChangeStatusSummary | null;
}) {
  if (!detail || !statusSummary?.canReview) {
    return <div className="action-card empty-card">当前状态不开放 approved 决策。</div>;
  }

  return (
    <form className="action-card" action={approveEnterpriseHubChangeRequestAction}>
      <input name="changeRequestId" type="hidden" value={detail.changeRequest.changeRequestId} />
      <div>
        <p className="eyebrow">Review</p>
        <h2>审核通过</h2>
      </div>
      <label>
        reviewNote
        <textarea name="reviewNote" maxLength={500} placeholder="可选，补充审核通过说明。" />
      </label>
      <div className="notice">
        approved 只表示审核通过，不会自动写入 live listing。
      </div>
      <button className="primary" type="submit">提交 approved</button>
    </form>
  );
}

function RequestRevisionForm({
  detail,
  statusSummary,
}: {
  detail: EnterpriseHubAdminChangeRequestDetailResponse | null;
  statusSummary: PublishedChangeStatusSummary | null;
}) {
  if (!detail || !statusSummary?.canReview) {
    return <div className="action-card empty-card">当前状态不开放 revision_required 决策。</div>;
  }

  return (
    <form className="action-card" action={requestEnterpriseHubChangeRevisionAction}>
      <input name="changeRequestId" type="hidden" value={detail.changeRequest.changeRequestId} />
      <div>
        <p className="eyebrow">Review</p>
        <h2>退回修改</h2>
      </div>
      <label>
        退回原因
        <textarea
          name="reviewNote"
          required
          maxLength={500}
          placeholder="必填，说明为什么要回到同一条 changeRequestId 继续修改。"
        />
      </label>
      <button className="primary" type="submit">提交 revision_required</button>
    </form>
  );
}

function RejectChangeRequestForm({
  detail,
  statusSummary,
}: {
  detail: EnterpriseHubAdminChangeRequestDetailResponse | null;
  statusSummary: PublishedChangeStatusSummary | null;
}) {
  if (!detail || !statusSummary?.canReview) {
    return <div className="action-card empty-card">当前状态不开放 rejected 决策。</div>;
  }

  return (
    <form className="action-card danger-card" action={rejectEnterpriseHubChangeRequestAction}>
      <input name="changeRequestId" type="hidden" value={detail.changeRequest.changeRequestId} />
      <div>
        <p className="eyebrow">Review</p>
        <h2>驳回变更</h2>
      </div>
      <label>
        驳回原因
        <textarea
          name="reviewNote"
          required
          maxLength={500}
          placeholder="必填，说明为什么当前 change request 不应进入上线 apply。"
        />
      </label>
      <button className="primary danger-button" type="submit">提交 rejected</button>
    </form>
  );
}

function ApplyChangeRequestForm({
  detail,
  statusSummary,
}: {
  detail: EnterpriseHubAdminChangeRequestDetailResponse | null;
  statusSummary: PublishedChangeStatusSummary | null;
}) {
  if (!detail) {
    return <div className="action-card empty-card">选中 change request 后，才会显示 apply 动作。</div>;
  }
  if (!statusSummary?.canApply) {
    return (
      <div className="action-card empty-card">
        当前状态不是 approved-but-not-applied，不开放 apply。
      </div>
    );
  }

  return (
    <form className="action-card" action={applyEnterpriseHubChangeRequestAction}>
      <input name="changeRequestId" type="hidden" value={detail.changeRequest.changeRequestId} />
      <div>
        <p className="eyebrow">Apply</p>
        <h2>写入 live listing</h2>
      </div>
      <div className="notice warning">
        这是与 review 分离的独立动作。只有当前 change request 处于 approved 时，才允许执行 apply。
      </div>
      <button className="primary" type="submit">执行 apply</button>
    </form>
  );
}

function toNoticeText(value: string) {
  if (value === 'change_request_approved') {
    return '已向服务端提交 approved 决策。当前仍未 apply 到 live listing。';
  }
  if (value === 'change_request_revision_required') {
    return '已向服务端提交 revision_required 决策。';
  }
  if (value === 'change_request_rejected') {
    return '已向服务端提交 rejected 决策。';
  }
  if (value === 'change_request_applied') {
    return '已向服务端提交 apply 动作，当前应以 live listing 新真值为准。';
  }
  return value;
}

function toChangeStatusLabel(value: string) {
  switch (value) {
    case 'submitted':
      return '已提交';
    case 'under_review':
      return '审核中';
    case 'revision_required':
      return '退回修改';
    case 'approved':
      return '审核通过';
    case 'rejected':
      return '已驳回';
    case 'applied':
      return '已 apply';
    default:
      return '草稿';
  }
}

function toBoardTypeLabel(value: string) {
  if (value === 'company') {
    return '公司';
  }
  if (value === 'factory') {
    return '工厂';
  }
  if (value === 'supplier') {
    return '供应商';
  }
  return value;
}

function formatDate(value: string | null | undefined) {
  if (!value) {
    return '暂无';
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime())
    ? value
    : date.toLocaleString('zh-CN', { hour12: false });
}

function joinDisplay(left?: string | null, right?: string | null) {
  return [left, right].filter(Boolean).join(' / ') || '暂无';
}
