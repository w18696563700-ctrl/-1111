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

export function authLoginInvalid(message: string) {
  return new UnauthorizedException({
    code: 'AUTH_LOGIN_INVALID',
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

export function authUnavailable(message: string) {
  return new ServiceUnavailableException({
    code: 'AUTH_RESOURCE_UNAVAILABLE',
    message
  });
}
