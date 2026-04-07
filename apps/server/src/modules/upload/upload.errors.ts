import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';

export function uploadInitInvalid(message: string) {
  return new BadRequestException({
    code: 'FILE_UPLOAD_INIT_INVALID',
    message
  });
}

export function uploadConfirmRequired(message: string) {
  return new BadRequestException({
    code: 'FILE_UPLOAD_CONFIRM_REQUIRED',
    message
  });
}

export function uploadSessionUnavailable(message: string) {
  return new NotFoundException({
    code: 'FILE_UPLOAD_CONFIRM_REQUIRED',
    message
  });
}

export function uploadSessionMissingFileAssetTruth(message: string) {
  return new ConflictException({
    code: 'FILE_UPLOAD_CONFIRM_REQUIRED',
    message
  });
}
