import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type CreditConstraintsReadAction = 'status' | 'explanation' | 'handoff';

@Injectable()
export class ProfileCreditConstraintsErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeStatusError(error: unknown) {
    return this.normalizeReadError(
      error,
      'status',
      'CREDIT_CONSTRAINT_STATUS_UNAVAILABLE',
      '当前信用与约束状态暂不可用，请稍后再试。',
    );
  }

  normalizeExplanationError(error: unknown) {
    return this.normalizeReadError(
      error,
      'explanation',
      'CREDIT_CONSTRAINT_STATUS_UNAVAILABLE',
      '当前信用与约束说明暂不可用，请稍后再试。',
    );
  }

  normalizeHandoffError(error: unknown) {
    return this.normalizeReadError(
      error,
      'handoff',
      'CREDIT_CONSTRAINT_STATUS_UNAVAILABLE',
      '当前信用与约束引导暂不可用，请稍后再试。',
    );
  }

  private normalizeReadError(
    error: unknown,
    action: CreditConstraintsReadAction,
    fallbackCode: string,
    fallbackMessage: string,
  ) {
    const normalized = this.errors.toHttpException(
      error,
      fallbackCode,
      fallbackMessage,
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: fallbackCode,
      },
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse());
    const originalMessage = this.asString(payload.message) ?? '';
    const code = this.normalizeCode(this.asString(payload.code) ?? fallbackCode, originalMessage);
    const translatedMessage = this.translateMessage(action, code);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: translatedMessage,
      details: this.buildDetails(payload.details, originalMessage, translatedMessage),
      source: this.asErrorSource(payload.source),
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(code: string, originalMessage: string) {
    if (originalMessage.startsWith('Cannot GET /server/profile/credit-and-constraints/')) {
      return 'CREDIT_AND_CONSTRAINTS_ROUTE_UNAVAILABLE';
    }

    if (
      code === 'AUTH_SESSION_INVALID' ||
      code === 'AUTH_PERMISSION_INSUFFICIENT' ||
      code === 'AUTH_RESOURCE_UNAVAILABLE' ||
      code === 'CREDIT_AND_CONSTRAINTS_ROUTE_UNAVAILABLE' ||
      code === 'CREDIT_CONSTRAINT_STATUS_UNAVAILABLE' ||
      code === 'DEPOSIT_POSTURE_UNAVAILABLE' ||
      code === 'TRANSACTION_GUARANTEE_POSTURE_UNAVAILABLE' ||
      code === 'DEPENDENCY_REFERENCE_UNAVAILABLE'
    ) {
      return code;
    }

    return code;
  }

  private translateMessage(action: CreditConstraintsReadAction, code: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return '当前无权限查看信用与约束。';
    }
    if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
      return '当前信用与约束资源不可用，请稍后再试。';
    }
    if (code === 'CREDIT_AND_CONSTRAINTS_ROUTE_UNAVAILABLE') {
      return '当前信用与约束入口暂不可用，请稍后再试。';
    }
    if (code === 'CREDIT_CONSTRAINT_STATUS_UNAVAILABLE') {
      return action === 'explanation'
        ? '当前信用与约束说明暂不可用，请稍后再试。'
        : action === 'handoff'
          ? '当前信用与约束引导暂不可用，请稍后再试。'
          : '当前信用与约束状态暂不可用，请稍后再试。';
    }
    if (code === 'DEPOSIT_POSTURE_UNAVAILABLE') {
      return action === 'explanation'
        ? '当前保证金姿态说明暂不可用，请稍后再试。'
        : action === 'handoff'
          ? '当前保证金引导暂不可用，请稍后再试。'
          : '当前保证金姿态暂不可用，请稍后再试。';
    }
    if (code === 'TRANSACTION_GUARANTEE_POSTURE_UNAVAILABLE') {
      return action === 'explanation'
        ? '当前交易保障姿态说明暂不可用，请稍后再试。'
        : action === 'handoff'
          ? '当前交易保障引导暂不可用，请稍后再试。'
          : '当前交易保障姿态暂不可用，请稍后再试。';
    }
    if (code === 'DEPENDENCY_REFERENCE_UNAVAILABLE') {
      return action === 'handoff'
        ? '当前依赖引导暂不可用，请稍后再试。'
        : '当前依赖说明暂不可用，请稍后再试。';
    }

    return action === 'handoff'
      ? '当前信用与约束引导暂不可用，请稍后再试。'
      : action === 'explanation'
        ? '当前信用与约束说明暂不可用，请稍后再试。'
        : '当前信用与约束状态暂不可用，请稍后再试。';
  }

  private buildDetails(
    rawDetails: unknown,
    originalMessage: string,
    translatedMessage: string,
  ): Record<string, unknown> | undefined {
    const details = this.asRecord(rawDetails);
    if (translatedMessage !== originalMessage && originalMessage.trim().length > 0) {
      details.originalMessage = originalMessage;
    }
    return Object.keys(details).length > 0 ? details : undefined;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object'
      ? { ...(value as Record<string, unknown>) }
      : {};
  }

  private asString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private asErrorSource(value: unknown): 'bff' | 'server' {
    return value === 'server' ? 'server' : 'bff';
  }
}
