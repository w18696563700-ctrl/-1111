import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'personal_certifications' })
export class PersonalCertificationEntity {
  @PrimaryColumn({ type: 'uuid' })
  id!: string;

  @Column({ name: 'organization_id', type: 'uuid', unique: true })
  organizationId!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64 })
  userId!: string;

  @Column({ name: 'certification_status', type: 'varchar', length: 32 })
  certificationStatus!: string;

  @Column({ name: 'real_name', type: 'varchar', length: 128, nullable: true })
  realName!: string | null;

  @Column({ name: 'id_number_masked', type: 'varchar', length: 32, nullable: true })
  idNumberMasked!: string | null;

  @Column({ name: 'id_card_front_file_id', type: 'varchar', length: 64, nullable: true })
  idCardFrontFileId!: string | null;

  @Column({ name: 'provider_request_id', type: 'varchar', length: 128, nullable: true })
  providerRequestId!: string | null;

  @Column({ name: 'submitted_at', type: 'timestamptz', nullable: true })
  submittedAt!: Date | null;

  @Column({ name: 'reviewed_at', type: 'timestamptz', nullable: true })
  reviewedAt!: Date | null;

  @Column({ name: 'reject_reason', type: 'text', nullable: true })
  rejectReason!: string | null;

  @Column({ name: 'locked_at', type: 'timestamptz', nullable: true })
  lockedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
