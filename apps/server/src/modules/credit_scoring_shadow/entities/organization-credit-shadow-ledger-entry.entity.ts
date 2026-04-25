import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'organization_shadow_credit_ledgers' })
export class OrganizationCreditShadowLedgerEntryEntity {
  @PrimaryColumn({ name: 'entry_id', type: 'varchar', length: 64 })
  entryId!: string;

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

  @Column({ name: 'before_score', type: 'numeric', precision: 6, scale: 2, nullable: true })
  beforeScore!: number | null;

  @Column({ name: 'after_score', type: 'numeric', precision: 6, scale: 2, nullable: true })
  afterScore!: number | null;

  @Column({ name: 'before_tier_code', type: 'varchar', length: 8, nullable: true })
  beforeTierCode!: string | null;

  @Column({ name: 'after_tier_code', type: 'varchar', length: 8, nullable: true })
  afterTierCode!: string | null;

  @Column({ name: 'before_risk_posture', type: 'varchar', length: 16, nullable: true })
  beforeRiskPosture!: string | null;

  @Column({ name: 'after_risk_posture', type: 'varchar', length: 16, nullable: true })
  afterRiskPosture!: string | null;

  @Column({ name: 'reason_codes', type: 'jsonb', default: () => "'[]'::jsonb" })
  reasonCodes!: string[];

  @Column({ name: 'changed_at', type: 'timestamptz' })
  changedAt!: Date;
}
