import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'forum_comment' })
export class ForumCommentEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'post_id', type: 'varchar', length: 64 })
  postId!: string;

  @Column({ name: 'parent_comment_id', type: 'varchar', length: 64, nullable: true })
  parentCommentId!: string | null;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'author_user_id', type: 'varchar', length: 64 })
  authorUserId!: string;

  @Column({ name: 'author_actor_id', type: 'varchar', length: 64, nullable: true })
  authorActorId!: string | null;

  @Column({ type: 'text' })
  body!: string;

  @Column({ type: 'varchar', length: 32, default: 'published' })
  state!: string;

  @Column({ name: 'published_at', type: 'timestamptz' })
  publishedAt!: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
