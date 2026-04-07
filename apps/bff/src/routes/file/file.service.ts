import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { IdempotencyService } from '../../core/idempotency/idempotency.service';
import { ForumCommandContextService } from '../forum/forum-command-context.service';

const FILE_UPLOAD_CONFIRM_ENDPOINT = '/api/app/file/upload/confirm';
const FORUM_DRAFT_ATTACHMENT_BUSINESS_TYPE = 'forum_draft_attachment';

type UploadInitCommand = {
  businessType: string;
  businessId: string | null;
  fileKind: string;
  mimeType: string;
  size: number;
  checksum: string;
};

type ServerFileAccessResponse = {
  fileAssetId?: unknown;
  mode?: unknown;
  accessUrl?: unknown;
  fileName?: unknown;
  mimeType?: unknown;
  expiresAt?: unknown;
  contentLengthBytes?: unknown;
};

@Injectable()
export class FileService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly idempotencyService: IdempotencyService,
    private readonly errors: ErrorNormalizerService,
    private readonly forumCommandContext: ForumCommandContextService,
  ) {}

  async initUpload(payload: Record<string, unknown>, headers: IncomingHttpHeaders, idempotencyKey?: string) {
    const cached = await this.idempotencyService.getCached('upload-init', idempotencyKey);
    if (cached) {
      return cached;
    }

    const commandPayload = this.toUploadInitCommand(payload);
    try {
      this.ensureUploadInitCommand(commandPayload);
      const forwardHeaders = await this.buildInitHeaders(commandPayload, headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/uploads/init', commandPayload, {
        headers: forwardHeaders,
      });
      const viewModel = this.toUploadInitViewModel(result);
      await this.idempotencyService.remember('upload-init', idempotencyKey, viewModel);
      return viewModel;
    } catch (error) {
      throw this.normalizeInitError(error, commandPayload.businessType);
    }
  }

  async confirmUpload(payload: Record<string, unknown>, headers: IncomingHttpHeaders, idempotencyKey?: string) {
    const cached = await this.idempotencyService.getCached('upload-confirm', idempotencyKey);
    if (cached) {
      return cached;
    }

    try {
      const commandPayload = this.toUploadConfirmCommand(payload);
      const result = await this.serverClient.post('/server/uploads/confirm', commandPayload, {
        headers: this.authContext.buildForwardHeaders(headers),
      });
      await this.idempotencyService.remember('upload-confirm', idempotencyKey, result);
      return result;
    } catch (error) {
      throw this.normalizeConfirmError(error);
    }
  }

  async getAccess(headers: IncomingHttpHeaders, fileAssetId?: string, mode?: string) {
    try {
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.get<Record<string, unknown>>('/server/file/access', {
        headers: forwardHeaders,
        params: {
          fileAssetId: this.asOptionalString(fileAssetId),
          mode: this.asOptionalString(mode),
        },
      });
      return this.toAccessViewModel(result);
    } catch (error) {
      throw this.normalizeAccessError(error);
    }
  }

  getSkeleton() {
    return {
      group: 'file',
      status: 'skeleton_only',
      truthOwner: 'Server.evidence',
      note: 'BFF only orchestrates init, direct upload handoff, and confirm.',
    };
  }

  private toUploadInitCommand(payload: Record<string, unknown>): UploadInitCommand {
    if (!Object.prototype.hasOwnProperty.call(payload, 'businessId')) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'FILE_UPLOAD_INIT_INVALID',
        message: 'Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum.',
        source: 'bff',
      });
    }
    return {
      businessType: this.asString(payload.businessType),
      businessId: this.readBusinessId(payload.businessId),
      fileKind: this.asString(payload.fileKind),
      mimeType: this.asString(payload.mimeType),
      size: this.asPositiveNumber(payload.size),
      checksum: this.asString(payload.checksum),
    };
  }

  private async buildInitHeaders(command: UploadInitCommand, headers: IncomingHttpHeaders) {
    if (command.businessType === FORUM_DRAFT_ATTACHMENT_BUSINESS_TYPE) {
      return this.forumCommandContext.buildCommandHeaders(headers);
    }
    return this.authContext.buildForwardHeaders(headers);
  }

  private normalizeConfirmError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'FILE_UPLOAD_CONFIRM_REQUIRED',
      '当前附件上传确认失败，请稍后再试。',
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse()) ?? {};
    const code = this.asString(payload.code);
    const originalMessage = this.asString(payload.message);
    if (!code || !originalMessage) {
      return normalized;
    }

    const translatedMessage = this.translateConfirmMessage(code, originalMessage);
    if (translatedMessage === originalMessage) {
      return normalized;
    }

    const details = this.asRecord(payload.details) ?? {};
    details.originalMessage = originalMessage;
    return new HttpException(
      {
        ...payload,
        statusCode,
        message: translatedMessage,
        details,
      },
      statusCode,
    );
  }

  private translateConfirmMessage(code: string, message: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }
    if (code === 'FILE_UPLOAD_CONFIRM_REQUIRED') {
      if (message.includes('uploadSessionId is required')) {
        return '当前附件上传确认参数不完整，请检查后再试。';
      }
      if (message.includes('Upload session does not exist')) {
        return '当前附件上传会话已失效，请重新上传后再试。';
      }
      if (message.includes('missing FileAsset truth')) {
        return '当前附件上传确认结果异常，请重新上传后再试。';
      }
      return '当前附件上传尚未确认完成，请重新上传后再试。';
    }

    return '当前附件上传确认失败，请稍后再试。';
  }

  private normalizeInitError(error: unknown, businessType: string) {
    const normalized = this.errors.toHttpException(
      error,
      'FILE_UPLOAD_INIT_FAILED',
      '上传初始化暂时失败，请稍后再试。',
    );
    if (businessType !== FORUM_DRAFT_ATTACHMENT_BUSINESS_TYPE) {
      return normalized;
    }

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse()) ?? {};
    const code = this.asString(payload.code);
    const originalMessage = this.asString(payload.message);
    if (!code || !originalMessage) {
      return normalized;
    }

    const translatedMessage = this.translateForumDraftAttachmentInitMessage(code, originalMessage);
    if (translatedMessage === originalMessage) {
      return normalized;
    }

    const details = this.asRecord(payload.details) ?? {};
    details.originalMessage = originalMessage;
    return new HttpException(
      {
        ...payload,
        statusCode,
        message: translatedMessage,
        details,
      },
      statusCode,
    );
  }

  private translateForumDraftAttachmentInitMessage(code: string, message: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }
    if (code === 'FILE_UPLOAD_INIT_INVALID') {
      if (
        message.includes('image or video media only') ||
        message.includes('bounded document attachments only')
      ) {
        return '论坛附件目前只支持图片、视频以及 PDF/文档文件。';
      }
      if (message.includes('20 MiB')) {
        return '论坛文档附件单个文件不能超过 20 MiB。';
      }
      if (message.includes('businessType, businessId, fileKind, mimeType, size, and checksum')) {
        return '当前附件上传参数不完整，请检查后再试。';
      }
      return '当前附件上传参数无效，请检查后再试。';
    }
    if (code === 'FORUM_DRAFT_UNAVAILABLE') {
      if (message.includes('not editable for attachment binding')) {
        return '当前草稿状态不允许继续绑定附件。';
      }
      if (message.includes('attachment binding')) {
        return '当前草稿暂不可用于绑定附件，请刷新后再试。';
      }
      return '当前论坛草稿暂不可用于附件上传，请稍后再试。';
    }
    return message;
  }

  private normalizeAccessError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'FILE_ACCESS_FAILED',
      '当前附件暂时无法读取，请稍后再试。',
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse()) ?? {};
    const code = this.asString(payload.code);
    const originalMessage = this.asString(payload.message);
    if (!code || !originalMessage) {
      return normalized;
    }

    const translatedMessage = this.translateAccessMessage(code, originalMessage);
    if (translatedMessage === originalMessage) {
      return normalized;
    }

    const details = this.asRecord(payload.details) ?? {};
    details.originalMessage = originalMessage;
    return new HttpException(
      {
        ...payload,
        statusCode,
        message: translatedMessage,
        details,
      },
      statusCode,
    );
  }

  private translateAccessMessage(code: string, message: string) {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }
    if (code === 'FILE_ACCESS_INVALID') {
      if (message.includes('fileAssetId is required')) {
        return '请先选择要读取的附件。';
      }
      if (message.includes('mode must be preview or download')) {
        return '当前附件读取方式无效，请检查后再试。';
      }
      return '当前附件读取参数无效，请检查后再试。';
    }
    if (code === 'FILE_ACCESS_NOT_FOUND') {
      return '当前附件不存在或暂不可用。';
    }
    if (code === 'FILE_ACCESS_PERMISSION_DENIED') {
      return '当前账号没有权限读取这个附件。';
    }
    if (code === 'FILE_ACCESS_UNAVAILABLE') {
      return '当前附件暂时不能读取。';
    }
    return '当前附件暂时无法读取，请稍后再试。';
  }

  private ensureUploadInitCommand(command: UploadInitCommand) {
    if (
      !command.businessType ||
      !command.fileKind ||
      !command.mimeType ||
      !command.checksum ||
      command.size <= 0
    ) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'FILE_UPLOAD_INIT_INVALID',
        message: 'Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum.',
        source: 'bff',
      });
    }
  }

  private readBusinessId(value: unknown): string | null {
    if (value === null) return null;
    if (typeof value !== 'string') {
      throw new BadRequestException({
        statusCode: 400,
        code: 'FILE_UPLOAD_INIT_INVALID',
        message: 'Upload init requires businessType, businessId, fileKind, mimeType, size, and checksum.',
        source: 'bff',
      });
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : null;
  }

  private toUploadConfirmCommand(payload: Record<string, unknown>) {
    const uploadSessionId = this.asString(payload.uploadSessionId);
    if (!uploadSessionId) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'FILE_UPLOAD_CONFIRM_REQUIRED',
        message: 'uploadSessionId is required for upload confirm.',
        source: 'bff',
      });
    }
    return { uploadSessionId };
  }

  private toUploadInitViewModel(result: Record<string, unknown>) {
    const directUpload = this.asRecord(result.directUpload) ?? {};
    const uploadSessionId = this.asString(result.uploadSessionId);
    const url = this.asString(directUpload.url);
    const method = this.asString(directUpload.method).toUpperCase();

    if (!uploadSessionId || !url || !method) {
      throw new Error('Upload init response is missing uploadSessionId or direct upload directive.');
    }

    return {
      uploadSessionId,
      directUpload: {
        url,
        method,
        headers: this.toHeaderMap(directUpload.headers),
      },
      confirm: {
        endpoint: FILE_UPLOAD_CONFIRM_ENDPOINT,
      },
    };
  }

  private toAccessViewModel(result: Record<string, unknown>) {
    const body = result as ServerFileAccessResponse;
    const fileAssetId = this.asOptionalString(body.fileAssetId);
    const mode = this.asOptionalString(body.mode);
    const accessUrl = this.asOptionalString(body.accessUrl);
    const fileName = this.asOptionalString(body.fileName);
    const mimeType = this.asOptionalString(body.mimeType);
    const expiresAt = this.asOptionalString(body.expiresAt);
    const contentLengthBytes = this.asOptionalNumber(body.contentLengthBytes);

    if (!fileAssetId || !mode || !accessUrl || !fileName || !mimeType || !expiresAt) {
      return result;
    }

    return {
      fileAssetId,
      mode,
      accessUrl,
      fileName,
      mimeType,
      expiresAt,
      ...(contentLengthBytes === undefined ? {} : { contentLengthBytes }),
    };
  }

  private toHeaderMap(value: unknown): Record<string, string> {
    const record = this.asRecord(value);
    if (!record) {
      return {};
    }

    return Object.fromEntries(
      Object.entries(record).flatMap(([key, entryValue]) => {
        const normalized = this.asString(entryValue);
        return normalized ? [[key, normalized]] : [];
      }),
    );
  }

  private asRecord(value: unknown): Record<string, unknown> | null {
    return value !== null && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : null;
  }

  private asString(value: unknown): string {
    if (typeof value !== 'string') {
      return '';
    }

    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private asOptionalString(value: unknown): string | undefined {
    const normalized = this.asString(value);
    return normalized.length > 0 ? normalized : undefined;
  }

  private asOptionalNumber(value: unknown): number | undefined {
    const normalized =
      typeof value === 'number' ? value : typeof value === 'string' && value.trim().length > 0 ? Number(value) : NaN;
    return Number.isFinite(normalized) ? normalized : undefined;
  }

  private asPositiveNumber(value: unknown): number {
    const normalized =
      typeof value === 'number' ? value : typeof value === 'string' && value.trim().length > 0 ? Number(value) : NaN;
    return Number.isFinite(normalized) && normalized > 0 ? normalized : 0;
  }
}
