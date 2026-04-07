import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'enterprise_review_summary' })
export class EnterpriseReviewSummaryEntity {
  @PrimaryColumn({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'avg_score', type: 'numeric', precision: 5, scale: 2, nullable: true })
  avgScore!: number | null;

  @Column({ name: 'review_count', type: 'integer', nullable: true })
  reviewCount!: number | null;

  @Column({ name: 'keyword_tags', type: 'jsonb', default: () => "'[]'" })
  keywordTags!: string[];

  @Column({ name: 'delivery_score', type: 'numeric', precision: 5, scale: 2, nullable: true })
  deliveryScore!: number | null;

  @Column({ name: 'quality_score', type: 'numeric', precision: 5, scale: 2, nullable: true })
  qualityScore!: number | null;

  @Column({ name: 'communication_score', type: 'numeric', precision: 5, scale: 2, nullable: true })
  communicationScore!: number | null;

  @Column({ name: 'last_updated_at', type: 'timestamptz', nullable: true })
  lastUpdatedAt!: Date | null;
}
