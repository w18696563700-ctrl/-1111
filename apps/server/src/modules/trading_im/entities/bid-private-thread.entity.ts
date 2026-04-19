import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index('idx_bid_private_threads_project_bid_unique', ['projectId', 'bidId'], { unique: true })
@Entity({ name: 'bid_private_threads' })
export class BidPrivateThreadEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'bid_id', type: 'varchar', length: 64 })
  bidId!: string;

  @Column({ name: 'project_owner_organization_id', type: 'varchar', length: 64 })
  projectOwnerOrganizationId!: string;

  @Column({ name: 'bidder_organization_id', type: 'varchar', length: 64 })
  bidderOrganizationId!: string;

  @Column({ name: 'lifecycle_state', type: 'varchar', length: 32, default: 'open' })
  lifecycleState!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
