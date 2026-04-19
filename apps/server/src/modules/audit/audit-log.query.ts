import { AUDIT_SOURCE_FAMILIES, type AuditLogListQuery, type AuditSourceFamily, type NormalizedAuditLog } from './audit-log.types';

export function readAuditLogListQuery(
  query: Record<string, unknown>,
  errorFactory: (message: string) => Error
): AuditLogListQuery {
  return {
    sourceFamily: readOptionalEnum(
      query.sourceFamily,
      AUDIT_SOURCE_FAMILIES,
      'sourceFamily',
      errorFactory
    ) as AuditSourceFamily | null,
    objectType: readOptionalText(query.objectType, 'objectType', 64, errorFactory),
    objectId: readOptionalText(query.objectId, 'objectId', 64, errorFactory),
    objectNo: readOptionalText(query.objectNo, 'objectNo', 128, errorFactory),
    actorId: readOptionalText(query.actorId, 'actorId', 64, errorFactory),
    requestId: readOptionalText(query.requestId, 'requestId', 64, errorFactory),
    traceId: readOptionalText(query.traceId, 'traceId', 64, errorFactory),
    action: readOptionalText(query.action, 'action', 64, errorFactory),
    occurredFrom: readOptionalDate(query.occurredFrom, 'occurredFrom', errorFactory),
    occurredTo: readOptionalDate(query.occurredTo, 'occurredTo', errorFactory),
    page: readPositiveInt(query.page, 1, 10_000, errorFactory),
    pageSize: readPositiveInt(query.pageSize, 20, 100, errorFactory)
  };
}

export function matchesAuditLogFilters(item: NormalizedAuditLog, query: AuditLogListQuery) {
  return (
    matchesValue(item.sourceFamily, query.sourceFamily) &&
    matchesValue(item.objectType, query.objectType) &&
    matchesValue(item.objectId, query.objectId) &&
    matchesValue(item.objectNo, query.objectNo) &&
    matchesValue(item.actorId, query.actorId) &&
    matchesValue(item.requestId, query.requestId) &&
    matchesValue(item.traceId, query.traceId) &&
    matchesValue(item.action, query.action) &&
    matchesOccurredFrom(item.occurredAt, query.occurredFrom) &&
    matchesOccurredTo(item.occurredAt, query.occurredTo)
  );
}

function matchesValue(current: string | null, expected: string | null) {
  if (!expected) {
    return true;
  }
  return (current ?? '') === expected;
}

function matchesOccurredFrom(current: string, occurredFrom: Date | null) {
  if (!occurredFrom) {
    return true;
  }
  return new Date(current).getTime() >= occurredFrom.getTime();
}

function matchesOccurredTo(current: string, occurredTo: Date | null) {
  if (!occurredTo) {
    return true;
  }
  return new Date(current).getTime() <= occurredTo.getTime();
}

function readPositiveInt(
  value: unknown,
  fallback: number,
  max: number,
  errorFactory: (message: string) => Error
) {
  if (value === undefined || value === null || value === '') {
    return fallback;
  }
  const numeric = Number(value);
  if (!Number.isInteger(numeric) || numeric <= 0 || numeric > max) {
    throw errorFactory('Pagination values are invalid.');
  }
  return numeric;
}

function readOptionalEnum(
  value: unknown,
  allowed: readonly string[],
  field: string,
  errorFactory: (message: string) => Error
) {
  if (value === undefined || value === null || value === '') {
    return null;
  }
  if (typeof value !== 'string' || !allowed.includes(value)) {
    throw errorFactory(`${field} is invalid.`);
  }
  return value;
}

function readOptionalText(
  value: unknown,
  field: string,
  maxLength: number,
  errorFactory: (message: string) => Error
) {
  if (value === undefined || value === null || value === '') {
    return null;
  }
  if (typeof value !== 'string') {
    throw errorFactory(`${field} is invalid.`);
  }
  const normalized = value.trim();
  if (!normalized || normalized.length > maxLength) {
    throw errorFactory(`${field} is invalid.`);
  }
  return normalized;
}

function readOptionalDate(
  value: unknown,
  field: string,
  errorFactory: (message: string) => Error
) {
  if (value === undefined || value === null || value === '') {
    return null;
  }
  if (typeof value !== 'string') {
    throw errorFactory(`${field} is invalid.`);
  }
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    throw errorFactory(`${field} is invalid.`);
  }
  return parsed;
}
