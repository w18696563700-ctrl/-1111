import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';
import {
  P0PayBusinessType,
  P0PayPaymentChannel,
  P0PayPaymentOrderRole,
  P0PayPaymentOrderStatus
} from '../p0-pay.types';

@Entity({ name: 'payment_orders' })
@Index('idx_payment_orders_business', ['businessType', 'businessId'])
@Index('idx_payment_orders_idempotency_scope', ['businessType', 'businessId', 'idempotencyKeyHash'], {
  unique: true
})
@Index('idx_payment_orders_merchant_order_no', ['merchantOrderNo'], { unique: true })
@Index('idx_payment_orders_channel_order', ['paymentChannel', 'channelOrderId'])
export class PaymentOrderEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'business_type', type: 'varchar', length: 64 })
  businessType!: P0PayBusinessType;

  @Column({ name: 'business_id', type: 'varchar', length: 64 })
  businessId!: string;

  @Column({ name: 'task_id', type: 'varchar', length: 64, default: '' })
  taskId!: string;

  @Column({ name: 'bid_id', type: 'varchar', length: 64, default: '' })
  bidId!: string;

  @Column({ name: 'payer_organization_id', type: 'varchar', length: 64 })
  payerOrganizationId!: string;

  @Column({ name: 'payee_organization_id', type: 'varchar', length: 64, default: '' })
  payeeOrganizationId!: string;

  @Column({ type: 'numeric', precision: 12, scale: 2 })
  amount!: string | number;

  @Column({ type: 'varchar', length: 8, default: 'CNY' })
  currency!: string;

  @Column({ name: 'payment_channel', type: 'varchar', length: 32 })
  paymentChannel!: P0PayPaymentChannel;

  @Column({ name: 'order_role', type: 'varchar', length: 32 })
  orderRole!: P0PayPaymentOrderRole;

  @Column({ type: 'varchar', length: 32 })
  status!: P0PayPaymentOrderStatus;

  @Column({ name: 'merchant_order_no', type: 'varchar', length: 96 })
  merchantOrderNo!: string;

  @Column({ name: 'channel_order_id', type: 'varchar', length: 128, nullable: true })
  channelOrderId!: string | null;

  @Column({ name: 'idempotency_key_hash', type: 'varchar', length: 128 })
  idempotencyKeyHash!: string;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @Column({ name: 'expires_at', type: 'timestamptz', nullable: true })
  expiresAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
