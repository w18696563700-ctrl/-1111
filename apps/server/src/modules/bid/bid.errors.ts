import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException
} from '@nestjs/common';

export function bidSubmitInvalid(message: string) {
  return new BadRequestException({
    code: 'BID_SUBMIT_INVALID',
    message
  });
}

export function bidResourceUnavailable(message = 'Current bid submit resource is unavailable.') {
  return new NotFoundException({
    code: 'AUTH_RESOURCE_UNAVAILABLE',
    message
  });
}

export function bidDuplicateSubmission(
  message = 'Current actor has already submitted a bid for this project.'
) {
  return new ConflictException({
    code: 'BID_DUPLICATE_SUBMISSION',
    message
  });
}

export function bidPermissionDenied(message = 'Current actor cannot update this bid.') {
  return new ForbiddenException({
    code: 'AUTH_PERMISSION_INSUFFICIENT',
    message
  });
}

export function bidSupplementConflict(
  message = 'Current bid supplement request is not writable.'
) {
  return new ConflictException({
    code: 'BID_SUBMISSION_SUPPLEMENT_CONFLICT',
    message
  });
}

export function bidSeatInvalid(message = 'Current bid seat is unavailable.') {
  return new NotFoundException({
    code: 'BID_SEAT_INVALID',
    message
  });
}

export function bidSeatInvalidState(message = 'Current bid seat is not in a valid state.') {
  return new BadRequestException({
    code: 'BID_SEAT_INVALID_STATE',
    message
  });
}

export function bidSeatConflict(message = 'Current bid seat is locked by another request.') {
  return new BadRequestException({
    code: 'BID_SEAT_CONFLICT',
    message
  });
}

export function bidSeatTimeout(message = 'Current bid seat has timed out.') {
  return new BadRequestException({
    code: 'BID_SEAT_TIMEOUT',
    message
  });
}

export function bidPackageCompletenessInvalid(
  message = 'Current bid package completeness request is invalid.'
) {
  return new BadRequestException({
    code: 'BID_PACKAGE_COMPLETENESS_INVALID',
    message
  });
}

export function bidPackageCompletenessUnavailable(
  message = 'Current bid package completeness is unavailable.'
) {
  return new NotFoundException({
    code: 'BID_PACKAGE_COMPLETENESS_UNAVAILABLE',
    message
  });
}
