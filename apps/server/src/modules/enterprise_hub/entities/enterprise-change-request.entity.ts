import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'enterprise_change_request' })
export class EnterpriseChangeRequestEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'board_type', type: 'varchar', length: 32 })
  boardType!: string;

  @Column({ name: 'change_status', type: 'varchar', length: 32, default: 'draft' })
  changeStatus!: string;

  @Column({ name: 'draft_basic', type: 'jsonb', default: () => "'{}'" })
  draftBasic!: Record<string, unknown>;

  @Column({ name: 'draft_board_profile', type: 'jsonb', nullable: true })
  draftBoardProfile!: Record<string, unknown> | null;

  @Column({ name: 'draft_primary_contact', type: 'jsonb', nullable: true })
  draftPrimaryContact!: Record<string, unknown> | null;

  @Column({ name: 'draft_cases', type: 'jsonb', default: () => "'[]'" })
  draftCases!: Record<string, unknown>[];

  @Column({ name: 'submitted_at', type: 'timestamptz', nullable: true })
  submittedAt!: Date | null;

  @Column({ name: 'reviewed_at', type: 'timestamptz', nullable: true })
  reviewedAt!: Date | null;

  @Column({ name: 'applied_at', type: 'timestamptz', nullable: true })
  appliedAt!: Date | null;

  @Column({ name: 'rejection_reason', type: 'text', nullable: true })
  rejectionReason!: string | null;

  @Column({ name: 'review_note', type: 'text', nullable: true })
  reviewNote!: string | null;

  @Column({ name: 'reviewer_actor_id', type: 'varchar', length: 64, nullable: true })
  reviewerActorId!: string | null;

  @Column({ name: 'applied_by_actor_id', type: 'varchar', length: 64, nullable: true })
  appliedByActorId!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
