import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'forum_drafts' })
export class ForumDraftEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'draft_no', type: 'varchar', length: 32, unique: true })
  draftNo!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'creator_user_id', type: 'varchar', length: 64 })
  creatorUserId!: string;

  @Column({ name: 'creator_actor_id', type: 'varchar', length: 64 })
  creatorActorId!: string;

  @Column({ name: 'owner_actor_id', type: 'varchar', length: 64 })
  ownerActorId!: string;

  @Column({ name: 'owner_organization_id', type: 'varchar', length: 64 })
  ownerOrganizationId!: string;

  @Column({ name: 'draft_type', type: 'varchar', length: 32, default: 'topic' })
  draftType!: string;

  @Column({ name: 'topic_id', type: 'varchar', length: 64, nullable: true })
  topicId!: string | null;

  @Column({ name: 'target_post_id', type: 'varchar', length: 64, nullable: true })
  targetPostId!: string | null;

  @Column({ name: 'parent_comment_id', type: 'varchar', length: 64, nullable: true })
  parentCommentId!: string | null;

  @Column({ type: 'varchar', length: 128 })
  title!: string;

  @Column({ type: 'text' })
  body!: string;

  @Column({ name: 'attachment_file_asset_ids', type: 'jsonb', default: () => "'[]'" })
  attachmentFileAssetIds!: string[];

  @Column({ type: 'varchar', length: 32, default: 'ready_to_publish' })
  state!: string;

  @Column({ name: 'published_post_id', type: 'varchar', length: 64, nullable: true })
  publishedPostId!: string | null;

  @Column({ name: 'consumed_at', type: 'timestamptz', nullable: true })
  consumedAt!: Date | null;

  @Column({ name: 'discarded_at', type: 'timestamptz', nullable: true })
  discardedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
