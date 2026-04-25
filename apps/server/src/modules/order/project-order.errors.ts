import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';

export function projectOrderCompleteInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_ORDER_COMPLETE_INVALID',
    message,
  });
}

export function projectOrderCompleteUnavailable(message: string) {
  return new NotFoundException({
    code: 'PROJECT_ORDER_COMPLETE_UNAVAILABLE',
    message,
  });
}

export function projectOrderCompleteInvalidState(message: string) {
  return new ConflictException({
    code: 'PROJECT_ORDER_COMPLETE_INVALID_STATE',
    message,
  });
}
