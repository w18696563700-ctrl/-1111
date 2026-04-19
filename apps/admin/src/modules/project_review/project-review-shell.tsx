import Link from 'next/link';
import type {
  AdminExhibitionReportCaseDetail,
  AdminExhibitionReportCaseListItem,
  ExhibitionReportAdjudicationResult
} from '@/core/server/admin-api-client';
import {
  decideExhibitionReportCaseAction,
  escalateExhibitionReportCaseAction,
  requestExhibitionReportExplanationAction
} from './project-review-actions';
import { loadProjectReviewState } from './project-review-state';

type ProjectReviewShellProps = {
  selectedReportCaseId?: string;
  notice?: string;
  error?: string;
  status?: string;
  targetType?: string;
  keyword?: string;
};

const STATUS_OPTIONS = [
  'submitted',
  'under_review',
  'explanation_requested',
  'escalated',
  'decided',
  'closed'
] as const;

const TARGET_TYPE_OPTIONS = [
  'project',
  'project_profile',
  'bid',
  'contract',
  'inspection'
] as const;

const ADJUDICATION_RESULTS: ExhibitionReportAdjudicationResult[] = [
  'not_established',
  'partially_established',
  'materially_established'
];

export async function ProjectReviewShell({
  selectedReportCaseId,
  notice,
  error,
  status,
  targetType,
  keyword
}: ProjectReviewShellProps) {
  const state = await loadProjectReviewState({
    selectedReportCaseId,
    status,
    targetType,
    keyword
  });

  return (
    <section className="panel review-console governance-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">Package B 案件台</p>
          <h1>展会举报案件队列与裁决台</h1>
        </div>
        <span className="badge">仅调用服务端管理接口</span>
      </div>
      <p className="lead">
        `/project_review` 在当前轮次只承接 exhibition report-case queue、detail、request explanation、decide、escalate。
        它不是项目发布审核通过后发布的状态机，也不拥有第二案件真源。
      </p>
      <div className="notice-grid">
        {notice ? <div className="notice">{toNoticeText(notice)}</div> : null}
        {error ? <div className="notice danger">{error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
      </div>
      <ProjectReviewFilters status={status} targetType={targetType} keyword={keyword} />
      <div className="review-grid governance-grid">
        <ProjectReviewList
          items={state.items}
          selectedReportCaseId={selectedReportCaseId}
          total={state.total}
        />
        <div className="detail-stack">
          <ProjectReviewDetail detail={state.detail} />
          <RequestExplanationForm detail={state.detail} />
          <DecideReportCaseForm detail={state.detail} />
          <EscalateReportCaseForm detail={state.detail} />
        </div>
      </div>
    </section>
  );
}

function ProjectReviewFilters({
  status,
  targetType,
  keyword
}: {
  status?: string;
  targetType?: string;
  keyword?: string;
}) {
  return (
    <form className="filter-card" action="/project_review">
      <label>
        案件状态
        <select name="status" defaultValue={status ?? ''}>
          <option value="">全部状态</option>
          {STATUS_OPTIONS.map((item) => (
            <option key={item} value={item}>{toStatusLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        目标类型
        <select name="targetType" defaultValue={targetType ?? ''}>
          <option value="">全部目标</option>
          {TARGET_TYPE_OPTIONS.map((item) => (
            <option key={item} value={item}>{toTargetTypeLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        关键词
        <input
          name="keyword"
          defaultValue={keyword ?? ''}
          placeholder="目标 ID、原因编码、reviewTaskId、ticketId"
        />
      </label>
      <button className="primary" type="submit">筛选案件</button>
    </form>
  );
}

function ProjectReviewList({
  items,
  selectedReportCaseId,
  total
}: {
  items: AdminExhibitionReportCaseListItem[];
  selectedReportCaseId?: string;
  total: number;
}) {
  if (!items.length) {
    return <div className="empty-card">当前没有服务端返回的 exhibition report-case。</div>;
  }

  return (
    <div className="review-list" aria-label="展会举报案件队列">
      <p className="eyebrow">共 {total} 条</p>
      {items.map((item) => (
        <Link
          className={item.reportCaseId === selectedReportCaseId ? 'task-card active' : 'task-card'}
          href={`/project_review/${encodeURIComponent(item.reportCaseId)}`}
          key={item.reportCaseId}
        >
          <span>{toStatusLabel(item.status)} · {toRestrictionLabel(item.temporaryRestrictionState)}</span>
          <strong>{toTargetTypeLabel(item.targetType)}：{item.targetId}</strong>
          <small>{item.reasonCode}</small>
          <small>{formatDate(item.submittedAt)}</small>
        </Link>
      ))}
    </div>
  );
}

function ProjectReviewDetail({ detail }: { detail: AdminExhibitionReportCaseDetail | null }) {
  if (!detail) {
    return (
      <div className="review-detail empty-card">
        在拿到有效的服务端管理员会话载体后，可在此查看举报案件详情并执行有界裁决动作。
      </div>
    );
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">案件详情</p>
          <h2>{detail.reportCaseId}</h2>
        </div>
        <span className="badge">{toStatusLabel(detail.status)}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>reportCaseId</dt><dd>{detail.reportCaseId}</dd></div>
        <div><dt>targetType</dt><dd>{toTargetTypeLabel(detail.targetType)}</dd></div>
        <div><dt>targetId</dt><dd>{detail.targetId}</dd></div>
        <div><dt>reasonCode</dt><dd>{detail.reasonCode}</dd></div>
        <div><dt>status</dt><dd>{toStatusLabel(detail.status)}</dd></div>
        <div><dt>temporaryRestrictionState</dt><dd>{toRestrictionLabel(detail.temporaryRestrictionState)}</dd></div>
        <div><dt>reviewTaskId</dt><dd>{detail.reviewTaskId ?? '暂无'}</dd></div>
        <div><dt>governanceTicketId</dt><dd>{detail.governanceTicketId ?? '暂无'}</dd></div>
        <div><dt>submittedAt</dt><dd>{formatDate(detail.submittedAt)}</dd></div>
        <div><dt>explanationRequestedAt</dt><dd>{formatDate(detail.explanationRequestedAt)}</dd></div>
        <div><dt>explanationReceivedAt</dt><dd>{formatDate(detail.explanationReceivedAt)}</dd></div>
        <div><dt>adjudicationResult</dt><dd>{toAdjudicationLabel(detail.adjudicationResult)}</dd></div>
        <div><dt>decidedAt</dt><dd>{formatDate(detail.decidedAt)}</dd></div>
      </dl>
      <div className="value-compare single">
        <div><span>reasonDetail</span><p>{detail.reasonDetail ?? '暂无'}</p></div>
        <div><span>decisionNote</span><p>{detail.decisionNote ?? '暂无'}</p></div>
      </div>
      <pre className="json-panel">
        {JSON.stringify(
          {
            reporter: detail.reporter ?? null,
            evidenceFileAssetIds: detail.evidenceFileAssetIds ?? []
          },
          null,
          2
        )}
      </pre>
    </div>
  );
}

function RequestExplanationForm({ detail }: { detail: AdminExhibitionReportCaseDetail | null }) {
  if (!detail) {
    return <div className="action-card empty-card">选中案件后，才会开放说明请求动作。</div>;
  }

  return (
    <form className="action-card" action={requestExhibitionReportExplanationAction}>
      <input name="reportCaseId" type="hidden" value={detail.reportCaseId} />
      <div>
        <p className="eyebrow">Request Explanation</p>
        <h2>说明请求</h2>
      </div>
      <label>
        问题
        <textarea
          name="question"
          required
          maxLength={500}
          placeholder="向被举报方请求补充说明或材料来源。"
        />
      </label>
      <label>
        说明截止时间
        <input name="dueAt" type="datetime-local" />
      </label>
      <button className="primary" type="submit">提交说明请求</button>
    </form>
  );
}

function DecideReportCaseForm({ detail }: { detail: AdminExhibitionReportCaseDetail | null }) {
  if (!detail) {
    return <div className="action-card empty-card">选中案件后，才会开放裁决动作。</div>;
  }

  return (
    <form className="action-card" action={decideExhibitionReportCaseAction}>
      <input name="reportCaseId" type="hidden" value={detail.reportCaseId} />
      <div>
        <p className="eyebrow">Decide</p>
        <h2>裁决案件</h2>
      </div>
      <label>
        adjudicationResult
        <select name="adjudicationResult" required defaultValue="not_established">
          {ADJUDICATION_RESULTS.map((item) => (
            <option key={item} value={item}>{toAdjudicationLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        decisionNote
        <textarea name="decisionNote" maxLength={500} placeholder="可选，填写本次裁决说明" />
      </label>
      <button className="primary" type="submit">提交裁决</button>
    </form>
  );
}

function EscalateReportCaseForm({ detail }: { detail: AdminExhibitionReportCaseDetail | null }) {
  if (!detail) {
    return <div className="action-card empty-card">选中案件后，才会开放升级动作。</div>;
  }

  return (
    <form className="action-card danger-card" action={escalateExhibitionReportCaseAction}>
      <input name="reportCaseId" type="hidden" value={detail.reportCaseId} />
      <div>
        <p className="eyebrow">Escalate</p>
        <h2>升级到治理链</h2>
      </div>
      <label>
        升级原因
        <textarea name="reason" required maxLength={500} placeholder="说明为何升级到治理票据链。" />
      </label>
      <div className="notice warning">
        当前动作只生成服务端治理升级引用，不在这里展开 ticket routing console。
      </div>
      <button className="primary danger-button" type="submit">升级案件</button>
    </form>
  );
}

function formatDate(value: string | null | undefined) {
  if (!value) {
    return '暂无';
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString('zh-CN', { hour12: false });
}

function toNoticeText(value: string) {
  if (value === 'explanation_requested') {
    return '说明请求命令已提交到服务端。';
  }
  if (value === 'report_case_decided') {
    return '案件裁决命令已提交到服务端。';
  }
  if (value === 'report_case_escalated') {
    return '案件升级命令已提交到服务端。';
  }
  return value;
}

function toStatusLabel(status: string) {
  if (status === 'submitted') {
    return '已提交';
  }
  if (status === 'under_review') {
    return '审核中';
  }
  if (status === 'explanation_requested') {
    return '待说明';
  }
  if (status === 'escalated') {
    return '已升级';
  }
  if (status === 'decided') {
    return '已裁决';
  }
  if (status === 'closed') {
    return '已关闭';
  }
  return status;
}

function toTargetTypeLabel(targetType: string) {
  if (targetType === 'project') {
    return '项目';
  }
  if (targetType === 'project_profile') {
    return '项目资料';
  }
  if (targetType === 'bid') {
    return '投标';
  }
  if (targetType === 'contract') {
    return '合同';
  }
  if (targetType === 'inspection') {
    return '验收';
  }
  return targetType;
}

function toRestrictionLabel(value: string) {
  if (value === 'not_applied') {
    return '未限流';
  }
  if (value === 'active') {
    return '限制生效中';
  }
  if (value === 'lifted') {
    return '限制已解除';
  }
  return value;
}

function toAdjudicationLabel(value: ExhibitionReportAdjudicationResult | null) {
  if (!value) {
    return '暂无';
  }
  if (value === 'not_established') {
    return '不成立';
  }
  if (value === 'partially_established') {
    return '部分成立';
  }
  if (value === 'materially_established') {
    return '实质成立';
  }
  return value;
}
