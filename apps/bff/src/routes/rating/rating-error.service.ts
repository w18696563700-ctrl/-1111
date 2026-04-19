import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type RatingAction = 'entry' | 'submit';

const ROUTE_DRIFT_PREFIXES = {
  entry: 'Cannot GET /server/rating/entry',
  submit: 'Cannot POST /server/rating/submit',
} as const;

@Injectable()
export class RatingErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeEntryError(error: unknown) {
    return this.normalizeError(
      error,
      'entry',
      'RATING_ENTRY_UNAVAILABLE',
      '当前评价入口暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'RATING_ENTRY_UNAVAILABLE',
      },
    );
  }

  normalizeSubmitError(error: unknown) {
    return this.normalizeError(
      error,
      'submit',
      'RATING_ENTRY_UNAVAILABLE',
      '当前评价提交入口暂不可用，请稍后再试。',
      {
        400: 'RATING_SUBMIT_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
        409: 'RATING_ENTRY_UNAVAILABLE',
      },
    );
  }

  private normalizeError(
    error: unknown,
    action: RatingAction,
    fallbackCode: string,
    fallbackMessage: string,
    statusCodeMap: Partial<Record<number, string>>,
  ) {
    const normalized = this.errors.toHttpException(
      error,
      fallbackCode,
      fallbackMessage,
      statusCodeMap,
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse());
    const originalMessage = this.asString(payload.message) ?? '';
    const code = this.normalizeCode(
      this.asString(payload.code) ?? fallbackCode,
      originalMessage,
      action,
      statusCode,
      fallbackCode,
    );
    const message = this.translateMessage(action, code);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message,
      details: undefined,
      source: this.asErrorSource(payload.source),
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(
    code: string,
    originalMessage: string,
    action: RatingAction,
    statusCode: number,
    fallbackCode: string,
  ) {
    if (originalMessage.includes(ROUTE_DRIFT_PREFIXES[action])) {
      return fallbackCode;
    }

    if (
      code === 'AUTH_SESSION_INVALID' ||
      code === 'AUTH_PERMISSION_INSUFFICIENT' ||
      code === 'AUTH_RESOURCE_UNAVAILABLE' ||
      code === 'RATING_ENTRY_UNAVAILABLE' ||
      code === 'RATING_SUBMIT_INVALID' ||
      code === 'RATING_INVALID_STATE'
    ) {
      return code;
    }

    if (statusCode === 400 || statusCode === 404 || statusCode === 409) {
      return fallbackCode;
    }

    return fallbackCode;
  }

  private translateMessage(action: RatingAction, code: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return action === 'submit'
        ? '当前无权限提交评价。'
        : '当前无权限进入评价入口。';
    }
    if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
      return action === 'submit'
        ? '当前评价资源不可用，暂时无法提交。'
        : '当前评价资源不可用，暂时无法查看。';
    }
    if (code === 'RATING_SUBMIT_INVALID') {
      return '当前评价提交参数无效，请检查后再试。';
    }
    if (code === 'RATING_INVALID_STATE') {
      return '当前评价状态暂不支持提交。';
    }
    if (code === 'RATING_ENTRY_UNAVAILABLE') {
      return action === 'submit'
        ? '当前评价提交入口暂不可用，请稍后再试。'
        : '当前评价入口暂不可用，请稍后再试。';
    }
    return action === 'submit'
      ? '当前评价提交入口暂不可用，请稍后再试。'
      : '当前评价入口暂不可用，请稍后再试。';
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object'
      ? { ...(value as Record<string, unknown>) }
      : {};
  }

  private asString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined;
  }

  private asErrorSource(value: unknown): 'bff' | 'server' {
    return value === 'server' ? 'server' : 'bff';
  }
}
