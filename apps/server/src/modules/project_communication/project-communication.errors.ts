import { BadRequestException, ConflictException, ForbiddenException, NotFoundException } from '@nestjs/common';

export function projectCommunicationInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_COMMUNICATION_INVALID',
    message
  });
}

export function projectCommunicationForbidden(message: string, details?: Record<string, unknown>) {
  return new ForbiddenException({
    code: 'PROJECT_COMMUNICATION_FORBIDDEN',
    message,
    details
  });
}

export function projectCommunicationUnavailable(message = 'Current project communication truth is unavailable.') {
  return new NotFoundException({
    code: 'PROJECT_COMMUNICATION_UNAVAILABLE',
    message
  });
}

export function projectCommunicationWorkbenchInvalid(code: string, message: string) {
  return new BadRequestException({ code, message });
}

export function projectCommunicationWorkbenchForbidden(
  code: string,
  message: string,
  details?: Record<string, unknown>
) {
  return new ForbiddenException({ code, message, details });
}

export function projectCommunicationWorkbenchConflict(code: string, message: string) {
  return new ConflictException({ code, message });
}

export function projectAlbumInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_ALBUM_INVALID',
    message
  });
}

export function projectAlbumForbidden(message: string, details?: Record<string, unknown>) {
  return new ForbiddenException({
    code: 'PROJECT_ALBUM_FORBIDDEN',
    message,
    details
  });
}

export function projectAlbumLimitExceeded(message: string) {
  return new ConflictException({
    code: 'PROJECT_ALBUM_LIMIT_EXCEEDED',
    message
  });
}

export function projectAlbumUnavailable(message = 'Current project album truth is unavailable.') {
  return new NotFoundException({
    code: 'PROJECT_ALBUM_UNAVAILABLE',
    message
  });
}
