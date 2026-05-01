import { HttpException, Injectable } from '@nestjs/common';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';

@Injectable()
export class ProfileOrganizationLeaveErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalize(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'ORG_MEMBER_LEAVE_INVALID',
      '当前退出组织暂不可用，请稍后再试。',
      {
        400: 'ORG_MEMBER_LEAVE_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'ORG_SCOPE_REQUIRED',
        404: 'ORG_MEMBER_UNAVAILABLE',
        409: 'ORG_LAST_ADMIN_LEAVE_BLOCKED',
      },
    );
    return this.rewriteMessage(normalized);
  }

  private rewriteMessage(exception: HttpException): HttpException {
    const statusCode = exception.getStatus();
    const payload = this.asRecord(exception.getResponse()) ?? {};
    const code = this.asString(payload.code) ?? 'UNKNOWN_ERROR';
    const source = this.asErrorSource(payload.source);
    const originalMessage = this.asString(payload.message) ?? '';
    const translatedMessage = this.translateMessage(code, originalMessage);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: translatedMessage,
      details: this.buildDetails(
        payload.details,
        originalMessage,
        translatedMessage,
      ),
      source,
    };
    return new HttpException(body, statusCode);
  }

  private translateMessage(code: string, message: string): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录态不可用，请重新登录或刷新后再试。';
    }
    if (code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return '当前无权限退出当前组织。';
    }
    if (code === 'AUTH_RESOURCE_UNAVAILABLE') {
      return '当前组织退出目标不可用，请稍后再试。';
    }
    if (code === 'ORG_SCOPE_REQUIRED') {
      return '当前还没有可退出的公司/组织，请先确认当前主体。';
    }
    if (code === 'ORG_MEMBER_UNAVAILABLE') {
      return '当前账号不在该组织的有效成员列表中，不能退出。';
    }
    if (code === 'ORG_LAST_ADMIN_LEAVE_BLOCKED') {
      return '你是当前组织最后一位管理员，需先添加或转交另一位管理员后才能退出。';
    }
    if (code !== 'ORG_MEMBER_LEAVE_INVALID') {
      return '当前退出组织暂不可用，请稍后再试。';
    }

    if (message.includes('Organization leave body must be an object.')) {
      return '当前退出组织参数格式无效，请检查后再试。';
    }
    if (message.includes('Optional leave reason')) {
      return '当前退出原因格式无效，请检查后再试。';
    }
    if (message.includes('cannot be left through the app-facing self-leave command')) {
      return '当前组织不能通过 App 自助退出。';
    }
    if (message.includes('membership state does not allow self-leave')) {
      return '当前成员状态不能退出该组织。';
    }
    return '当前退出组织请求无效，请检查后再试。';
  }

  private buildDetails(
    details: unknown,
    originalMessage: string,
    translatedMessage: string,
  ): Record<string, unknown> {
    const detailRecord = this.asRecord(details) ?? {};
    return {
      ...detailRecord,
      originalMessage,
      translatedMessage,
    };
  }

  private asRecord(value: unknown): Record<string, unknown> | null {
    return value !== null && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : null;
  }

  private asString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : null;
  }

  private asErrorSource(value: unknown) {
    return value === 'bff' || value === 'server' ? value : 'bff';
  }
}
