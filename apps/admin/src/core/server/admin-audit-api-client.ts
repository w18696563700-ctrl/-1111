import { adminJsonRequest, toQueryString } from './admin-api-runtime';

export type AuditSourceFamily = 'identity' | 'project_publish' | 'content_safety';

export type AdminAuditLogListItem = {
  auditLogId: string;
  sourceFamily: AuditSourceFamily;
  objectType: string;
  objectId: string;
  objectNo: string | null;
  action: string;
  actorId: string | null;
  actorRole: string | null;
  requestId: string | null;
  traceId: string | null;
  occurredAt: string;
};

export type AdminAuditLogDetail = AdminAuditLogListItem & {
  beforeState: string | null;
  afterState: string | null;
  reason: string | null;
  payload: Record<string, unknown>;
};

export type AdminAuditLogListResponse = {
  items: AdminAuditLogListItem[];
  pagination: {
    page: number;
    pageSize: number;
    total: number;
  };
};

export async function fetchAdminAuditLogs(query: {
  sourceFamily?: AuditSourceFamily;
  objectType?: string;
  objectId?: string;
  objectNo?: string;
  actorId?: string;
  requestId?: string;
  traceId?: string;
  action?: string;
  occurredFrom?: string;
  occurredTo?: string;
  page?: number;
  pageSize?: number;
} = {}) {
  return adminJsonRequest<AdminAuditLogListResponse>(`/audit/logs${toQueryString(query)}`);
}

export async function fetchAdminAuditLog(auditLogId: string) {
  return adminJsonRequest<AdminAuditLogDetail>(
    `/audit/logs/${encodeURIComponent(auditLogId)}`
  );
}
