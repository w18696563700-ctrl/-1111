import { NotFoundException } from '@nestjs/common';

export function paymentStatusUnavailable(message: string) {
  return new NotFoundException({
    code: 'PAYMENT_STATUS_UNAVAILABLE',
    message
  });
}

export function billingReferenceUnavailable(message: string) {
  return new NotFoundException({
    code: 'BILLING_REFERENCE_UNAVAILABLE',
    message
  });
}

export function paymentHandoffUnavailable(message: string) {
  return new NotFoundException({
    code: 'PAYMENT_HANDOFF_UNAVAILABLE',
    message
  });
}

export function dependencyReferenceUnavailable(message: string) {
  return new NotFoundException({
    code: 'DEPENDENCY_REFERENCE_UNAVAILABLE',
    message
  });
}
