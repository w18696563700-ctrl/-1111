import { BadRequestException, NotFoundException } from '@nestjs/common';
import { certificationDuplicateSubmit } from '../organization/organization-auth.errors';

export function certificationSubmitInvalid(message: string) {
  return new BadRequestException({
    code: 'CERTIFICATION_SUBMIT_INVALID',
    message
  });
}

export function certificationResubmitInvalid(message: string) {
  return new BadRequestException({
    code: 'CERTIFICATION_RESUBMIT_INVALID',
    message
  });
}

export function securityDeviceUnavailable(message: string) {
  return new NotFoundException({
    code: 'SECURITY_DEVICE_UNAVAILABLE',
    message
  });
}

export function securityDeviceRevokeInvalid(message: string) {
  return new BadRequestException({
    code: 'SECURITY_DEVICE_REVOKE_INVALID',
    message
  });
}

export function personalNicknameInvalid(message: string) {
  return new BadRequestException({
    code: 'PERSONAL_NICKNAME_INVALID',
    message
  });
}

export function personalAvatarInvalid(message: string) {
  return new BadRequestException({
    code: 'PERSONAL_AVATAR_INVALID',
    message
  });
}

export function personalAvatarFileUnavailable(message: string) {
  return new NotFoundException({
    code: 'PERSONAL_AVATAR_FILE_UNAVAILABLE',
    message
  });
}

export function profileSafetySubmissionInvalid(message: string) {
  return new BadRequestException({
    code: 'PROFILE_SAFETY_SUBMISSION_INVALID',
    message
  });
}

export function profileSafetySubmissionUnavailable(message: string) {
  return new NotFoundException({
    code: 'PROFILE_SAFETY_SUBMISSION_UNAVAILABLE',
    message
  });
}

export function profileSafetyReviewStateInvalid(message: string) {
  return new BadRequestException({
    code: 'PROFILE_SAFETY_REVIEW_STATE_INVALID',
    message
  });
}

export function organizationMemberUnavailable(message: string) {
  return new NotFoundException({
    code: 'ORG_MEMBER_UNAVAILABLE',
    message
  });
}

export function organizationMemberInvalid(message: string) {
  return new BadRequestException({
    code: 'ORG_MEMBER_INVALID',
    message
  });
}

export { certificationDuplicateSubmit };
