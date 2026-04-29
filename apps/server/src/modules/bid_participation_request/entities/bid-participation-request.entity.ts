import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index('idx_bid_participation_requests_project_requester_created', ['projectId', 'requesterOrganizationId', 'createdAt'])
@Entity({ name: 'bid_participation_requests' })
export class BidParticipationRequestEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'requester_organization_id', type: 'varchar', length: 64 })
  requesterOrganizationId!: string;

  @Column({ name: 'requested_by_user_id', type: 'varchar', length: 64 })
  requestedByUserId!: string;

  @Column({ name: 'requested_by_actor_id', type: 'varchar', length: 64, default: '' })
  requestedByActorId!: string;

  @Column({ type: 'varchar', length: 32, default: 'pending' })
  state!: string;

  @Column({ name: 'reviewed_by_user_id', type: 'varchar', length: 64, nullable: true })
  reviewedByUserId!: string | null;

  @Column({ name: 'reviewed_by_actor_id', type: 'varchar', length: 64, nullable: true })
  reviewedByActorId!: string | null;

  @Column({ name: 'reviewed_at', type: 'timestamptz', nullable: true })
  reviewedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}

