import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';

export function membershipOrderCreateRejected(message: string) {
  return new BadRequestException({
    code: 'MEMBERSHIP_ORDER_CREATE_REJECTED',
    message
  });
}

export function membershipOrderStateConflict(message: string) {
  return new ConflictException({
    code: 'MEMBERSHIP_ORDER_CREATE_REJECTED',
    message
  });
}

export function membershipOrderNotFound(message = 'Membership order is unavailable.') {
  return new NotFoundException({
    code: 'MEMBERSHIP_ORDER_NOT_FOUND',
    message
  });
}

export function membershipPayInitRejected(message: string) {
  return new BadRequestException({
    code: 'MEMBERSHIP_PAY_INIT_REJECTED',
    message
  });
}
