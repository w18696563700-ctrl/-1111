import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'forum_author_follows' })
export class ForumAuthorFollowEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'follower_user_id', type: 'varchar', length: 64 })
  followerUserId!: string;

  @Column({ name: 'follower_actor_id', type: 'varchar', length: 64, nullable: true })
  followerActorId!: string | null;

  @Column({ name: 'follower_organization_id', type: 'varchar', length: 64 })
  followerOrganizationId!: string;

  @Column({ name: 'target_author_user_id', type: 'varchar', length: 64 })
  targetAuthorUserId!: string;

  @Column({ name: 'target_organization_id', type: 'varchar', length: 64 })
  targetOrganizationId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
