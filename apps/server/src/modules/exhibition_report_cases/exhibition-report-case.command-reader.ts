import {
  EXHIBITION_REPORT_ADJUDICATION_RESULTS,
  EXHIBITION_REPORT_CASE_STATUSES,
  EXHIBITION_REPORT_REASON_CODES,
  EXHIBITION_REPORT_TARGET_TYPES,
  ExhibitionReportAdjudicationResult,
  ExhibitionReportCaseStatus,
  ExhibitionReportReasonCode,
  ExhibitionReportTargetType
} from './exhibition-report-case.constants';

export type ExhibitionReportCaseListQuery = {
  page: number;
  pageSize: number;
  status: ExhibitionReportCaseStatus | null;
  targetType: ExhibitionReportTargetType | null;
  keyword: string | null;
};

export type RequestExplanationCommand = {
  question: string;
  dueAt: Date | null;
};

export type DecideCommand = {
  adjudicationResult: ExhibitionReportAdjudicationResult;
  decisionNote: string | null;
};

export type EscalateCommand = {
  reason: string;
};

export type ExhibitionReportSubmitCommand = {
  targetType: ExhibitionReportTargetType;
  targetId: string;
  reasonCode: ExhibitionReportReasonCode;
  reasonDetail: string | null;
  evidenceFileAssetIds: string[];
};

export function readListQuery(
  query: Record<string, unknown>,
  errorFactory: (message: string) => Error
): ExhibitionReportCaseListQuery {
  return {
    page: readPositiveInt(query.page, 1, 10_000, errorFactory),
    pageSize: readPositiveInt(query.pageSize, 20, 100, errorFactory),
    status: readOptionalEnum(
      query.status,
      EXHIBITION_REPORT_CASE_STATUSES,
      'status',
      errorFactory
    ) as ExhibitionReportCaseStatus | null,
    targetType: readOptionalEnum(
      query.targetType,
      EXHIBITION_REPORT_TARGET_TYPES,
      'targetType',
      errorFactory
    ) as ExhibitionReportTargetType | null,
    keyword: readOptionalText(query.keyword, 128, errorFactory)
  };
}

export function readReportCaseId(
  value: unknown,
  fieldName: string,
  errorFactory: (message: string) => Error
) {
  const id = readRequiredText(value, fieldName, 64, errorFactory);
  if (!/^[a-zA-Z0-9._:-]{4,64}$/.test(id)) {
    throw errorFactory(`${fieldName} is invalid.`);
  }
  return id;
}

export function toRequestExplanationCommand(
  payload: Record<string, unknown>,
  errorFactory: (message: string) => Error
): RequestExplanationCommand {
  if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
    throw errorFactory('Exhibition report request explanation payload must be an object.');
  }
  return {
    question: readRequiredText(payload.question, 'question', 500, errorFactory),
    dueAt: readOptionalDate(payload.dueAt, 'dueAt', errorFactory)
  };
}

export function toDecideCommand(
  payload: Record<string, unknown>,
  errorFactory: (message: string) => Error
): DecideCommand {
  if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
    throw errorFactory('Exhibition report decide payload must be an object.');
  }
  return {
    adjudicationResult: readEnum(
      payload.adjudicationResult,
      EXHIBITION_REPORT_ADJUDICATION_RESULTS,
      'adjudicationResult',
      errorFactory
    ) as ExhibitionReportAdjudicationResult,
    decisionNote: readOptionalText(payload.decisionNote, 500, errorFactory)
  };
}

export function toEscalateCommand(
  payload: Record<string, unknown>,
  errorFactory: (message: string) => Error
): EscalateCommand {
  if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
    throw errorFactory('Exhibition report escalate payload must be an object.');
  }
  return {
    reason: readRequiredText(payload.reason, 'reason', 500, errorFactory)
  };
}

export function toSubmitCommand(
  payload: Record<string, unknown>,
  errorFactory: (message: string) => Error
): ExhibitionReportSubmitCommand {
  if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
    throw errorFactory('Exhibition report submit payload must be an object.');
  }
  return {
    targetType: readEnum(
      payload.targetType,
      EXHIBITION_REPORT_TARGET_TYPES,
      'targetType',
      errorFactory
    ) as ExhibitionReportTargetType,
    targetId: readReportCaseTargetId(payload.targetId, errorFactory),
    reasonCode: readEnum(
      payload.reasonCode,
      EXHIBITION_REPORT_REASON_CODES,
      'reasonCode',
      errorFactory
    ) as ExhibitionReportReasonCode,
    reasonDetail: readOptionalText(payload.reasonDetail, 500, errorFactory),
    evidenceFileAssetIds: readOptionalStringArray(
      payload.evidenceFileAssetIds,
      'evidenceFileAssetIds',
      20,
      64,
      errorFactory
    )
  };
}

export function canRequestExplanation(status: string) {
  return status === 'submitted' || status === 'under_review';
}

export function canDecide(status: string) {
  return (
    status === 'submitted' ||
    status === 'under_review' ||
    status === 'explanation_requested' ||
    status === 'escalated'
  );
}

export function canEscalate(status: string) {
  return (
    status === 'submitted' ||
    status === 'under_review' ||
    status === 'explanation_requested'
  );
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

function readEnum(
  value: unknown,
  allowed: readonly string[],
  fieldName: string,
  errorFactory: (message: string) => Error
) {
  if (typeof value !== 'string') {
    throw errorFactory(`${fieldName} is invalid.`);
  }
  if (!allowed.includes(value)) {
    throw errorFactory(`${fieldName} is invalid.`);
  }
  return value;
}

function readOptionalEnum(
  value: unknown,
  allowed: readonly string[],
  fieldName: string,
  errorFactory: (message: string) => Error
) {
  if (value === undefined || value === null || value === '') {
    return null;
  }
  return readEnum(value, allowed, fieldName, errorFactory);
}

function readRequiredText(
  value: unknown,
  fieldName: string,
  maxLength: number,
  errorFactory: (message: string) => Error
) {
  if (typeof value !== 'string') {
    throw errorFactory(`${fieldName} is required.`);
  }
  const normalized = value.trim();
  if (!normalized || normalized.length > maxLength) {
    throw errorFactory(`${fieldName} is invalid.`);
  }
  return normalized;
}

function readReportCaseTargetId(value: unknown, errorFactory: (message: string) => Error) {
  const id = readRequiredText(value, 'targetId', 64, errorFactory);
  if (!/^[a-zA-Z0-9._:-]{2,64}$/.test(id)) {
    throw errorFactory('targetId is invalid.');
  }
  return id;
}

function readOptionalText(
  value: unknown,
  maxLength: number,
  errorFactory: (message: string) => Error
) {
  if (value === undefined || value === null || value === '') {
    return null;
  }
  if (typeof value !== 'string') {
    throw errorFactory('Text field must be a string.');
  }
  const normalized = value.trim();
  if (!normalized) {
    return null;
  }
  if (normalized.length > maxLength) {
    throw errorFactory(`Text field exceeds maximum length ${maxLength}.`);
  }
  return normalized;
}

function readOptionalStringArray(
  value: unknown,
  fieldName: string,
  maxItems: number,
  maxLength: number,
  errorFactory: (message: string) => Error
) {
  if (value === undefined || value === null) {
    return [];
  }
  if (!Array.isArray(value)) {
    throw errorFactory(`${fieldName} must be an array.`);
  }
  if (value.length > maxItems) {
    throw errorFactory(`${fieldName} exceeds maximum item count ${maxItems}.`);
  }

  const result: string[] = [];
  const seen = new Set<string>();
  for (const item of value) {
    const normalized = readRequiredText(item, fieldName, maxLength, errorFactory);
    if (!seen.has(normalized)) {
      result.push(normalized);
      seen.add(normalized);
    }
  }
  return result;
}

function readOptionalDate(
  value: unknown,
  fieldName: string,
  errorFactory: (message: string) => Error
) {
  if (value === undefined || value === null || value === '') {
    return null;
  }
  if (typeof value !== 'string') {
    throw errorFactory(`${fieldName} must be a valid date time.`);
  }
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    throw errorFactory(`${fieldName} must be a valid date time.`);
  }
  return parsed;
}
