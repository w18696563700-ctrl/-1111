import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

const ROUTE_DRIFT_PREFIX = 'Cannot GET /server/profile/governance/status';

@Injectable()
export class ProfileGovernanceStatusErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeStatusError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'GOVERNANCE_STATUS_RESOURCE_UNAVAILABLE',
      '当前治理状态暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'GOVERNANCE_STATUS_RESOURCE_UNAVAILABLE',
      },
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse());
    const originalMessage = this.asString(payload.message) ?? '';
    const code = this.normalizeCode(
      this.asString(payload.code) ?? 'GOVERNANCE_STATUS_RESOURCE_UNAVAILABLE',
      originalMessage,
      statusCode,
    );
    const translatedMessage = this.translateMessage(code, originalMessage);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: translatedMessage,
      details: this.buildDetails(payload.details, originalMessage, translatedMessage),
      source: this.asErrorSource(payload.source),
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(code: string, originalMessage: string, statusCode: number) {
    if (originalMessage.includes(ROUTE_DRIFT_PREFIX)) {
      return 'GOVERNANCE_STATUS_RESOURCE_UNAVAILABLE';
    }
    if (
      code === 'AUTH_SESSION_INVALID' ||
      code === 'AUTH_PERMISSION_INSUFFICIENT' ||
      code === 'AUTH_RESOURCE_UNAVAILABLE' ||
      code === 'GOVERNANCE_STATUS_RESOURCE_UNAVAILABLE'
    ) {
      return code;
    }
    if (statusCode === 404) {
      return 'GOVERNANCE_STATUS_RESOURCE_UNAVAILABLE';
    }
    return 'GOVERNANCE_STATUS_RESOURCE_UNAVAILABLE';
  }

  private translateMessage(code: string, originalMessage: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return '当前无权限查看治理状态。';
    }
    if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
      return '当前治理资源不可用，请稍后再试。';
    }
    if (originalMessage.includes(ROUTE_DRIFT_PREFIX)) {
      return '当前治理状态入口暂不可用，请稍后再试。';
    }
    return '当前治理状态暂不可用，请稍后再试。';
  }

  private buildDetails(rawDetails: unknown, originalMessage: string, translatedMessage: string) {
    const details = this.asRecord(rawDetails);
    if (translatedMessage !== originalMessage && originalMessage.trim().length > 0) {
      details.originalMessage = originalMessage;
    }
    return Object.keys(details).length > 0 ? details : undefined;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object' ? { ...(value as Record<string, unknown>) } : {};
  }

  private asString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private asErrorSource(value: unknown): 'bff' | 'server' {
    return value === 'server' ? 'server' : 'bff';
  }
}
