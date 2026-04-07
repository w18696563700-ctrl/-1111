import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'content_safety_audit_logs' })
export class ContentSafetyAuditLogEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'subject_type', type: 'varchar', length: 64 })
  subjectType!: string;

  @Column({ name: 'subject_id', type: 'varchar', length: 64 })
  subjectId!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64, nullable: true })
  userId!: string | null;

  @Column({ name: 'actor_id', type: 'varchar', length: 64, nullable: true })
  actorId!: string | null;

  @Column({ name: 'actor_role', type: 'varchar', length: 64, default: '' })
  actorRole!: string;

  @Column({ type: 'varchar', length: 64 })
  action!: string;

  @Column({ name: 'engine_type', type: 'varchar', length: 16 })
  engineType!: string;

  @Column({ type: 'varchar', length: 32 })
  decision!: string;

  @Column({ name: 'reason_code', type: 'varchar', length: 64, nullable: true })
  reasonCode!: string | null;

  @Column({ type: 'text', nullable: true })
  reason!: string | null;

  @Column({ name: 'matched_rule_ids', type: 'jsonb', default: () => "'[]'" })
  matchedRuleIds!: string[];

  @Column({ type: 'jsonb', default: () => "'{}'" })
  metadata!: Record<string, unknown>;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
