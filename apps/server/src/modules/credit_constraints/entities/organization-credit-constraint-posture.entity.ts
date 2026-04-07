import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'organization_credit_constraint_postures' })
export class OrganizationCreditConstraintPostureEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'credit_constraint_status', type: 'varchar', length: 32 })
  creditConstraintStatus!: string;

  @Column({ name: 'performance_constraint_status', type: 'varchar', length: 32 })
  performanceConstraintStatus!: string;

  @Column({ name: 'restriction_reason_code', type: 'varchar', length: 64, nullable: true })
  restrictionReasonCode!: string | null;

  @Column({ name: 'advisory_reason_code', type: 'varchar', length: 64, nullable: true })
  advisoryReasonCode!: string | null;

  @Column({ name: 'execution_availability_status', type: 'varchar', length: 32 })
  executionAvailabilityStatus!: string;

  @Column({ name: 'explanation_key', type: 'varchar', length: 64 })
  explanationKey!: string;

  @Column({ name: 'handoff_key', type: 'varchar', length: 64 })
  handoffKey!: string;

  @Column({ name: 'dependency_key', type: 'varchar', length: 64, nullable: true })
  dependencyKey!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
