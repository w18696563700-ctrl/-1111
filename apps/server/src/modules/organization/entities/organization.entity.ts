import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'organizations' })
export class OrganizationEntity {
  @PrimaryColumn({ type: 'uuid' })
  id!: string;

  @Column({ type: 'varchar', length: 256 })
  name!: string;

  @Column({ name: 'organization_type', type: 'varchar', length: 32 })
  organizationType!: string;

  @Column({ name: 'province_code', type: 'varchar', length: 32, nullable: true })
  provinceCode!: string | null;

  @Column({ name: 'city_code', type: 'varchar', length: 32, nullable: true })
  cityCode!: string | null;

  @Column({ name: 'contact_name', type: 'varchar', length: 128, nullable: true })
  contactName!: string | null;

  @Column({ name: 'contact_mobile', type: 'varchar', length: 32, nullable: true })
  contactMobile!: string | null;

  @Column({ type: 'varchar', length: 64, nullable: true })
  uscc!: string | null;

  @Column({ name: 'business_license_file_id', type: 'uuid', nullable: true })
  businessLicenseFileId!: string | null;

  @Column({ type: 'text', nullable: true })
  intro!: string | null;

  @Column({ type: 'varchar', length: 32, default: 'draft' })
  status!: string;

  @Column({ name: 'created_by', type: 'uuid', nullable: true })
  createdBy!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
