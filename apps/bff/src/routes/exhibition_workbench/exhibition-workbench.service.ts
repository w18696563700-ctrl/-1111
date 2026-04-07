import { HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';

@Injectable()
export class ExhibitionWorkbenchService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async getSummary(headers: IncomingHttpHeaders) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/exhibition/workbench',
        {
          headers: this.authContext.buildAuthTransportHeaders(headers),
        },
      );
      return this.toWorkbenchSummaryResponse(result);
    } catch (error) {
      throw this.normalizeError(error);
    }
  }

  private normalizeError(error: unknown) {
    const normalized = this.errors.toHttpException(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前项目工作台暂不可用，请稍后再试。',
      {
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        404: 'AUTH_RESOURCE_UNAVAILABLE',
      },
    );

    const payload = this.asOptionalRecord(normalized.getResponse());
    if (
      !payload ||
      normalized.getStatus() !== 401 ||
      this.asString(payload.code) !== 'AUTH_SESSION_INVALID'
    ) {
      return normalized;
    }

    return new HttpException(
      {
        ...payload,
        statusCode: normalized.getStatus(),
        source: payload.source === 'server' ? 'server' : 'bff',
        message: '当前登录态不可用，请重新登录或刷新后再试。',
      },
      normalized.getStatus(),
    );
  }

  private toWorkbenchSummaryResponse(result: Record<string, unknown>) {
    this.requireRecord(
      result.project_chain,
      'Workbench response is missing project_chain.',
    );
    this.requireRecord(
      result.order_chain,
      'Workbench response is missing order_chain.',
    );
    this.requireRecord(
      result.fulfillment_chain,
      'Workbench response is missing fulfillment_chain.',
    );
    this.requireRecord(
      result.extension_boundary,
      'Workbench response is missing extension_boundary.',
    );

    return result;
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
