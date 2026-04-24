import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'forum_posts' })
export class ForumPostEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'post_no', type: 'varchar', length: 32, unique: true })
  postNo!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'author_user_id', type: 'varchar', length: 64 })
  authorUserId!: string;

  @Column({ name: 'author_actor_id', type: 'varchar', length: 64 })
  authorActorId!: string;

  @Column({ name: 'author_organization_id', type: 'varchar', length: 64 })
  authorOrganizationId!: string;

  @Column({ name: 'source_draft_id', type: 'varchar', length: 64, nullable: true })
  sourceDraftId!: string | null;

  @Column({ name: 'topic_id', type: 'varchar', length: 64 })
  topicId!: string;

  @Column({ type: 'varchar', length: 128 })
  title!: string;

  @Column({ type: 'text' })
  body!: string;

  @Column({ type: 'text' })
  excerpt!: string;

  @Column({ name: 'attachment_file_asset_ids', type: 'jsonb', default: () => "'[]'" })
  attachmentFileAssetIds!: string[];

  @Column({ type: 'varchar', length: 32, default: 'published' })
  state!: string;

  @Column({ name: 'comment_count', type: 'integer', default: 0 })
  commentCount!: number;

  @Column({ name: 'last_moderation_case_id', type: 'varchar', length: 64, nullable: true })
  lastModerationCaseId!: string | null;

  @Column({ name: 'published_at', type: 'timestamptz' })
  publishedAt!: Date;

  @Column({ name: 'hidden_at', type: 'timestamptz', nullable: true })
  hiddenAt!: Date | null;

  @Column({ name: 'archived_at', type: 'timestamptz', nullable: true })
  archivedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
