import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException
} from '@nestjs/common';

export function p0PayInvalid(message: string) {
  return new BadRequestException({
    code: 'P0_PAY_INVALID',
    message
  });
}

export function p0PayResourceUnavailable(message = 'Current P0-Pay resource is unavailable.') {
  return new NotFoundException({
    code: 'P0_PAY_RESOURCE_UNAVAILABLE',
    message
  });
}

export function p0PayPermissionDenied(message = 'Current actor cannot operate this P0-Pay resource.') {
  return new ForbiddenException({
    code: 'P0_PAY_PERMISSION_DENIED',
    message
  });
}

export function p0PayStateConflict(message = 'Current P0-Pay resource is not in a valid state.') {
  return new ConflictException({
    code: 'P0_PAY_STATE_CONFLICT',
    message
  });
}

export function p0PayIdempotencyConflict(
  message = 'Current idempotency key has already been used for another P0-Pay request.'
) {
  return new ConflictException({
    code: 'P0_PAY_IDEMPOTENCY_CONFLICT',
    message
  });
}
