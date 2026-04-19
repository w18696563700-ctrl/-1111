import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type OrganizationCreditScoringReadAction = 'status' | 'explanation' | 'handoff';

const CANONICAL_ERROR_CODES = new Set([
  'SHADOW_RESULT_UNAVAILABLE',
  'SAMPLE_INSUFFICIENT',
  'FUTURE_CREDIT_FAMILY_UNAVAILABLE',
  'FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE',
  'FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE',
]);

@Injectable()
export class ProfileOrganizationCreditScoringErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeStatusError(error: unknown) {
    return this.normalizeReadError(
      error,
      'status',
      '当前组织信用评分状态暂不可用，请稍后再试。',
    );
  }

  normalizeExplanationError(error: unknown) {
    return this.normalizeReadError(
      error,
      'explanation',
      '当前组织信用评分说明暂不可用，请稍后再试。',
    );
  }

  normalizeHandoffError(error: unknown) {
    return this.normalizeReadError(
      error,
      'handoff',
      '当前组织信用评分引导暂不可用，请稍后再试。',
    );
  }

  private normalizeReadError(
    error: unknown,
    action: OrganizationCreditScoringReadAction,
    fallbackMessage: string,
  ) {
    const normalized = this.errors.toHttpException(
      error,
      'FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE',
      fallbackMessage,
      {
        401: 'FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE',
        403: 'FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE',
        404: 'SHADOW_RESULT_UNAVAILABLE',
        503: 'FUTURE_CREDIT_FAMILY_UNAVAILABLE',
      },
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse());
    const originalCode = this.asString(payload.code);
    const originalMessage = this.asString(payload.message) ?? '';
    const code = this.normalizeCode(originalCode, originalMessage, statusCode);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: this.translateMessage(action, code),
      details: undefined,
      source: payload.source === 'server' ? 'server' : 'bff',
    };
    return new HttpException(body, statusCode);
  }

  private normalizeCode(
    code: string | undefined,
    originalMessage: string,
    statusCode: number,
  ) {
    if (originalMessage.startsWith('Cannot GET /server/profile/organization-credit-scoring/')) {
      return 'FUTURE_CREDIT_FAMILY_UNAVAILABLE';
    }

    if (code && CANONICAL_ERROR_CODES.has(code)) {
      return code;
    }

    if (code === 'AUTH_SESSION_INVALID' || code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return 'FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE';
    }
    if (statusCode === 401 || statusCode === 403) {
      return 'FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE';
    }
    if (statusCode === 404) {
      return 'SHADOW_RESULT_UNAVAILABLE';
    }

    return 'FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE';
  }

  private translateMessage(
    action: OrganizationCreditScoringReadAction,
    code: string,
  ) {
    if (code === 'FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE') {
      return '当前无权限查看组织信用评分。';
    }
    if (code === 'SAMPLE_INSUFFICIENT') {
      return action === 'handoff'
        ? '当前有效评价样本不足，暂无法提供组织信用评分引导。'
        : action === 'explanation'
          ? '当前有效评价样本不足，暂无法提供组织信用评分说明。'
          : '当前有效评价样本不足，暂无法形成组织信用评分。';
    }
    if (code === 'SHADOW_RESULT_UNAVAILABLE') {
      return action === 'handoff'
        ? '当前组织信用评分引导暂不可用，请稍后再试。'
        : action === 'explanation'
          ? '当前组织信用评分说明暂不可用，请稍后再试。'
          : '当前组织信用评分状态暂不可用，请稍后再试。';
    }
    if (code === 'FUTURE_CREDIT_FAMILY_UNAVAILABLE') {
      return '当前组织信用评分入口暂不可用，请稍后再试。';
    }
    return action === 'handoff'
      ? '当前组织信用评分引导暂不可用，请稍后再试。'
      : action === 'explanation'
        ? '当前组织信用评分说明暂不可用，请稍后再试。'
        : '当前组织信用评分状态暂不可用，请稍后再试。';
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object'
      ? { ...(value as Record<string, unknown>) }
      : {};
  }

  private asString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }
}
