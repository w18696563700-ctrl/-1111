import Link from 'next/link';
import {
  AdminApiError,
  AdminReviewTask,
  AdminReviewTaskDetail,
  fetchContentSafetyReviewTask,
  fetchContentSafetyReviewTasks
} from '@/core/server/admin-api-client';
import {
  approveProfileSubmissionAction,
  decideForumReportAction,
  rejectProfileSubmissionAction
} from './review-actions';

type ReviewShellProps = {
  selectedTaskId?: string;
  notice?: string;
  error?: string;
};

type ReviewState = {
  tasks: AdminReviewTask[];
  detail: AdminReviewTaskDetail | null;
  error: string | null;
};

export async function ReviewShell({ selectedTaskId, notice, error }: ReviewShellProps) {
  const state = await loadReviewState(selectedTaskId);

  return (
    <section className="panel review-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">审核台 P0</p>
          <h1>内容安全审核队列</h1>
        </div>
        <span className="badge">仅调用服务端管理接口</span>
      </div>
      <p className="lead">
        这是 CS-024 的最小审核台。任务真相仍然归属服务端；当前管理页只读取审核载体，并提交资料安全提审的有界审核命令。
      </p>
      <div className="notice-grid">
        {notice ? <div className="notice">{toNoticeText(notice)}</div> : null}
        {error ? <div className="notice danger">{error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
      </div>
      <div className="review-grid">
        <ReviewTaskList tasks={state.tasks} selectedTaskId={selectedTaskId} />
        <ReviewTaskDetailPanel detail={state.detail} />
      </div>
    </section>
  );
}

async function loadReviewState(selectedTaskId?: string): Promise<ReviewState> {
  try {
    const list = await fetchContentSafetyReviewTasks();
    const taskId = selectedTaskId ?? list.items[0]?.taskId;
    const detail = taskId ? await fetchContentSafetyReviewTask(taskId) : null;
    return { tasks: list.items, detail, error: null };
  } catch (error) {
    return { tasks: [], detail: null, error: toLoadError(error) };
  }
}

function ReviewTaskList({
  tasks,
  selectedTaskId
}: {
  tasks: AdminReviewTask[];
  selectedTaskId?: string;
}) {
  if (!tasks.length) {
    return <div className="empty-card">当前没有服务端返回的审核任务。</div>;
  }

  return (
    <div className="review-list" aria-label="内容安全审核任务">
      {tasks.map((task) => (
        <Link
          className={task.taskId === selectedTaskId ? 'task-card active' : 'task-card'}
          href={`/review?taskId=${encodeURIComponent(task.taskId)}`}
          key={task.taskId}
        >
          <span>{toTaskTypeLabel(task.taskType)}</span>
          <strong>{task.subjectId}</strong>
          <small>{toReviewStatusLabel(task.status)} · {formatDate(task.submittedAt)}</small>
        </Link>
      ))}
    </div>
  );
}

function ReviewTaskDetailPanel({ detail }: { detail: AdminReviewTaskDetail | null }) {
  if (!detail) {
    return (
      <div className="review-detail empty-card">
        在拿到有效的服务端管理员会话载体后，可在此查看任务详情。
      </div>
    );
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">任务详情</p>
          <h2>{toTaskTypeLabel(detail.taskType)}</h2>
        </div>
        <span className="badge">{toReviewStatusLabel(detail.status)}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>任务 ID</dt><dd>{detail.taskId}</dd></div>
        <div><dt>来源表</dt><dd>{detail.sourceTable}</dd></div>
        <div><dt>主体</dt><dd>{detail.subjectId}</dd></div>
        <div><dt>提交时间</dt><dd>{formatDate(detail.submittedAt)}</dd></div>
      </dl>
      {detail.taskType === 'profile_safety_submission'
        ? <ProfileSubmissionDetail detail={detail} />
        : <ForumReportDetail detail={detail} />}
    </div>
  );
}

function ProfileSubmissionDetail({ detail }: { detail: AdminReviewTaskDetail }) {
  return (
    <div className="detail-stack">
      <dl className="meta-grid compact">
        <div><dt>用户</dt><dd>{detail.subjectUserId}</dd></div>
        <div><dt>字段</dt><dd>{detail.fieldKey}</dd></div>
        <div><dt>规则判定</dt><dd>{detail.ruleDecision}</dd></div>
        <div><dt>引擎</dt><dd>{detail.engineType}</dd></div>
      </dl>
      <div className="value-compare">
        <div><span>当前值</span><p>{detail.currentValue ?? detail.proposedFileAssetId ?? '暂无'}</p></div>
        <div><span>提交值</span><p>{detail.proposedValue ?? detail.proposedAvatarUrl ?? detail.proposedFileAssetId ?? '暂无'}</p></div>
      </div>
      <form className="action-card" action={approveProfileSubmissionAction}>
        <input type="hidden" name="submissionId" value={detail.subjectId} />
        <label>
          审核备注
          <textarea name="reviewNote" placeholder="可选，填写通过备注" />
        </label>
        <button className="primary" type="submit">通过资料提审</button>
      </form>
      <form className="action-card danger-card" action={rejectProfileSubmissionAction}>
        <input type="hidden" name="submissionId" value={detail.subjectId} />
        <label>
          驳回原因
          <textarea name="reason" required placeholder="必填，请填写驳回原因" />
        </label>
        <button className="primary danger-button" type="submit">驳回资料提审</button>
      </form>
    </div>
  );
}

function ForumReportDetail({ detail }: { detail: AdminReviewTaskDetail }) {
  const canDecide = detail.allowedActions?.includes('decide') ?? false;

  return (
    <div className="detail-stack">
      {canDecide ? (
        <div className="notice warning">
          论坛举报 P0 只允许案件裁决并写入 audit；不直接隐藏/恢复内容，不限制作者。
        </div>
      ) : (
        <div className="notice">
          当前状态不可继续裁决；如需隐藏、恢复或限制作者，必须走后续独立治理包。
        </div>
      )}
      <dl className="meta-grid compact">
        <div><dt>目标对象</dt><dd>{detail.targetType}:{detail.targetId}</dd></div>
        <div><dt>目标作者</dt><dd>{detail.targetAuthorUserId ?? '暂无'}</dd></div>
        <div><dt>举报人</dt><dd>{detail.reporterUserId}</dd></div>
        <div><dt>原因编码</dt><dd>{detail.reasonCode}</dd></div>
      </dl>
      <pre className="json-panel">{JSON.stringify(detail.targetSnapshot ?? {}, null, 2)}</pre>
      {canDecide ? (
        <form className="action-card" action={decideForumReportAction}>
          <input type="hidden" name="ticketId" value={detail.subjectId} />
          <label>
            裁决结果
            <select name="decision" defaultValue="resolved">
              <option value="resolved">举报成立</option>
              <option value="rejected">举报不成立</option>
              <option value="closed">关闭工单</option>
            </select>
          </label>
          <label>
            裁决原因
            <textarea name="reason" required placeholder="必填，写入 append-only audit" />
          </label>
          <button className="primary" type="submit">提交举报裁决</button>
        </form>
      ) : null}
    </div>
  );
}

function toTaskTypeLabel(taskType: string) {
  return taskType === 'forum_report_ticket' ? '论坛举报工单' : '资料安全提审';
}

function toReviewStatusLabel(status: string) {
  if (status === 'pending_review') {
    return '待审核';
  }
  if (status === 'approved') {
    return '已通过';
  }
  if (status === 'rejected') {
    return '已驳回';
  }
  if (status === 'submitted') {
    return '待处理';
  }
  if (status === 'resolved') {
    return '举报成立';
  }
  if (status === 'closed') {
    return '已关闭';
  }
  return status;
}

function formatDate(value: string | undefined) {
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
  return error instanceof Error ? error.message : '无法从服务端管理接口加载审核任务。';
}

function toNoticeText(value: string) {
  if (value === 'profile_approved') {
    return '资料提审通过命令已提交到服务端。';
  }
  if (value === 'profile_rejected') {
    return '资料提审驳回命令已提交到服务端。';
  }
  if (value === 'forum_report_decided') {
    return '论坛举报裁决已提交到服务端，并进入 append-only audit。';
  }
  return value;
}
