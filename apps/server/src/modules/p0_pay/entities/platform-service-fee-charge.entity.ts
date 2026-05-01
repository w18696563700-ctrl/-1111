import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';
import {
  P0PayFeeRateSource,
  P0PayMembershipTierSnapshot,
  PlatformServiceFeeChargeStatus
} from '../p0-pay.types';

@Entity({ name: 'platform_service_fee_charges' })
@Index('idx_platform_service_fee_charges_contract', ['contractConfirmationId'])
@Index('idx_platform_service_fee_charges_payment_order', ['paymentOrderId'])
export class PlatformServiceFeeChargeEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'task_id', type: 'varchar', length: 64 })
  taskId!: string;

  @Column({ name: 'contract_confirmation_id', type: 'varchar', length: 64 })
  contractConfirmationId!: string;

  @Column({ name: 'authorization_id', type: 'varchar', length: 64 })
  authorizationId!: string;

  @Column({ name: 'factory_organization_id', type: 'varchar', length: 64 })
  factoryOrganizationId!: string;

  @Column({ name: 'final_confirmed_amount', type: 'numeric', precision: 12, scale: 2 })
  finalConfirmedAmount!: string | number;

  @Column({ name: 'fee_rate', type: 'numeric', precision: 8, scale: 6 })
  feeRate!: string | number;

  @Column({ name: 'base_fee_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  baseFeeAmount!: string | number | null;

  @Column({ name: 'membership_discount_rate', type: 'numeric', precision: 8, scale: 4, nullable: true })
  membershipDiscountRate!: string | number | null;

  @Column({ name: 'cap_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  capAmount!: string | number | null;

  @Column({ name: 'final_fee_amount', type: 'numeric', precision: 12, scale: 2 })
  finalFeeAmount!: string | number;

  @Column({ name: 'released_remainder_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  releasedRemainderAmount!: string | number | null;

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

  @Column({ name: 'payment_order_id', type: 'varchar', length: 64, nullable: true })
  paymentOrderId!: string | null;

  @Column({ name: 'charge_status', type: 'varchar', length: 32 })
  chargeStatus!: PlatformServiceFeeChargeStatus;

  @Column({ name: 'charged_at', type: 'timestamptz', nullable: true })
  chargedAt!: Date | null;

  @Column({ name: 'refunded_at', type: 'timestamptz', nullable: true })
  refundedAt!: Date | null;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
