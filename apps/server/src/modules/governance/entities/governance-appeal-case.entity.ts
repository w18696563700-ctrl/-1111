import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'governance_appeal_cases' })
@Index('idx_governance_appeal_cases_penalty_submitted', ['penaltyId', 'submittedAt'])
@Index('idx_governance_appeal_cases_status_submitted', ['status', 'submittedAt'])
export class GovernanceAppealCaseEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'penalty_id', type: 'varchar', length: 64 })
  penaltyId!: string;

  @Column({ type: 'varchar', length: 32 })
  status!: string;

  @Column({ type: 'text' })
  reason!: string;

  @Column({ type: 'varchar', length: 32, nullable: true })
  decision!: string | null;

  @Column({ name: 'decision_note', type: 'text', nullable: true })
  decisionNote!: string | null;

  @Column({ name: 'evidence_file_asset_ids', type: 'jsonb', default: () => "'[]'" })
  evidenceFileAssetIds!: string[];

  @Column({ name: 'submitted_by', type: 'varchar', length: 64 })
  submittedBy!: string;

  @Column({ name: 'submitted_at', type: 'timestamptz' })
  submittedAt!: Date;

  @Column({ name: 'decided_by', type: 'varchar', length: 64, nullable: true })
  decidedBy!: string | null;

  @Column({ name: 'decided_at', type: 'timestamptz', nullable: true })
  decidedAt!: Date | null;

  @Column({ type: 'jsonb', default: () => "'{}'" })
  metadata!: Record<string, unknown>;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
