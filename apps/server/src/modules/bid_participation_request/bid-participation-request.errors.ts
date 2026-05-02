import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';

export function bidParticipationInvalid(message = 'Current bid participation request is invalid.') {
  return new BadRequestException({
    code: 'BID_PARTICIPATION_INVALID',
    message,
  });
}

export function bidParticipationUnavailable(
  message = 'Current bid participation resource is unavailable.',
) {
  return new NotFoundException({
    code: 'BID_PARTICIPATION_UNAVAILABLE',
    message,
  });
}

export function bidParticipationForbidden(
  message = 'Current actor cannot access this bid participation resource.',
) {
  return new ForbiddenException({
    code: 'BID_PARTICIPATION_FORBIDDEN',
    message,
  });
}

export function bidParticipationRequired(
  message = 'Current actor must be approved before participating in this bid.',
) {
  return new ForbiddenException({
    code: 'BID_PARTICIPATION_REQUIRED',
    message,
  });
}

export function bidParticipationConflict(
  message = 'Current bid participation request conflicts with existing truth.',
) {
  return new ConflictException({
    code: 'BID_PARTICIPATION_CONFLICT',
    message,
  });
}

export function bidParticipationInvalidState(
  message = 'Current bid participation request is not in a valid state for this action.',
) {
  return new ConflictException({
    code: 'BID_PARTICIPATION_INVALID_STATE',
    message,
  });
}
