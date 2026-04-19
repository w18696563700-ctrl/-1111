import { Column, CreateDateColumn, Entity, Index, PrimaryColumn } from 'typeorm';

@Entity({ name: 'ai_review_gateway_requests' })
@Index('idx_ai_review_gateway_requests_trace_created', ['traceId', 'createdAt'])
export class AiReviewGatewayRequestEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'engine_type', type: 'varchar', length: 32 })
  engineType!: string;

  @Column({ name: 'provider_key', type: 'varchar', length: 64 })
  providerKey!: string;

  @Column({ name: 'review_object_type', type: 'varchar', length: 64 })
  reviewObjectType!: string;

  @Column({ name: 'object_id', type: 'varchar', length: 128 })
  objectId!: string;

  @Column({ name: 'policy_profile', type: 'varchar', length: 64 })
  policyProfile!: string;

  @Column({ name: 'request_payload_ref', type: 'varchar', length: 128 })
  requestPayloadRef!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64 })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
