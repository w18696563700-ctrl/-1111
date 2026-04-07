import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'profile_safety_submissions' })
export class ProfileSafetySubmissionEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64 })
  userId!: string;

  @Column({ name: 'field_key', type: 'varchar', length: 32 })
  fieldKey!: string;

  @Column({ type: 'varchar', length: 32 })
  status!: string;

  @Column({ name: 'current_value', type: 'text', nullable: true })
  currentValue!: string | null;

  @Column({ name: 'proposed_value', type: 'text', nullable: true })
  proposedValue!: string | null;

  @Column({ name: 'proposed_file_asset_id', type: 'varchar', length: 64, nullable: true })
  proposedFileAssetId!: string | null;

  @Column({ name: 'proposed_avatar_url', type: 'text', nullable: true })
  proposedAvatarUrl!: string | null;

  @Column({ name: 'engine_type', type: 'varchar', length: 16 })
  engineType!: string;

  @Column({ name: 'rule_decision', type: 'varchar', length: 32 })
  ruleDecision!: string;

  @Column({ name: 'matched_rule_ids', type: 'jsonb', default: () => "'[]'" })
  matchedRuleIds!: string[];

  @Column({ name: 'reject_reason_code', type: 'varchar', length: 64, nullable: true })
  rejectReasonCode!: string | null;

  @Column({ name: 'reject_reason', type: 'text', nullable: true })
  rejectReason!: string | null;

  @Column({ name: 'submitted_by', type: 'varchar', length: 64 })
  submittedBy!: string;

  @Column({ name: 'reviewed_by', type: 'varchar', length: 64, nullable: true })
  reviewedBy!: string | null;

  @Column({ name: 'reviewed_at', type: 'timestamptz', nullable: true })
  reviewedAt!: Date | null;

  @Column({ name: 'resubmitted_from_id', type: 'varchar', length: 64, nullable: true })
  resubmittedFromId!: string | null;

  @Column({ name: 'metadata', type: 'jsonb', default: () => "'{}'" })
  metadata!: Record<string, unknown>;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
