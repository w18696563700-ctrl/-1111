import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { requireErrorCode } from '../../shared/contracts';
import {
  readAppNotificationListReadModel,
  readAppNotificationReadResultReadModel,
  readDevicePushTokenRegisterReadModel
} from './notification.read-model';

const NOTIFICATION_ERROR_CODES = {
  authSessionInvalid: requireErrorCode('AUTH_SESSION_INVALID'),
  unavailable: requireErrorCode('NOTIFICATION_UNAVAILABLE'),
  forbidden: requireErrorCode('NOTIFICATION_FORBIDDEN'),
  readInvalid: requireErrorCode('NOTIFICATION_READ_INVALID'),
  pushTokenInvalid: requireErrorCode('PUSH_TOKEN_INVALID'),
  pushTokenUnavailable: requireErrorCode('PUSH_TOKEN_UNAVAILABLE')
} as const;

@Injectable()
export class NotificationRouteService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService
  ) {}

  async registerDeviceToken(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    const path = '/server/notifications/device-token/register';
    try {
      const result = await this.serverClient.post<unknown>(path, payload, {
        headers: this.buildScopedHeaders(headers)
      });
      return readDevicePushTokenRegisterReadModel(result);
    } catch (error) {
      throw this.normalizeNotificationError(
        error,
        NOTIFICATION_ERROR_CODES.pushTokenUnavailable,
        '当前设备通知注册暂不可用，请稍后再试。',
        { 400: NOTIFICATION_ERROR_CODES.pushTokenInvalid }
      );
    }
  }

  async listNotifications(
    query: {
      pageSize?: string;
      cursor?: string;
      source?: string;
      lane?: string;
    },
    headers: IncomingHttpHeaders
  ) {
    const path = '/server/notifications/list';
    try {
      const result = await this.serverClient.get<unknown>(path, {
        headers: this.buildScopedHeaders(headers),
        params: {
          pageSize: this.readOptionalQuery(query.pageSize),
          cursor: this.readOptionalQuery(query.cursor),
          source: this.readOptionalQuery(query.source),
          lane: this.readOptionalQuery(query.lane)
        }
      });
      return readAppNotificationListReadModel(result);
    } catch (error) {
      throw this.normalizeNotificationError(
        error,
        NOTIFICATION_ERROR_CODES.unavailable,
        '当前通知中心暂不可用，请稍后再试。'
      );
    }
  }

  async markRead(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    const path = '/server/notifications/read';
    try {
      const result = await this.serverClient.post<unknown>(path, payload, {
        headers: this.buildScopedHeaders(headers)
      });
      return readAppNotificationReadResultReadModel(result);
    } catch (error) {
      throw this.normalizeNotificationReadError(error);
    }
  }

  private normalizeNotificationError(
    error: unknown,
    fallbackCode: string,
    fallbackMessage: string,
    statusCodeMap: Partial<Record<number, string>> = {}
  ) {
    return this.errors.toHttpException(error, fallbackCode, fallbackMessage, {
      400: fallbackCode,
      401: NOTIFICATION_ERROR_CODES.authSessionInvalid,
      403: NOTIFICATION_ERROR_CODES.forbidden,
      404: NOTIFICATION_ERROR_CODES.unavailable,
      503: NOTIFICATION_ERROR_CODES.unavailable,
      ...statusCodeMap
    });
  }

  private normalizeNotificationReadError(error: unknown) {
    return this.errors.toHttpException(
      error,
      NOTIFICATION_ERROR_CODES.unavailable,
      '当前通知已读操作暂不可用，请稍后再试。',
      {
        400: NOTIFICATION_ERROR_CODES.readInvalid,
        401: NOTIFICATION_ERROR_CODES.authSessionInvalid,
        403: NOTIFICATION_ERROR_CODES.forbidden,
        404: NOTIFICATION_ERROR_CODES.unavailable,
        503: NOTIFICATION_ERROR_CODES.unavailable
      }
    );
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
