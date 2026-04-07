import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'organization_billing_references' })
export class OrganizationBillingReferenceEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'billing_reference_status_code', type: 'varchar', length: 32 })
  billingReferenceStatusCode!: string;

  @Column({ name: 'billing_reference_code', type: 'varchar', length: 128, nullable: true })
  billingReferenceCode!: string | null;

  @Column({ name: 'billing_reference_visibility_code', type: 'varchar', length: 32 })
  billingReferenceVisibilityCode!: string;

  @Column({ name: 'billing_explanation_key', type: 'varchar', length: 64 })
  billingExplanationKey!: string;

  @Column({ name: 'billing_handoff_key', type: 'varchar', length: 64 })
  billingHandoffKey!: string;

  @Column({ name: 'billing_dependency_key', type: 'varchar', length: 64, nullable: true })
  billingDependencyKey!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
