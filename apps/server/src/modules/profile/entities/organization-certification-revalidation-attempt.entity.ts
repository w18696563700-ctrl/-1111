import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'organization_certification_revalidation_attempt' })
export class OrganizationCertificationRevalidationAttemptEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'certification_id', type: 'varchar', length: 64, nullable: true })
  certificationId!: string | null;

  @Column({ name: 'triggered_by_user_id', type: 'varchar', length: 64 })
  triggeredByUserId!: string;

  @Column({ name: 'triggered_by_actor_id', type: 'varchar', length: 64 })
  triggeredByActorId!: string;

  @Column({ name: 'triggered_by_role', type: 'varchar', length: 64, default: '' })
  triggeredByRole!: string;

  @Column({ name: 'source_license_file_id', type: 'varchar', length: 64 })
  sourceLicenseFileId!: string;

  @Column({ name: 'correction_note', type: 'text', nullable: true })
  correctionNote!: string | null;

  @Column({ name: 'before_status', type: 'varchar', length: 32 })
  beforeStatus!: string;

  @Column({ name: 'after_status', type: 'varchar', length: 32 })
  afterStatus!: string;

  @Column({ name: 'command_outcome', type: 'varchar', length: 32 })
  commandOutcome!: string;

  @Column({ name: 'old_snapshot', type: 'jsonb', default: () => "'{}'::jsonb" })
  oldSnapshot!: Record<string, unknown>;

  @Column({ name: 'requested_snapshot', type: 'jsonb', default: () => "'{}'::jsonb" })
  requestedSnapshot!: Record<string, unknown>;

  @Column({ name: 'ocr_snapshot', type: 'jsonb', nullable: true })
  ocrSnapshot!: Record<string, unknown> | null;

  @Column({ name: 'outcome_reason', type: 'text', nullable: true })
  outcomeReason!: string | null;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
