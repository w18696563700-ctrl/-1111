import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
  UnauthorizedException
} from '@nestjs/common';

export function authSessionInvalid(message: string) {
  return new UnauthorizedException({
    code: 'AUTH_SESSION_INVALID',
    message
  });
}

export function authPermissionInsufficient(message: string) {
  return new ForbiddenException({
    code: 'AUTH_PERMISSION_INSUFFICIENT',
    message
  });
}

export function authResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'AUTH_RESOURCE_UNAVAILABLE',
    message
  });
}

export function certificationDuplicateSubmit(message: string) {
  return new ConflictException({
    code: 'CERTIFICATION_DUPLICATE_SUBMIT',
    message
  });
}

export function orgCreateInvalid(message: string) {
  return new BadRequestException({
    code: 'ORG_CREATE_INVALID',
    message
  });
}

export function orgJoinInvalid(message: string) {
  return new BadRequestException({
    code: 'ORG_JOIN_INVALID',
    message
  });
}

export function orgJoinDuplicate(message: string) {
  return new ConflictException({
    code: 'ORG_JOIN_DUPLICATE',
    message
  });
}

export function orgSwitchInvalid(message: string) {
  return new BadRequestException({
    code: 'ORG_SWITCH_INVALID',
    message
  });
}
