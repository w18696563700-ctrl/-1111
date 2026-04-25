import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index(
  'idx_project_communication_threads_unique_pair',
  ['projectId', 'ownerOrganizationId', 'counterpartOrganizationId'],
  { unique: true }
)
@Entity({ name: 'project_communication_threads' })
export class ProjectCommunicationThreadEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'owner_organization_id', type: 'varchar', length: 64 })
  ownerOrganizationId!: string;

  @Column({ name: 'counterpart_organization_id', type: 'varchar', length: 64 })
  counterpartOrganizationId!: string;

  @Column({ name: 'thread_state', type: 'varchar', length: 32, default: 'open' })
  threadState!: string;

  @Column({ name: 'last_message_id', type: 'varchar', length: 64, nullable: true })
  lastMessageId!: string | null;

  @Column({ name: 'last_message_at', type: 'timestamptz', nullable: true })
  lastMessageAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
