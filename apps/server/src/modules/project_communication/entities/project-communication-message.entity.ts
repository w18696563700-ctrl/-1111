import { Column, CreateDateColumn, Entity, Index, PrimaryColumn } from 'typeorm';

@Index('idx_project_communication_messages_thread_created', ['threadId', 'createdAt'])
@Index(
  'idx_project_communication_messages_client_dedupe',
  ['threadId', 'senderOrganizationId', 'clientMessageId']
)
@Entity({ name: 'project_communication_messages' })
export class ProjectCommunicationMessageEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'thread_id', type: 'varchar', length: 64 })
  threadId!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'sender_user_id', type: 'varchar', length: 64 })
  senderUserId!: string;

  @Column({ name: 'sender_actor_id', type: 'varchar', length: 64, nullable: true })
  senderActorId!: string | null;

  @Column({ name: 'sender_organization_id', type: 'varchar', length: 64 })
  senderOrganizationId!: string;

  @Column({ name: 'message_kind', type: 'varchar', length: 32, default: 'text' })
  messageKind!: string;

  @Column({ type: 'text' })
  body!: string;

  @Column({ type: 'jsonb', default: () => "'{}'::jsonb" })
  payload!: Record<string, unknown>;

  @Column({ name: 'client_message_id', type: 'varchar', length: 96, nullable: true })
  clientMessageId!: string | null;

  @Column({ name: 'message_state', type: 'varchar', length: 32, default: 'active' })
  messageState!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
