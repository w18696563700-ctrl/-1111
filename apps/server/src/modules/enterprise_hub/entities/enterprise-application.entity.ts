import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'enterprise_application' })
export class EnterpriseApplicationEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'apply_board_type', type: 'varchar', length: 32 })
  applyBoardType!: string;

  @Column({ name: 'applicant_name', type: 'varchar', length: 64 })
  applicantName!: string;

  @Column({ name: 'applicant_mobile', type: 'varchar', length: 32 })
  applicantMobile!: string;

  @Column({ name: 'submitted_material_snapshot', type: 'jsonb', nullable: true })
  submittedMaterialSnapshot!: Record<string, unknown> | null;

  @Column({ name: 'application_status', type: 'varchar', length: 32, default: 'draft' })
  applicationStatus!: string;

  @Column({ name: 'rejection_reason', type: 'text', nullable: true })
  rejectionReason!: string | null;

  @Column({ name: 'submitted_at', type: 'timestamptz', nullable: true })
  submittedAt!: Date | null;

  @Column({ name: 'reviewed_at', type: 'timestamptz', nullable: true })
  reviewedAt!: Date | null;

  @Column({ name: 'reviewer_id', type: 'varchar', length: 64, nullable: true })
  reviewerId!: string | null;

  @Column({ name: 'review_note', type: 'text', nullable: true })
  reviewNote!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
