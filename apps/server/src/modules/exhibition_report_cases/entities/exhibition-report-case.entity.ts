import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'exhibition_report_cases' })
@Index('idx_exhibition_report_cases_status_created', ['status', 'createdAt'])
@Index('idx_exhibition_report_cases_target_created', ['targetType', 'targetId', 'createdAt'])
export class ExhibitionReportCaseEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'target_type', type: 'varchar', length: 32 })
  targetType!: string;

  @Column({ name: 'target_id', type: 'varchar', length: 64 })
  targetId!: string;

  @Column({ name: 'reason_code', type: 'varchar', length: 64 })
  reasonCode!: string;

  @Column({ name: 'reason_detail', type: 'text', nullable: true })
  reasonDetail!: string | null;

  @Column({ name: 'reporter_user_id', type: 'varchar', length: 64 })
  reporterUserId!: string;

  @Column({ name: 'reporter_organization_id', type: 'varchar', length: 64, nullable: true })
  reporterOrganizationId!: string | null;

  @Column({ type: 'varchar', length: 32, default: 'submitted' })
  status!: string;

  @Column({
    name: 'temporary_restriction_state',
    type: 'varchar',
    length: 32,
    default: 'not_applied'
  })
  temporaryRestrictionState!: string;

  @Column({ name: 'review_task_id', type: 'varchar', length: 64, nullable: true })
  reviewTaskId!: string | null;

  @Column({ name: 'governance_ticket_ref', type: 'varchar', length: 64, nullable: true })
  governanceTicketRef!: string | null;

  @Column({ name: 'evidence_file_asset_ids', type: 'jsonb', default: () => "'[]'" })
  evidenceFileAssetIds!: string[];

  @Column({ name: 'explanation_requested_at', type: 'timestamptz', nullable: true })
  explanationRequestedAt!: Date | null;

  @Column({ name: 'explanation_due_at', type: 'timestamptz', nullable: true })
  explanationDueAt!: Date | null;

  @Column({ name: 'explanation_received_at', type: 'timestamptz', nullable: true })
  explanationReceivedAt!: Date | null;

  @Column({ name: 'adjudication_result', type: 'varchar', length: 32, nullable: true })
  adjudicationResult!: string | null;

  @Column({ name: 'decision_note', type: 'text', nullable: true })
  decisionNote!: string | null;

  @Column({ name: 'decided_at', type: 'timestamptz', nullable: true })
  decidedAt!: Date | null;

  @Column({ name: 'closed_at', type: 'timestamptz', nullable: true })
  closedAt!: Date | null;

  @Column({ type: 'jsonb', default: () => "'{}'" })
  metadata!: Record<string, unknown>;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
