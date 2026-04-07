import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'audit_logs' })
export class IdentityAuditLogEntity {
  @PrimaryColumn({ type: 'uuid' })
  id!: string;

  @Column({ name: 'object_type', type: 'varchar', length: 64 })
  objectType!: string;

  @Column({ name: 'object_id', type: 'varchar', length: 64 })
  objectId!: string;

  @Column({ name: 'object_no', type: 'varchar', length: 128, default: '' })
  objectNo!: string;

  @Column({ type: 'varchar', length: 64 })
  action!: string;

  @Column({ name: 'actor_id', type: 'varchar', length: 64, nullable: true })
  actorId!: string | null;

  @Column({ name: 'actor_role', type: 'varchar', length: 64, default: '' })
  actorRole!: string;

  @Column({ name: 'before_state', type: 'varchar', length: 64, default: '' })
  beforeState!: string;

  @Column({ name: 'after_state', type: 'varchar', length: 64, default: '' })
  afterState!: string;

  @Column({ type: 'text', default: '' })
  reason!: string;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'occurred_at', type: 'timestamptz' })
  occurredAt!: Date;
}
