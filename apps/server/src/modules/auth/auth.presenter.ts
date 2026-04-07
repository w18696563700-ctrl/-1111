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

  toActionAck(traceId: string) {
    return {
      ok: true,
      traceId
    };
  }
}
