import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'forum_report_ticket' })
export class ForumReportTicketEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'target_type', type: 'varchar', length: 32 })
  targetType!: string;

  @Column({ name: 'target_id', type: 'varchar', length: 64 })
  targetId!: string;

  @Column({ name: 'target_author_user_id', type: 'varchar', length: 64, nullable: true })
  targetAuthorUserId!: string | null;

  @Column({ name: 'target_organization_id', type: 'varchar', length: 64, nullable: true })
  targetOrganizationId!: string | null;

  @Column({ name: 'reporter_user_id', type: 'varchar', length: 64 })
  reporterUserId!: string;

  @Column({ name: 'reporter_actor_id', type: 'varchar', length: 64 })
  reporterActorId!: string;

  @Column({ name: 'reporter_organization_id', type: 'varchar', length: 64 })
  reporterOrganizationId!: string;

  @Column({ name: 'reason_code', type: 'varchar', length: 64 })
  reasonCode!: string;

  @Column({ name: 'reason_detail', type: 'varchar', length: 200, nullable: true })
  reasonDetail!: string | null;

  @Column({ type: 'varchar', length: 32 })
  status!: string;

  @Column({ name: 'target_snapshot', type: 'jsonb', default: () => "'{}'" })
  targetSnapshot!: Record<string, unknown>;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
