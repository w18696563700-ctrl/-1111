import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index('idx_project_clarifications_project_created', ['projectId', 'createdAt'])
@Entity({ name: 'project_clarifications' })
export class ProjectClarificationEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'author_user_id', type: 'varchar', length: 64, nullable: true })
  authorUserId!: string | null;

  @Column({ name: 'author_actor_id', type: 'varchar', length: 64, nullable: true })
  authorActorId!: string | null;

  @Column({ name: 'author_organization_id', type: 'varchar', length: 64, default: '' })
  authorOrganizationId!: string;

  @Column({ name: 'author_role', type: 'varchar', length: 32 })
  authorRole!: string;

  @Column({ type: 'text' })
  body!: string;

  @Column({ name: 'attachment_file_asset_ids', type: 'jsonb', default: () => "'[]'::jsonb" })
  attachmentFileAssetIds!: string[];

  @Column({ name: 'lifecycle_state', type: 'varchar', length: 32, default: 'active' })
  lifecycleState!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
