import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';
import { InquiryDepositStatus, P0PayPaymentChannel } from '../p0-pay.types';

@Entity({ name: 'inquiry_quote_deposits' })
@Index('idx_inquiry_quote_deposits_task', ['taskId'])
@Index('idx_inquiry_quote_deposits_payment_order', ['paymentOrderId'])
export class InquiryQuoteDepositEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'task_id', type: 'varchar', length: 64 })
  taskId!: string;

  @Column({ name: 'publisher_organization_id', type: 'varchar', length: 64 })
  publisherOrganizationId!: string;

  @Column({ type: 'numeric', precision: 12, scale: 2, default: 200 })
  amount!: string | number;

  @Column({ type: 'varchar', length: 8, default: 'CNY' })
  currency!: string;

  @Column({ name: 'payment_channel', type: 'varchar', length: 32, nullable: true })
  paymentChannel!: P0PayPaymentChannel | null;

  @Column({ name: 'payment_order_id', type: 'varchar', length: 64, nullable: true })
  paymentOrderId!: string | null;

  @Column({ type: 'varchar', length: 32 })
  status!: InquiryDepositStatus;

  @Column({ name: 'rule_version', type: 'varchar', length: 64, default: '' })
  ruleVersion!: string;

  @Column({ name: 'rule_snapshot_hash', type: 'varchar', length: 128, default: '' })
  ruleSnapshotHash!: string;

  @Column({ name: 'paid_at', type: 'timestamptz', nullable: true })
  paidAt!: Date | null;

  @Column({ name: 'refund_requested_at', type: 'timestamptz', nullable: true })
  refundRequestedAt!: Date | null;

  @Column({ name: 'refunded_at', type: 'timestamptz', nullable: true })
  refundedAt!: Date | null;

  @Column({ name: 'deducted_at', type: 'timestamptz', nullable: true })
  deductedAt!: Date | null;

  @Column({ name: 'deduction_reason', type: 'text', default: '' })
  deductionReason!: string;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
