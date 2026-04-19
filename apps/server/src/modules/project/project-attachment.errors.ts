import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';

export function projectAttachmentInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_ATTACHMENT_INVALID',
    message
  });
}

export function projectAttachmentDuplicate(message: string) {
  return new ConflictException({
    code: 'PROJECT_ATTACHMENT_DUPLICATE',
    message
  });
}

export function projectAttachmentUnavailable(message = 'Current project attachment is unavailable.') {
  return new NotFoundException({
    code: 'AUTH_RESOURCE_UNAVAILABLE',
    message
  });
}
