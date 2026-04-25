import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index('idx_orders_project_unique', ['projectId'], { unique: true })
@Index('idx_orders_bid_unique', ['bidId'], { unique: true })
@Index('idx_orders_buyer_state_updated', ['buyerOrganizationId', 'state', 'updatedAt'])
@Index('idx_orders_seller_state_updated', ['sellerOrganizationId', 'state', 'updatedAt'])
@Entity({ name: 'orders' })
export class ProjectOrderEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'order_no', type: 'varchar', length: 64, nullable: true })
  orderNo!: string | null;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'bid_id', type: 'varchar', length: 64, nullable: true })
  bidId!: string | null;

  @Column({ name: 'buyer_organization_id', type: 'varchar', length: 64 })
  buyerOrganizationId!: string;

  @Column({ name: 'supplier_organization_id', type: 'varchar', length: 64, nullable: true })
  sellerOrganizationId!: string | null;

  @Column({ type: 'text', nullable: true })
  title!: string | null;

  @Column({ name: 'total_amount', type: 'numeric', precision: 12, scale: 2, nullable: true })
  totalAmount!: string | number | null;

  @Column({ type: 'varchar', length: 32, default: 'active' })
  state!: string;

  @Column({ name: 'activated_at', type: 'timestamptz', nullable: true })
  activatedAt!: Date | null;

  @Column({ name: 'completed_at', type: 'timestamptz', nullable: true })
  completedAt!: Date | null;

  @Column({ name: 'completion_request_state', type: 'varchar', length: 32, default: 'none' })
  completionRequestState!: string;

  @Column({ name: 'completion_requested_at', type: 'timestamptz', nullable: true })
  completionRequestedAt!: Date | null;

  @Column({ name: 'completion_requested_by', type: 'varchar', length: 64, nullable: true })
  completionRequestedBy!: string | null;

  @Column({ name: 'completion_requested_by_organization_id', type: 'varchar', length: 64, nullable: true })
  completionRequestedByOrganizationId!: string | null;

  @Column({ name: 'completion_request_note', type: 'text', nullable: true })
  completionRequestNote!: string | null;

  @Column({ name: 'completion_confirmed_at', type: 'timestamptz', nullable: true })
  completionConfirmedAt!: Date | null;

  @Column({ name: 'completion_confirmed_by', type: 'varchar', length: 64, nullable: true })
  completionConfirmedBy!: string | null;

  @Column({ name: 'completion_confirmed_by_organization_id', type: 'varchar', length: 64, nullable: true })
  completionConfirmedByOrganizationId!: string | null;

  @Column({ name: 'completion_rejected_at', type: 'timestamptz', nullable: true })
  completionRejectedAt!: Date | null;

  @Column({ name: 'completion_rejected_by', type: 'varchar', length: 64, nullable: true })
  completionRejectedBy!: string | null;

  @Column({ name: 'completion_rejected_by_organization_id', type: 'varchar', length: 64, nullable: true })
  completionRejectedByOrganizationId!: string | null;

  @Column({ name: 'completion_rejection_reason', type: 'text', nullable: true })
  completionRejectionReason!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
