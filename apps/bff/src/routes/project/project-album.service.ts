import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  readProjectAlbumPhotoListReadModel,
  readProjectAlbumPhotoReadModel,
} from './project-album.read-model';

@Injectable()
export class ProjectAlbumService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async listPhotos(projectId: string | undefined, headers: IncomingHttpHeaders) {
    const normalizedProjectId = this.readProjectId(projectId);
    const path = this.albumPath(normalizedProjectId);
    try {
      const result = await this.serverClient.get<unknown>(path, {
        headers: this.authContext.buildForwardHeaders(headers),
      });
      return readProjectAlbumPhotoListReadModel(result);
    } catch (error) {
      throw this.normalizeAlbumError(error, 'GET', path);
    }
  }

  async bindPhoto(
    projectId: string | undefined,
    payload: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ) {
    const normalizedProjectId = this.readProjectId(projectId);
    const path = this.albumPath(normalizedProjectId);
    try {
      const result = await this.serverClient.post<unknown>(
        path,
        this.toBindPayload(payload),
        { headers: this.authContext.buildForwardHeaders(headers) },
      );
      return readProjectAlbumPhotoReadModel(result);
    } catch (error) {
      throw this.normalizeAlbumError(error, 'POST', path);
    }
  }

  async removePhoto(
    projectId: string | undefined,
    photoId: string | undefined,
    headers: IncomingHttpHeaders,
  ) {
    const normalizedProjectId = this.readProjectId(projectId);
    const normalizedPhotoId = this.readRequiredString(photoId, 'photoId');
    const path = `${this.albumPath(normalizedProjectId)}/${encodeURIComponent(
      normalizedPhotoId,
    )}`;
    try {
      const result = await this.serverClient.delete<unknown>(path, {
        headers: this.authContext.buildForwardHeaders(headers),
      });
      return readProjectAlbumPhotoReadModel(result);
    } catch (error) {
      throw this.normalizeAlbumError(error, 'DELETE', path);
    }
  }

  private toBindPayload(payload: Record<string, unknown>) {
    if (!payload || Array.isArray(payload) || typeof payload !== 'object') {
      throw this.invalid('Project album bind body must be an object.');
    }
    const fileAssetId = this.readRequiredString(payload.fileAssetId, 'fileAssetId');
    const category = this.readRequiredString(payload.category, 'category');
    if (!['contract', 'progress', 'final', 'defect'].includes(category)) {
      throw this.invalid('Field `category` must be contract/progress/final/defect.');
    }
    return {
      fileAssetId,
      category,
      caption: this.readOptionalString(payload.caption, 'caption'),
      sortOrder: this.readOptionalNonNegativeInteger(payload.sortOrder, 'sortOrder'),
    };
  }

  private albumPath(projectId: string) {
    return `/server/projects/${encodeURIComponent(projectId)}/album/photos`;
  }

  private readProjectId(value: string | undefined) {
    return this.readRequiredString(value, 'projectId');
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    throw this.invalid(`Field \`${field}\` is required.`);
  }

  private readOptionalString(value: unknown, field: string) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw this.invalid(`Field \`${field}\` must be a string when provided.`);
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : null;
  }

  private readOptionalNonNegativeInteger(value: unknown, field: string) {
    if (value === undefined || value === null || value === '') {
      return null;
    }
    const parsed = typeof value === 'number' ? value : Number(value);
    if (!Number.isInteger(parsed) || parsed < 0) {
      throw this.invalid(`Field \`${field}\` must be a non-negative integer.`);
    }
    return parsed;
  }

  private invalid(message: string) {
    return new BadRequestException({
      statusCode: 400,
      code: 'PROJECT_ALBUM_INVALID',
      message,
      source: 'bff',
    });
  }

  private normalizeAlbumError(error: unknown, method: string, path: string) {
    const normalized = this.errors.toHttpException(
      error,
      'PROJECT_ALBUM_UNAVAILABLE',
      '当前项目相册暂不可用，请稍后再试。',
      {
        400: 'PROJECT_ALBUM_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'PROJECT_ALBUM_FORBIDDEN',
        404: 'PROJECT_ALBUM_UNAVAILABLE',
        409: 'PROJECT_ALBUM_LIMIT_EXCEEDED',
      },
    );
    const payload = this.asRecord(normalized.getResponse());
    const message = this.asString(payload.message) ?? '';
    if (
      normalized.getStatus() === 404 &&
      message.includes(`Cannot ${method} ${path}`)
    ) {
      return new HttpException(
        {
          statusCode: normalized.getStatus(),
          code: 'PROJECT_ALBUM_UNAVAILABLE',
          message: '当前项目相册暂不可用，请稍后再试。',
          source: payload.source === 'server' ? 'server' : 'bff',
        },
        normalized.getStatus(),
      );
    }
    return normalized;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object'
      ? (value as Record<string, unknown>)
      : {};
  }

  private asString(value: unknown) {
    return typeof value === 'string' ? value : undefined;
  }
}
