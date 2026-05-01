import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index('idx_app_notifications_user_created', ['userId', 'createdAt'])
@Index('idx_app_notifications_org_created', ['organizationId', 'createdAt'])
@Index('idx_app_notifications_project_thread', ['projectId', 'threadId'])
@Entity({ name: 'app_notifications' })
export class AppNotificationEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64, default: '' })
  userId!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64, default: '' })
  organizationId!: string;

  @Column({ type: 'varchar', length: 64 })
  type!: string;

  @Column({ type: 'varchar', length: 64 })
  source!: string;

  @Column({ type: 'varchar', length: 160 })
  title!: string;

  @Column({ type: 'text', nullable: true })
  body!: string | null;

  @Column({ name: 'project_id', type: 'varchar', length: 64, nullable: true })
  projectId!: string | null;

  @Column({ name: 'thread_id', type: 'varchar', length: 64, nullable: true })
  threadId!: string | null;

  @Column({ name: 'route_target', type: 'jsonb', default: () => "'{}'::jsonb" })
  routeTarget!: Record<string, unknown>;

  @Column({ name: 'read_at', type: 'timestamptz', nullable: true })
  readAt!: Date | null;

  @Column({ name: 'notification_state', type: 'varchar', length: 32, default: 'active' })
  notificationState!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
