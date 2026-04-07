import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'forum_post' })
export class ForumPostEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'author_user_id', type: 'varchar', length: 64 })
  authorUserId!: string;

  @Column({ name: 'author_actor_id', type: 'varchar', length: 64 })
  authorActorId!: string;

  @Column({ name: 'source_draft_id', type: 'varchar', length: 64, nullable: true })
  sourceDraftId!: string | null;

  @Column({ name: 'topic_id', type: 'varchar', length: 64 })
  topicId!: string;

  @Column({ type: 'varchar', length: 160 })
  title!: string;

  @Column({ type: 'text' })
  body!: string;

  @Column({ type: 'text' })
  excerpt!: string;

  @Column({ name: 'attachment_file_asset_ids', type: 'jsonb', default: () => "'[]'" })
  attachmentFileAssetIds!: string[];

  @Column({ type: 'varchar', length: 32, default: 'published' })
  state!: string;

  @Column({ name: 'published_at', type: 'timestamptz' })
  publishedAt!: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
