import {
  BadRequestException,
  ConflictException,
} from '@nestjs/common';

export function milestoneSubmitInvalid(message: string) {
  return new BadRequestException({
    code: 'MILESTONE_SUBMIT_INVALID',
    message,
  });
}

export function milestoneInvalidState(message: string) {
  return new ConflictException({
    code: 'MILESTONE_INVALID_STATE',
    message,
  });
}

export function inspectionSubmitInvalid(message: string) {
  return new BadRequestException({
    code: 'INSPECTION_SUBMIT_INVALID',
    message,
  });
}

export function inspectionRecheckInvalid(message: string) {
  return new BadRequestException({
    code: 'INSPECTION_RECHECK_INVALID',
    message,
  });
}

export function inspectionEntryUnavailable(message: string) {
  return new ConflictException({
    code: 'INSPECTION_ENTRY_UNAVAILABLE',
    message,
  });
}

export function inspectionInvalidState(message: string) {
  return new ConflictException({
    code: 'INSPECTION_INVALID_STATE',
    message,
  });
}

export function contractConfirmInvalid(message: string) {
  return new BadRequestException({
    code: 'CONTRACT_CONFIRM_INVALID',
    message,
  });
}

export function contractAmendInvalid(message: string) {
  return new BadRequestException({
    code: 'CONTRACT_AMEND_INVALID',
    message,
  });
}

export function contractEntryUnavailable(message: string) {
  return new ConflictException({
    code: 'CONTRACT_ENTRY_UNAVAILABLE',
    message,
  });
}

export function contractInvalidState(message: string) {
  return new ConflictException({
    code: 'CONTRACT_INVALID_STATE',
    message,
  });
}

export function disputeOpenInvalid(message: string) {
  return new BadRequestException({
    code: 'DISPUTE_OPEN_INVALID',
    message,
  });
}

export function disputeWithdrawInvalid(message: string) {
  return new BadRequestException({
    code: 'DISPUTE_WITHDRAW_INVALID',
    message,
  });
}

export function disputeInvalidState(message: string) {
  return new ConflictException({
    code: 'DISPUTE_INVALID_STATE',
    message,
  });
}
