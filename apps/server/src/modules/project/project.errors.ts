import { BadRequestException, NotFoundException } from '@nestjs/common';

export function projectCreateInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_CREATE_INVALID',
    message
  });
}

export function projectUnavailable(message = 'Current project is unavailable.') {
  return new NotFoundException({
    code: 'AUTH_RESOURCE_UNAVAILABLE',
    message
  });
}
