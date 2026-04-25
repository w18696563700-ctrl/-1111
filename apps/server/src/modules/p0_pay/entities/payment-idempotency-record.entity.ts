import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'payment_idempotency_records' })
@Index(
  'idx_payment_idempotency_records_scope_key',
  ['operationKey', 'scopeKey', 'idempotencyKeyHash'],
  { unique: true }
)
export class PaymentIdempotencyRecordEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'operation_key', type: 'varchar', length: 96 })
  operationKey!: string;

  @Column({ name: 'scope_key', type: 'varchar', length: 256 })
  scopeKey!: string;

  @Column({ name: 'idempotency_key_hash', type: 'varchar', length: 128 })
  idempotencyKeyHash!: string;

  @Column({ name: 'request_hash', type: 'varchar', length: 128 })
  requestHash!: string;

  @Column({ name: 'resource_type', type: 'varchar', length: 64 })
  resourceType!: string;

  @Column({ name: 'resource_id', type: 'varchar', length: 64 })
  resourceId!: string;

  @Column({ type: 'varchar', length: 32 })
  status!: 'succeeded' | 'failed';

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
