import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

type ProfileBlockAction = 'block' | 'unblock' | 'status';

@Injectable()
export class ProfileBlockErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeBlockError(error: unknown): HttpException {
    return this.normalizeCommandError(error, 'block');
  }

  normalizeUnblockError(error: unknown): HttpException {
    return this.normalizeCommandError(error, 'unblock');
  }

  normalizeStatusError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'GOVERNANCE_BLOCK_TARGET_UNAVAILABLE',
      '当前拉黑关系状态暂不可用，请稍后再试。',
      {
        400: 'GOVERNANCE_BLOCK_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'GOVERNANCE_BLOCK_TARGET_UNAVAILABLE',
      },
    );
    return this.rewriteError(normalized, 'status');
  }

  private normalizeCommandError(
    error: unknown,
    action: Exclude<ProfileBlockAction, 'status'>,
  ): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'GOVERNANCE_BLOCK_INVALID',
      '当前拉黑关系操作暂不可用，请稍后再试。',
      {
        400: 'GOVERNANCE_BLOCK_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'GOVERNANCE_BLOCK_TARGET_UNAVAILABLE',
      },
    );
    return this.rewriteError(normalized, action);
  }

  private rewriteError(
    exception: HttpException,
    action: ProfileBlockAction,
  ): HttpException {
    const statusCode = exception.getStatus();
    const payload = this.asRecord(exception.getResponse());
    const code = this.normalizeCode(this.asString(payload.code) ?? 'UNKNOWN_ERROR', statusCode);
    const originalMessage = this.asString(payload.message) ?? '';
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

  private normalizeCode(code: string, statusCode: number) {
    if (
      code === 'GOVERNANCE_BLOCK_INVALID' ||
      code === 'GOVERNANCE_BLOCK_TARGET_UNAVAILABLE' ||
      code === 'AUTH_SESSION_INVALID' ||
      code === 'AUTH_PERMISSION_INSUFFICIENT'
    ) {
      return code;
    }
    if (statusCode === 404) {
      return 'GOVERNANCE_BLOCK_TARGET_UNAVAILABLE';
    }
    if (statusCode === 400) {
      return 'GOVERNANCE_BLOCK_INVALID';
    }
    return code;
  }

  private translateMessage(
    action: ProfileBlockAction,
    code: string,
    message: string,
  ) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return '当前无权限操作该拉黑关系。';
    }
    if (code === 'GOVERNANCE_BLOCK_TARGET_UNAVAILABLE') {
      return action === 'status'
        ? '当前拉黑关系状态暂不可用，请稍后再试。'
        : '当前拉黑目标不可用，请刷新后再试。';
    }
    if (code !== 'GOVERNANCE_BLOCK_INVALID') {
      return action === 'status'
        ? '当前拉黑关系状态暂不可用，请稍后再试。'
        : '当前拉黑关系操作暂不可用，请稍后再试。';
    }
    return this.translateInvalidMessage(action, message);
  }

  private translateInvalidMessage(action: ProfileBlockAction, message: string) {
    if (message.includes('targetUserId') || message.includes('target user')) {
      return '请先选择要操作的用户后再试。';
    }
    if (message.includes('self') || message.includes('current actor')) {
      return '不能对当前登录账号执行该拉黑操作。';
    }
    if (message.includes('body must be an object')) {
      return '当前拉黑关系参数格式无效，请检查后再试。';
    }
    if (action === 'status') {
      return '当前拉黑关系状态参数无效，请检查后再试。';
    }
    return action === 'block'
      ? '当前拉黑请求无效，请检查后再试。'
      : '当前取消拉黑请求无效，请检查后再试。';
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
