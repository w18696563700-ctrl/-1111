import { HttpException } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type BidBridgeAction = 'award' | 'result';

const ROUTE_DRIFT_PREFIXES = {
  award: 'Cannot POST /server/bid/award',
  result: 'Cannot GET /server/bid/result',
} as const;

export function normalizeBidAwardError(error: unknown, errors: ErrorNormalizerService) {
  const normalized = errors.toHttpException(
    error,
    'AUTH_RESOURCE_UNAVAILABLE',
    '当前定标入口暂不可用，请稍后再试。',
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
  const originalCode = asString(payload.code);
  const originalMessage = asString(payload.message);
  const code = normalizeBidBridgeCode(
    'award',
    originalCode,
    originalMessage,
    statusCode,
    'AUTH_RESOURCE_UNAVAILABLE',
    {
      400: 'BID_AWARD_INVALID',
      404: 'AUTH_RESOURCE_UNAVAILABLE',
      409: 'BID_AWARD_INVALID_STATE',
    },
    new Set([
      'AUTH_SESSION_INVALID',
      'AUTH_PERMISSION_INSUFFICIENT',
      'AUTH_RESOURCE_UNAVAILABLE',
      'BID_AWARD_INVALID',
      'BID_AWARD_INVALID_STATE',
      'BID_AWARD_DUPLICATE',
      'BID_AWARD_CONCURRENT_CONFLICT',
      'ORDER_CONVERSION_FAILED',
      'CONTRACT_SEED_FAILED',
    ]),
  );
  const message = rewriteAwardErrorMessage(code, originalMessage);

  return toHttpException(payload, statusCode, code, message);
}

export function normalizeBidResultError(error: unknown, errors: ErrorNormalizerService) {
  const normalized = errors.toHttpException(
    error,
    'BID_RESULT_UNAVAILABLE',
    '当前投标结果暂不可用，请稍后再试。',
    {
      400: 'BID_RESULT_INVALID',
      401: 'AUTH_SESSION_INVALID',
      403: 'AUTH_PERMISSION_INSUFFICIENT',
      404: 'BID_RESULT_UNAVAILABLE',
    },
  );

  const statusCode = normalized.getStatus();
  const payload = asRecord(normalized.getResponse());
  const originalCode = asString(payload.code);
  const originalMessage = asString(payload.message);
  const code = normalizeBidBridgeCode(
    'result',
    originalCode,
    originalMessage,
    statusCode,
    'BID_RESULT_UNAVAILABLE',
    {
      400: 'BID_RESULT_INVALID',
      404: 'BID_RESULT_UNAVAILABLE',
    },
    new Set([
      'AUTH_SESSION_INVALID',
      'AUTH_PERMISSION_INSUFFICIENT',
      'BID_RESULT_INVALID',
      'BID_RESULT_UNAVAILABLE',
    ]),
  );
  const message = rewriteResultErrorMessage(code, originalMessage);

  return toHttpException(payload, statusCode, code, message);
}

function normalizeBidBridgeCode(
  action: BidBridgeAction,
  code: string | undefined,
  originalMessage: string | undefined,
  statusCode: number,
  fallbackCode: string,
  statusFallbacks: Partial<Record<number, string>>,
  passThroughCodes: Set<string>,
) {
  if (originalMessage?.includes(ROUTE_DRIFT_PREFIXES[action])) {
    return fallbackCode;
  }

  if (code && passThroughCodes.has(code)) {
    return code;
  }

  return statusFallbacks[statusCode] ?? fallbackCode;
}

function rewriteAwardErrorMessage(code: string, message: string | undefined) {
  if (code === 'AUTH_SESSION_INVALID') {
    return '当前登录态不可用，请重新登录后再试。';
  }
  if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
    if (message === 'Current actor lacks the required buyer scope for bid award.') {
      return '当前组织身份不可用，请先进入可定标的买方组织后再试。';
    }
    return '当前组织不具备定标权限，请确认买方组织身份后再试。';
  }
  if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
    if (message === 'Current project is unavailable for bid award.') {
      return '当前项目不可用，暂时无法定标。';
    }
    if (message === 'Current winning bid is unavailable for bid award.') {
      return '当前中标投标不可用，暂时无法定标。';
    }
    return '当前定标资源不可用，请稍后再试。';
  }
  if (code === 'BID_AWARD_INVALID') {
    return rewriteAwardInvalidMessage(message);
  }
  if (code === 'BID_AWARD_INVALID_STATE') {
    return '当前项目或投标状态暂不支持定标。';
  }
  if (code === 'BID_AWARD_DUPLICATE') {
    return '当前项目已完成定标，请勿重复提交。';
  }
  if (code === 'BID_AWARD_CONCURRENT_CONFLICT') {
    return '当前项目正在定标处理中，请稍后重试。';
  }
  if (code === 'ORDER_CONVERSION_FAILED') {
    return '当前定标后的订单生成失败，请稍后再试。';
  }
  if (code === 'CONTRACT_SEED_FAILED') {
    return '当前定标后的合同初始化失败，请稍后再试。';
  }
  return '当前定标入口暂不可用，请稍后再试。';
}

function rewriteAwardInvalidMessage(message: string | undefined) {
  if (message === 'Bid award body must be an object.') {
    return '当前定标数据格式无效，请刷新后重试。';
  }
  if (message === 'Field `projectId` is required for bid award.') {
    return '当前项目标识缺失，无法提交定标。';
  }
  if (message === 'Field `winningBidId` is required for bid award.') {
    return '当前中标投标标识缺失，无法提交定标。';
  }
  if (message === 'Field `reasonCode` is required for bid award.') {
    return '当前定标原因编码缺失，无法提交定标。';
  }
  if (message === 'Field `reasonText` is required for bid award.') {
    return '当前定标原因说明缺失，无法提交定标。';
  }
  if (message === 'Current buyer organization cannot award its own bid.') {
    return '当前组织不能对自己项目下的投标执行定标。';
  }
  return '当前定标参数无效，请检查后再试。';
}

function rewriteResultErrorMessage(code: string, message: string | undefined) {
  if (code === 'AUTH_SESSION_INVALID') {
    return '当前登录态不可用，请重新登录后再试。';
  }
  if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
    if (message === 'Current actor lacks the required organization scope for bid result.') {
      return '当前组织身份不可用，请先进入可查看竞标结果的组织后再试。';
    }
    if (message === 'Current organization type is not allowed for bid result.') {
      return '当前组织类型未开放竞标结果读取权限，请切换到供应商或需求方/供应商主体后再试。';
    }
    if (message === 'Current organization certification is not approved for bid result.') {
      return '当前组织认证尚未通过，暂不具备查看竞标结果的资格。';
    }
    if (message === 'Current personal certification is not approved for bid result.') {
      return '当前我的认证尚未通过，暂不具备查看竞标结果的资格。请先完成身份证正面认证。';
    }
    if (message === 'Current personal certification is locked to another actor for bid result.') {
      return '当前公司的我的认证已锁定到其他账号，不支持换人，当前账号暂不具备查看竞标结果的资格。';
    }
    if (message === 'Current organization cannot read bid result for its own project.') {
      return '当前组织不能读取自己发布项目的竞标结果。';
    }
    return '当前组织不具备查看竞标结果的权限。';
  }
  if (code === 'BID_RESULT_INVALID') {
    if (message === 'Field `projectId` is required for bid result.') {
      return '当前项目标识缺失，无法查看投标结果。';
    }
    return '当前投标结果查询参数无效，请检查后再试。';
  }
  return '当前投标结果暂不可用，请稍后再试。';
}

function toHttpException(
  payload: Record<string, unknown>,
  statusCode: number,
  code: string,
  message: string,
) {
  const body: NormalizedErrorBody = {
    ...payload,
    statusCode,
    code,
    source: payload.source === 'server' ? 'server' : 'bff',
    message,
  };
  return new HttpException(body, statusCode);
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
