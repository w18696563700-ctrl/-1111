import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';

export function messageInteractionInvalid(message = 'Current message interaction request is invalid.') {
  return new BadRequestException({
    code: 'MESSAGE_INTERACTION_INVALID',
    message,
  });
}

export function messageInteractionUnavailable(
  message = 'Current message interaction is unavailable.',
) {
  return new NotFoundException({
    code: 'MESSAGE_INTERACTION_UNAVAILABLE',
    message,
  });
}

export function messageInteractionForbidden(
  message = 'Current actor cannot access message interactions.',
) {
  return new ForbiddenException({
    code: 'MESSAGE_INTERACTION_FORBIDDEN',
    message,
  });
}
