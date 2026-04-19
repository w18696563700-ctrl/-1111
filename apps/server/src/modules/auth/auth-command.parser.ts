import { Injectable } from '@nestjs/common';
import { AUTH_LOGIN_SCENE, AUTH_PASSWORD_RESET_SCENE } from './auth.constants';
import { authConsentRequired, authRequestInvalid } from './auth.errors';

export type OtpSendCommand = {
  mobile: string;
  scene: string;
  deviceId: string | null;
};

export type OtpLoginCommand = {
  mobile: string;
  otpCode: string;
  deviceId: string;
  consentAccepted: true;
  deviceName: string | null;
  osType: string | null;
  appVersion: string | null;
};

export type PasswordLoginCommand = {
  mobile: string;
  password: string;
  deviceId: string | null;
  consentAccepted: true;
  deviceName: string | null;
  osType: string | null;
  appVersion: string | null;
};

export type RefreshSessionCommand = {
  refreshToken: string;
  deviceId: string | null;
};

export type PasswordSetCommand = {
  newPassword: string;
};

export type PasswordResetCommand = {
  mobile: string;
  otpCode: string;
  newPassword: string;
};

export type LogoutCommand = {
  revokeAllOtherDevices: boolean;
  deviceId: string | null;
};

export type WhitelistTestSessionCommand = {
  userId: string | null;
  mobile: string | null;
  organizationId: string;
  roleKey: string;
  certificationStatus: string | null;
  expiresAt: Date;
  reason: string;
  deviceId: string | null;
  deviceName: string | null;
};

@Injectable()
export class AuthCommandParser {
  parseOtpSend(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    const scene = this.readRequiredString(source.scene, 'scene');
    if (scene !== AUTH_LOGIN_SCENE && scene !== AUTH_PASSWORD_RESET_SCENE) {
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
    if (source.consentAccepted !== true) {
      throw authConsentRequired('请先阅读并同意《用户协议》《隐私政策》。');
    }
    return {
      mobile: this.readRequiredString(source.mobile, 'mobile'),
      otpCode: this.readRequiredString(source.otpCode, 'otpCode'),
      deviceId: this.readRequiredString(source.deviceId, 'deviceId'),
      consentAccepted: true,
      deviceName: this.readOptionalString(source.deviceName),
      osType: this.readOptionalString(source.osType),
      appVersion: this.readOptionalString(source.appVersion)
    } satisfies OtpLoginCommand;
  }

  parsePasswordLogin(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    if (source.consentAccepted !== true) {
      throw authConsentRequired('请先阅读并同意《用户协议》《隐私政策》。');
    }
    return {
      mobile: this.readRequiredString(source.mobile, 'mobile'),
      password: this.readRequiredString(source.password, 'password'),
      deviceId: this.readOptionalString(source.deviceId),
      consentAccepted: true,
      deviceName: this.readOptionalString(source.deviceName),
      osType: this.readOptionalString(source.osType),
      appVersion: this.readOptionalString(source.appVersion)
    } satisfies PasswordLoginCommand;
  }

  parsePasswordSet(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      newPassword: this.readRequiredString(source.newPassword, 'newPassword')
    } satisfies PasswordSetCommand;
  }

  parsePasswordReset(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      mobile: this.readRequiredString(source.mobile, 'mobile'),
      otpCode: this.readRequiredString(source.otpCode, 'otpCode'),
      newPassword: this.readRequiredString(source.newPassword, 'newPassword')
    } satisfies PasswordResetCommand;
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

  parseWhitelistTestSession(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    const userId = this.readOptionalString(source.userId);
    const mobile = this.readOptionalString(source.mobile);
    if (!userId && !mobile) {
      throw authRequestInvalid('Field `userId` or `mobile` is required.');
    }

    const expiresAtRaw = this.readRequiredString(source.expiresAt, 'expiresAt');
    const expiresAt = new Date(expiresAtRaw);
    if (Number.isNaN(expiresAt.getTime()) || expiresAt.getTime() <= Date.now()) {
      throw authRequestInvalid('Field `expiresAt` must be a future ISO datetime.');
    }

    return {
      userId,
      mobile,
      organizationId: this.readRequiredString(source.organizationId, 'organizationId'),
      roleKey: this.readRequiredString(source.roleKey, 'roleKey'),
      certificationStatus: this.readOptionalString(source.certificationStatus),
      expiresAt,
      reason: this.readRequiredString(source.reason, 'reason'),
      deviceId: this.readOptionalString(source.deviceId),
      deviceName: this.readOptionalString(source.deviceName)
    } satisfies WhitelistTestSessionCommand;
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
