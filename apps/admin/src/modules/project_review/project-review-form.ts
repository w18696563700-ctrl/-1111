import type {
  DecideExhibitionReportCasePayload,
  ExhibitionReportAdjudicationResult,
  RequestExhibitionReportExplanationPayload
} from '../../core/server/admin-api-client';

const ADJUDICATION_RESULTS: ExhibitionReportAdjudicationResult[] = [
  'not_established',
  'partially_established',
  'materially_established'
];

export function readReportCaseId(formData: FormData) {
  return readRequired(formData, 'reportCaseId', 64);
}

export function buildRequestExplanationPayload(
  formData: FormData
): RequestExhibitionReportExplanationPayload {
  return {
    question: readRequired(formData, 'question', 500),
    dueAt: readOptionalDate(formData, 'dueAt')
  };
}

export function buildDecideReportCasePayload(
  formData: FormData
): DecideExhibitionReportCasePayload {
  return {
    adjudicationResult: readEnum(formData, 'adjudicationResult', ADJUDICATION_RESULTS),
    decisionNote: readOptional(formData, 'decisionNote', 500)
  };
}

export function buildEscalateReportCasePayload(formData: FormData) {
  return {
    reason: readRequired(formData, 'reason', 500)
  };
}

function readEnum<T extends readonly string[]>(formData: FormData, key: string, allowed: T) {
  const value = readRequired(formData, key, 64);
  if (!allowed.includes(value)) {
    throw new Error(`${key} 不在当前有界服务端接口支持范围内。`);
  }
  return value as T[number];
}

function readRequired(formData: FormData, key: string, maxLength: number) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`${key} 为必填项。`);
  }
  const normalized = value.trim();
  if (normalized.length > maxLength) {
    throw new Error(`${key} 长度超出限制。`);
  }
  return normalized;
}

function readOptional(formData: FormData, key: string, maxLength: number) {
  const value = formData.get(key);
  if (typeof value !== 'string' || !value.trim()) {
    return null;
  }
  const normalized = value.trim();
  if (normalized.length > maxLength) {
    throw new Error(`${key} 长度超出限制。`);
  }
  return normalized;
}

function readOptionalDate(formData: FormData, key: string) {
  const value = readOptional(formData, key, 64);
  if (!value) {
    return null;
  }
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    throw new Error(`${key} 必须是合法的日期时间。`);
  }
  return parsed.toISOString();
}
