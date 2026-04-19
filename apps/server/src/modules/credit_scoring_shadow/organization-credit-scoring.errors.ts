import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';

export function shadowResultUnavailable(message: string) {
  return new NotFoundException({
    code: 'SHADOW_RESULT_UNAVAILABLE',
    message,
  });
}

export function sampleInsufficient(message: string) {
  return new BadRequestException({
    code: 'SAMPLE_INSUFFICIENT',
    message,
  });
}

export function futureCreditFamilyUnavailable(message: string) {
  return new ServiceUnavailableException({
    code: 'FUTURE_CREDIT_FAMILY_UNAVAILABLE',
    message,
  });
}

export function futureReserveDependencyUnavailable(message: string) {
  return new ServiceUnavailableException({
    code: 'FUTURE_RESERVE_DEPENDENCY_UNAVAILABLE',
    message,
  });
}

export function futureVisibilityOrAuthorizationUnavailable(message: string) {
  return new ForbiddenException({
    code: 'FUTURE_VISIBILITY_OR_AUTHORIZATION_UNAVAILABLE',
    message,
  });
}
