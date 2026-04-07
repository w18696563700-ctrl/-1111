import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type MembershipReadAction = 'current' | 'explanation' | 'quota' | 'upgrade_guide';

const ROUTE_DRIFT_PREFIX = 'Cannot GET /server/profile/membership/';

@Injectable()
export class ProfileMembershipErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeCurrentError(error: unknown): HttpException {
    return this.normalizeReadError(
      error,
      'current',
      'MEMBERSHIP_CURRENT_UNAVAILABLE',
      '当前会员状态暂不可用，请稍后再试。',
    );
  }

  normalizeExplanationError(error: unknown): HttpException {
    return this.normalizeReadError(
      error,
      'explanation',
      'MEMBERSHIP_EXPLANATION_UNAVAILABLE',
      '当前会员权益说明暂不可用，请稍后再试。',
    );
  }

  normalizeQuotaError(error: unknown): HttpException {
    return this.normalizeReadError(
      error,
      'quota',
      'MEMBERSHIP_QUOTA_UNAVAILABLE',
      '当前会员配额摘要暂不可用，请稍后再试。',
    );
  }

  normalizeUpgradeGuideError(error: unknown): HttpException {
    return this.normalizeReadError(
      error,
      'upgrade_guide',
      'MEMBERSHIP_UPGRADE_GUIDE_UNAVAILABLE',
      '当前会员升级引导暂不可用，请稍后再试。',
    );
  }

  private normalizeReadError(
    error: unknown,
    action: MembershipReadAction,
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
    const code = this.normalizeCode(
      this.asString(payload.code) ?? fallbackCode,
      originalMessage,
      action,
    );
    const translatedMessage = this.translateMessage(action, code, originalMessage);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: translatedMessage,
      details: this.buildDetails(payload.details, originalMessage, translatedMessage),
      source: this.asErrorSource(payload.source),
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(
    code: string,
    originalMessage: string,
    action: MembershipReadAction,
  ) {
    if (originalMessage.includes(ROUTE_DRIFT_PREFIX)) {
      return 'MEMBERSHIP_ROUTE_UNAVAILABLE';
    }

    if (
      code === 'AUTH_SESSION_INVALID' ||
      code === 'AUTH_PERMISSION_INSUFFICIENT' ||
      code === 'AUTH_RESOURCE_UNAVAILABLE' ||
      code === 'MEMBERSHIP_ROUTE_UNAVAILABLE'
    ) {
      return code;
    }

    if (action === 'current' && code === 'MEMBERSHIP_CURRENT_UNAVAILABLE') {
      return code;
    }
    if (action === 'explanation' && code === 'MEMBERSHIP_EXPLANATION_UNAVAILABLE') {
      return code;
    }
    if (action === 'quota' && code === 'MEMBERSHIP_QUOTA_UNAVAILABLE') {
      return code;
    }
    if (action === 'upgrade_guide' && code === 'MEMBERSHIP_UPGRADE_GUIDE_UNAVAILABLE') {
      return code;
    }

    return code;
  }

  private translateMessage(
    action: MembershipReadAction,
    code: string,
    originalMessage: string,
  ) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }

    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      if (action === 'current') {
        return '当前无权限查看会员状态。';
      }
      if (action === 'explanation') {
        return '当前无权限查看会员权益说明。';
      }
      if (action === 'quota') {
        return '当前无权限查看会员配额摘要。';
      }
      return '当前无权限查看会员升级引导。';
    }

    if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
      return '当前会员资源不可用，请稍后再试。';
    }

    if (code === 'MEMBERSHIP_ROUTE_UNAVAILABLE') {
      return '当前会员能力入口暂不可用，请稍后再试。';
    }

    if (action === 'current') {
      return '当前会员状态暂不可用，请稍后再试。';
    }
    if (action === 'explanation') {
      return '当前会员权益说明暂不可用，请稍后再试。';
    }
    if (action === 'quota') {
      return '当前会员配额摘要暂不可用，请稍后再试。';
    }

    if (originalMessage.includes(ROUTE_DRIFT_PREFIX)) {
      return '当前会员能力入口暂不可用，请稍后再试。';
    }
    return '当前会员升级引导暂不可用，请稍后再试。';
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
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined;
  }

  private asErrorSource(value: unknown): 'bff' | 'server' {
    return value === 'server' ? 'server' : 'bff';
  }
}
