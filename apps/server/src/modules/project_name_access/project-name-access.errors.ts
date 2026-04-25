import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';

export function projectNameAccessInvalid(message = 'Current project name access request is invalid.') {
  return new BadRequestException({
    code: 'PROJECT_NAME_ACCESS_INVALID',
    message,
  });
}

export function projectNameAccessUnavailable(
  message = 'Current project name access resource is unavailable.',
) {
  return new NotFoundException({
    code: 'PROJECT_NAME_ACCESS_UNAVAILABLE',
    message,
  });
}

export function projectNameAccessForbidden(
  message = 'Current actor cannot access this project name access resource.',
) {
  return new ForbiddenException({
    code: 'PROJECT_NAME_ACCESS_FORBIDDEN',
    message,
  });
}

export function projectNameAccessConflict(
  message = 'Current project name access request conflicts with existing truth.',
) {
  return new ConflictException({
    code: 'PROJECT_NAME_ACCESS_CONFLICT',
    message,
  });
}

export function projectNameAccessInvalidState(
  message = 'Current project name access request is not in a valid state for this action.',
) {
  return new ConflictException({
    code: 'PROJECT_NAME_ACCESS_INVALID_STATE',
    message,
  });
}

