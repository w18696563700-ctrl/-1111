import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import type {
  ProjectBidMaterialKind,
  ProjectBidMaterialListResponse,
  ProjectBidMaterialReadModel
} from './project-bid-material.read-model';

const PROJECT_BID_MATERIAL_KINDS = new Set<ProjectBidMaterialKind>([
  'effect_image',
  'construction_doc',
  'material_sample',
  'equipment_material_list',
  'service_list'
]);

@Injectable()
export class ProjectBidMaterialService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async getBidMaterials(projectId: string | undefined, headers: IncomingHttpHeaders) {
    const normalizedProjectId = this.readProjectId(projectId);
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        `/server/projects/${encodeURIComponent(normalizedProjectId)}/bid-materials`,
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(headers)
        }
      );
      return this.toListResponse(this.requireRecord(result, 'Project bid-material response must be an object.'));
    } catch (error) {
      throw this.normalizeListError(error);
    }
  }

  private normalizeListError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前项目材料清单暂不可读，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE'
      }
    );

    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const statusCode = normalized.getStatus();
    const code = this.asString(payload.code);

    if (statusCode == 401 && code === 'AUTH_SESSION_INVALID') {
      return new HttpException(
        {
          ...payload,
          statusCode,
          source: payload.source === 'server' ? 'server' : 'bff',
          message: '当前登录态不可用，请重新登录或刷新后再试。'
        },
        statusCode
      );
    }

    if (statusCode === 403 && code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return new HttpException(
        {
          ...payload,
          statusCode,
          source: payload.source === 'server' ? 'server' : 'bff',
          message: '当前项目材料清单暂不可读，请稍后再试。'
        },
        statusCode
      );
    }

    if (statusCode === 404) {
      return new HttpException(
        {
          ...payload,
          statusCode,
          code: 'AUTH_RESOURCE_UNAVAILABLE',
          source: payload.source === 'server' ? 'server' : 'bff',
          message: '当前项目材料清单暂不可读，请稍后再试。'
        },
        statusCode
      );
    }

    return normalized;
  }

  private readProjectId(value: string | undefined) {
    const normalized = this.asString(value);
    if (normalized) {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'AUTH_RESOURCE_UNAVAILABLE',
      message: '当前项目不可用。',
      source: 'bff'
    });
  }

  private toListResponse(result: Record<string, unknown>): ProjectBidMaterialListResponse {
    const projectId = this.asString(result.projectId);
    const attachments = result.attachments;
    if (!projectId || !Array.isArray(attachments)) {
      throw new Error('Project bid-material response is missing required fields.');
    }

    return {
      projectId,
      attachments: attachments.map((item) =>
        this.toReadModel(this.requireRecord(item, 'Project bid-material item must be an object.'), projectId)
      )
    };
  }

  private toReadModel(
    result: Record<string, unknown>,
    projectId: string
  ): ProjectBidMaterialReadModel {
    const attachmentId = this.asString(result.attachmentId);
    const fileAssetId = this.asString(result.fileAssetId);
    const fileName = this.asString(result.fileName);
    const attachmentKind = this.requireAttachmentKind(result.attachmentKind);
    const mimeType = this.asString(result.mimeType);
    const createdAt = this.asString(result.createdAt);

    if (!attachmentId || !fileAssetId || !fileName || !mimeType || !createdAt) {
      throw new Error('Project bid-material item is missing required fields.');
    }

    return {
      attachmentId,
      projectId: this.asString(result.projectId) || projectId,
      fileAssetId,
      fileName,
      attachmentKind,
      mimeType,
      sortOrder: this.asNumber(result.sortOrder, 0),
      createdAt
    };
  }

  private requireAttachmentKind(value: unknown): ProjectBidMaterialKind {
    const normalized = this.asString(value);
    if (!PROJECT_BID_MATERIAL_KINDS.has(normalized as ProjectBidMaterialKind)) {
      throw new Error('Project bid-material kind is invalid.');
    }
    return normalized as ProjectBidMaterialKind;
  }

  private requireRecord(value: unknown, message: string) {
    const record = this.asOptionalRecord(value);
    if (record) {
      return record;
    }
    throw new Error(message);
  }

  private asOptionalRecord(value: unknown) {
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
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value;
    }
    if (typeof value === 'string') {
      const normalized = value.trim();
      if (normalized.length > 0) {
        const parsed = Number(normalized);
        if (Number.isFinite(parsed)) {
          return parsed;
        }
      }
    }
    return fallback;
  }
}
