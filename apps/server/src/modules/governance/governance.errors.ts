import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';

export function governancePenaltyResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'GOVERNANCE_PENALTY_RESOURCE_UNAVAILABLE',
    message
  });
}

export function governancePenaltyApplyInvalid(message: string) {
  return new BadRequestException({
    code: 'GOVERNANCE_PENALTY_APPLY_INVALID',
    message
  });
}

export function governanceAppealResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'GOVERNANCE_APPEAL_RESOURCE_UNAVAILABLE',
    message
  });
}

export function governanceAppealDecideInvalid(message: string) {
  return new BadRequestException({
    code: 'GOVERNANCE_APPEAL_DECIDE_INVALID',
    message
  });
}

export function governanceInvalidState(message: string) {
  return new ConflictException({
    code: 'GOVERNANCE_INVALID_STATE',
    message
  });
}

export function governanceRescanJobResourceUnavailable(message: string) {
  return new NotFoundException({
    code: 'GOVERNANCE_RESCAN_JOB_RESOURCE_UNAVAILABLE',
    message
  });
}

export function governanceRescanJobCreateInvalid(message: string) {
  return new BadRequestException({
    code: 'GOVERNANCE_RESCAN_JOB_CREATE_INVALID',
    message
  });
}
