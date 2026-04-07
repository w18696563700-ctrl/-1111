import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'organization_membership_quota_snapshots' })
export class OrganizationMembershipQuotaSnapshotEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'quota_type', type: 'varchar', length: 64 })
  quotaType!: string;

  @Column({ name: 'current_value', type: 'integer', nullable: true })
  currentValue!: number | null;

  @Column({ name: 'refresh_rule', type: 'varchar', length: 64, nullable: true })
  refreshRule!: string | null;

  @Column({ name: 'next_refresh_at', type: 'timestamptz', nullable: true })
  nextRefreshAt!: Date | null;

  @Column({ name: 'last_refreshed_at', type: 'timestamptz', nullable: true })
  lastRefreshedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
