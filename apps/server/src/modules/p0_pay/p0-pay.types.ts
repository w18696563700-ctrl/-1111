export type P0PayPaymentChannel = 'alipay' | 'wechat' | 'other';

export type P0PayPaymentOrderRole = 'payment' | 'authorization' | 'refund' | 'release';

export type P0PayPaymentOrderStatus =
  | 'created'
  | 'pending_user_confirm'
  | 'succeeded'
  | 'failed'
  | 'cancelled'
  | 'closed'
  | 'release_pending'
  | 'released'
  | 'refund_pending'
  | 'refunded'
  | 'expired';

export type P0PayBusinessType =
  | 'project_authenticity_sincerity_payment'
  | 'project_authenticity_sincerity_refund'
  | 'bid_service_fee_authorization_freeze'
  | 'bid_service_fee_authorization_release'
  | 'platform_service_fee_authorization'
  | 'platform_service_fee_charge'
  | 'inquiry_deposit';

export type PlatformServiceFeeAuthorizationStatus =
  | 'pending_freeze'
  | 'frozen'
  | 'release_pending'
  | 'released'
  | 'charge_pending'
  | 'pending_authorization'
  | 'authorized'
  | 'authorization_released'
  | 'pending_contract_confirm'
  | 'charged'
  | 'refund_pending'
  | 'refunded'
  | 'breach_hold'
  | 'cancelled'
  | 'failed'
  | 'expired';

export type InquiryDepositStatus =
  | 'pending_payment'
  | 'paid'
  | 'refund_pending'
  | 'refunded'
  | 'withheld'
  | 'deducted'
  | 'dispute_hold'
  | 'cancelled'
  | 'failed'
  | 'expired';

export type ContractConfirmationStatus =
  | 'pending_counterparty_confirm'
  | 'confirmed_deal'
  | 'failed'
  | 'pending_counterparty'
  | 'confirmed'
  | 'cancelled';

export type PlatformServiceFeeChargeStatus =
  | 'charge_pending'
  | 'pending_charge'
  | 'charged'
  | 'charge_failed'
  | 'refund_pending'
  | 'refunded'
  | 'cancelled';

export type P0PayFeeRateSource =
  | 'fixed_default'
  | 'paid_membership_tier'
  | 'legacy_fixed_default'
  | 'unknown';

export type P0PayMembershipTierSnapshot =
  | 'none'
  | 'free_certified'
  | 'standard'
  | 'professional'
  | 'ka'
  | 'flagship'
  | 'unknown';

export type P0PayCallbackVerificationStatus =
  | 'received'
  | 'verified'
  | 'rejected'
  | 'duplicate';

export type P0PayCallbackApplyStatus =
  | 'not_applied'
  | 'applied'
  | 'duplicate'
  | 'ignored_out_of_order'
  | 'apply_failed';

export type PlatformPricingObjectType =
  | 'project_authenticity_sincerity_order'
  | 'bid_service_fee_authorization'
  | 'deal_confirmation'
  | 'platform_service_fee_charge'
  | 'payment_order'
  | 'payment_callback_event'
  | 'project';

export type PlatformPricingAuditAction =
  | 'project_authenticity_sincerity_order_created'
  | 'project_authenticity_sincerity_pay_init_issued'
  | 'project_authenticity_sincerity_paid'
  | 'project_authenticity_sincerity_refund_requested'
  | 'project_authenticity_sincerity_refunded'
  | 'project_authenticity_sincerity_withheld'
  | 'bid_service_fee_authorization_created'
  | 'bid_service_fee_authorization_freeze_init_issued'
  | 'bid_service_fee_authorization_frozen'
  | 'bid_service_fee_authorization_release_requested'
  | 'bid_service_fee_authorization_released'
  | 'bid_submit_blocked_by_pricing_gate'
  | 'deal_confirmation_submitted'
  | 'deal_confirmation_confirmed'
  | 'platform_service_fee_charge_created'
  | 'platform_service_fee_charged'
  | 'payment_callback_received'
  | 'payment_callback_verified'
  | 'payment_callback_rejected';

export function normalizeProjectAuthenticitySincerityStatus(status: InquiryDepositStatus) {
  if (status === 'deducted' || status === 'dispute_hold') {
    return 'withheld';
  }
  return status;
}

export function normalizeBidServiceFeeAuthorizationStatus(status: PlatformServiceFeeAuthorizationStatus) {
  if (status === 'pending_authorization') {
    return 'pending_freeze';
  }
  if (status === 'authorized') {
    return 'frozen';
  }
  if (status === 'authorization_released' || status === 'refund_pending' || status === 'refunded') {
    return 'released';
  }
  if (status === 'pending_contract_confirm') {
    return 'charge_pending';
  }
  if (status === 'expired') {
    return 'failed';
  }
  return status;
}

export function normalizeDealConfirmationStatus(status: ContractConfirmationStatus) {
  if (status === 'pending_counterparty') {
    return 'pending_counterparty_confirm';
  }
  if (status === 'confirmed') {
    return 'confirmed_deal';
  }
  return status;
}
