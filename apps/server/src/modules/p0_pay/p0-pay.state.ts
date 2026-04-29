export const PLATFORM_PRICING_RULE_VERSION = 'platform_pricing_rules_master_v1';

export const PLATFORM_PRICING_RULE_NAME =
  'project_authenticity_sincerity_and_bid_service_fee_authorization_v1';

export const P0_PAY_RULE_VERSION = PLATFORM_PRICING_RULE_VERSION;

export const P0_PAY_DEFAULT_SERVICE_FEE_RATE = 0.03;

export const PROJECT_AUTHENTICITY_SINCERITY_AMOUNT = '200.00';

export const BID_SERVICE_FEE_AUTHORIZATION_QUOTA_AMOUNT = '4000.00';

export const PLATFORM_SERVICE_FEE_CAP_AMOUNT = '4000.00';

export const P0_PAY_INQUIRY_DEPOSIT_AMOUNT = PROJECT_AUTHENTICITY_SINCERITY_AMOUNT;

export const P0_PAY_SERVICE_FEE_AGREEMENT_TEXT =
  '竞标服务费预授权额度：竞标申请审核通过后冻结 4000 元；成交成立后按平台规则扣取服务费，剩余额度原路释放。';

export const PROJECT_AUTHENTICITY_SINCERITY_RULE_TEXT =
  '项目真实性诚意金：发布项目需冻结 200 元；项目成交或按规则正式撤回后可退回，恶意发布或虚假项目可按规则处理。';

export const P0_PAY_ACCOUNT_BINDING_POLICY = {
  requiresPreBoundPaymentAccount: false,
  storesUserPaymentAccountIdentifiers: false,
  mode: 'order_level_payment_and_authorization'
} as const;

export const P0_PAY_SERVICE_FEE_AUTHORIZATION_MUTABLE_STATUSES = new Set([
  'pending_freeze',
  'frozen',
  'release_pending',
  'charge_pending',
  'pending_authorization',
  'authorized',
  'pending_contract_confirm'
]);

export const PLATFORM_PRICING_PAYMENT_BUSINESS_TYPES = {
  projectAuthenticitySincerityPayment: 'project_authenticity_sincerity_payment',
  projectAuthenticitySincerityRefund: 'project_authenticity_sincerity_refund',
  bidServiceFeeAuthorizationFreeze: 'bid_service_fee_authorization_freeze',
  bidServiceFeeAuthorizationRelease: 'bid_service_fee_authorization_release',
  platformServiceFeeCharge: 'platform_service_fee_charge'
} as const;

export const PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS = {
  projectAuthenticitySincerityOrderCreate: 'projectAuthenticitySincerityOrder.create',
  projectAuthenticitySincerityPayInit: 'projectAuthenticitySincerityOrder.payInit',
  projectAuthenticitySincerityRefund: 'projectAuthenticitySincerityOrder.refund',
  bidServiceFeeAuthorizationCreate: 'bidServiceFeeAuthorization.create',
  bidServiceFeeAuthorizationFreezeInit: 'bidServiceFeeAuthorization.freezeInit',
  bidServiceFeeAuthorizationRelease: 'bidServiceFeeAuthorization.release',
  dealConfirmationUpsert: 'dealConfirmation.upsert',
  platformServiceFeeChargeCreate: 'platformServiceFeeCharge.create'
} as const;

export const PLATFORM_PRICING_RESOURCE_TYPES = {
  projectAuthenticitySincerityOrder: 'project_authenticity_sincerity_order',
  bidServiceFeeAuthorization: 'bid_service_fee_authorization',
  dealConfirmation: 'deal_confirmation',
  platformServiceFeeCharge: 'platform_service_fee_charge',
  paymentOrder: 'payment_order',
  paymentCallbackEvent: 'payment_callback_event',
  project: 'project'
} as const;

export const PLATFORM_PRICING_AUDIT_ACTIONS = {
  projectAuthenticitySincerityOrderCreated: 'project_authenticity_sincerity_order_created',
  projectAuthenticitySincerityPayInitIssued: 'project_authenticity_sincerity_pay_init_issued',
  projectAuthenticitySincerityPaid: 'project_authenticity_sincerity_paid',
  projectAuthenticitySincerityRefundRequested: 'project_authenticity_sincerity_refund_requested',
  projectAuthenticitySincerityRefunded: 'project_authenticity_sincerity_refunded',
  projectAuthenticitySincerityWithheld: 'project_authenticity_sincerity_withheld',
  bidServiceFeeAuthorizationCreated: 'bid_service_fee_authorization_created',
  bidServiceFeeAuthorizationFreezeInitIssued: 'bid_service_fee_authorization_freeze_init_issued',
  bidServiceFeeAuthorizationFrozen: 'bid_service_fee_authorization_frozen',
  bidServiceFeeAuthorizationReleaseRequested: 'bid_service_fee_authorization_release_requested',
  bidServiceFeeAuthorizationReleased: 'bid_service_fee_authorization_released',
  bidSubmitBlockedByPricingGate: 'bid_submit_blocked_by_pricing_gate',
  dealConfirmationSubmitted: 'deal_confirmation_submitted',
  dealConfirmationConfirmed: 'deal_confirmation_confirmed',
  platformServiceFeeChargeCreated: 'platform_service_fee_charge_created',
  platformServiceFeeCharged: 'platform_service_fee_charged',
  paymentCallbackReceived: 'payment_callback_received',
  paymentCallbackVerified: 'payment_callback_verified',
  paymentCallbackRejected: 'payment_callback_rejected'
} as const;

export const P0_PAY_CALLBACK_SECRET_ENV = 'P0_PAY_CALLBACK_SECRET';
