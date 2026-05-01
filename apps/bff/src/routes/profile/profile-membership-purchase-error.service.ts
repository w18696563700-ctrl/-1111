import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type MembershipPurchaseAction =
  | 'purchase_offers'
  | 'order_create'
  | 'pay_init'
  | 'order_result';

const ALLOWED_CODES = new Set([
  'AUTH_SESSION_INVALID',
  'AUTH_PERMISSION_INSUFFICIENT',
  'AUTH_RESOURCE_UNAVAILABLE',
  'MEMBERSHIP_PURCHASE_OFFERS_UNAVAILABLE',
  'MEMBERSHIP_ORDER_CREATE_REJECTED',
  'MEMBERSHIP_ORDER_NOT_FOUND',
  'MEMBERSHIP_PAY_INIT_REJECTED',
  'MEMBERSHIP_ORDER_RESULT_UNAVAILABLE',
]);

@Injectable()
export class ProfileMembershipPurchaseErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizePurchaseOffersError(error: unknown): HttpException {
    return this.normalize(
      error,
      'purchase_offers',
      'MEMBERSHIP_PURCHASE_OFFERS_UNAVAILABLE',
      '当前会员购买方案暂不可用，请稍后再试。',
    );
  }

  normalizeOrderCreateError(error: unknown): HttpException {
    return this.normalize(
      error,
      'order_create',
      'MEMBERSHIP_ORDER_CREATE_REJECTED',
      '当前会员订单暂不能创建，请刷新后再试。',
    );
  }

  normalizePayInitError(error: unknown): HttpException {
    return this.normalize(
      error,
      'pay_init',
      'MEMBERSHIP_PAY_INIT_REJECTED',
      '当前会员支付暂不能初始化，请稍后再试。',
    );
  }

  normalizeOrderResultError(error: unknown): HttpException {
    return this.normalize(
      error,
      'order_result',
      'MEMBERSHIP_ORDER_RESULT_UNAVAILABLE',
      '当前会员订单结果暂不可读，请稍后再试。',
    );
  }

  private normalize(
    error: unknown,
    action: MembershipPurchaseAction,
    fallbackCode: string,
    fallbackMessage: string,
  ) {
    const normalized = this.errors.toHttpException(
      error,
      fallbackCode,
      fallbackMessage,
      {
        400: fallbackCode,
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: action === 'order_result' ? 'MEMBERSHIP_ORDER_NOT_FOUND' : fallbackCode,
      },
    );
    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse());
    const code = this.normalizeCode(this.asString(payload.code), fallbackCode);
    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: this.translateMessage(code, fallbackMessage),
      details: this.asRecord(payload.details),
      source: this.asErrorSource(payload.source),
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(code: string | undefined, fallbackCode: string) {
    if (code && ALLOWED_CODES.has(code)) {
      return code;
    }
    return fallbackCode;
  }

  private translateMessage(code: string, fallbackMessage: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return '当前无权限操作会员订单。';
    }
    if (code === 'MEMBERSHIP_ORDER_NOT_FOUND') {
      return '当前会员订单不存在或不可见。';
    }
    return fallbackMessage;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object'
      ? { ...(value as Record<string, unknown>) }
      : {};
  }

  private asString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim() ? value.trim() : undefined;
  }

  private asErrorSource(value: unknown): 'bff' | 'server' {
    return value === 'server' ? 'server' : 'bff';
  }
}
