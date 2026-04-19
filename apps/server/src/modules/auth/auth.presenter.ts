import { Injectable } from '@nestjs/common';
import { AUTH_OTP_COOLDOWN_SECONDS } from './auth.constants';

@Injectable()
export class AuthPresenter {
  toOtpSendAccepted(traceId: string) {
    return {
      cooldownSeconds: AUTH_OTP_COOLDOWN_SECONDS,
      traceId
    };
  }

  toSessionEstablished(input: {
    accessToken: string;
    refreshToken: string;
    expiresInSeconds: number;
    shellBootstrapState: 'authenticated' | 'no_organization';
  }) {
    return {
      accessToken: input.accessToken,
      refreshToken: input.refreshToken,
      expiresInSeconds: input.expiresInSeconds,
      shellBootstrapState: input.shellBootstrapState
    };
  }

  toSessionRefreshed(input: {
    accessToken: string;
    refreshToken: string;
    expiresInSeconds: number;
  }) {
    return {
      accessToken: input.accessToken,
      refreshToken: input.refreshToken,
      expiresInSeconds: input.expiresInSeconds
    };
  }

  toWhitelistTestSessionEstablished(input: {
    sessionId: string;
    accessToken: string;
    refreshToken: string;
    expiresInSeconds: number;
    organizationId: string;
    roleKey: string;
    certificationStatus: string;
    authMode: 'whitelist_test';
  }) {
    return {
      sessionId: input.sessionId,
      accessToken: input.accessToken,
      refreshToken: input.refreshToken,
      expiresInSeconds: input.expiresInSeconds,
      organizationId: input.organizationId,
      roleKey: input.roleKey,
      certificationStatus: input.certificationStatus,
      authMode: input.authMode
    };
  }

  toActionAck(traceId: string) {
    return {
      ok: true,
      traceId
    };
  }
}
