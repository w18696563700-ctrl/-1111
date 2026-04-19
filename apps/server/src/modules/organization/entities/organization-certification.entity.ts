import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'organization_certifications' })
export class OrganizationCertificationEntity {
  @PrimaryColumn({ type: 'uuid' })
  id!: string;

  @Column({ name: 'organization_id', type: 'uuid' })
  organizationId!: string;

  @Column({ name: 'certification_status', type: 'varchar', length: 32 })
  certificationStatus!: string;

  @Column({ name: 'legal_name', type: 'varchar', length: 256 })
  legalName!: string;

  @Column({ type: 'varchar', length: 64 })
  uscc!: string;

  @Column({ name: 'license_file_id', type: 'uuid' })
  licenseFileId!: string;

  @Column({ type: 'text', nullable: true })
  address!: string | null;

  @Column({ name: 'established_at', type: 'date', nullable: true })
  establishedAt!: string | null;

  @Column({ name: 'legal_person', type: 'text', nullable: true })
  legalPerson!: string | null;

  @Column({ name: 'business_type', type: 'text', nullable: true })
  businessType!: string | null;

  @Column({ name: 'registered_capital', type: 'text', nullable: true })
  registeredCapital!: string | null;

  @Column({ name: 'business_term', type: 'text', nullable: true })
  businessTerm!: string | null;

  @Column({ name: 'business_scope', type: 'text', nullable: true })
  businessScope!: string | null;

  @Column({ name: 'submitted_at', type: 'timestamptz', nullable: true })
  submittedAt!: Date | null;

  @Column({ name: 'reviewed_at', type: 'timestamptz', nullable: true })
  reviewedAt!: Date | null;

  @Column({ name: 'reviewed_by', type: 'uuid', nullable: true })
  reviewedBy!: string | null;

  @Column({ name: 'reject_reason', type: 'text', nullable: true })
  rejectReason!: string | null;

  @Column({ name: 'expires_at', type: 'timestamptz', nullable: true })
  expiresAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
