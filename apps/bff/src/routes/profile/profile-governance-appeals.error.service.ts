import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type AppealReadAction = 'list' | 'detail';
const ROUTE_DRIFT_PREFIX = 'Cannot GET /server/profile/governance/appeals';

@Injectable()
export class ProfileGovernanceAppealsErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeListError(error: unknown): HttpException {
    return this.normalizeReadError(error, 'list', '当前申诉记录暂不可用，请稍后再试。');
  }

  normalizeDetailError(error: unknown): HttpException {
    return this.normalizeReadError(error, 'detail', '当前申诉详情暂不可用，请刷新后再试。');
  }

  private normalizeReadError(error: unknown, action: AppealReadAction, fallbackMessage: string) {
    const normalized = this.errors.toHttpException(
      error,
      'GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE',
      fallbackMessage,
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE',
      },
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse());
    const originalMessage = this.asString(payload.message) ?? '';
    const code = this.normalizeCode(
      this.asString(payload.code) ?? 'GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE',
      originalMessage,
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

  private normalizeCode(code: string, originalMessage: string): string {
    if (originalMessage.includes(ROUTE_DRIFT_PREFIX)) {
      return 'GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE';
    }
    if (code === 'AUTH_SESSION_INVALID' || code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return code;
    }
    if (
      code === 'GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE' ||
      code === 'GOVERNANCE_PENALTY_RESOURCE_UNAVAILABLE' ||
      code === 'GOVERNANCE_APPEAL_DECIDE_INVALID'
    ) {
      return 'GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE';
    }
    return 'GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE';
  }

  private translateMessage(action: AppealReadAction, code: string, originalMessage: string): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return action === 'list' ? '当前无权限查看申诉记录。' : '当前无权限查看申诉详情。';
    }
    if (originalMessage.includes('appealCaseId is invalid')) {
      return '当前申诉记录暂不可用，请刷新后再试。';
    }
    return action === 'list' ? '当前申诉记录暂不可用，请稍后再试。' : '当前申诉详情暂不可用，请刷新后再试。';
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
