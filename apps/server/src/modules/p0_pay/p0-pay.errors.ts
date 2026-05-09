import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException
} from '@nestjs/common';

type PricingErrorCode =
  | 'PROJECT_AUTHENTICITY_SINCERITY_REQUIRED'
  | 'PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_POLICY_UNAVAILABLE'
  | 'PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_INVALID'
  | 'PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_REJECTED'
  | 'PROJECT_AUTHENTICITY_SINCERITY_ORDER_CREATE_REJECTED'
  | 'PROJECT_AUTHENTICITY_SINCERITY_ORDER_NOT_FOUND'
  | 'PROJECT_AUTHENTICITY_SINCERITY_PAY_INIT_REJECTED'
  | 'PROJECT_AUTHENTICITY_SINCERITY_INVALID_STATE'
  | 'BID_SERVICE_FEE_AUTHORIZATION_REQUIRED'
  | 'BID_SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED'
  | 'BID_SERVICE_FEE_AUTHORIZATION_NOT_FOUND'
  | 'BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED'
  | 'BID_SERVICE_FEE_AUTHORIZATION_RELEASE_REJECTED'
  | 'BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE'
  | 'DEAL_CONFIRMATION_INVALID'
  | 'DEAL_CONFIRMATION_INVALID_STATE'
  | 'DEAL_CONFIRMATION_COUNTERPARTY_PENDING'
  | 'PRICING_RULE_VERSION_MISMATCH';

export function p0PayInvalid(message: string) {
  return new BadRequestException({
    code: 'P0_PAY_INVALID',
    message
  });
}

export function p0PayResourceUnavailable(message = 'Current P0-Pay resource is unavailable.') {
  return new NotFoundException({
    code: 'P0_PAY_RESOURCE_UNAVAILABLE',
    message
  });
}

export function p0PayPermissionDenied(message = 'Current actor cannot operate this P0-Pay resource.') {
  return new ForbiddenException({
    code: 'P0_PAY_PERMISSION_DENIED',
    message
  });
}

export function p0PayStateConflict(message = 'Current P0-Pay resource is not in a valid state.') {
  return new ConflictException({
    code: 'P0_PAY_STATE_CONFLICT',
    message
  });
}

export function p0PayIdempotencyConflict(
  message = 'Current idempotency key has already been used for another P0-Pay request.'
) {
  return new ConflictException({
    code: 'P0_PAY_IDEMPOTENCY_CONFLICT',
    message
  });
}

export function pricingInvalid(code: PricingErrorCode, message: string) {
  return new BadRequestException({ code, message });
}

export function pricingNotFound(code: PricingErrorCode, message: string) {
  return new NotFoundException({ code, message });
}

export function pricingStateConflict(code: PricingErrorCode, message: string) {
  return new ConflictException({ code, message });
}

export function projectAuthenticitySincerityRequired(
  message = 'Project authenticity sincerity payment is required before publishing.'
) {
  return pricingStateConflict('PROJECT_AUTHENTICITY_SINCERITY_REQUIRED', message);
}

export function projectAuthenticitySincerityInternalTestPolicyUnavailable(
  message = 'Project authenticity sincerity green-channel conditions are not satisfied.'
) {
  return pricingStateConflict('PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_POLICY_UNAVAILABLE', message);
}

export function projectAuthenticitySincerityFreezeFeedbackInvalid(
  message = 'Project authenticity sincerity freeze feedback choice is invalid.'
) {
  return pricingInvalid('PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_INVALID', message);
}

export function projectAuthenticitySincerityFreezeFeedbackRejected(
  message = 'Project authenticity sincerity freeze feedback cannot be submitted.'
) {
  return pricingStateConflict('PROJECT_AUTHENTICITY_SINCERITY_FREEZE_FEEDBACK_REJECTED', message);
}

export function projectAuthenticitySincerityOrderCreateRejected(
  message = 'Project authenticity sincerity order cannot be created.'
) {
  return pricingStateConflict('PROJECT_AUTHENTICITY_SINCERITY_ORDER_CREATE_REJECTED', message);
}

export function projectAuthenticitySincerityOrderNotFound(
  message = 'Project authenticity sincerity order is unavailable.'
) {
  return pricingNotFound('PROJECT_AUTHENTICITY_SINCERITY_ORDER_NOT_FOUND', message);
}

export function projectAuthenticitySincerityPayInitRejected(
  message = 'Project authenticity sincerity payment cannot be initialized.'
) {
  return pricingStateConflict('PROJECT_AUTHENTICITY_SINCERITY_PAY_INIT_REJECTED', message);
}

export function projectAuthenticitySincerityInvalidState(
  message = 'Project authenticity sincerity order is not in a valid state.'
) {
  return pricingStateConflict('PROJECT_AUTHENTICITY_SINCERITY_INVALID_STATE', message);
}

export function bidServiceFeeAuthorizationRequired(
  message = 'Bid service fee authorization freeze is required before project communication free-send opens.'
) {
  return pricingStateConflict('BID_SERVICE_FEE_AUTHORIZATION_REQUIRED', message);
}

export function bidServiceFeeAuthorizationCreateRejected(
  message = 'Bid service fee authorization cannot be created.'
) {
  return pricingStateConflict('BID_SERVICE_FEE_AUTHORIZATION_CREATE_REJECTED', message);
}

export function bidServiceFeeAuthorizationNotFound(
  message = 'Bid service fee authorization is unavailable.'
) {
  return pricingNotFound('BID_SERVICE_FEE_AUTHORIZATION_NOT_FOUND', message);
}

export function bidServiceFeeAuthorizationFreezeInitRejected(
  message = 'Bid service fee authorization freeze cannot be initialized.'
) {
  return pricingStateConflict('BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED', message);
}

export function bidServiceFeeAuthorizationReleaseRejected(
  message = 'Bid service fee authorization cannot be released.'
) {
  return pricingStateConflict('BID_SERVICE_FEE_AUTHORIZATION_RELEASE_REJECTED', message);
}

export function bidServiceFeeAuthorizationInvalidState(
  message = 'Bid service fee authorization is not in a valid state.'
) {
  return pricingStateConflict('BID_SERVICE_FEE_AUTHORIZATION_INVALID_STATE', message);
}

export function dealConfirmationInvalid(message = 'Deal confirmation request is invalid.') {
  return pricingInvalid('DEAL_CONFIRMATION_INVALID', message);
}

export function dealConfirmationInvalidState(message = 'Deal confirmation is not in a valid state.') {
  return pricingStateConflict('DEAL_CONFIRMATION_INVALID_STATE', message);
}

export function dealConfirmationCounterpartyPending(message = 'Deal confirmation is pending counterparty confirmation.') {
  return pricingStateConflict('DEAL_CONFIRMATION_COUNTERPARTY_PENDING', message);
}

export function pricingRuleVersionMismatch(message = 'Pricing rule version does not match current Server truth.') {
  return pricingInvalid('PRICING_RULE_VERSION_MISMATCH', message);
}
