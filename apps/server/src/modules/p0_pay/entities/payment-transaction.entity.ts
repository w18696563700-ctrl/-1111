import { Column, CreateDateColumn, Entity, Index, PrimaryColumn } from 'typeorm';
import { P0PayPaymentChannel } from '../p0-pay.types';

@Entity({ name: 'payment_transactions' })
@Index('idx_payment_transactions_order_created', ['paymentOrderId', 'createdAt'])
@Index('idx_payment_transactions_channel_transaction', ['paymentChannel', 'channelTransactionId'], {
  unique: true
})
export class PaymentTransactionEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'payment_order_id', type: 'varchar', length: 64 })
  paymentOrderId!: string;

  @Column({ name: 'transaction_type', type: 'varchar', length: 32 })
  transactionType!: 'authorization' | 'payment' | 'refund' | 'release' | 'callback';

  @Column({ name: 'payment_channel', type: 'varchar', length: 32 })
  paymentChannel!: P0PayPaymentChannel;

  @Column({ name: 'channel_transaction_id', type: 'varchar', length: 128, nullable: true })
  channelTransactionId!: string | null;

  @Column({ type: 'numeric', precision: 12, scale: 2 })
  amount!: string | number;

  @Column({ name: 'requested_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  requestedAmount!: string | number | null;

  @Column({ name: 'confirmed_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  confirmedAmount!: string | number | null;

  @Column({ type: 'varchar', length: 32 })
  status!: 'pending' | 'succeeded' | 'failed' | 'cancelled';

  @Column({ name: 'channel_action_type', type: 'varchar', length: 32, default: 'unavailable' })
  channelActionType!: 'sdk_payload' | 'web_redirect' | 'qr_code' | 'unavailable' | 'server_capture';

  @Column({ name: 'channel_reference', type: 'varchar', length: 128, default: '' })
  channelReference!: string;

  @Column({ name: 'raw_status', type: 'varchar', length: 128, default: '' })
  rawStatus!: string;

  @Column({ name: 'initiated_at', type: 'timestamptz', nullable: true })
  initiatedAt!: Date | null;

  @Column({ name: 'confirmed_at', type: 'timestamptz', nullable: true })
  confirmedAt!: Date | null;

  @Column({ name: 'failed_at', type: 'timestamptz', nullable: true })
  failedAt!: Date | null;

  @Column({ name: 'failure_reason_code', type: 'varchar', length: 96, default: '' })
  failureReasonCode!: string;

  @Column({ name: 'occurred_at', type: 'timestamptz', nullable: true })
  occurredAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
