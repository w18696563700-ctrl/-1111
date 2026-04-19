import { HttpException, Injectable } from '@nestjs/common';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import type { NormalizedErrorBody } from '../../shared/api';

@Injectable()
export class ForumReportMineErrorService {
  constructor(private readonly errors: ErrorNormalizerService) {}

  normalizeMineListError(error: unknown): HttpException {
    return this.normalize(error, '我的举报记录暂时不可用，请稍后再试。');
  }

  normalizeMineDetailError(error: unknown): HttpException {
    return this.normalize(error, '当前举报记录暂不可用，请刷新后再试。');
  }

  private normalize(error: unknown, fallbackMessage: string): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'FORUM_REPORT_ROUTE_UNAVAILABLE',
      fallbackMessage,
      { 404: 'FORUM_REPORT_ROUTE_UNAVAILABLE' },
    );
    return this.rewriteMessage(normalized, fallbackMessage);
  }

  private rewriteMessage(exception: HttpException, fallbackMessage: string): HttpException {
    const statusCode = exception.getStatus();
    const payload = this.asRecord(exception.getResponse());
    const code = this.asString(payload.code) ?? 'FORUM_REPORT_ROUTE_UNAVAILABLE';
    const source = this.asErrorSource(payload.source);
    const originalMessage = this.asString(payload.message) ?? '';
    const message = this.translateMessage(code, originalMessage, fallbackMessage);
    const details = this.buildDetails(payload.details, originalMessage, message);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message,
      details,
      source,
    };
    return new HttpException(body, statusCode);
  }

  private translateMessage(code: string, message: string, fallbackMessage: string): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }
    if (code === 'FORUM_REPORT_INVALID') {
      if (message.includes('ticketId is invalid')) {
        return '举报记录参数无效，请刷新后再试。';
      }
      return '举报记录参数无效，请检查后再试。';
    }
    if (code === 'FORUM_REPORT_UNAVAILABLE') {
      return '当前举报记录暂不可用，请刷新后再试。';
    }
    if (code === 'FORUM_REPORT_ROUTE_UNAVAILABLE') {
      return '我的举报记录入口暂不可用，请稍后再试。';
    }
    return fallbackMessage;
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
    return value && typeof value === 'object' ? { ...(value as Record<string, unknown>) } : {};
  }

  private asString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private asErrorSource(value: unknown): 'bff' | 'server' {
    return value === 'server' ? 'server' : 'bff';
  }
}
