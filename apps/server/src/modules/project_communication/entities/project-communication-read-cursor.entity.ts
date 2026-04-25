import { Column, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'project_communication_read_cursors' })
export class ProjectCommunicationReadCursorEntity {
  @PrimaryColumn({ name: 'thread_id', type: 'varchar', length: 64 })
  threadId!: string;

  @PrimaryColumn({ name: 'organization_id', type: 'varchar', length: 64 })
  organizationId!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'last_read_message_id', type: 'varchar', length: 64, nullable: true })
  lastReadMessageId!: string | null;

  @Column({ name: 'last_read_at', type: 'timestamptz' })
  lastReadAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
