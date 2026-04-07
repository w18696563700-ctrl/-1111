import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'forum_draft' })
export class ForumDraftEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'creator_user_id', type: 'varchar', length: 64 })
  creatorUserId!: string;

  @Column({ name: 'creator_actor_id', type: 'varchar', length: 64 })
  creatorActorId!: string;

  @Column({ name: 'draft_type', type: 'varchar', length: 32, default: 'topic' })
  draftType!: string;

  @Column({ name: 'topic_id', type: 'varchar', length: 64 })
  topicId!: string;

  @Column({ type: 'varchar', length: 160 })
  title!: string;

  @Column({ type: 'text' })
  body!: string;

  @Column({ name: 'attachment_file_asset_ids', type: 'jsonb', default: () => "'[]'" })
  attachmentFileAssetIds!: string[];

  @Column({ type: 'varchar', length: 32, default: 'ready_to_publish' })
  state!: string;

  @Column({ name: 'published_post_id', type: 'varchar', length: 64, nullable: true })
  publishedPostId!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
