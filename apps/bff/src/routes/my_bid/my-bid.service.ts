import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { readMyBidsReadModel } from './my-bid.read-model';

@Injectable()
export class MyBidService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async getMyBids(state: string | undefined, headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>('/server/my/bids', {
        headers: this.buildScopedHeaders(headers),
        params: state ? { state: this.readState(state) } : undefined,
      });
      return readMyBidsReadModel(result);
    } catch (error) {
      throw this.normalizeListError(error);
    }
  }

  private readState(state: string) {
    const normalized = state.trim();
    if (normalized === 'active' || normalized === 'historical') {
      return normalized;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'MY_BIDS_INVALID',
      message: '当前我的竞标查询参数无效，请检查后重试。',
      source: 'bff',
    });
  }

  private buildScopedHeaders(headers: IncomingHttpHeaders) {
    return {
      ...this.authContext.buildForwardHeaders(headers),
      ...this.readOrganizationScopeHeaders(headers),
    };
  }

  private readOrganizationScopeHeaders(headers: IncomingHttpHeaders) {
    const result: Record<string, string> = {};
    this.assignIfPresent(
      result,
      'x-organization-id',
      this.readHeader(headers, 'x-organization-id', 'x-org-id'),
    );
    this.assignIfPresent(
      result,
      'x-actor-role',
      this.readHeader(headers, 'x-actor-role', 'x-role'),
    );
    return result;
  }

  private normalizeListError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'MY_BIDS_UNAVAILABLE',
      '当前我的竞标暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'MY_BIDS_FORBIDDEN',
        404: 'MY_BIDS_UNAVAILABLE',
      },
    );

    const payload = this.readErrorPayload(normalized);
    if (
      normalized.getStatus() === 404 &&
      this.isRawRouteMessage(payload.message, '/server/my/bids')
    ) {
      return new HttpException(
        {
          statusCode: 404,
          code: 'MY_BIDS_UNAVAILABLE',
          message: '当前我的竞标暂不可用，请稍后再试。',
          source: payload.source === 'bff' ? 'bff' : 'server',
        },
        404,
      );
    }

    return normalized;
  }

  private readErrorPayload(error: HttpException) {
    const response = error.getResponse();
    if (response && typeof response === 'object' && !Array.isArray(response)) {
      return response as Record<string, unknown>;
    }
    return {
      statusCode: error.getStatus(),
      code: 'MY_BIDS_UNAVAILABLE',
      message: String(response),
      source: 'server',
    };
  }

  private isRawRouteMessage(message: unknown, pathName: string) {
    return typeof message === 'string' && message.includes(pathName);
  }

  private assignIfPresent(
    target: Record<string, string>,
    key: string,
    value: string | undefined,
  ) {
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
}
