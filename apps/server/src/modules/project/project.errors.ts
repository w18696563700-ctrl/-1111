import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';

export function projectCreateInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_CREATE_INVALID',
    message
  });
}

export function projectWithdrawInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_WITHDRAW_INVALID',
    message
  });
}

export function projectArchiveInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_ARCHIVE_INVALID',
    message
  });
}

export function projectCloseInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_CLOSE_INVALID',
    message
  });
}

export function projectWithdrawPublishedInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_WITHDRAW_PUBLISHED_INVALID',
    message
  });
}

export function projectSubmittedDiscardInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_SUBMITTED_DISCARD_INVALID',
    message
  });
}

export function projectCancellationRequestInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_CANCELLATION_REQUEST_INVALID',
    message
  });
}

export function projectCancellationResponseInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_CANCELLATION_RESPONSE_INVALID',
    message
  });
}

export function projectBreachRecordInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_BREACH_RECORD_INVALID',
    message
  });
}

export function projectUnavailable(message = 'Current project is unavailable.') {
  return new NotFoundException({
    code: 'AUTH_RESOURCE_UNAVAILABLE',
    message
  });
}

export function projectSaveInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_SAVE_INVALID',
    message
  });
}

export function projectSubmitInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_SUBMIT_INVALID',
    message
  });
}

export function projectPublishInvalid(message: string) {
  return new BadRequestException({
    code: 'PROJECT_PUBLISH_INVALID',
    message
  });
}

export function projectInvalidState(message: string) {
  return new ConflictException({
    code: 'PROJECT_INVALID_STATE',
    message
  });
}

export function projectExitInvalidState(message: string) {
  return new ConflictException({
    code: 'PROJECT_EXIT_INVALID_STATE',
    message
  });
}
