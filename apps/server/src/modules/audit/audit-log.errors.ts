import { BadRequestException, NotFoundException } from '@nestjs/common';

export function auditLogQueryInvalid(message: string) {
  return new BadRequestException({
    code: 'AUDIT_LOG_QUERY_INVALID',
    message
  });
}

export function auditLogResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'AUDIT_LOG_RESOURCE_UNAVAILABLE',
    message
  });
}
