import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'governance_rescan_jobs' })
@Index('idx_governance_rescan_jobs_scope_status_created', [
  'scopeType',
  'status',
  'createdAt'
])
@Index('idx_governance_rescan_jobs_created', ['createdAt'])
export class GovernanceRescanJobEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'scope_type', type: 'varchar', length: 32, default: '' })
  scopeType!: string;

  @Column({ type: 'varchar', length: 32, default: 'queued' })
  status!: string;

  @Column({ name: 'window_start', type: 'timestamptz' })
  windowStart!: Date;

  @Column({ name: 'window_end', type: 'timestamptz' })
  windowEnd!: Date;

  @Column({ name: 'candidate_count', type: 'integer', default: 0 })
  candidateCount!: number;

  @Column({ name: 'flagged_count', type: 'integer', default: 0 })
  flaggedCount!: number;

  @Column({ type: 'text' })
  reason!: string;

  @Column({ name: 'rule_set_version', type: 'varchar', length: 64, default: '' })
  ruleSetVersion!: string;

  @Column({ name: 'engine_mode', type: 'varchar', length: 64, default: '' })
  engineMode!: string;

  @Column({ name: 'created_by', type: 'varchar', length: 64, default: '' })
  createdBy!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @Column({ name: 'completed_at', type: 'timestamptz', nullable: true })
  completedAt!: Date | null;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
