import { NotFoundException } from '@nestjs/common';

export function creditConstraintStatusUnavailable(message: string) {
  return new NotFoundException({
    code: 'CREDIT_CONSTRAINT_STATUS_UNAVAILABLE',
    message
  });
}

export function depositPostureUnavailable(message: string) {
  return new NotFoundException({
    code: 'DEPOSIT_POSTURE_UNAVAILABLE',
    message
  });
}

export function transactionGuaranteePostureUnavailable(message: string) {
  return new NotFoundException({
    code: 'TRANSACTION_GUARANTEE_POSTURE_UNAVAILABLE',
    message
  });
}

export function dependencyReferenceUnavailable(message: string) {
  return new NotFoundException({
    code: 'DEPENDENCY_REFERENCE_UNAVAILABLE',
    message
  });
}
