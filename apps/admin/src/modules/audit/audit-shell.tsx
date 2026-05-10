import Link from 'next/link';
import type {
  AdminAuditLogDetail,
  AdminAuditLogListItem,
  AuditSourceFamily
} from '@/core/server/admin-api-client';
import { loadAuditState } from './audit-state';

type AuditShellProps = {
  selectedAuditLogId?: string;
  sourceFamily?: string;
  objectType?: string;
  objectId?: string;
  objectNo?: string;
  actorId?: string;
  requestId?: string;
  traceId?: string;
  action?: string;
  occurredFrom?: string;
  occurredTo?: string;
  error?: string;
};

const SOURCE_FAMILY_OPTIONS: AuditSourceFamily[] = [
  'identity',
  'project_publish',
  'content_safety'
];

export async function AuditShell(props: AuditShellProps) {
  const state = await loadAuditState(props);

  return (
    <section className="panel review-console governance-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">Package C 审计工作台</p>
          <h1>Append-only 审计队列与核验台</h1>
        </div>
        <span className="badge">仅调用服务端管理接口</span>
      </div>
      <p className="lead">
        `/audit` 当前只承接 append-only audit queue、filter、detail inspect。
        它不是 export、write、repair 或 generic observability console。
      </p>
      <div className="notice-grid">
        {props.error ? <div className="notice danger">{props.error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
      </div>
      <AuditFilters {...props} />
      <div className="review-grid governance-grid">
        <AuditLogList items={state.items} total={state.total} filters={props} />
        <AuditLogDetailPanel detail={state.detail} />
      </div>
    </section>
  );
}

function AuditFilters(props: AuditShellProps) {
  return (
    <form className="filter-card" action="/audit">
      <label>
        sourceFamily
        <select name="sourceFamily" defaultValue={props.sourceFamily ?? ''}>
          <option value="">全部 family</option>
          {SOURCE_FAMILY_OPTIONS.map((item) => (
            <option key={item} value={item}>{toSourceFamilyLabel(item)}</option>
          ))}
        </select>
      </label>
      <label>
        objectType
        <input name="objectType" defaultValue={props.objectType ?? ''} />
      </label>
      <label>
        objectId
        <input name="objectId" defaultValue={props.objectId ?? ''} />
      </label>
      <label>
        objectNo
        <input name="objectNo" defaultValue={props.objectNo ?? ''} />
      </label>
      <label>
        actorId
        <input name="actorId" defaultValue={props.actorId ?? ''} />
      </label>
      <label>
        requestId
        <input name="requestId" defaultValue={props.requestId ?? ''} />
      </label>
      <label>
        traceId
        <input name="traceId" defaultValue={props.traceId ?? ''} />
      </label>
      <label>
        action
        <input name="action" defaultValue={props.action ?? ''} />
      </label>
      <label>
        occurredFrom
        <input name="occurredFrom" defaultValue={props.occurredFrom ?? ''} placeholder="ISO 8601" />
      </label>
      <label>
        occurredTo
        <input name="occurredTo" defaultValue={props.occurredTo ?? ''} placeholder="ISO 8601" />
      </label>
      <button className="primary" type="submit">筛选审计日志</button>
    </form>
  );
}

function AuditLogList({
  items,
  total,
  filters
}: {
  items: AdminAuditLogListItem[];
  total: number;
  filters: AuditShellProps;
}) {
  if (!items.length) {
    return <div className="empty-card">当前没有服务端返回的 append-only audit log。</div>;
  }

  return (
    <div className="review-list" aria-label="append-only audit logs">
      <p className="eyebrow">共 {total} 条</p>
      {items.map((item) => (
        <Link
          className={item.auditLogId === filters.selectedAuditLogId ? 'task-card active' : 'task-card'}
          href={buildAuditDetailHref(item.auditLogId, filters)}
          key={item.auditLogId}
        >
          <span>{toSourceFamilyLabel(item.sourceFamily)} · {item.action}</span>
          <strong>{item.objectType}:{item.objectId}</strong>
          <small>requestId: {item.requestId ?? '暂无'}</small>
          <small>{formatDate(item.occurredAt)}</small>
        </Link>
      ))}
    </div>
  );
}

function AuditLogDetailPanel({ detail }: { detail: AdminAuditLogDetail | null }) {
  if (!detail) {
    return (
      <div className="review-detail empty-card">
        在拿到有效的服务端管理员会话载体后，可在此检视 append-only audit detail。
      </div>
    );
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">Audit Detail</p>
          <h2>{detail.auditLogId}</h2>
        </div>
        <span className="badge">{toSourceFamilyLabel(detail.sourceFamily)}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>auditLogId</dt><dd>{detail.auditLogId}</dd></div>
        <div><dt>sourceFamily</dt><dd>{toSourceFamilyLabel(detail.sourceFamily)}</dd></div>
        <div><dt>objectType</dt><dd>{detail.objectType}</dd></div>
        <div><dt>objectId</dt><dd>{detail.objectId}</dd></div>
        <div><dt>objectNo</dt><dd>{detail.objectNo ?? '暂无'}</dd></div>
        <div><dt>action</dt><dd>{detail.action}</dd></div>
        <div><dt>actorId</dt><dd>{detail.actorId ?? '暂无'}</dd></div>
        <div><dt>actorRole</dt><dd>{detail.actorRole ?? '暂无'}</dd></div>
        <div><dt>requestId</dt><dd>{detail.requestId ?? '暂无'}</dd></div>
        <div><dt>traceId</dt><dd>{detail.traceId ?? '暂无'}</dd></div>
        <div><dt>occurredAt</dt><dd>{formatDate(detail.occurredAt)}</dd></div>
      </dl>
      <div className="value-compare">
        <div><span>beforeState</span><p>{detail.beforeState ?? '暂无'}</p></div>
        <div><span>afterState</span><p>{detail.afterState ?? '暂无'}</p></div>
      </div>
      <div className="value-compare single">
        <div><span>reason</span><p>{detail.reason ?? '暂无'}</p></div>
      </div>
      <pre className="json-panel">{JSON.stringify(detail.payload ?? {}, null, 2)}</pre>
    </div>
  );
}

function buildAuditDetailHref(auditLogId: string, filters: AuditShellProps) {
  const params = new URLSearchParams();
  params.set('auditLogId', auditLogId);
  for (const [key, value] of Object.entries({
    sourceFamily: filters.sourceFamily,
    objectType: filters.objectType,
    objectId: filters.objectId,
    objectNo: filters.objectNo,
    actorId: filters.actorId,
    requestId: filters.requestId,
    traceId: filters.traceId,
    action: filters.action,
    occurredFrom: filters.occurredFrom,
    occurredTo: filters.occurredTo
  })) {
    if (value?.trim()) {
      params.set(key, value.trim());
    }
  }
  return `/audit?${params.toString()}`;
}

function toSourceFamilyLabel(value: string) {
  if (value === 'identity') {
    return 'identity';
  }
  if (value === 'project_publish') {
    return 'project_publish';
  }
  if (value === 'content_safety') {
    return 'content_safety';
  }
  return value;
}

function formatDate(value: string) {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toLocaleString('zh-CN', { hour12: false });
}
