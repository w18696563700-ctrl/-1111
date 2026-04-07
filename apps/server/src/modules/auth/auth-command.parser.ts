import { Injectable } from '@nestjs/common';
import { AUTH_LOGIN_SCENE } from './auth.constants';
import { authRequestInvalid } from './auth.errors';

export type OtpSendCommand = {
  mobile: string;
  scene: string;
  deviceId: string | null;
};

export type OtpLoginCommand = {
  mobile: string;
  otpCode: string;
  deviceId: string;
  deviceName: string | null;
  osType: string | null;
  appVersion: string | null;
};

export type RefreshSessionCommand = {
  refreshToken: string;
  deviceId: string | null;
};

export type LogoutCommand = {
  revokeAllOtherDevices: boolean;
  deviceId: string | null;
};

@Injectable()
export class AuthCommandParser {
  parseOtpSend(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    const scene = this.readRequiredString(source.scene, 'scene');
    if (scene !== AUTH_LOGIN_SCENE) {
      throw authRequestInvalid('Only the login OTP scene is available in the current round.');
    }
    return {
      mobile: this.readRequiredString(source.mobile, 'mobile'),
      scene,
      deviceId: this.readOptionalString(source.deviceId)
    } satisfies OtpSendCommand;
  }

  parseOtpLogin(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      mobile: this.readRequiredString(source.mobile, 'mobile'),
      otpCode: this.readRequiredString(source.otpCode, 'otpCode'),
      deviceId: this.readRequiredString(source.deviceId, 'deviceId'),
      deviceName: this.readOptionalString(source.deviceName),
      osType: this.readOptionalString(source.osType),
      appVersion: this.readOptionalString(source.appVersion)
    } satisfies OtpLoginCommand;
  }

  parseRefresh(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      refreshToken: this.readRequiredString(source.refreshToken, 'refreshToken'),
      deviceId: this.readOptionalString(source.deviceId)
    } satisfies RefreshSessionCommand;
  }

  parseLogout(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      revokeAllOtherDevices: source.revokeAllOtherDevices === true,
      deviceId: this.readOptionalString(source.deviceId)
    } satisfies LogoutCommand;
  }

  private asRecord(value: unknown) {
    if (value === undefined || value === null) {
      return {};
    }
    if (Array.isArray(value) || typeof value !== 'object') {
      throw authRequestInvalid('Auth payload must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) {
      throw authRequestInvalid(`Field \`${field}\` is required.`);
    }
    return value.trim();
  }

  private readOptionalString(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw authRequestInvalid('Optional auth fields must be strings when provided.');
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }
}
