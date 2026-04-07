import { BadRequestException, NotFoundException } from '@nestjs/common';

export function governanceBlockInvalid(message: string) {
  return new BadRequestException({
    code: 'GOVERNANCE_BLOCK_INVALID',
    message
  });
}

export function governanceBlockTargetUnavailable(message: string) {
  return new NotFoundException({
    code: 'GOVERNANCE_BLOCK_TARGET_UNAVAILABLE',
    message
  });
}
