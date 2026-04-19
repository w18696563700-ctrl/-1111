import { Column, Entity, UpdateDateColumn, PrimaryColumn } from 'typeorm';

@Entity({ name: 'organization_shadow_credit_aggregates' })
export class OrganizationCreditShadowAggregateEntity {
  @PrimaryColumn({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'aggregation_mode', type: 'varchar', length: 32 })
  aggregationMode!: string;

  @Column({ name: 'sample_status', type: 'varchar', length: 32 })
  sampleStatus!: string;

  @Column({ name: 'rated_completed_order_count', type: 'integer', default: 0 })
  ratedCompletedOrderCount!: number;

  @Column({ name: 'very_satisfied_count', type: 'integer', default: 0 })
  verySatisfiedCount!: number;

  @Column({ name: 'satisfied_count', type: 'integer', default: 0 })
  satisfiedCount!: number;

  @Column({ name: 'passable_count', type: 'integer', default: 0 })
  passableCount!: number;

  @Column({ name: 'negative_count', type: 'integer', default: 0 })
  negativeCount!: number;

  @Column({ name: 'positive_rate', type: 'numeric', precision: 6, scale: 2, default: 0 })
  positiveRate!: number;

  @Column({ name: 'negative_rate', type: 'numeric', precision: 6, scale: 2, default: 0 })
  negativeRate!: number;

  @Column({ name: 'recent_consecutive_negative_count', type: 'integer', default: 0 })
  recentConsecutiveNegativeCount!: number;

  @Column({ name: 'last20_rated_negative_rate', type: 'numeric', precision: 6, scale: 2, default: 0 })
  last20RatedNegativeRate!: number;

  @Column({ name: 'base_score', type: 'numeric', precision: 6, scale: 2, default: 60 })
  baseScore!: number;

  @Column({ name: 'raw_score', type: 'numeric', precision: 6, scale: 2, default: 0 })
  rawScore!: number;

  @Column({ name: 'effective_score', type: 'numeric', precision: 6, scale: 2, default: 0 })
  effectiveScore!: number;

  @Column({ name: 'public_score', type: 'numeric', precision: 6, scale: 2, nullable: true })
  publicScore!: number | null;

  @Column({ name: 'tier_code', type: 'varchar', length: 8 })
  tierCode!: 'T0' | 'T1' | 'T2' | 'T3' | 'T4';

  @Column({ name: 'risk_posture', type: 'varchar', length: 16 })
  riskPosture!: 'normal' | 'observe' | 'risk_alert';

  @Column({ name: 'tier_reason_codes', type: 'jsonb', default: () => "'[]'::jsonb" })
  tierReasonCodes!: string[];

  @Column({ name: 'posture_reason_codes', type: 'jsonb', default: () => "'[]'::jsonb" })
  postureReasonCodes!: string[];

  @Column({ name: 'reason_summary', type: 'text', default: '' })
  reasonSummary!: string;

  @Column({ type: 'integer', default: 1 })
  version!: number;

  @Column({ name: 'last_rated_order_id', type: 'varchar', length: 64, nullable: true })
  lastRatedOrderId!: string | null;

  @Column({ name: 'last_rated_at', type: 'timestamptz', nullable: true })
  lastRatedAt!: Date | null;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}

