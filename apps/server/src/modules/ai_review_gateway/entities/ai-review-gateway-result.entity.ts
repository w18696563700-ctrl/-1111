import { Column, CreateDateColumn, Entity, Index, JoinColumn, ManyToOne, PrimaryColumn } from 'typeorm';
import { AiReviewGatewayResultStatus } from '../ai-review-gateway.constants';
import { AiReviewGatewayRequestEntity } from './ai-review-gateway-request.entity';

const numericTransformer = {
  to: (value: number) => value,
  from: (value: string | number | null) => Number(value ?? 0)
};

@Entity({ name: 'ai_review_gateway_results' })
@Index('idx_ai_review_gateway_results_status_created', ['status', 'createdAt'])
@Index('idx_ai_review_gateway_results_request_id', ['requestId'], { unique: true })
export class AiReviewGatewayResultEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'request_id', type: 'varchar', length: 64 })
  requestId!: string;

  @ManyToOne(() => AiReviewGatewayRequestEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'request_id' })
  request?: AiReviewGatewayRequestEntity;

  @Column({ type: 'varchar', length: 32 })
  decision!: string;

  @Column({
    name: 'risk_score',
    type: 'numeric',
    precision: 6,
    scale: 2,
    default: 0,
    transformer: numericTransformer
  })
  riskScore!: number;

  @Column({ name: 'risk_labels', type: 'jsonb', default: () => "'[]'" })
  riskLabels!: string[];

  @Column({ name: 'provider_response_ref', type: 'varchar', length: 128 })
  providerResponseRef!: string;

  @Column({
    type: 'varchar',
    length: 32,
    default: 'queued'
  })
  status!: AiReviewGatewayResultStatus;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
