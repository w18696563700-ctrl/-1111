import { BadRequestException, ForbiddenException, ServiceUnavailableException } from '@nestjs/common';

export function notificationInvalid(message: string) {
  return new BadRequestException({ code: 'NOTIFICATION_READ_INVALID', message });
}

export function notificationForbidden(message: string) {
  return new ForbiddenException({ code: 'NOTIFICATION_FORBIDDEN', message });
}

export function notificationUnavailable(message = 'Current notification center is unavailable.') {
  return new ServiceUnavailableException({ code: 'NOTIFICATION_UNAVAILABLE', message });
}

export function pushTokenInvalid(message: string) {
  return new BadRequestException({ code: 'PUSH_TOKEN_INVALID', message });
}
