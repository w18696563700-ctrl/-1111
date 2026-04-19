import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';

export function invalidBoardType(message = 'boardType is invalid for enterprise hub.') {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_INVALID_BOARD_TYPE',
    message
  });
}

export function missingRequiredFields(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
    message
  });
}

export function invalidStateTransition(message: string) {
  return new ConflictException({
    code: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
    message
  });
}

export function invalidMediaOwnership(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_INVALID_MEDIA_OWNERSHIP',
    message,
  });
}

export function enterpriseNotFound(message = 'Enterprise hub listing is unavailable.') {
  return new NotFoundException({
    code: 'ENTERPRISE_HUB_ENTERPRISE_NOT_FOUND',
    message
  });
}

export function applicationNotFound(message = 'Enterprise hub application is unavailable.') {
  return new NotFoundException({
    code: 'ENTERPRISE_HUB_APPLICATION_NOT_FOUND',
    message
  });
}

export function profileNotCompleted(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_PROFILE_NOT_COMPLETED',
    message
  });
}

export function caseNotFound(message = 'Enterprise hub case is unavailable.') {
  return new NotFoundException({
    code: 'ENTERPRISE_HUB_CASE_NOT_FOUND',
    message
  });
}

export function certificationNotFound(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_CERTIFICATION_NOT_FOUND',
    message
  });
}

export function enterpriseNotApproved(message: string) {
  return new ConflictException({
    code: 'ENTERPRISE_HUB_ENTERPRISE_NOT_APPROVED',
    message
  });
}

export function permissionDenied(message: string) {
  return new ForbiddenException({
    code: 'ENTERPRISE_HUB_PERMISSION_DENIED',
    message
  });
}

export function duplicateRecommendationSlot(message: string) {
  return new ConflictException({
    code: 'ENTERPRISE_HUB_DUPLICATE_RECOMMENDATION_SLOT',
    message
  });
}

export function certificationRequired(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_CERTIFICATION_REQUIRED',
    message
  });
}

export function contactRequired(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_CONTACT_REQUIRED',
    message
  });
}

export function caseRequired(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_CASE_REQUIRED',
    message
  });
}

export function changeCorridorRequired(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED',
    message
  });
}

export function changeCorridorNotAvailable(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE',
    message
  });
}

export function locationResolveInvalid(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_LOCATION_RESOLVE_INVALID',
    message,
  });
}

export function locationResolveProviderUnavailable(message: string) {
  return new ServiceUnavailableException({
    code: 'ENTERPRISE_LOCATION_RESOLVE_PROVIDER_UNAVAILABLE',
    message,
  });
}

export function locationResolveFailed(message: string) {
  return new ServiceUnavailableException({
    code: 'ENTERPRISE_LOCATION_RESOLVE_FAILED',
    message,
  });
}

export function locationWriteInvalid(message: string) {
  return new BadRequestException({
    code: 'ENTERPRISE_LOCATION_WRITE_INVALID',
    message,
  });
}

export function locationProviderConfigMissing(message: string) {
  return new ServiceUnavailableException({
    code: 'ENTERPRISE_LOCATION_PROVIDER_CONFIG_MISSING',
    message,
  });
}
