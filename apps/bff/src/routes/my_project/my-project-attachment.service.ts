import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import type {
  MyProjectAttachmentDeleteResponse,
  MyProjectAttachmentListResponse,
  MyProjectAttachmentReadModel,
} from './my-project-attachment.read-model';

type AttachmentBindCommand = {
  fileAssetId: string;
  fileName: string;
  attachmentKind: string;
  sortOrder?: number;
};

type ActionErrorMessages = {
  unavailableMessage: string;
  forbiddenMessage: string;
  invalidMessage: string;
};

@Injectable()
export class MyProjectAttachmentService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async getAttachments(projectId: string, headers: IncomingHttpHeaders) {
    const normalizedProjectId = this.readRouteId(
      projectId,
      '当前项目资料路由参数无效，请检查后再试。',
    );
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/projects/${encodeURIComponent(normalizedProjectId)}/attachments`,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toListResponse(
        this.requireRecord(result, 'Project attachment list response must be an object.'),
        normalizedProjectId,
      );
    } catch (error) {
      throw this.normalizeActionError(error, {
        unavailableMessage: '当前项目资料暂不可用，请稍后再试。',
        forbiddenMessage: '当前账号没有权限查看该项目资料。',
        invalidMessage: '当前项目资料参数无效，请检查后再试。',
      });
    }
  }

  async bindAttachment(
    projectId: string,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    const normalizedProjectId = this.readRouteId(
      projectId,
      '当前项目资料路由参数无效，请检查后再试。',
    );
    const command = this.toBindCommand(payload);
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        `/server/projects/${encodeURIComponent(normalizedProjectId)}/attachments`,
        command,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toReadModel(
        this.requireRecord(result, 'Project attachment bind response must be an object.'),
        normalizedProjectId,
      );
    } catch (error) {
      throw this.normalizeActionError(error, {
        unavailableMessage: '当前项目资料补充入口暂不可用，请稍后再试。',
        forbiddenMessage: '当前账号没有权限补充该项目资料。',
        invalidMessage: '当前项目资料补充参数无效，请检查后再试。',
      });
    }
  }

  async deleteAttachment(
    projectId: string,
    attachmentId: string,
    headers: IncomingHttpHeaders,
  ) {
    const normalizedProjectId = this.readRouteId(
      projectId,
      '当前项目资料路由参数无效，请检查后再试。',
    );
    const normalizedAttachmentId = this.readRouteId(
      attachmentId,
      '当前项目资料删除路由参数无效，请检查后再试。',
    );
    try {
      const result = await this.serverClient.delete<Record<string, unknown>>(
        `/server/projects/${encodeURIComponent(normalizedProjectId)}/attachments/${encodeURIComponent(
          normalizedAttachmentId,
        )}`,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toDeleteResponse(
        this.requireRecord(result, 'Project attachment delete response must be an object.'),
        normalizedProjectId,
        normalizedAttachmentId,
      );
    } catch (error) {
      throw this.normalizeActionError(error, {
        unavailableMessage: '当前项目资料删除入口暂不可用，请稍后再试。',
        forbiddenMessage: '当前账号没有权限删除该项目资料。',
        invalidMessage: '当前项目资料删除参数无效，请检查后再试。',
      });
    }
  }

  private normalizeActionError(
    error: unknown,
    messages: ActionErrorMessages,
  ) {
    const normalized = this.errors.toHttpException(
      error,
      'PROJECT_ATTACHMENT_UNAVAILABLE',
      messages.unavailableMessage,
      {
        400: 'PROJECT_ATTACHMENT_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'PROJECT_ATTACHMENT_FORBIDDEN',
        404: 'PROJECT_ATTACHMENT_UNAVAILABLE',
        409: 'PROJECT_ATTACHMENT_DUPLICATE',
      },
    );

    const statusCode = normalized.getStatus();
    const payload = this.asRecord(normalized.getResponse()) ?? {};
    const originalMessage = this.asString(payload.message);
    const details = this.asRecord(payload.details) ?? {};

    if (statusCode === 401) {
      return this.toHttpException(
        payload,
        statusCode,
        'AUTH_SESSION_INVALID',
        '当前登录状态已失效，请重新登录后再试。',
        originalMessage,
        details,
      );
    }

    if (statusCode === 403) {
      return this.toHttpException(
        payload,
        statusCode,
        'PROJECT_ATTACHMENT_FORBIDDEN',
        messages.forbiddenMessage,
        originalMessage,
        details,
      );
    }

    if (statusCode === 404) {
      return this.toHttpException(
        payload,
        statusCode,
        'PROJECT_ATTACHMENT_UNAVAILABLE',
        messages.unavailableMessage,
        originalMessage,
        details,
      );
    }

    if (statusCode === 409) {
      const invalidStateMessage = this.translateInvalidStateMessage(originalMessage);
      return this.toHttpException(
        payload,
        statusCode,
        invalidStateMessage == null
            ? 'PROJECT_ATTACHMENT_DUPLICATE'
            : 'PROJECT_INVALID_STATE',
        invalidStateMessage ?? '当前资料已存在，请勿重复补充。',
        originalMessage,
        details,
      );
    }

    if (statusCode === 400) {
      return this.toHttpException(
        payload,
        statusCode,
        'PROJECT_ATTACHMENT_INVALID',
        this.translateInvalidMessage(originalMessage, messages.invalidMessage),
        originalMessage,
        details,
      );
    }

    return normalized;
  }

  private toHttpException(
    payload: Record<string, unknown>,
    statusCode: number,
    code: string,
    message: string,
    originalMessage: string,
    details: Record<string, unknown>,
  ) {
    const normalizedDetails = { ...details };
    if (originalMessage && originalMessage !== message) {
      normalizedDetails.originalMessage = originalMessage;
    }

    return new HttpException(
      {
        ...payload,
        statusCode,
        code,
        message,
        details: normalizedDetails,
        source: payload.source === 'server' ? 'server' : 'bff',
      },
      statusCode,
    );
  }

  private translateInvalidMessage(message: string, fallback: string) {
    if (!message) {
      return fallback;
    }

    if (
      message.includes('Field `fileAssetId` is required') ||
      message.includes('Field `fileName` is required') ||
      message.includes('Field `attachmentKind` is required')
    ) {
      return '当前项目资料补充参数不完整，请检查后再试。';
    }

    if (message.includes('Field `sortOrder`')) {
      return '当前项目资料排序参数无效，请检查后再试。';
    }

    if (message.includes('attachmentKind is not supported')) {
      return '当前项目资料类型不支持，请检查后再试。';
    }

    if (message.includes('mime type is not allowed')) {
      return '当前项目资料文件类型与资料分类不匹配，请检查后再试。';
    }

    if (message.includes('FileAsset truth is unavailable')) {
      return '当前资料文件暂不可用，请重新上传后再试。';
    }

    if (message.includes('FileAsset truth is not aligned')) {
      return '当前资料文件与项目绑定不一致，请重新上传后再试。';
    }

    if (
      message.includes('Only published projects may enter') ||
      message.includes('Only submitted-or-later projects may enter')
    ) {
      return '当前项目状态暂不支持补充资料。';
    }

    return fallback;
  }

  private translateInvalidStateMessage(message: string) {
    if (
      message.includes('Only published projects may enter') ||
      message.includes('Only submitted-or-later projects may enter')
    ) {
      return '当前项目状态暂不支持补充资料。';
    }

    return null;
  }

  private toBindCommand(payload: Record<string, unknown>): AttachmentBindCommand {
    const source = this.asRecord(payload) ?? {};
    const fileAssetId = this.asString(source.fileAssetId);
    const fileName = this.asString(source.fileName);
    const attachmentKind = this.asString(source.attachmentKind);

    if (!fileAssetId || !fileName || !attachmentKind) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'PROJECT_ATTACHMENT_INVALID',
        message: '当前项目资料补充参数不完整，请检查后再试。',
        source: 'bff',
      });
    }

    const sortOrder = this.readOptionalSortOrder(source.sortOrder);
    return sortOrder === undefined
      ? { fileAssetId, fileName, attachmentKind }
      : { fileAssetId, fileName, attachmentKind, sortOrder };
  }

  private readOptionalSortOrder(value: unknown) {
    if (value === null || value === undefined || value === '') {
      return undefined;
    }

    const normalized =
      typeof value === 'number'
        ? value
        : typeof value === 'string' && value.trim().length > 0
          ? Number(value)
          : NaN;
    if (!Number.isInteger(normalized) || normalized < 0) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'PROJECT_ATTACHMENT_INVALID',
        message: '当前项目资料排序参数无效，请检查后再试。',
        source: 'bff',
      });
    }
    return normalized;
  }

  private readRouteId(value: string, message: string) {
    const normalized = this.asString(value);
    if (normalized) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'PROJECT_ATTACHMENT_INVALID',
      message,
      source: 'bff',
    });
  }

  private toListResponse(
    result: Record<string, unknown>,
    projectId: string,
  ): MyProjectAttachmentListResponse {
    const rawAttachments = Array.isArray(result.attachments)
      ? result.attachments
      : result.items;
    if (!Array.isArray(rawAttachments)) {
      throw new Error('Project attachment list response is missing `attachments`.');
    }

    return {
      projectId: this.asString(result.projectId) || projectId,
      attachments: rawAttachments.map((item) =>
        this.toReadModel(
          this.requireRecord(item, 'Project attachment item must be an object.'),
          projectId,
        ),
      ),
    };
  }

  private toReadModel(
    result: Record<string, unknown>,
    projectId: string,
  ): MyProjectAttachmentReadModel {
    const attachmentId = this.asString(result.attachmentId);
    const fileAssetId = this.asString(result.fileAssetId);
    const fileName = this.asString(result.fileName);
    const attachmentKind = this.asString(result.attachmentKind);
    const mimeType = this.asString(result.mimeType);
    const createdAt = this.asString(result.createdAt);
    const createdBy = this.asString(result.createdBy);

    if (
      !attachmentId ||
      !fileAssetId ||
      !fileName ||
      !attachmentKind ||
      !mimeType ||
      !createdAt
    ) {
      throw new Error('Project attachment response is missing required fields.');
    }

    return {
      attachmentId,
      projectId: this.asString(result.projectId) || projectId,
      fileAssetId,
      fileName,
      attachmentKind,
      mimeType,
      visibility: this.asString(result.visibility) || 'owner_private',
      sortOrder: this.asNumber(result.sortOrder, 0),
      createdAt,
      ...(createdBy ? { createdBy } : {}),
    };
  }

  private toDeleteResponse(
    result: Record<string, unknown>,
    projectId: string,
    attachmentId: string,
  ): MyProjectAttachmentDeleteResponse {
    const responseProjectId = this.asString(result.projectId) || projectId;
    const responseAttachmentId = this.asString(result.attachmentId) || attachmentId;

    return {
      projectId: responseProjectId,
      attachmentId: responseAttachmentId,
      deleted: true,
    };
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    const record = this.asRecord(value);
    if (record) {
      return record;
    }
    throw new Error(message);
  }

  private asRecord(value: unknown): Record<string, unknown> | null {
    return value !== null && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : null;
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }

    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private asNumber(value: unknown, fallback: number) {
    const normalized =
      typeof value === 'number'
        ? value
        : typeof value === 'string' && value.trim().length > 0
          ? Number(value)
          : NaN;
    return Number.isFinite(normalized) ? normalized : fallback;
  }
}
