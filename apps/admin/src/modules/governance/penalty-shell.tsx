import Link from 'next/link';
import {
  AdminApiError,
  AdminGovernancePenaltyDetail,
  AdminGovernancePenaltyListItem,
  GovernancePenaltyStatus,
  fetchGovernancePenalties,
  fetchGovernancePenalty
} from '@/core/server/admin-api-client';
import { applyGovernancePenaltyAction } from './penalty-actions';
import { GovernanceTabs } from './governance-tabs';

type PenaltyShellProps = {
  selectedPenaltyId?: string;
  notice?: string;
  error?: string;
  status?: string;
  keyword?: string;
};

type PenaltyState = {
  items: AdminGovernancePenaltyListItem[];
  detail: AdminGovernancePenaltyDetail | null;
  total: number;
  error: string | null;
};

const STATUS_OPTIONS: GovernancePenaltyStatus[] = ['active', 'lifted', 'expired'];
const PENALTY_TYPES = ['warning', 'watchlist', 'restrict_publish', 'restrict_bid', 'blacklist'];
const SUBJECT_TYPES = ['organization', 'organization_member'];

export async function PenaltyShell({
  selectedPenaltyId,
  notice,
  error,
  status,
  keyword
}: PenaltyShellProps) {
  const state = await loadPenaltyState({ selectedPenaltyId, status, keyword });

  return (
    <section className="panel review-console governance-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">CS-027 治理</p>
          <h1>治理处罚</h1>
        </div>
        <span className="badge">仅调用服务端管理接口</span>
      </div>
      <p className="lead">
        这是 CS-027 的最小管理消费面。处罚真相、状态与审计仍然归属服务端；当前控制台只负责列表、详情与有界处罚命令提交。
      </p>
      <GovernanceTabs tab="penalties" />
      <div className="notice-grid">
        {notice ? <div className="notice">{toNoticeText(notice)}</div> : null}
        {error ? <div className="notice danger">{error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
      </div>
      <PenaltyFilters status={status} keyword={keyword} />
      <div className="review-grid governance-grid">
        <PenaltyList items={state.items} selectedPenaltyId={selectedPenaltyId} total={state.total} />
        <div className="detail-stack">
          <PenaltyDetailPanel detail={state.detail} />
          <PenaltyApplyForm />
        </div>
      </div>
    </section>
  );
}

async function loadPenaltyState(input: {
  selectedPenaltyId?: string;
  status?: string;
  keyword?: string;
}): Promise<PenaltyState> {
  try {
    const list = await fetchGovernancePenalties({
      page: 1,
      pageSize: 20,
      status: readStatus(input.status),
      keyword: input.keyword?.trim() || undefined
    });
    const penaltyId = input.selectedPenaltyId ?? list.items[0]?.penaltyId;
    const detail = penaltyId ? await fetchGovernancePenalty(penaltyId) : null;
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

function PenaltyFilters({ status, keyword }: { status?: string; keyword?: string }) {
  return (
    <form className="filter-card" action="/governance/penalties">
      <label>
        状态
        <select name="status" defaultValue={status ?? ''}>
          <option value="">全部状态</option>
          {STATUS_OPTIONS.map((item) => (
            <option key={item} value={item}>{toPenaltyStatusLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        关键词
        <input name="keyword" defaultValue={keyword ?? ''} placeholder="主体 ID、原因编码" />
      </label>
      <button className="primary" type="submit">筛选处罚</button>
    </form>
  );
}

function PenaltyList({
  items,
  selectedPenaltyId,
  total
}: {
  items: AdminGovernancePenaltyListItem[];
  selectedPenaltyId?: string;
  total: number;
}) {
  if (!items.length) {
    return <div className="empty-card">当前没有服务端返回的治理处罚记录。</div>;
  }

  return (
    <div className="review-list" aria-label="治理处罚">
      <p className="eyebrow">共 {total} 条</p>
      {items.map((item) => (
        <Link
          className={item.penaltyId === selectedPenaltyId ? 'task-card active' : 'task-card'}
          href={`/governance/penalties/${encodeURIComponent(item.penaltyId)}`}
          key={item.penaltyId}
        >
          <span>{toPenaltyTypeLabel(item.penaltyType)} · {toPenaltyStatusLabel(item.status)}</span>
          <strong>{toSubjectTypeLabel(item.subjectType)}：{item.subjectId}</strong>
          <small>{formatDate(item.effectiveFrom)} - {formatDate(item.effectiveUntil)}</small>
        </Link>
      ))}
    </div>
  );
}

function PenaltyDetailPanel({ detail }: { detail: AdminGovernancePenaltyDetail | null }) {
  if (!detail) {
    return (
      <div className="review-detail empty-card">
        在拿到有效的服务端管理员会话载体后，可在此查看处罚详情。
      </div>
    );
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">处罚详情</p>
          <h2>{toPenaltyTypeLabel(detail.penaltyType)}</h2>
        </div>
        <span className="badge">{toPenaltyStatusLabel(detail.status)}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>处罚 ID</dt><dd>{detail.penaltyId}</dd></div>
        <div><dt>主体</dt><dd>{toSubjectTypeLabel(detail.subjectType)}：{detail.subjectId}</dd></div>
        <div><dt>原因编码</dt><dd>{detail.reasonCode}</dd></div>
        <div><dt>创建人</dt><dd>{detail.createdBy ?? '暂无'}</dd></div>
        <div><dt>生效开始</dt><dd>{formatDate(detail.effectiveFrom)}</dd></div>
        <div><dt>生效截止</dt><dd>{formatDate(detail.effectiveUntil)}</dd></div>
        <div><dt>创建时间</dt><dd>{formatDate(detail.createdAt)}</dd></div>
      </dl>
      <div className="value-compare single">
        <div><span>原因摘要</span><p>{detail.reasonSummary ?? '暂无'}</p></div>
      </div>
      <pre className="json-panel">{JSON.stringify({ evidenceFileAssetIds: detail.evidenceFileAssetIds ?? [] }, null, 2)}</pre>
    </div>
  );
}

function PenaltyApplyForm() {
  return (
    <form className="action-card penalty-apply-card" action={applyGovernancePenaltyAction}>
      <div>
        <p className="eyebrow">发起处罚</p>
        <h2>CS-027 有界处罚入口</h2>
      </div>
      <label>
        主体类型
        <select name="subjectType" required defaultValue="organization">
          {SUBJECT_TYPES.map((item) => (
            <option key={item} value={item}>{toSubjectTypeLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        主体 ID
        <input name="subjectId" required maxLength={64} placeholder="填写组织或组织成员 ID" />
      </label>
      <label>
        处罚类型
        <select name="penaltyType" required defaultValue="warning">
          {PENALTY_TYPES.map((item) => (
            <option key={item} value={item}>{toPenaltyTypeLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        原因编码
        <input name="reasonCode" required maxLength={64} placeholder="例如 manual_review_violation" />
      </label>
      <label>
        原因摘要
        <textarea name="reasonSummary" maxLength={500} placeholder="可选，填写本次有界处罚说明" />
      </label>
      <label>
        生效截止时间
        <input name="effectiveUntil" type="datetime-local" />
      </label>
      <label>
        证据 FileAsset ID 列表
        <textarea name="evidenceFileAssetIds" placeholder="可选，使用逗号或换行分隔 FileAsset ID" />
      </label>
      <div className="notice warning">
        当前表单只开放服务端已支持的 CS-027 有界处罚字段。
      </div>
      <button className="primary" type="submit">提交到服务端</button>
    </form>
  );
}

function readStatus(value: string | undefined): GovernancePenaltyStatus | undefined {
  if (!value) {
    return undefined;
  }
  return STATUS_OPTIONS.includes(value as GovernancePenaltyStatus)
    ? value as GovernancePenaltyStatus
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
  return error instanceof Error ? error.message : '无法从服务端管理接口加载治理处罚。';
}

function toNoticeText(value: string) {
  if (value === 'penalty_applied') {
    return '治理处罚命令已提交到服务端。';
  }
  return value;
}

function toPenaltyStatusLabel(status: string) {
  if (status === 'active') {
    return '生效中';
  }
  if (status === 'lifted') {
    return '已解除';
  }
  if (status === 'expired') {
    return '已过期';
  }
  return status;
}

function toPenaltyTypeLabel(type: string) {
  if (type === 'warning') {
    return '警告';
  }
  if (type === 'watchlist') {
    return '观察名单';
  }
  if (type === 'restrict_publish') {
    return '限制发布';
  }
  if (type === 'restrict_bid') {
    return '限制投标';
  }
  if (type === 'blacklist') {
    return '黑名单';
  }
  return type;
}

function toSubjectTypeLabel(type: string) {
  if (type === 'organization') {
    return '组织';
  }
  if (type === 'organization_member') {
    return '组织成员';
  }
  return type;
}
