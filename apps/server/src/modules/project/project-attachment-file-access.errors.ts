import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
  ServiceUnavailableException
} from '@nestjs/common';

export function fileAccessInvalid(message: string) {
  return new BadRequestException({
    code: 'FILE_ACCESS_INVALID',
    message
  });
}

export function fileAccessNotFound(message = 'Current file access target is unavailable.') {
  return new NotFoundException({
    code: 'FILE_ACCESS_NOT_FOUND',
    message
  });
}

export function fileAccessPermissionDenied(message = 'Current actor is not allowed to access this file.') {
  return new ForbiddenException({
    code: 'FILE_ACCESS_PERMISSION_DENIED',
    message
  });
}

export function fileAccessUnavailable(message = 'Current file access URL is unavailable.') {
  return new ServiceUnavailableException({
    code: 'FILE_ACCESS_UNAVAILABLE',
    message
  });
}
