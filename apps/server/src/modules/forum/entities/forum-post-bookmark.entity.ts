import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'forum_post_bookmarks' })
export class ForumPostBookmarkEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'post_id', type: 'varchar', length: 64 })
  postId!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64 })
  userId!: string;

  @Column({ name: 'actor_id', type: 'varchar', length: 64, nullable: true })
  actorId!: string | null;

  @Column({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
