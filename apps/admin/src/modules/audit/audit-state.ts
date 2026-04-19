import {
  AdminApiError,
  AdminAuditLogDetail,
  AdminAuditLogListItem,
  AuditSourceFamily,
  fetchAdminAuditLog,
  fetchAdminAuditLogs
} from '../../core/server/admin-api-client';

type AuditClient = {
  fetchList: typeof fetchAdminAuditLogs;
  fetchDetail: typeof fetchAdminAuditLog;
};

export type AuditShellState = {
  items: AdminAuditLogListItem[];
  detail: AdminAuditLogDetail | null;
  total: number;
  error: string | null;
};

const DEFAULT_CLIENT: AuditClient = {
  fetchList: fetchAdminAuditLogs,
  fetchDetail: fetchAdminAuditLog
};

const SOURCE_FAMILY_OPTIONS: AuditSourceFamily[] = ['identity', 'project_publish'];

export async function loadAuditState(
  input: {
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
  },
  client: AuditClient = DEFAULT_CLIENT
): Promise<AuditShellState> {
  try {
    const list = await client.fetchList({
      sourceFamily: readAuditSourceFamily(input.sourceFamily),
      objectType: readOptionalFilter(input.objectType),
      objectId: readOptionalFilter(input.objectId),
      objectNo: readOptionalFilter(input.objectNo),
      actorId: readOptionalFilter(input.actorId),
      requestId: readOptionalFilter(input.requestId),
      traceId: readOptionalFilter(input.traceId),
      action: readOptionalFilter(input.action),
      occurredFrom: readOptionalFilter(input.occurredFrom),
      occurredTo: readOptionalFilter(input.occurredTo),
      page: 1,
      pageSize: 20
    });
    const auditLogId = input.selectedAuditLogId ?? list.items[0]?.auditLogId;
    const detail = auditLogId ? await client.fetchDetail(auditLogId) : null;
    return {
      items: list.items,
      detail,
      total: list.pagination.total,
      error: null
    };
  } catch (error) {
    return {
      items: [],
      detail: null,
      total: 0,
      error: toAuditLoadError(error)
    };
  }
}

export function readAuditSourceFamily(value: string | undefined) {
  if (!value) {
    return undefined;
  }
  return SOURCE_FAMILY_OPTIONS.includes(value as AuditSourceFamily)
    ? (value as AuditSourceFamily)
    : undefined;
}

export function toAuditLoadError(error: unknown) {
  if (error instanceof AdminApiError) {
    return `${error.code}: ${error.message}`;
  }
  return error instanceof Error ? error.message : '无法从服务端管理接口加载审计工作台。';
}

function readOptionalFilter(value: string | undefined) {
  const normalized = value?.trim() ?? '';
  return normalized ? normalized : undefined;
}
