export const AUDIT_SOURCE_FAMILIES = ['identity', 'project_publish', 'content_safety'] as const;

export type AuditSourceFamily = (typeof AUDIT_SOURCE_FAMILIES)[number];

export type AuditLogListQuery = {
  sourceFamily: AuditSourceFamily | null;
  objectType: string | null;
  objectId: string | null;
  objectNo: string | null;
  actorId: string | null;
  requestId: string | null;
  traceId: string | null;
  action: string | null;
  occurredFrom: Date | null;
  occurredTo: Date | null;
  page: number;
  pageSize: number;
};

export type NormalizedAuditLog = {
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
  beforeState: string | null;
  afterState: string | null;
  reason: string | null;
  payload: Record<string, unknown>;
};
