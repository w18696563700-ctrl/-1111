import { BadRequestException, ForbiddenException, ServiceUnavailableException } from '@nestjs/common';

export function notificationInvalid(message: string, details?: Record<string, unknown>) {
  return new BadRequestException({
    code: 'NOTIFICATION_READ_INVALID',
    message,
    ...(details ? { details } : {})
  });
}

export function notificationForbidden(message: string) {
  return new ForbiddenException({ code: 'NOTIFICATION_FORBIDDEN', message });
}

export function notificationMarkReadTargetUnavailable(message: string, details?: Record<string, unknown>) {
  return new BadRequestException({
    code: 'NOTIFICATION_MARK_READ_TARGET_UNAVAILABLE',
    message,
    ...(details ? { details } : {})
  });
}

export function notificationUnavailable(message = 'Current notification center is unavailable.') {
  return new ServiceUnavailableException({ code: 'NOTIFICATION_UNAVAILABLE', message });
}

export function pushTokenInvalid(message: string) {
  return new BadRequestException({ code: 'PUSH_TOKEN_INVALID', message });
}
