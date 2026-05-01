import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import {
  readAppNotificationListReadModel,
  readAppNotificationReadResultReadModel,
  readDevicePushTokenRegisterReadModel
} from './notification.read-model';

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
      throw this.normalizeNotificationError(error, 'PUSH_TOKEN_UNAVAILABLE', '当前设备通知注册暂不可用，请稍后再试。');
    }
  }

  async listNotifications(pageSize: string | undefined, cursor: string | undefined, headers: IncomingHttpHeaders) {
    const path = '/server/notifications/list';
    try {
      const result = await this.serverClient.get<unknown>(path, {
        headers: this.buildScopedHeaders(headers),
        params: {
          pageSize: this.readOptionalQuery(pageSize),
          cursor: this.readOptionalQuery(cursor)
        }
      });
      return readAppNotificationListReadModel(result);
    } catch (error) {
      throw this.normalizeNotificationError(error, 'NOTIFICATION_UNAVAILABLE', '当前通知中心暂不可用，请稍后再试。');
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
      throw this.normalizeNotificationError(error, 'NOTIFICATION_READ_INVALID', '当前通知已读操作暂不可用，请稍后再试。');
    }
  }

  private normalizeNotificationError(error: unknown, fallbackCode: string, fallbackMessage: string) {
    return this.errors.toHttpException(error, fallbackCode, fallbackMessage, {
      400: fallbackCode,
      401: 'AUTH_SESSION_INVALID',
      403: 'NOTIFICATION_FORBIDDEN',
      404: 'NOTIFICATION_UNAVAILABLE'
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

  private readOptionalQuery(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized || undefined;
  }
}
