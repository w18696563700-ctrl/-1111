import { BadRequestException, HttpException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';

type OtpSendResponse = {
  cooldownSeconds: number;
  traceId: string;
};

type SessionEstablishResponse = {
  accessToken: string;
  refreshToken: string;
  expiresInSeconds: number;
  shellBootstrapState: 'authenticated' | 'no_organization';
};

type SessionRefreshResponse = {
  accessToken: string;
  refreshToken: string;
  expiresInSeconds: number;
};

type ActionAckResponse = {
  ok: boolean;
  traceId: string;
};

@Injectable()
export class AuthService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async sendOtp(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/auth/otp/send',
        this.buildOtpSendPayload(payload, headers),
        {
          headers: this.authContext.buildAuthTransportHeaders(headers),
        },
      );
      return this.toOtpSendResponse(result);
    } catch (error) {
      throw this.normalizeSendError(error);
    }
  }

  async loginWithOtp(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/auth/otp/login',
        this.buildOtpLoginPayload(payload, headers),
        {
          headers: this.authContext.buildAuthTransportHeaders(headers),
        },
      );
      return this.toSessionEstablishResponse(result);
    } catch (error) {
      throw this.normalizeLoginError(error);
    }
  }

  async loginWithPassword(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/auth/password/login',
        this.buildPasswordLoginPayload(payload, headers),
        {
          headers: this.authContext.buildAuthTransportHeaders(headers),
        },
      );
      return this.toSessionEstablishResponse(result);
    } catch (error) {
      throw this.normalizePasswordLoginError(error);
    }
  }

  async setPassword(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/auth/password/set',
        this.buildPasswordSetPayload(payload),
        {
          headers: this.authContext.buildReadOnlyForwardHeaders(headers),
        },
      );
      return this.toActionAckResponse(result);
    } catch (error) {
      throw this.normalizePasswordSetError(error);
    }
  }

  async resetPassword(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/auth/password/reset',
        this.buildPasswordResetPayload(payload),
        {
          headers: this.authContext.buildAuthTransportHeaders(headers),
        },
      );
      return this.toActionAckResponse(result);
    } catch (error) {
      throw this.normalizePasswordResetError(error);
    }
  }

  async refreshSession(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/auth/refresh',
        this.requireRequestBody(payload),
        {
          headers: this.authContext.buildAuthTransportHeaders(headers),
        },
      );
      return this.toSessionRefreshResponse(result);
    } catch (error) {
      throw this.normalizeRefreshError(error);
    }
  }

  async logout(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/auth/logout',
        this.requireOptionalRequestBody(payload),
        {
          headers: this.authContext.buildAuthTransportHeaders(headers),
        },
      );
      return this.toActionAckResponse(result);
    } catch (error) {
      throw this.normalizeLogoutError(error);
    }
  }

  private normalizeSendError(error: unknown) {
    return this.normalizeAuthError(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前验证码发送能力暂不可用，请稍后再试。',
      {
        400: 'AUTH_REQUEST_INVALID',
        429: 'AUTH_RATE_LIMITED',
        503: 'AUTH_RESOURCE_UNAVAILABLE',
      },
      {
        AUTH_REQUEST_INVALID: '当前验证码发送请求无效，请检查后重试。',
        AUTH_RATE_LIMITED: '验证码发送过于频繁，请稍后再试。',
        AUTH_OTP_SEND_LIMIT_REACHED: '当前手机号今日验证码次数已达上限，请明日再试或更换其他手机号。',
        AUTH_RESOURCE_UNAVAILABLE: '当前验证码发送能力暂不可用，请稍后再试。',
      },
    );
  }

  private normalizeLoginError(error: unknown) {
    return this.normalizeAuthError(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前登录能力暂不可用，请稍后再试。',
      {
        400: 'AUTH_REQUEST_INVALID',
        401: 'AUTH_LOGIN_INVALID',
        429: 'AUTH_RATE_LIMITED',
        503: 'AUTH_RESOURCE_UNAVAILABLE',
      },
      {
        AUTH_CONSENT_REQUIRED: '请先阅读并同意《用户协议》《隐私政策》。',
        AUTH_REQUEST_INVALID: '当前登录请求无效，请检查后重试。',
        AUTH_LOGIN_INVALID: '当前验证码错误或已失效，请重试。',
        AUTH_RATE_LIMITED: '当前登录请求过于频繁，请稍后再试。',
        AUTH_RESOURCE_UNAVAILABLE: '当前登录能力暂不可用，请稍后再试。',
      },
    );
  }

  private normalizePasswordLoginError(error: unknown) {
    return this.normalizeAuthError(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前登录能力暂不可用，请稍后再试。',
      {
        400: 'AUTH_REQUEST_INVALID',
        401: 'AUTH_PASSWORD_LOGIN_INVALID',
        429: 'AUTH_RATE_LIMITED',
        503: 'AUTH_RESOURCE_UNAVAILABLE',
      },
      {
        AUTH_CONSENT_REQUIRED: '请先阅读并同意《用户协议》《隐私政策》。',
        AUTH_PASSWORD_LOGIN_INVALID: '手机号或密码错误，请检查后重试。',
        AUTH_PASSWORD_NOT_SET: '手机号或密码错误，请检查后重试。',
        AUTH_REQUEST_INVALID: '当前登录请求无效，请检查后重试。',
        AUTH_RATE_LIMITED: '当前登录请求过于频繁，请稍后再试。',
        AUTH_RESOURCE_UNAVAILABLE: '当前登录能力暂不可用，请稍后再试。',
      },
    );
  }

  private normalizePasswordSetError(error: unknown) {
    return this.normalizeAuthError(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前设置密码能力暂不可用，请稍后再试。',
      {
        400: 'AUTH_REQUEST_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        503: 'AUTH_RESOURCE_UNAVAILABLE',
      },
      {
        AUTH_PASSWORD_SET_NOT_ALLOWED: '当前场景不允许设置密码。',
        AUTH_PASSWORD_POLICY_INVALID: '密码不符合要求，请检查后重试。',
        AUTH_REQUEST_INVALID: '当前设置密码请求无效，请检查后重试。',
        AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录后再试。',
        AUTH_PERMISSION_INSUFFICIENT: '当前无权限执行密码设置。',
        AUTH_RESOURCE_UNAVAILABLE: '当前设置密码能力暂不可用，请稍后再试。',
      },
    );
  }

  private normalizePasswordResetError(error: unknown) {
    return this.normalizeAuthError(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前重置密码能力暂不可用，请稍后再试。',
      {
        400: 'AUTH_REQUEST_INVALID',
        401: 'AUTH_PASSWORD_RESET_OTP_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        503: 'AUTH_RESOURCE_UNAVAILABLE',
      },
      {
        AUTH_PASSWORD_RESET_OTP_INVALID: '验证码无效或已过期，请重新获取后重试。',
        AUTH_PASSWORD_POLICY_INVALID: '密码不符合要求，请检查后重试。',
        AUTH_REQUEST_INVALID: '当前重置密码请求无效，请检查后重试。',
        AUTH_PERMISSION_INSUFFICIENT: '当前无权限执行密码重置。',
        AUTH_RESOURCE_UNAVAILABLE: '当前重置密码能力暂不可用，请稍后再试。',
      },
    );
  }

  private normalizeRefreshError(error: unknown) {
    return this.normalizeAuthError(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前登录刷新能力暂不可用，请稍后再试。',
      {
        400: 'AUTH_REQUEST_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        503: 'AUTH_RESOURCE_UNAVAILABLE',
      },
      {
        AUTH_REQUEST_INVALID: '当前刷新请求无效，请检查后重试。',
        AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录或刷新后再试。',
        AUTH_PERMISSION_INSUFFICIENT: '当前无权限执行登录刷新操作。',
        AUTH_RESOURCE_UNAVAILABLE: '当前登录刷新能力暂不可用，请稍后再试。',
      },
    );
  }

  private normalizeLogoutError(error: unknown) {
    return this.normalizeAuthError(
      error,
      'AUTH_RESOURCE_UNAVAILABLE',
      '当前退出能力暂不可用，请稍后再试。',
      {
        400: 'AUTH_REQUEST_INVALID',
        401: 'AUTH_SESSION_INVALID',
        403: 'AUTH_PERMISSION_INSUFFICIENT',
        503: 'AUTH_RESOURCE_UNAVAILABLE',
      },
      {
        AUTH_REQUEST_INVALID: '当前退出请求无效，请检查后重试。',
        AUTH_SESSION_INVALID: '当前登录态不可用，请重新登录或刷新后再试。',
        AUTH_PERMISSION_INSUFFICIENT: '当前无权限执行退出操作。',
        AUTH_RESOURCE_UNAVAILABLE: '当前退出能力暂不可用，请稍后再试。',
      },
    );
  }

  private normalizeAuthError(
    error: unknown,
    fallbackCode: string,
    fallbackMessage: string,
    statusCodeMap: Partial<Record<number, string>>,
    messageByCode: Record<string, string>,
  ) {
    const normalized = this.errors.toHttpException(
      error,
      fallbackCode,
      fallbackMessage,
      statusCodeMap,
    );
    const payload = this.asOptionalRecord(normalized.getResponse()) ?? {};
    const code =
      this.asString(payload.code) || statusCodeMap[normalized.getStatus()] || fallbackCode;
    const message = messageByCode[code] ?? fallbackMessage;

    return new HttpException(
      {
        ...payload,
        statusCode: normalized.getStatus(),
        code,
        message,
        source: payload.source === 'server' ? 'server' : 'bff',
      },
      normalized.getStatus(),
    );
  }

  private toOtpSendResponse(result: Record<string, unknown>): OtpSendResponse {
    const cooldownSeconds = this.asNonNegativeInteger(result.cooldownSeconds);
    const traceId = this.asString(result.traceId);
    if (cooldownSeconds === undefined || !traceId) {
      throw new Error('Auth OTP send response is missing required fields.');
    }

    return {
      cooldownSeconds,
      traceId,
    };
  }

  private toSessionEstablishResponse(
    result: Record<string, unknown>,
  ): SessionEstablishResponse {
    const accessToken = this.asString(result.accessToken);
    const refreshToken = this.asString(result.refreshToken);
    const expiresInSeconds = this.asPositiveInteger(result.expiresInSeconds);
    const shellBootstrapState = this.asShellBootstrapState(
      result.shellBootstrapState,
    );
    if (
      !accessToken ||
      !refreshToken ||
      expiresInSeconds === undefined ||
      !shellBootstrapState
    ) {
      throw new Error('Auth login response is missing required fields.');
    }

    return {
      accessToken,
      refreshToken,
      expiresInSeconds,
      shellBootstrapState,
    };
  }

  private toSessionRefreshResponse(
    result: Record<string, unknown>,
  ): SessionRefreshResponse {
    const accessToken = this.asString(result.accessToken);
    const refreshToken = this.asString(result.refreshToken);
    const expiresInSeconds = this.asPositiveInteger(result.expiresInSeconds);
    if (!accessToken || !refreshToken || expiresInSeconds === undefined) {
      throw new Error('Auth refresh response is missing required fields.');
    }

    return {
      accessToken,
      refreshToken,
      expiresInSeconds,
    };
  }

  private toActionAckResponse(result: Record<string, unknown>): ActionAckResponse {
    const traceId = this.asString(result.traceId);
    if (result.ok !== true && result.ok !== false) {
      throw new Error('Auth logout response is missing ok.');
    }
    if (!traceId) {
      throw new Error('Auth logout response is missing traceId.');
    }

    return {
      ok: result.ok,
      traceId,
    };
  }

  private requireRequestBody(
    value: Record<string, unknown> | undefined,
  ): Record<string, unknown> {
    return this.requireRecord(value, '当前请求体无效，请检查后重试。');
  }

  private requireOptionalRequestBody(
    value: Record<string, unknown> | undefined,
  ): Record<string, unknown> {
    if (value === undefined) {
      return {};
    }
    return this.requireRecord(value, '当前请求体无效，请检查后重试。');
  }

  private buildOtpLoginPayload(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ): Record<string, unknown> {
    const result = { ...this.requireRequestBody(payload) };
    const deviceId =
      this.asString(result.deviceId) || this.readHeader(headers, 'x-device-id');

    if (deviceId) {
      result.deviceId = deviceId;
    }

    return result;
  }

  private buildOtpSendPayload(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ): Record<string, unknown> {
    const result = { ...this.requireRequestBody(payload) };
    const deviceId =
      this.asString(result.deviceId) || this.readHeader(headers, 'x-device-id');

    if (deviceId) {
      result.deviceId = deviceId;
    }

    return result;
  }

  private buildPasswordLoginPayload(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ): Record<string, unknown> {
    const source = this.requireRequestBody(payload);
    const result: Record<string, unknown> = {};
    const mobile = this.asString(source.mobile);
    const password = this.asString(source.password);
    const deviceName = this.asString(source.deviceName);
    const osType = this.asString(source.osType);
    const deviceId = this.asString(source.deviceId) || this.readHeader(headers, 'x-device-id');

    if (mobile) {
      result.mobile = mobile;
    }
    if (password) {
      result.password = password;
    }
    if (source.consentAccepted !== undefined) {
      result.consentAccepted = source.consentAccepted;
    }
    if (deviceName) {
      result.deviceName = deviceName;
    }
    if (osType) {
      result.osType = osType;
    }
    if (deviceId) {
      result.deviceId = deviceId;
    }

    return result;
  }

  private buildPasswordSetPayload(
    payload: Record<string, unknown> | undefined,
  ): Record<string, unknown> {
    const source = this.requireRequestBody(payload);
    const newPassword = this.asString(source.newPassword);
    if (!newPassword) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'AUTH_REQUEST_INVALID',
        message: '当前设置密码请求无效，请检查后重试。',
        source: 'bff',
      });
    }

    return { newPassword };
  }

  private buildPasswordResetPayload(
    payload: Record<string, unknown> | undefined,
  ): Record<string, unknown> {
    const source = this.requireRequestBody(payload);
    const mobile = this.asString(source.mobile);
    const otpCode = this.asString(source.otpCode);
    const newPassword = this.asString(source.newPassword);
    if (!mobile || !otpCode || !newPassword) {
      throw new BadRequestException({
        statusCode: 400,
        code: 'AUTH_REQUEST_INVALID',
        message: '当前重置密码请求无效，请检查后重试。',
        source: 'bff',
      });
    }

    return { mobile, otpCode, newPassword };
  }

  private requireRecord(
    value: unknown,
    message: string,
  ): Record<string, unknown> {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'AUTH_REQUEST_INVALID',
      message,
      source: 'bff',
    });
  }

  private asOptionalRecord(value: unknown): Record<string, unknown> | null {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    return null;
  }

  private asString(value: unknown) {
    if (typeof value !== 'string') {
      return '';
    }
    const normalized = value.trim();
    return normalized.length > 0 ? normalized : '';
  }

  private readHeader(
    headers: IncomingHttpHeaders,
    ...keys: string[]
  ): string | undefined {
    for (const key of keys) {
      const value = headers[key];
      if (Array.isArray(value)) {
        if (value[0]) {
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

  private asPositiveInteger(value: unknown) {
    const normalized =
      typeof value === 'number'
        ? value
        : typeof value === 'string' && value.trim().length > 0
          ? Number(value)
          : NaN;
    return Number.isInteger(normalized) && normalized > 0
      ? normalized
      : undefined;
  }

  private asNonNegativeInteger(value: unknown) {
    const normalized =
      typeof value === 'number'
        ? value
        : typeof value === 'string' && value.trim().length > 0
          ? Number(value)
          : NaN;
    return Number.isInteger(normalized) && normalized >= 0
      ? normalized
      : undefined;
  }

  private asShellBootstrapState(
    value: unknown,
  ): SessionEstablishResponse['shellBootstrapState'] | undefined {
    return value === 'authenticated' || value === 'no_organization'
      ? value
      : undefined;
  }
}
