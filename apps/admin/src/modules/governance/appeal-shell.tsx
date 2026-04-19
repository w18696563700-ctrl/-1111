import Link from 'next/link';
import {
  AdminApiError,
  AdminGovernanceAppealDetail,
  AdminGovernanceAppealListItem,
  GovernanceAppealDecision,
  GovernanceAppealStatus,
  fetchGovernanceAppeal,
  fetchGovernanceAppeals
} from '@/core/server/admin-api-client';
import { decideGovernanceAppealAction } from './appeal-actions';
import { GovernanceTabs } from './governance-tabs';

type AppealShellProps = {
  selectedAppealCaseId?: string;
  notice?: string;
  error?: string;
  status?: string;
  keyword?: string;
};

type AppealState = {
  items: AdminGovernanceAppealListItem[];
  detail: AdminGovernanceAppealDetail | null;
  total: number;
  error: string | null;
};

const STATUS_OPTIONS: GovernanceAppealStatus[] = [
  'submitted',
  'under_review',
  'upheld',
  'modified',
  'revoked',
  'closed'
];
const DECISION_OPTIONS: GovernanceAppealDecision[] = ['uphold', 'modify', 'revoke'];

export async function AppealShell({
  selectedAppealCaseId,
  notice,
  error,
  status,
  keyword
}: AppealShellProps) {
  const state = await loadAppealState({ selectedAppealCaseId, status, keyword });

  return (
    <section className="panel review-console governance-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">CS-028 治理</p>
          <h1>治理申诉</h1>
        </div>
        <span className="badge">仅调用服务端管理接口</span>
      </div>
      <p className="lead">
        这是 CS-028 的最小管理消费面。申诉真相与处罚侧效果仍然归属服务端；当前控制台只负责列表、详情与有界裁决命令提交。
      </p>
      <GovernanceTabs tab="appeals" />
      <div className="notice-grid">
        {notice ? <div className="notice">{toNoticeText(notice)}</div> : null}
        {error ? <div className="notice danger">{error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
      </div>
      <AppealFilters status={status} keyword={keyword} />
      <div className="review-grid governance-grid">
        <AppealList items={state.items} selectedAppealCaseId={selectedAppealCaseId} total={state.total} />
        <div className="detail-stack">
          <AppealDetailPanel detail={state.detail} />
          <AppealDecideForm detail={state.detail} />
        </div>
      </div>
    </section>
  );
}

async function loadAppealState(input: {
  selectedAppealCaseId?: string;
  status?: string;
  keyword?: string;
}): Promise<AppealState> {
  try {
    const list = await fetchGovernanceAppeals({
      page: 1,
      pageSize: 20,
      status: readStatus(input.status),
      keyword: input.keyword?.trim() || undefined
    });
    const appealCaseId = input.selectedAppealCaseId ?? list.items[0]?.appealCaseId;
    const detail = appealCaseId ? await fetchGovernanceAppeal(appealCaseId) : null;
    return {
      items: list.items,
      detail,
      total: list.pagination.total,
      error: null
    };
  } catch (error) {
    return { items: [], detail: null, total: 0, error: toLoadError(error) };
  }
}

function AppealFilters({ status, keyword }: { status?: string; keyword?: string }) {
  return (
    <form className="filter-card" action="/governance/appeals">
      <label>
        状态
        <select name="status" defaultValue={status ?? ''}>
          <option value="">全部状态</option>
          {STATUS_OPTIONS.map((item) => (
            <option key={item} value={item}>{toAppealStatusLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        关键词
        <input name="keyword" defaultValue={keyword ?? ''} placeholder="申诉 ID、处罚 ID、原因" />
      </label>
      <button className="primary" type="submit">筛选申诉</button>
    </form>
  );
}

function AppealList({
  items,
  selectedAppealCaseId,
  total
}: {
  items: AdminGovernanceAppealListItem[];
  selectedAppealCaseId?: string;
  total: number;
}) {
  if (!items.length) {
    return <div className="empty-card">当前没有服务端返回的治理申诉记录。</div>;
  }

  return (
    <div className="review-list" aria-label="治理申诉">
      <p className="eyebrow">共 {total} 条</p>
      {items.map((item) => (
        <Link
          className={item.appealCaseId === selectedAppealCaseId ? 'task-card active' : 'task-card'}
          href={`/governance/appeals/${encodeURIComponent(item.appealCaseId)}`}
          key={item.appealCaseId}
        >
          <span>{toAppealStatusLabel(item.status)}</span>
          <strong>{item.appealCaseId}</strong>
          <small>处罚 ID：{item.penaltyId}</small>
          <small>{formatDate(item.submittedAt)}</small>
        </Link>
      ))}
    </div>
  );
}

function AppealDetailPanel({ detail }: { detail: AdminGovernanceAppealDetail | null }) {
  if (!detail) {
    return (
      <div className="review-detail empty-card">
        在拿到有效的服务端管理员会话载体后，可在此查看申诉详情。
      </div>
    );
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">申诉详情</p>
          <h2>{detail.appealCaseId}</h2>
        </div>
        <span className="badge">{toAppealStatusLabel(detail.status)}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>申诉 ID</dt><dd>{detail.appealCaseId}</dd></div>
        <div><dt>处罚 ID</dt><dd>{detail.penaltyId}</dd></div>
        <div><dt>提交时间</dt><dd>{formatDate(detail.submittedAt)}</dd></div>
        <div><dt>裁决时间</dt><dd>{formatDate(detail.decidedAt)}</dd></div>
      </dl>
      <div className="value-compare single">
        <div><span>申诉原因</span><p>{detail.reason}</p></div>
        <div><span>裁决备注</span><p>{detail.decisionNote ?? '暂无'}</p></div>
      </div>
      <pre className="json-panel">{JSON.stringify({ evidenceFileAssetIds: detail.evidenceFileAssetIds ?? [] }, null, 2)}</pre>
    </div>
  );
}

function AppealDecideForm({ detail }: { detail: AdminGovernanceAppealDetail | null }) {
  if (!detail) {
    return (
      <div className="action-card empty-card">
        选中申诉记录后，才会开放有界裁决命令。
      </div>
    );
  }

  return (
    <form className="action-card" action={decideGovernanceAppealAction}>
      <input name="appealCaseId" type="hidden" value={detail.appealCaseId} />
      <div>
        <p className="eyebrow">裁决申诉</p>
        <h2>CS-028 有界裁决入口</h2>
      </div>
      <label>
        裁决结论
        <select name="decision" required defaultValue="uphold">
          {DECISION_OPTIONS.map((item) => (
            <option key={item} value={item}>{toAppealDecisionLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        裁决备注
        <textarea name="decisionNote" maxLength={500} placeholder="可选，填写本次有界裁决说明" />
      </label>
      <div className="notice warning">
        当前表单只开放服务端已支持的 CS-028 有界裁决字段。
      </div>
      <button className="primary" type="submit">提交到服务端</button>
    </form>
  );
}

function readStatus(value: string | undefined): GovernanceAppealStatus | undefined {
  if (!value) {
    return undefined;
  }
  return STATUS_OPTIONS.includes(value as GovernanceAppealStatus)
    ? value as GovernanceAppealStatus
    : undefined;
}

function formatDate(value: string | null | undefined) {
  if (!value) {
    return '暂无';
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString('zh-CN', { hour12: false });
}

function toLoadError(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '无法从服务端管理接口加载治理申诉。';
}

function toNoticeText(value: string) {
  if (value === 'appeal_decided') {
    return '治理申诉裁决命令已提交到服务端。';
  }
  return value;
}

function toAppealStatusLabel(status: string) {
  if (status === 'submitted') {
    return '已提交';
  }
  if (status === 'under_review') {
    return '审核中';
  }
  if (status === 'upheld') {
    return '维持原判';
  }
  if (status === 'modified') {
    return '已调整';
  }
  if (status === 'revoked') {
    return '已撤销';
  }
  if (status === 'closed') {
    return '已关闭';
  }
  return status;
}

function toAppealDecisionLabel(decision: string) {
  if (decision === 'uphold') {
    return '维持原判';
  }
  if (decision === 'modify') {
    return '调整处罚';
  }
  if (decision === 'revoke') {
    return '撤销处罚';
  }
  return decision;
}
