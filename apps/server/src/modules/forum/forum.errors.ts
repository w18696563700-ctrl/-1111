import { BadRequestException, ConflictException, NotFoundException, ServiceUnavailableException } from '@nestjs/common';

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


export function forumReportUnavailable(message: string) {
  return new NotFoundException({
    code: 'FORUM_REPORT_UNAVAILABLE',
    message
  });
}

export function forumPostUnavailable(message: string) {
  return new NotFoundException({
    code: 'FORUM_POST_UNAVAILABLE',
    message
  });
}

export function forumAuthorUnavailable(message: string) {
  return new NotFoundException({
    code: 'FORUM_AUTHOR_UNAVAILABLE',
    message
  });
}

export function forumCommentInvalid(message: string) {
  return new BadRequestException({
    code: 'FORUM_COMMENT_INVALID',
    message
  });
}

export function forumCommentInvalidState(message: string) {
  return new ConflictException({
    code: 'FORUM_COMMENT_INVALID_STATE',
    message
  });
}

export function forumInteractionUnavailable(message: string) {
  return new ServiceUnavailableException({
    code: 'FORUM_INTERACTION_UNAVAILABLE',
    message
  });
}
