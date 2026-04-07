import { BadRequestException, NotFoundException } from '@nestjs/common';

export function forumDraftInvalid(message: string) {
  return new BadRequestException({
    code: 'FORUM_DRAFT_INVALID',
    message
  });
}

export function forumDraftUnavailable(message: string) {
  return new NotFoundException({
    code: 'FORUM_DRAFT_UNAVAILABLE',
    message
  });
}

export function forumPublishInvalid(message: string) {
  return new BadRequestException({
    code: 'FORUM_PUBLISH_INVALID',
    message
  });
}

export function forumPublishInvalidState(message: string) {
  return new BadRequestException({
    code: 'FORUM_PUBLISH_INVALID_STATE',
    message
  });
}

export function forumReportInvalid(message: string) {
  return new BadRequestException({
    code: 'FORUM_REPORT_INVALID',
    message
  });
}

export function forumPostUnavailable(message: string) {
  return new NotFoundException({
    code: 'FORUM_POST_UNAVAILABLE',
    message
  });
}
