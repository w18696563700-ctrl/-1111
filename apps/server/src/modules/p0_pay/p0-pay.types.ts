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
  | 'platform_service_fee_authorization'
  | 'platform_service_fee_charge'
  | 'inquiry_deposit';

export type PlatformServiceFeeAuthorizationStatus =
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
  | 'deducted'
  | 'dispute_hold'
  | 'cancelled'
  | 'failed'
  | 'expired';

export type ContractConfirmationStatus =
  | 'pending_counterparty'
  | 'confirmed'
  | 'cancelled';

export type PlatformServiceFeeChargeStatus =
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
