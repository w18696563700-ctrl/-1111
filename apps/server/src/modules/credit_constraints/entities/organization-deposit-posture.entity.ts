import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'organization_deposit_postures' })
export class OrganizationDepositPostureEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'requirement_status', type: 'varchar', length: 32 })
  requirementStatus!: string;

  @Column({ name: 'eligibility_status', type: 'varchar', length: 32 })
  eligibilityStatus!: string;

  @Column({ name: 'restriction_status', type: 'varchar', length: 32 })
  restrictionStatus!: string;

  @Column({ name: 'deposit_posture_status', type: 'varchar', length: 32 })
  depositPostureStatus!: string;

  @Column({ name: 'handoff_key', type: 'varchar', length: 64 })
  handoffKey!: string;

  @Column({ name: 'dependency_key', type: 'varchar', length: 64, nullable: true })
  dependencyKey!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
