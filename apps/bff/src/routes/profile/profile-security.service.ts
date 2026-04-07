import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import type {
  ActionAckViewModel,
  SecurityDeviceItemViewModel,
  SecurityDevicesViewModel,
} from './profile-security.read-model';
import { readSecurityDeviceTrustStatus } from './profile-security.read-model';
import { ProfileSecurityErrorService } from './profile-security-error.service';

@Injectable()
export class ProfileSecurityService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly securityErrors: ProfileSecurityErrorService,
  ) {}

  async getSecurityDevices(headers: IncomingHttpHeaders): Promise<SecurityDevicesViewModel> {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>('/server/profile/security/devices', {
        headers: this.authContext.buildReadOnlyForwardHeaders(headers),
      });
      return this.toSecurityDevicesViewModel(
        this.requireRecord(result, 'Security devices response must be an object.'),
      );
    } catch (error) {
      throw this.securityErrors.normalizeDevicesListError(error);
    }
  }

  async revokeSecurityDevice(
    deviceId: string,
    body: Record<string, unknown>,
    headers: IncomingHttpHeaders,
  ): Promise<ActionAckViewModel> {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        `/server/profile/security/devices/${encodeURIComponent(deviceId)}/revoke`,
        body,
        {
          headers: this.authContext.buildForwardHeaders(headers),
        },
      );
      return this.toActionAckViewModel(
        this.requireRecord(result, 'Security device revoke response must be an object.'),
      );
    } catch (error) {
      throw this.securityErrors.normalizeDeviceRevokeError(error);
    }
  }

  private toSecurityDevicesViewModel(
    result: Record<string, unknown>,
  ): SecurityDevicesViewModel {
    if (!Array.isArray(result.items)) {
      throw new Error('Security devices response is missing items.');
    }

    return {
      items: result.items.map((item) => this.toSecurityDeviceItemViewModel(item)),
    };
  }

  private toSecurityDeviceItemViewModel(value: unknown): SecurityDeviceItemViewModel {
    const item = this.requireRecord(value, 'Security devices response contains an invalid item.');
    const deviceId = this.asString(item.deviceId);
    const currentDevice = item.currentDevice;
    const trustStatus = readSecurityDeviceTrustStatus(
      item.trustStatus,
      'Security devices response contains an invalid trustStatus.',
    );

    if (!deviceId || typeof currentDevice !== 'boolean') {
      throw new Error('Security devices response contains an incomplete item.');
    }

    return {
      deviceId,
      deviceName: this.asNullableString(item.deviceName),
      osType: this.asNullableString(item.osType),
      appVersion: this.asNullableString(item.appVersion),
      currentDevice,
      trustStatus,
      lastSeenAt: this.asNullableString(item.lastSeenAt),
      revokedAt: this.asNullableString(item.revokedAt),
    };
  }

  private toActionAckViewModel(
    result: Record<string, unknown>,
  ): ActionAckViewModel {
    const traceId = this.asString(result.traceId);
    if (result.ok !== true || !traceId) {
      throw new Error('Security device revoke response is missing required ack fields.');
    }

    return {
      ok: true,
      traceId,
    };
  }

  private requireRecord(value: unknown, message: string): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private asNullableString(value: unknown) {
    if (value === null || value === undefined) {
      return null;
    }
    return this.asString(value) || null;
  }
}
