import { HttpException } from '@nestjs/common';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import type { NormalizedErrorBody } from '../../shared/api';

type BidSeatAction = 'lock' | 'release' | 'status';

const ROUTE_DRIFT_PREFIXES = {
  lock: 'Cannot POST /server/bid/seat/lock',
  release: 'Cannot POST /server/bid/seat/release',
  status: 'Cannot GET /server/bid/seat/status',
  completeness: 'Cannot GET /server/bid/package-completeness',
} as const;

const SEAT_TIMEOUT_KEYWORDS = ['timeout', 'timed out', 'expired', 'stale locked', 'stale_locked'];
const SEAT_CONFLICT_KEYWORDS = ['conflict', 'occupied', 'already locked', 'already held', 'another bid'];

export function normalizeBidSeatError(
  error: unknown,
  errors: ErrorNormalizerService,
  action: BidSeatAction,
) {
  const normalized = errors.toHttpException(
    error,
    'AUTH_RESOURCE_UNAVAILABLE',
    action === 'status' ? '当前席位状态暂不可用，请稍后再试。' : '当前席位资源暂不可用，请稍后再试。',
    {
      400: 'BID_SEAT_INVALID',
      401: 'AUTH_SESSION_INVALID',
      403: 'AUTH_PERMISSION_INSUFFICIENT',
      404: 'AUTH_RESOURCE_UNAVAILABLE',
      409: 'BID_SEAT_INVALID_STATE',
    },
  );
  const statusCode = normalized.getStatus();
  const payload = asRecord(normalized.getResponse());
  const originalMessage = asString(payload.message) ?? '';
  const code = normalizeSeatCode(asString(payload.code), originalMessage, statusCode, action);
  const message = translateSeatMessage(action, code, originalMessage);

  const body: NormalizedErrorBody = {
    statusCode,
    code,
    message,
    details: undefined,
    source: payload.source === 'server' ? 'server' : 'bff',
  };
  return new HttpException(body, statusCode);
}

export function normalizeBidPackageCompletenessError(
  error: unknown,
  errors: ErrorNormalizerService,
) {
  const normalized = errors.toHttpException(
    error,
    'BID_PACKAGE_COMPLETENESS_UNAVAILABLE',
    '当前投标资料完整性暂不可用，请稍后再试。',
    {
      400: 'BID_PACKAGE_COMPLETENESS_INVALID',
      401: 'AUTH_SESSION_INVALID',
      403: 'AUTH_PERMISSION_INSUFFICIENT',
      404: 'BID_PACKAGE_COMPLETENESS_UNAVAILABLE',
    },
  );
  const statusCode = normalized.getStatus();
  const payload = asRecord(normalized.getResponse());
  const originalMessage = asString(payload.message) ?? '';
  const code = normalizeCompletenessCode(asString(payload.code), originalMessage, statusCode);
  const message = translateCompletenessMessage(code);

  const body: NormalizedErrorBody = {
    statusCode,
    code,
    message,
    details: undefined,
    source: payload.source === 'server' ? 'server' : 'bff',
  };
  return new HttpException(body, statusCode);
}

function normalizeSeatCode(
  code: string | undefined,
  originalMessage: string,
  statusCode: number,
  action: BidSeatAction,
) {
  if (originalMessage.includes(ROUTE_DRIFT_PREFIXES[action])) {
    return 'AUTH_RESOURCE_UNAVAILABLE';
  }

  if (
    code === 'BID_SEAT_INVALID' ||
    code === 'BID_SEAT_INVALID_STATE' ||
    code === 'BID_SEAT_CONFLICT' ||
    code === 'BID_SEAT_TIMEOUT' ||
    code === 'AUTH_SESSION_INVALID' ||
    code === 'AUTH_PERMISSION_INSUFFICIENT' ||
    code === 'AUTH_RESOURCE_UNAVAILABLE'
  ) {
    return code;
  }

  const loweredMessage = originalMessage.toLowerCase();
  if ((code ?? '').includes('TIMEOUT') || containsKeyword(loweredMessage, SEAT_TIMEOUT_KEYWORDS)) {
    return 'BID_SEAT_TIMEOUT';
  }
  if ((code ?? '').includes('CONFLICT') || containsKeyword(loweredMessage, SEAT_CONFLICT_KEYWORDS)) {
    return 'BID_SEAT_CONFLICT';
  }

  if (statusCode === 400) {
    return 'BID_SEAT_INVALID';
  }
  if (statusCode === 401) {
    return 'AUTH_SESSION_INVALID';
  }
  if (statusCode === 403) {
    return 'AUTH_PERMISSION_INSUFFICIENT';
  }
  if (statusCode === 404) {
    return 'AUTH_RESOURCE_UNAVAILABLE';
  }
  if (statusCode === 409) {
    return 'BID_SEAT_INVALID_STATE';
  }
  return 'AUTH_RESOURCE_UNAVAILABLE';
}

function translateSeatMessage(
  action: BidSeatAction,
  code: string,
  originalMessage: string,
) {
  if (code === 'AUTH_SESSION_INVALID') {
    return '当前登录态不可用，请重新登录后再试。';
  }
  if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
    return action === 'status'
      ? '当前组织不具备查看席位状态的权限，请确认组织身份后再试。'
      : '当前组织不具备席位操作权限，请确认组织身份后再试。';
  }
  if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
    return action === 'status' ? '当前席位状态暂不可用，请稍后再试。' : '当前席位资源暂不可用，请稍后再试。';
  }
  if (code === 'BID_SEAT_INVALID') {
    return '当前席位请求参数无效，请检查后重试。';
  }
  if (code === 'BID_SEAT_INVALID_STATE') {
    return '当前席位状态暂不支持此操作。';
  }
  if (code === 'BID_SEAT_CONFLICT') {
    return containsKeyword(originalMessage.toLowerCase(), ['release'])
      ? '当前席位已发生变化，请刷新后再试。'
      : '当前席位已被占用，请刷新后重试。';
  }
  if (code === 'BID_SEAT_TIMEOUT') {
    return '当前席位锁定已超时，请刷新后重试。';
  }
  return action === 'status' ? '当前席位状态暂不可用，请稍后再试。' : '当前席位资源暂不可用，请稍后再试。';
}

function normalizeCompletenessCode(
  code: string | undefined,
  originalMessage: string,
  statusCode: number,
) {
  if (originalMessage.includes(ROUTE_DRIFT_PREFIXES.completeness)) {
    return 'BID_PACKAGE_COMPLETENESS_UNAVAILABLE';
  }

  if (
    code === 'BID_PACKAGE_COMPLETENESS_INVALID' ||
    code === 'BID_PACKAGE_COMPLETENESS_UNAVAILABLE' ||
    code === 'AUTH_SESSION_INVALID' ||
    code === 'AUTH_PERMISSION_INSUFFICIENT'
  ) {
    return code;
  }

  if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
    return 'BID_PACKAGE_COMPLETENESS_UNAVAILABLE';
  }
  if (statusCode === 400) {
    return 'BID_PACKAGE_COMPLETENESS_INVALID';
  }
  if (statusCode === 401) {
    return 'AUTH_SESSION_INVALID';
  }
  if (statusCode === 403) {
    return 'AUTH_PERMISSION_INSUFFICIENT';
  }
  if (statusCode === 404) {
    return 'BID_PACKAGE_COMPLETENESS_UNAVAILABLE';
  }
  return 'BID_PACKAGE_COMPLETENESS_UNAVAILABLE';
}

function translateCompletenessMessage(code: string) {
  if (code === 'AUTH_SESSION_INVALID') {
    return '当前登录态不可用，请重新登录后再试。';
  }
  if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
    return '当前组织不具备查看投标资料完整性的权限，请确认组织身份后再试。';
  }
  if (code === 'BID_PACKAGE_COMPLETENESS_INVALID') {
    return '当前投标资料完整性查询参数无效，请检查后重试。';
  }
  return '当前投标资料完整性暂不可用，请稍后再试。';
}

function containsKeyword(message: string, keywords: string[]) {
  return keywords.some((keyword) => message.includes(keyword));
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object' ? { ...(value as Record<string, unknown>) } : {};
}

function asString(value: unknown) {
  return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
}
