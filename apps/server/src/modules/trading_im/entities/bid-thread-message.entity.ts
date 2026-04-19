import { Column, CreateDateColumn, Entity, Index, PrimaryColumn } from 'typeorm';

@Index('idx_bid_thread_messages_thread_created', ['threadId', 'createdAt'])
@Entity({ name: 'bid_thread_messages' })
export class BidThreadMessageEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'thread_id', type: 'varchar', length: 64 })
  threadId!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'bid_id', type: 'varchar', length: 64 })
  bidId!: string;

  @Column({ name: 'sender_user_id', type: 'varchar', length: 64, nullable: true })
  senderUserId!: string | null;

  @Column({ name: 'sender_actor_id', type: 'varchar', length: 64, nullable: true })
  senderActorId!: string | null;

  @Column({ name: 'sender_organization_id', type: 'varchar', length: 64 })
  senderOrganizationId!: string;

  @Column({ name: 'sender_role', type: 'varchar', length: 32 })
  senderRole!: string;

  @Column({ type: 'text' })
  body!: string;

  @Column({ name: 'attachment_file_asset_ids', type: 'jsonb', default: () => "'[]'::jsonb" })
  attachmentFileAssetIds!: string[];

  @Column({ name: 'message_state', type: 'varchar', length: 32, default: 'active' })
  messageState!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
