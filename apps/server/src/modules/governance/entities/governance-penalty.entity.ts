import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'governance_penalties' })
@Index('idx_governance_penalties_subject_status_created', [
  'subjectType',
  'subjectId',
  'status',
  'createdAt'
])
@Index('idx_governance_penalties_created', ['createdAt'])
export class GovernancePenaltyEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'subject_type', type: 'varchar', length: 32 })
  subjectType!: string;

  @Column({ name: 'subject_id', type: 'varchar', length: 64 })
  subjectId!: string;

  @Column({ name: 'penalty_type', type: 'varchar', length: 32 })
  penaltyType!: string;

  @Column({ type: 'varchar', length: 32 })
  status!: string;

  @Column({ name: 'reason_code', type: 'varchar', length: 64 })
  reasonCode!: string;

  @Column({ name: 'reason_summary', type: 'text', nullable: true })
  reasonSummary!: string | null;

  @Column({ name: 'evidence_file_asset_ids', type: 'jsonb', default: () => "'[]'" })
  evidenceFileAssetIds!: string[];

  @Column({ name: 'effective_from', type: 'timestamptz' })
  effectiveFrom!: Date;

  @Column({ name: 'effective_until', type: 'timestamptz', nullable: true })
  effectiveUntil!: Date | null;

  @Column({ name: 'created_by', type: 'varchar', length: 64 })
  createdBy!: string;

  @Column({ name: 'operator_actor_id', type: 'varchar', length: 64 })
  operatorActorId!: string;

  @Column({ name: 'operator_user_id', type: 'varchar', length: 64 })
  operatorUserId!: string;

  @Column({ name: 'operator_role', type: 'varchar', length: 64, default: '' })
  operatorRole!: string;

  @Column({ type: 'jsonb', default: () => "'{}'" })
  metadata!: Record<string, unknown>;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
