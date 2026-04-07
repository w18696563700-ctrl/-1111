import { HttpException, Injectable } from '@nestjs/common';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import type { NormalizedErrorBody } from '../../shared/api';
import type {
  ForumInteractionReadSurface,
  ForumInteractionWriteAction,
} from './forum-command-error.types';
import { ForumDraftCommandErrorMessageService } from './forum-draft-command-error-message.service';
import { ForumInteractionCommandErrorMessageService } from './forum-interaction-command-error-message.service';
import { ForumOwnPostCommandErrorMessageService } from './forum-own-post-command-error-message.service';
import { ForumReportCommandErrorMessageService } from './forum-report-command-error-message.service';

@Injectable()
export class ForumCommandErrorService {
  constructor(
    private readonly errors: ErrorNormalizerService,
    private readonly draftMessages: ForumDraftCommandErrorMessageService,
    private readonly reportMessages: ForumReportCommandErrorMessageService,
    private readonly interactionMessages: ForumInteractionCommandErrorMessageService,
    private readonly ownPostMessages: ForumOwnPostCommandErrorMessageService,
  ) {}

  normalizeDraftSaveError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'FORUM_DRAFT_SAVE_FAILED',
      '论坛草稿暂时保存失败，请稍后再试。',
    );
    return this.rewriteMessage(normalized, (code, message) =>
      this.draftMessages.translateDraftSaveMessage(code, message),
    );
  }

  normalizePublishError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'FORUM_PUBLISH_FAILED',
      '论坛草稿暂时发布失败，请稍后再试。',
    );
    return this.rewriteMessage(normalized, (code, message) =>
      this.draftMessages.translatePublishMessage(code, message),
    );
  }

  normalizeReportSubmitError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'FORUM_REPORT_SUBMIT_FAILED',
      '举报提交暂时失败，请稍后再试。',
    );
    return this.rewriteMessage(normalized, (code, message) =>
      this.reportMessages.translateReportSubmitMessage(code, message),
    );
  }

  normalizeInteractionReadError(
    error: unknown,
    surface: ForumInteractionReadSurface,
  ): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'FORUM_INTERACTION_FAILED',
      '论坛互动内容暂时不可用，请稍后再试。',
    );
    return this.rewriteMessage(normalized, (code, message) =>
      this.interactionMessages.translateInteractionReadMessage(surface, code, message),
    );
  }

  normalizeInteractionWriteError(
    error: unknown,
    action: ForumInteractionWriteAction,
  ): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'FORUM_INTERACTION_FAILED',
      '论坛互动操作暂时失败，请稍后再试。',
    );
    return this.rewriteMessage(normalized, (code, message) =>
      this.interactionMessages.translateInteractionWriteMessage(action, code, message),
    );
  }

  normalizeOwnPostReadError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'FORUM_OWN_POST_FAILED',
      '我的帖子暂时不可用，请稍后再试。',
    );
    return this.rewriteMessage(normalized, (code, message) =>
      this.ownPostMessages.translateOwnPostReadMessage(code, message),
    );
  }

  normalizeOwnPostEditError(error: unknown): HttpException {
    return this.normalizeOwnPostActionError(error, 'edit');
  }

  normalizeOwnPostDeleteError(error: unknown): HttpException {
    return this.normalizeOwnPostActionError(error, 'delete');
  }

  normalizeDraftOpenError(error: unknown): HttpException {
    const normalized = this.errors.toHttpException(
      error,
      'FORUM_DRAFT_OPEN_FAILED',
      '草稿暂时无法打开，请稍后再试。',
    );
    return this.rewriteMessage(normalized, (code, message) =>
      this.draftMessages.translateDraftOpenMessage(code, message),
    );
  }

  private normalizeOwnPostActionError(error: unknown, action: 'edit' | 'delete') {
    const normalized = this.errors.toHttpException(
      error,
      action === 'edit' ? 'FORUM_POST_EDIT_FAILED' : 'FORUM_POST_DELETE_FAILED',
      action === 'edit' ? '帖子暂时不能进入编辑，请稍后再试。' : '帖子暂时不能删除，请稍后再试。',
    );
    return this.rewriteMessage(normalized, (code, message) =>
      this.ownPostMessages.translateOwnPostActionMessage(action, code, message),
    );
  }

  private rewriteMessage(
    exception: HttpException,
    translate: (code: string, message: string) => string,
  ): HttpException {
    const statusCode = exception.getStatus();
    const payload = this.asRecord(exception.getResponse());
    const code = this.asString(payload.code) ?? 'UNKNOWN_ERROR';
    const source = this.asErrorSource(payload.source);
    const originalMessage = this.asString(payload.message) ?? '';
    const translatedMessage = translate(code, originalMessage);
    const details = this.buildDetails(payload.details, originalMessage, translatedMessage);

    const body: NormalizedErrorBody = {
      statusCode,
      code,
      message: translatedMessage,
      details,
      source,
    };
    return new HttpException(body, statusCode);
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
