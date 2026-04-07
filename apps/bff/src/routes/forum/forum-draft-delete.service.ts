import { HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import type { NormalizedErrorBody } from '../../shared/api';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { ForumCommandContextService } from './forum-command-context.service';

type ServerForumDraftDeletedResponse = {
  draftId?: unknown;
  state?: unknown;
};

@Injectable()
export class ForumDraftDeleteService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly forumCommandContext: ForumCommandContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async deleteDraft(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const draftId = this.asOptionalString(payload.draftId);
      if (!draftId) {
        throw new HttpException(
          {
            statusCode: 400,
            code: 'FORUM_DRAFT_DELETE_INVALID',
            message: 'draftId is required for forum draft delete.',
            source: 'bff',
          },
          400,
        );
      }
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/forum/draft/delete',
        { draftId },
        { headers: forwardHeaders },
      );
      return this.shapeDeleteResult(result);
    } catch (error) {
      throw this.normalizeDeleteError(error);
    }
  }

  private shapeDeleteResult(result: Record<string, unknown>) {
    const body = result as ServerForumDraftDeletedResponse;
    const draftId = this.asOptionalString(body.draftId);
    const state = this.asOptionalString(body.state);
    if (!draftId || !state) {
      return result;
    }

    return { draftId, state };
  }

  private normalizeDeleteError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'FORUM_DRAFT_DELETE_FAILED',
      '当前草稿暂时无法删除，请稍后再试。',
    );
    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse());
    const code = this.asOptionalString(payload.code) ?? 'FORUM_DRAFT_DELETE_FAILED';
    const originalMessage = this.asOptionalString(payload.message) ?? '';
    const translatedMessage = this.translateMessage(statusCode, code, originalMessage);
    const details = this.asRecord(payload.details);
    if (translatedMessage !== originalMessage && originalMessage.length > 0) {
      details.originalMessage = originalMessage;
    }

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: translatedMessage,
      details: Object.keys(details).length > 0 ? details : undefined,
      source: payload.source === 'server' ? 'server' : 'bff',
    };
    return new HttpException(body, statusCode);
  }

  private translateMessage(statusCode: number, code: string, message: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }
    if (statusCode === 404 && message.includes('Cannot POST /server/forum/draft/delete')) {
      return '当前草稿删除入口暂不可用，请稍后再试。';
    }
    if (
      code === 'FORUM_DRAFT_DELETE_INVALID' ||
      code === 'FORUM_DRAFT_INVALID'
    ) {
      if (message.includes('draftId is required')) {
        return '请先选择要删除的草稿。';
      }
      return '当前草稿删除参数无效，请检查后再试。';
    }
    if (
      code === 'FORUM_DRAFT_DELETE_PERMISSION_DENIED' ||
      code === 'FORUM_DRAFT_PERMISSION_DENIED'
    ) {
      return '当前账号暂不能删除这份草稿。';
    }
    if (
      code === 'FORUM_DRAFT_DELETE_NOT_FOUND' ||
      code === 'FORUM_DRAFT_NOT_FOUND'
    ) {
      return '当前草稿不存在或已被删除。';
    }
    if (
      code === 'FORUM_DRAFT_DELETE_INVALID_STATE' ||
      code === 'FORUM_DRAFT_UNAVAILABLE'
    ) {
      return '当前草稿暂时不能删除。';
    }
    return '当前草稿暂时无法删除，请稍后再试。';
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object'
      ? { ...(value as Record<string, unknown>) }
      : {};
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined;
  }
}
