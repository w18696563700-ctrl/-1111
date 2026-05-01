import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

export type MembershipOrderStatus =
  | 'created'
  | 'pending_pay'
  | 'paying'
  | 'paid'
  | 'granting'
  | 'active'
  | 'closed'
  | 'failed';

export type MembershipPaymentStatus =
  | 'not_started'
  | 'pending'
  | 'succeeded'
  | 'failed'
  | 'closed'
  | 'unknown';

export type MembershipEntitlementStatus =
  | 'not_granted'
  | 'granting'
  | 'active'
  | 'grant_failed'
  | 'expired';

@Entity({ name: 'membership_orders' })
@Index('idx_membership_orders_org_updated', ['organizationId', 'updatedAt'])
@Index('idx_membership_orders_status_updated', ['orderStatus', 'updatedAt'])
@Index('idx_membership_orders_payment_order', ['paymentOrderId'])
@Index('idx_membership_orders_paid_membership', ['paidMembershipId'])
export class MembershipOrderEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'created_by_user_id', type: 'varchar', length: 64 })
  createdByUserId!: string;

  @Column({ name: 'sku_code', type: 'varchar', length: 64 })
  skuCode!: string;

  @Column({ name: 'sku_name', type: 'varchar', length: 128 })
  skuName!: string;

  @Column({ name: 'membership_tier', type: 'varchar', length: 32 })
  membershipTier!: string;

  @Column({ name: 'duration_months', type: 'integer' })
  durationMonths!: number;

  @Column({ name: 'payable_amount', type: 'numeric', precision: 12, scale: 2 })
  payableAmount!: string | number;

  @Column({ type: 'varchar', length: 8, default: 'CNY' })
  currency!: string;

  @Column({ name: 'order_status', type: 'varchar', length: 32 })
  orderStatus!: MembershipOrderStatus;

  @Column({ name: 'payment_status', type: 'varchar', length: 32 })
  paymentStatus!: MembershipPaymentStatus;

  @Column({ name: 'entitlement_status', type: 'varchar', length: 32 })
  entitlementStatus!: MembershipEntitlementStatus;

  @Column({ name: 'payment_order_id', type: 'varchar', length: 64, nullable: true })
  paymentOrderId!: string | null;

  @Column({ name: 'paid_membership_id', type: 'varchar', length: 64, nullable: true })
  paidMembershipId!: string | null;

  @Column({ name: 'order_expires_at', type: 'timestamptz', nullable: true })
  orderExpiresAt!: Date | null;

  @Column({ name: 'effective_at', type: 'timestamptz', nullable: true })
  effectiveAt!: Date | null;

  @Column({ name: 'expires_at', type: 'timestamptz', nullable: true })
  expiresAt!: Date | null;

  @Column({ name: 'failure_reason_code', type: 'varchar', length: 96, default: '' })
  failureReasonCode!: string;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
