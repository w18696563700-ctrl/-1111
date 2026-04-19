import {
  BadRequestException,
  HttpException,
  ServiceUnavailableException,
  UnauthorizedException
} from '@nestjs/common';

export function authRequestInvalid(message: string) {
  return new BadRequestException({
    code: 'AUTH_REQUEST_INVALID',
    message
  });
}

export function authConsentRequired(message: string) {
  return new BadRequestException({
    code: 'AUTH_CONSENT_REQUIRED',
    message
  });
}

export function authLoginInvalid(message: string) {
  return new UnauthorizedException({
    code: 'AUTH_LOGIN_INVALID',
    message
  });
}

export function authPasswordLoginInvalid(message: string) {
  return new UnauthorizedException({
    code: 'AUTH_PASSWORD_LOGIN_INVALID',
    message
  });
}

export function authPasswordNotSet(message: string) {
  return new UnauthorizedException({
    code: 'AUTH_PASSWORD_NOT_SET',
    message
  });
}

export function authPasswordSetNotAllowed(message: string) {
  return new BadRequestException({
    code: 'AUTH_PASSWORD_SET_NOT_ALLOWED',
    message
  });
}

export function authPasswordResetOtpInvalid(message: string) {
  return new UnauthorizedException({
    code: 'AUTH_PASSWORD_RESET_OTP_INVALID',
    message
  });
}

export function authPasswordPolicyInvalid(message: string) {
  return new BadRequestException({
    code: 'AUTH_PASSWORD_POLICY_INVALID',
    message
  });
}

export function authRateLimited(message: string) {
  return new HttpException(
    {
      code: 'AUTH_RATE_LIMITED',
      message
    },
    429
  );
}

export function authOtpSendLimitReached(
  message: string,
  details?: Record<string, unknown>
) {
  return new HttpException(
    {
      code: 'AUTH_OTP_SEND_LIMIT_REACHED',
      message,
      ...(details ? { details } : {})
    },
    429
  );
}

export function authUnavailable(message: string) {
  return new ServiceUnavailableException({
    code: 'AUTH_RESOURCE_UNAVAILABLE',
    message
  });
}
