import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'organization_payment_statuses' })
export class OrganizationPaymentStatusEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'payment_status_code', type: 'varchar', length: 32 })
  paymentStatusCode!: string;

  @Column({ name: 'payment_availability_code', type: 'varchar', length: 32 })
  paymentAvailabilityCode!: string;

  @Column({ name: 'payment_handoff_key', type: 'varchar', length: 64 })
  paymentHandoffKey!: string;

  @Column({ name: 'payment_explanation_key', type: 'varchar', length: 64 })
  paymentExplanationKey!: string;

  @Column({ name: 'payment_dependency_key', type: 'varchar', length: 64, nullable: true })
  paymentDependencyKey!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
