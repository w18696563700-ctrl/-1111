import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'organization_shadow_credit_recompute_triggers' })
export class OrganizationCreditShadowRecomputeTriggerEntity {
  @PrimaryColumn({ name: 'trigger_id', type: 'varchar', length: 64 })
  triggerId!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'trigger_type', type: 'varchar', length: 64 })
  triggerType!: string;

  @Column({ name: 'source_type', type: 'varchar', length: 64, default: 'order_rating' })
  sourceType!: string;

  @Column({ name: 'source_order_id', type: 'varchar', length: 64, nullable: true })
  sourceOrderId!: string | null;

  @Column({ name: 'source_rating_id', type: 'varchar', length: 64, nullable: true })
  sourceRatingId!: string | null;

  @Column({ name: 'reason_codes', type: 'jsonb', default: () => "'[]'::jsonb" })
  reasonCodes!: string[];

  @Column({ name: 'trigger_status', type: 'varchar', length: 32, default: 'processed' })
  triggerStatus!: 'pending' | 'processed' | 'failed';

  @Column({ name: 'processed_at', type: 'timestamptz', nullable: true })
  processedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
