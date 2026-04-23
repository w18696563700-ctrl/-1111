import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { readMessageInteractionListReadModel } from './message-interaction.read-model';

@Injectable()
export class MessageInteractionService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async getInteractions(lane: string | undefined, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<unknown>('/server/message/interactions', {
        headers: this.buildScopedHeaders(headers),
        params: { lane: this.readLane(lane) }
      });
      return readMessageInteractionListReadModel(result);
    } catch (error) {
      throw this.sanitizeError(
        this.errors.toHttpException(
          error,
          'MESSAGE_INTERACTION_UNAVAILABLE',
          '当前项目沟通入口暂不可用，请稍后再试。',
          {
            400: 'MESSAGE_INTERACTION_UNAVAILABLE',
            401: 'AUTH_SESSION_INVALID',
            403: 'MESSAGE_INTERACTION_FORBIDDEN',
            404: 'MESSAGE_INTERACTION_UNAVAILABLE'
          }
        )
      );
    }
  }

  private sanitizeError(error: HttpException) {
    const payload = this.readErrorPayload(error);
    const message = String(payload.message ?? '');
    if (
      error.getStatus() !== 404 &&
      !message.includes('Cannot GET /server/message/interactions')
    ) {
      return error;
    }
    return new HttpException(
      {
        statusCode: error.getStatus(),
        code: 'MESSAGE_INTERACTION_UNAVAILABLE',
        message: '当前项目沟通入口暂不可用，请稍后再试。',
        source: payload.source === 'bff' ? 'bff' : 'server'
      },
      error.getStatus()
    );
  }

  private readLane(lane: string | undefined) {
    const normalized = lane?.trim() ?? '';
    if (!normalized) {
      return 'project_communication';
    }
    if (normalized === 'project_communication') {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'MESSAGE_INTERACTION_INVALID',
      message: '当前项目沟通查询参数无效，请检查后重试。',
      source: 'bff'
    });
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

  private readErrorPayload(error: HttpException) {
    const response = error.getResponse();
    if (response && typeof response === 'object' && !Array.isArray(response)) {
      return response as Record<string, unknown>;
    }
    return {
      statusCode: error.getStatus(),
      code: 'MESSAGE_INTERACTION_UNAVAILABLE',
      message: String(response),
      source: 'server'
    };
  }
}
