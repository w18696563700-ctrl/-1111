import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type OrderCompletionAction = 'request' | 'confirm' | 'reject';

const ROUTE_DRIFT_PREFIXES: Record<OrderCompletionAction, string> = {
  request: 'Cannot POST /server/order/complete/request',
  confirm: 'Cannot POST /server/order/complete/confirm',
  reject: 'Cannot POST /server/order/complete/reject',
};

const PASS_THROUGH_CODES = new Set([
  'AUTH_SESSION_INVALID',
  'AUTH_PERMISSION_INSUFFICIENT',
  'PROJECT_ORDER_COMPLETE_INVALID',
  'PROJECT_ORDER_COMPLETE_UNAVAILABLE',
  'PROJECT_ORDER_COMPLETE_INVALID_STATE',
]);

@Injectable()
export class OrderCompletionErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeRequestError(error: unknown) {
    return this.normalizeError(error, 'request');
  }

  normalizeConfirmError(error: unknown) {
    return this.normalizeError(error, 'confirm');
  }

  normalizeRejectError(error: unknown) {
    return this.normalizeError(error, 'reject');
  }

  private normalizeError(error: unknown, action: OrderCompletionAction) {
    const normalized = this.errors.toHttpException(
      error,
      'PROJECT_ORDER_COMPLETE_UNAVAILABLE',
      '当前订单完工入口暂不可用，请稍后再试。',
      {
        400: 'PROJECT_ORDER_COMPLETE_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'PROJECT_ORDER_COMPLETE_UNAVAILABLE',
        409: 'PROJECT_ORDER_COMPLETE_INVALID_STATE',
      },
    );

    const statusCode = normalized.getStatus();
    const payload = asRecord(normalized.getResponse());
    const originalMessage = asString(payload.message);
    const code = this.normalizeCode(
      action,
      asString(payload.code),
      originalMessage,
      statusCode,
    );

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: this.translateMessage(action, code),
      source: payload.source === 'server' ? 'server' : 'bff',
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(
    action: OrderCompletionAction,
    code: string | undefined,
    originalMessage: string | undefined,
    statusCode: number,
  ) {
    if (originalMessage?.includes(ROUTE_DRIFT_PREFIXES[action])) {
      return 'PROJECT_ORDER_COMPLETE_UNAVAILABLE';
    }
    if (code && PASS_THROUGH_CODES.has(code)) {
      return code;
    }
    if (statusCode === 400) {
      return 'PROJECT_ORDER_COMPLETE_INVALID';
    }
    if (statusCode === 409) {
      return 'PROJECT_ORDER_COMPLETE_INVALID_STATE';
    }
    return 'PROJECT_ORDER_COMPLETE_UNAVAILABLE';
  }

  private translateMessage(action: OrderCompletionAction, code: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return action === 'request'
        ? '当前组织不具备发起完工申请权限，请确认承接方组织身份后再试。'
        : '当前组织不具备处理完工申请权限，请确认发布方组织身份后再试。';
    }
    if (code === 'PROJECT_ORDER_COMPLETE_INVALID') {
      return this.invalidMessage(action);
    }
    if (code === 'PROJECT_ORDER_COMPLETE_INVALID_STATE') {
      return this.invalidStateMessage(action);
    }
    return this.unavailableMessage(action);
  }

  private invalidMessage(action: OrderCompletionAction) {
    if (action === 'request') {
      return '当前完工申请参数无效，请检查后再试。';
    }
    if (action === 'confirm') {
      return '当前完工确认参数无效，请检查后再试。';
    }
    return '当前完工拒绝参数无效，请检查后再试。';
  }

  private invalidStateMessage(action: OrderCompletionAction) {
    if (action === 'request') {
      return '当前订单状态暂不支持发起完工申请。';
    }
    if (action === 'confirm') {
      return '当前订单状态暂不支持确认完工。';
    }
    return '当前订单状态暂不支持拒绝完工。';
  }

  private unavailableMessage(action: OrderCompletionAction) {
    if (action === 'request') {
      return '当前完工申请入口暂不可用，请稍后再试。';
    }
    if (action === 'confirm') {
      return '当前完工确认入口暂不可用，请稍后再试。';
    }
    return '当前完工拒绝入口暂不可用，请稍后再试。';
  }
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
