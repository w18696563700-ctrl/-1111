import { HttpException } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

const ROUTE_DRIFT_PREFIX = 'Cannot POST /server/bid/select-bid-and-create-order';

const PASS_THROUGH_CODES = new Set([
  'AUTH_SESSION_INVALID',
  'AUTH_PERMISSION_INSUFFICIENT',
  'AUTH_RESOURCE_UNAVAILABLE',
  'BID_AWARD_INVALID',
  'BID_AWARD_INVALID_STATE',
  'BID_AWARD_DUPLICATE',
  'BID_AWARD_CONCURRENT_CONFLICT',
  'ORDER_CONVERSION_FAILED',
  'CONTRACT_SEED_FAILED',
]);

export function normalizeBidSelectAndCreateOrderError(
  error: unknown,
  errors: ErrorNormalizerService,
) {
  const normalized = errors.toHttpException(
    error,
    'AUTH_RESOURCE_UNAVAILABLE',
    '当前选择合作方入口暂不可用，请稍后再试。',
    {
      400: 'BID_AWARD_INVALID',
      401: 'AUTH_SESSION_INVALID',
      403: 'AUTH_PERMISSION_INSUFFICIENT',
      404: 'AUTH_RESOURCE_UNAVAILABLE',
      409: 'BID_AWARD_INVALID_STATE',
    },
  );

  const statusCode = normalized.getStatus();
  const payload = asRecord(normalized.getResponse());
  const originalMessage = asString(payload.message);
  const code = normalizeCode(
    asString(payload.code),
    originalMessage,
    statusCode,
  );

  const body: NormalizedErrorBody = {
    ...payload,
    statusCode,
    code,
    source: payload.source === 'server' ? 'server' : 'bff',
    message: translateMessage(code, originalMessage),
  };
  return new HttpException(body, statusCode);
}

function normalizeCode(
  code: string | undefined,
  originalMessage: string | undefined,
  statusCode: number,
) {
  if (originalMessage?.includes(ROUTE_DRIFT_PREFIX)) {
    return 'AUTH_RESOURCE_UNAVAILABLE';
  }
  if (code && PASS_THROUGH_CODES.has(code)) {
    return code;
  }
  if (statusCode === 400) {
    return 'BID_AWARD_INVALID';
  }
  if (statusCode === 409) {
    return 'BID_AWARD_INVALID_STATE';
  }
  return 'AUTH_RESOURCE_UNAVAILABLE';
}

function translateMessage(code: string, message: string | undefined) {
  if (code === 'AUTH_SESSION_INVALID') {
    return '当前登录态不可用，请重新登录后再试。';
  }
  if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
    if (message === 'Current actor lacks the required buyer scope for bid award.') {
      return '当前组织身份不可用，请先进入可选择合作方的发布方组织后再试。';
    }
    return '当前组织不具备选择合作方权限，请确认发布方组织身份后再试。';
  }
  if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
    if (message === 'Current project is unavailable for bid award.') {
      return '当前项目不可用，暂时无法选择合作方。';
    }
    if (message === 'Current winning bid is unavailable for bid award.') {
      return '当前投标不可用，暂时无法选择为合作方。';
    }
    return '当前选择合作方入口暂不可用，请稍后再试。';
  }
  if (code === 'BID_AWARD_INVALID') {
    return translateInvalidMessage(message);
  }
  if (code === 'BID_AWARD_INVALID_STATE') {
    return '当前项目或投标状态暂不支持选择合作方。';
  }
  if (code === 'BID_AWARD_DUPLICATE') {
    return '当前项目已选择合作方，请勿重复提交。';
  }
  if (code === 'BID_AWARD_CONCURRENT_CONFLICT') {
    return '当前项目正在选择合作方处理中，请稍后重试。';
  }
  if (code === 'ORDER_CONVERSION_FAILED') {
    return '当前选择合作方后的订单生成失败，请稍后再试。';
  }
  if (code === 'CONTRACT_SEED_FAILED') {
    return '当前选择合作方后的合同初始化失败，请稍后再试。';
  }
  return '当前选择合作方入口暂不可用，请稍后再试。';
}

function translateInvalidMessage(message: string | undefined) {
  if (message === 'Bid award body must be an object.') {
    return '当前选择合作方数据格式无效，请刷新后重试。';
  }
  if (message === 'Field `projectId` is required for bid award.') {
    return '当前项目标识缺失，无法选择合作方。';
  }
  if (message === 'Field `winningBidId` is required for bid award.') {
    return '当前投标标识缺失，无法选择合作方。';
  }
  if (message === 'Field `reasonCode` is required for bid award.') {
    return '当前选择合作方原因编码缺失，无法提交。';
  }
  if (message === 'Field `reasonText` is required for bid award.') {
    return '当前选择合作方原因说明缺失，无法提交。';
  }
  if (message === 'Current buyer organization cannot award its own bid.') {
    return '当前组织不能选择自己项目下的投标作为合作方。';
  }
  return '当前选择合作方参数无效，请检查后再试。';
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object'
    ? { ...(value as Record<string, unknown>) }
    : {};
}

function asString(value: unknown) {
  return typeof value === 'string' && value.trim().length > 0
    ? value.trim()
    : undefined;
}
