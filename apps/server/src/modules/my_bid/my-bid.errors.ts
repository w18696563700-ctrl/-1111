import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';

export function myBidsInvalid(message = 'Current my bids request is invalid.') {
  return new BadRequestException({
    code: 'MY_BIDS_INVALID',
    message,
  });
}

export function myBidsUnavailable(message = 'Current my bids list is unavailable.') {
  return new NotFoundException({
    code: 'MY_BIDS_UNAVAILABLE',
    message,
  });
}

export function myBidsForbidden(message = 'Current actor cannot access my bids.') {
  return new ForbiddenException({
    code: 'MY_BIDS_FORBIDDEN',
    message,
  });
}
