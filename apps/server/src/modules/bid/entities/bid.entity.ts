import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index('idx_bids_project_bidder_unique', ['projectId', 'bidderOrganizationId'], {
  unique: true
})
@Entity({ name: 'bids' })
export class BidEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'bid_no', type: 'varchar', length: 64 })
  bidNo!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'bidder_organization_id', type: 'varchar', length: 64 })
  bidderOrganizationId!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'actor_id', type: 'varchar', length: 64, nullable: true })
  actorId!: string | null;

  @Column({ name: 'user_id', type: 'varchar', length: 64, nullable: true })
  userId!: string | null;

  @Column({ name: 'quote_amount', type: 'numeric', precision: 12, scale: 2 })
  quoteAmount!: string | number;

  @Column({ name: 'proposal_summary', type: 'text' })
  proposalSummary!: string;

  @Column({ type: 'varchar', length: 32, default: 'submitted' })
  state!: string;

  @Column({ name: 'submitted_by', type: 'varchar', length: 64 })
  submittedBy!: string;

  @Column({ name: 'submitted_at', type: 'timestamptz' })
  submittedAt!: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
