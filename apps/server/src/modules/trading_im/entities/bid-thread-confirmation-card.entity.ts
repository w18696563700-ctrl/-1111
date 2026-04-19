import { Column, CreateDateColumn, Entity, Index, PrimaryColumn } from 'typeorm';

@Index('idx_bid_thread_confirmation_cards_thread_created', ['threadId', 'createdAt'])
@Entity({ name: 'bid_thread_confirmation_cards' })
export class BidThreadConfirmationCardEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'thread_id', type: 'varchar', length: 64 })
  threadId!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'bid_id', type: 'varchar', length: 64 })
  bidId!: string;

  @Column({ name: 'confirmation_type', type: 'varchar', length: 32 })
  confirmationType!: string;

  @Column({ name: 'source_message_id', type: 'varchar', length: 64 })
  sourceMessageId!: string;

  @Column({ type: 'text' })
  summary!: string;

  @Column({ name: 'creator_user_id', type: 'varchar', length: 64, nullable: true })
  creatorUserId!: string | null;

  @Column({ name: 'creator_actor_id', type: 'varchar', length: 64, nullable: true })
  creatorActorId!: string | null;

  @Column({ name: 'creator_organization_id', type: 'varchar', length: 64 })
  creatorOrganizationId!: string;

  @Column({ name: 'creator_role', type: 'varchar', length: 32 })
  creatorRole!: string;

  @Column({ name: 'card_state', type: 'varchar', length: 32, default: 'active' })
  cardState!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
