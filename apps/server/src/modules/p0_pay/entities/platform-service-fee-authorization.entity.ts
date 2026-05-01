import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';
import {
  P0PayFeeRateSource,
  P0PayMembershipTierSnapshot,
  P0PayPaymentChannel,
  PlatformServiceFeeAuthorizationStatus
} from '../p0-pay.types';

@Entity({ name: 'platform_service_fee_authorizations' })
@Index('idx_platform_service_fee_auth_task_bid', ['taskId', 'bidId'])
@Index('idx_platform_service_fee_auth_payment_order', ['paymentOrderId'])
export class PlatformServiceFeeAuthorizationEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'task_id', type: 'varchar', length: 64 })
  taskId!: string;

  @Column({ name: 'bid_id', type: 'varchar', length: 64 })
  bidId!: string;

  @Column({ name: 'bid_participation_request_id', type: 'varchar', length: 64, nullable: true })
  bidParticipationRequestId!: string | null;

  @Column({ name: 'factory_organization_id', type: 'varchar', length: 64 })
  factoryOrganizationId!: string;

  @Column({ name: 'bidder_organization_id', type: 'varchar', length: 64, nullable: true })
  bidderOrganizationId!: string | null;

  @Column({ name: 'publisher_organization_id', type: 'varchar', length: 64 })
  publisherOrganizationId!: string;

  @Column({ name: 'quoted_amount', type: 'numeric', precision: 12, scale: 2 })
  quotedAmount!: string | number;

  @Column({ name: 'fee_rate', type: 'numeric', precision: 8, scale: 6 })
  feeRate!: string | number;

  @Column({ name: 'estimated_fee_amount', type: 'numeric', precision: 12, scale: 2 })
  estimatedFeeAmount!: string | number;

  @Column({ name: 'base_fee_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  baseFeeAmount!: string | number | null;

  @Column({ name: 'membership_discount_rate', type: 'numeric', precision: 8, scale: 4, nullable: true })
  membershipDiscountRate!: string | number | null;

  @Column({ name: 'cap_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  capAmount!: string | number | null;

  @Column({ name: 'authorization_quota_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  authorizationQuotaAmount!: string | number | null;

  @Column({ name: 'charged_amount_used', type: 'numeric', precision: 12, scale: 2, default: 0 })
  chargedAmountUsed!: string | number;

  @Column({ name: 'released_amount', type: 'numeric', precision: 12, scale: 2, default: 0 })
  releasedAmount!: string | number;

  @Column({ name: 'fee_rate_label', type: 'varchar', length: 64, default: '基础平台定价规则' })
  feeRateLabel!: string;

  @Column({ name: 'fee_rate_source', type: 'varchar', length: 32, default: 'legacy_fixed_default' })
  feeRateSource!: P0PayFeeRateSource;

  @Column({ name: 'membership_tier_snapshot', type: 'varchar', length: 32, default: 'none' })
  membershipTierSnapshot!: P0PayMembershipTierSnapshot;

  @Column({ name: 'fee_rate_rule_version', type: 'varchar', length: 64, default: '' })
  feeRateRuleVersion!: string;

  @Column({ name: 'fee_rate_snapshot_hash', type: 'varchar', length: 128, default: '' })
  feeRateSnapshotHash!: string;

  @Column({ name: 'fee_calculated_at', type: 'timestamptz', nullable: true })
  feeCalculatedAt!: Date | null;

  @Column({ name: 'final_confirmed_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  finalConfirmedAmount!: string | number | null;

  @Column({ name: 'final_fee_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  finalFeeAmount!: string | number | null;

  @Column({ name: 'payment_channel', type: 'varchar', length: 32, nullable: true })
  paymentChannel!: P0PayPaymentChannel | null;

  @Column({ name: 'payment_order_id', type: 'varchar', length: 64, nullable: true })
  paymentOrderId!: string | null;

  @Column({ name: 'authorization_order_id', type: 'varchar', length: 96, nullable: true })
  authorizationOrderId!: string | null;

  @Column({ type: 'varchar', length: 32 })
  status!: PlatformServiceFeeAuthorizationStatus;

  @Column({ name: 'rule_version', type: 'varchar', length: 64 })
  ruleVersion!: string;

  @Column({ name: 'rule_snapshot_hash', type: 'varchar', length: 128 })
  ruleSnapshotHash!: string;

  @Column({ name: 'agreement_text_snapshot', type: 'text', default: '' })
  agreementTextSnapshot!: string;

  @Column({ name: 'agreed_at', type: 'timestamptz' })
  agreedAt!: Date;

  @Column({ name: 'authorized_at', type: 'timestamptz', nullable: true })
  authorizedAt!: Date | null;

  @Column({ name: 'frozen_at', type: 'timestamptz', nullable: true })
  frozenAt!: Date | null;

  @Column({ name: 'released_at', type: 'timestamptz', nullable: true })
  releasedAt!: Date | null;

  @Column({ name: 'refunded_at', type: 'timestamptz', nullable: true })
  refundedAt!: Date | null;

  @Column({ name: 'breach_hold_reason', type: 'text', default: '' })
  breachHoldReason!: string;

  @Column({ name: 'breach_held_at', type: 'timestamptz', nullable: true })
  breachHeldAt!: Date | null;

  @Column({ name: 'charged_at', type: 'timestamptz', nullable: true })
  chargedAt!: Date | null;

  @Column({ name: 'created_by_user_id', type: 'varchar', length: 64, default: '' })
  createdByUserId!: string;

  @Column({ name: 'created_by_actor_id', type: 'varchar', length: 64, default: '' })
  createdByActorId!: string;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
