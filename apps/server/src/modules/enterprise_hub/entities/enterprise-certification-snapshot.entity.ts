import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'enterprise_certification_snapshot' })
export class EnterpriseCertificationSnapshotEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'certification_type', type: 'varchar', length: 64 })
  certificationType!: string;

  @Column({ name: 'certification_name', type: 'varchar', length: 128 })
  certificationName!: string;

  @Column({ name: 'certification_file_asset_id', type: 'varchar', length: 64 })
  certificationFileAssetId!: string;

  @Column({ name: 'cert_status', type: 'varchar', length: 32, default: 'pending' })
  certStatus!: string;

  @Column({ name: 'reviewer_id', type: 'varchar', length: 64, nullable: true })
  reviewerId!: string | null;

  @Column({ name: 'review_note', type: 'text', nullable: true })
  reviewNote!: string | null;

  @Column({ name: 'verified_at', type: 'timestamptz', nullable: true })
  verifiedAt!: Date | null;
}
