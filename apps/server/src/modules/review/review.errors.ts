import {
  BadRequestException,
  ConflictException,
  NotFoundException
} from '@nestjs/common';

export function organizationReviewResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'ORG_REVIEW_RESOURCE_UNAVAILABLE',
    message
  });
}

export function organizationReviewApproveInvalid(message: string) {
  return new BadRequestException({
    code: 'ORG_REVIEW_APPROVE_INVALID',
    message
  });
}

export function organizationReviewRejectInvalid(message: string) {
  return new BadRequestException({
    code: 'ORG_REVIEW_REJECT_INVALID',
    message
  });
}

export function organizationReviewInvalidState(message: string) {
  return new ConflictException({
    code: 'ORG_REVIEW_INVALID_STATE',
    message
  });
}

export function contentSafetyReviewTaskInvalid(message: string) {
  return new BadRequestException({
    code: 'CONTENT_SAFETY_REVIEW_TASK_INVALID',
    message
  });
}

export function contentSafetyReviewTaskUnavailable(message: string) {
  return new NotFoundException({
    code: 'CONTENT_SAFETY_REVIEW_TASK_UNAVAILABLE',
    message
  });
}

export function contentSafetyReviewTaskInvalidState(message: string) {
  return new ConflictException({
    code: 'CONTENT_SAFETY_REVIEW_TASK_INVALID_STATE',
    message
  });
}
