import { BadRequestException, ConflictException } from '@nestjs/common';

export function ratingEntryUnavailable(message: string) {
  return new ConflictException({
    code: 'RATING_ENTRY_UNAVAILABLE',
    message,
  });
}

export function ratingSubmitInvalid(message: string) {
  return new BadRequestException({
    code: 'RATING_SUBMIT_INVALID',
    message,
  });
}

export function ratingInvalidState(message: string) {
  return new ConflictException({
    code: 'RATING_INVALID_STATE',
    message,
  });
}
