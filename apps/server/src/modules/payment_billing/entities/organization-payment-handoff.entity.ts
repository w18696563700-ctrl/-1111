import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'organization_payment_handoffs' })
export class OrganizationPaymentHandoffEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'handoff_status_code', type: 'varchar', length: 32 })
  handoffStatusCode!: string;

  @Column({ name: 'handoff_target_family', type: 'varchar', length: 64 })
  handoffTargetFamily!: string;

  @Column({ name: 'handoff_explanation_key', type: 'varchar', length: 64 })
  handoffExplanationKey!: string;

  @Column({ name: 'dependency_required', type: 'boolean', default: false })
  dependencyRequired!: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
