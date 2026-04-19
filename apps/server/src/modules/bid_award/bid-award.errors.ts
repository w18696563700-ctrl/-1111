import {
  BadRequestException,
  ConflictException,
  InternalServerErrorException,
  NotFoundException
} from '@nestjs/common';

export function bidAwardInvalid(message: string) {
  return new BadRequestException({
    code: 'BID_AWARD_INVALID',
    message
  });
}

export function bidAwardInvalidState(message: string) {
  return new ConflictException({
    code: 'BID_AWARD_INVALID_STATE',
    message
  });
}

export function bidAwardDuplicate(message: string) {
  return new ConflictException({
    code: 'BID_AWARD_DUPLICATE',
    message
  });
}

export function bidAwardConcurrentConflict(message: string) {
  return new ConflictException({
    code: 'BID_AWARD_CONCURRENT_CONFLICT',
    message
  });
}

export function bidResultInvalid(message: string) {
  return new BadRequestException({
    code: 'BID_RESULT_INVALID',
    message
  });
}

export function bidResultUnavailable(message: string) {
  return new NotFoundException({
    code: 'BID_RESULT_UNAVAILABLE',
    message
  });
}

export function orderConversionFailed(message: string) {
  return new InternalServerErrorException({
    code: 'ORDER_CONVERSION_FAILED',
    message
  });
}

export function contractSeedFailed(message: string) {
  return new InternalServerErrorException({
    code: 'CONTRACT_SEED_FAILED',
    message
  });
}
