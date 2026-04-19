import { HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import type {
  ProjectPublicResourceCategory,
  ProjectPublicResourceListResponse,
  ProjectPublicResourceReadModel,
} from './project-public-resource.read-model';

const RESOURCE_CATEGORIES = new Set<ProjectPublicResourceCategory>([
  'contract_template',
  'process_guide',
  'other_resource',
]);

const APP_SHARED_VISIBILITY = 'app_shared';

@Injectable()
export class ProjectPublicResourceService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async getPublicResources(headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/projects/public-resources',
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(
            headers,
          ),
        },
      );
      return this.toListResponse(
        this.requireRecord(
          result,
          'Project public resource response must be an object.',
        ),
      );
    } catch (error) {
      throw this.normalizeListError(error);
    }
  }

  private normalizeListError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前公共资源目录暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const statusCode = normalized.getStatus();
    const code = this.asString(payload.code);

    if (statusCode === 401 && code === 'AUTH_SESSION_INVALID') {
      return new HttpException(
        {
          ...payload,
          statusCode,
          source: payload.source === 'server' ? 'server' : 'bff',
          message: '当前登录态不可用，请重新登录或刷新后再试。',
        },
        statusCode,
      );
    }

    if (statusCode === 403 && code === 'AUTH_PERMISSION_INSUFFICIENT') {
      return new HttpException(
        {
          ...payload,
          statusCode,
          source: payload.source === 'server' ? 'server' : 'bff',
          message: '当前账号暂不可访问公共资源目录。',
        },
        statusCode,
      );
    }

    if (statusCode === 404) {
      return new HttpException(
        {
          ...payload,
          statusCode,
          code: 'AUTH_RESOURCE_UNAVAILABLE',
          source: payload.source === 'server' ? 'server' : 'bff',
          message: '当前公共资源目录暂不可用，请稍后再试。',
        },
        statusCode,
      );
    }

    return normalized;
  }

  private toListResponse(
    result: Record<string, unknown>,
  ): ProjectPublicResourceListResponse {
    if (!Array.isArray(result.resources)) {
      throw new Error('Project public resource response is missing resources.');
    }

    return {
      resources: result.resources.map((item) =>
        this.toResourceReadModel(
          this.requireRecord(
            item,
            'Project public resource item must be an object.',
          ),
        ),
      ),
    };
  }

  private toResourceReadModel(
    result: Record<string, unknown>,
  ): ProjectPublicResourceReadModel {
    return {
      resourceId: this.requireString(result.resourceId, 'resourceId'),
      resourceCategory: this.requireCategory(result.resourceCategory),
      title: this.requireString(result.title, 'title'),
      summary: this.toNullableText(result.summary),
      fileAssetId: this.requireString(result.fileAssetId, 'fileAssetId'),
      fileName: this.requireString(result.fileName, 'fileName'),
      mimeType: this.requireString(result.mimeType, 'mimeType'),
      visibility: this.requireVisibility(result.visibility),
      sortOrder: this.requireNumber(result.sortOrder, 'sortOrder'),
      publishedAt: this.requireString(result.publishedAt, 'publishedAt'),
    };
  }

  private requireCategory(value: unknown): ProjectPublicResourceCategory {
    const normalized = this.requireString(value, 'resourceCategory');
    if (!RESOURCE_CATEGORIES.has(normalized as ProjectPublicResourceCategory)) {
      throw new Error('Project public resource category is invalid.');
    }
    return normalized as ProjectPublicResourceCategory;
  }

  private requireVisibility(value: unknown): 'app_shared' {
    const normalized = this.requireString(value, 'visibility');
    if (normalized !== APP_SHARED_VISIBILITY) {
      throw new Error('Project public resource visibility is invalid.');
    }
    return APP_SHARED_VISIBILITY;
  }

  private requireNumber(value: unknown, fieldName: string) {
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

    throw new Error(`Project public resource ${fieldName} is invalid.`);
  }

  private requireString(value: unknown, fieldName: string) {
    const normalized = this.asString(value);
    if (!normalized) {
      throw new Error(`Project public resource ${fieldName} is required.`);
    }
    return normalized;
  }

  private toNullableText(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : null;
  }

  private requireRecord(value: unknown, message: string) {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
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
}
