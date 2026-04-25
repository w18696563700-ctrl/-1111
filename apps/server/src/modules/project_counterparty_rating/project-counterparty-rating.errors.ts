import { BadRequestException, ConflictException, ForbiddenException, NotFoundException } from '@nestjs/common';

export function projectCounterpartyRatingInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_COUNTERPARTY_RATING_INVALID',
    message
  });
}

export function projectCounterpartyRatingForbidden(message: string, details?: Record<string, unknown>) {
  return new ForbiddenException({
    code: 'PROJECT_COUNTERPARTY_RATING_FORBIDDEN',
    message,
    details
  });
}

export function projectCounterpartyRatingUnavailable(message = 'Current project counterparty rating is unavailable.') {
  return new NotFoundException({
    code: 'PROJECT_COUNTERPARTY_RATING_UNAVAILABLE',
    message
  });
}

export function projectCounterpartyRatingAlreadySubmitted(message: string) {
  return new ConflictException({
    code: 'PROJECT_COUNTERPARTY_RATING_DUPLICATE',
    message
  });
}
