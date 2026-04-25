import { Column, Entity, Index, PrimaryColumn } from 'typeorm';
import {
  P0PayCallbackApplyStatus,
  P0PayCallbackVerificationStatus,
  P0PayPaymentChannel
} from '../p0-pay.types';

@Entity({ name: 'payment_callback_events' })
@Index('idx_payment_callback_events_channel_event', ['paymentChannel', 'channelEventId'], {
  unique: true
})
@Index('idx_payment_callback_events_order_received', ['merchantOrderNo', 'receivedAt'])
export class PaymentCallbackEventEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'payment_channel', type: 'varchar', length: 32 })
  paymentChannel!: P0PayPaymentChannel;

  @Column({ name: 'merchant_order_no', type: 'varchar', length: 96 })
  merchantOrderNo!: string;

  @Column({ name: 'channel_event_id', type: 'varchar', length: 128 })
  channelEventId!: string;

  @Column({ name: 'provider_event_id', type: 'varchar', length: 128, default: '' })
  providerEventId!: string;

  @Column({ name: 'event_type', type: 'varchar', length: 64 })
  eventType!: string;

  @Column({ name: 'event_status', type: 'varchar', length: 64, default: '' })
  eventStatus!: string;

  @Column({ name: 'payload_snapshot', type: 'jsonb', default: () => "'{}'::jsonb" })
  payloadSnapshot!: Record<string, unknown>;

  @Column({ name: 'callback_payload_hash', type: 'varchar', length: 128, default: '' })
  callbackPayloadHash!: string;

  @Column({ name: 'verification_status', type: 'varchar', length: 32, default: 'received' })
  verificationStatus!: P0PayCallbackVerificationStatus;

  @Column({ name: 'apply_status', type: 'varchar', length: 32, default: 'not_applied' })
  applyStatus!: P0PayCallbackApplyStatus;

  @Column({ name: 'rejected_reason_code', type: 'varchar', length: 96, default: '' })
  rejectedReasonCode!: string;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @Column({ name: 'received_at', type: 'timestamptz' })
  receivedAt!: Date;

  @Column({ name: 'verified_at', type: 'timestamptz', nullable: true })
  verifiedAt!: Date | null;

  @Column({ name: 'applied_at', type: 'timestamptz', nullable: true })
  appliedAt!: Date | null;

  @Column({ name: 'processed_at', type: 'timestamptz', nullable: true })
  processedAt!: Date | null;
}
