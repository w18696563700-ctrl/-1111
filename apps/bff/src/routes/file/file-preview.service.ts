import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { readFilePreviewAccessReadModel } from './file-preview.read-model';

@Injectable()
export class FilePreviewService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async getPreviewAccess(
    headers: IncomingHttpHeaders,
    projectId: string | undefined,
    threadId: string | undefined,
    fileAssetId: string | undefined
  ) {
    try {
      const result = await this.serverClient.get<unknown>('/server/file/preview/access', {
        headers: this.buildScopedHeaders(headers),
        params: {
          projectId: this.readOptionalQuery(projectId),
          threadId: this.readOptionalQuery(threadId),
          fileAssetId: this.readOptionalQuery(fileAssetId)
        }
      });
      return readFilePreviewAccessReadModel(result);
    } catch (error) {
      throw this.errors.toHttpException(error, 'FILE_PREVIEW_UNAVAILABLE', '当前项目沟通附件预览暂不可用，请稍后再试。', {
        400: 'FILE_PREVIEW_UNAVAILABLE',
        401: 'AUTH_SESSION_INVALID',
        403: 'FILE_PREVIEW_FORBIDDEN',
        404: 'FILE_PREVIEW_UNAVAILABLE'
      });
    }
  }

  private buildScopedHeaders(headers: IncomingHttpHeaders) {
    return {
      ...this.authContext.buildForwardHeaders(headers),
      ...this.readOrganizationScopeHeaders(headers)
    };
  }

  private readOrganizationScopeHeaders(headers: IncomingHttpHeaders) {
    const result: Record<string, string> = {};
    this.assignIfPresent(result, 'x-organization-id', this.readHeader(headers, 'x-organization-id', 'x-org-id'));
    this.assignIfPresent(result, 'x-actor-role', this.readHeader(headers, 'x-actor-role', 'x-role'));
    return result;
  }

  private assignIfPresent(target: Record<string, string>, key: string, value: string | undefined) {
    if (value) {
      target[key] = value;
    }
  }

  private readHeader(headers: IncomingHttpHeaders, ...keys: string[]) {
    for (const key of keys) {
      const value = headers[key];
      if (Array.isArray(value)) {
        if (typeof value[0] === 'string' && value[0].length > 0) {
          return value[0];
        }
        continue;
      }
      if (typeof value === 'string' && value.length > 0) {
        return value;
      }
    }
    return undefined;
  }

  private readOptionalQuery(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized || undefined;
  }
}
