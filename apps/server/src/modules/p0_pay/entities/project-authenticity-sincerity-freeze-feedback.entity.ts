import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

export type ProjectAuthenticitySincerityFreezeFeedbackChoice =
  | 'support_freeze'
  | 'oppose_freeze';

@Entity({ name: 'project_authenticity_sincerity_freeze_feedback' })
@Index('idx_project_auth_sincerity_feedback_project', ['projectId'])
@Index('idx_project_auth_sincerity_feedback_project_choice', ['projectId', 'choice'])
@Index('idx_project_auth_sincerity_feedback_user_project', ['projectId', 'userId'], {
  unique: true,
})
export class ProjectAuthenticitySincerityFreezeFeedbackEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64 })
  userId!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64, default: '' })
  organizationId!: string;

  @Column({ name: 'actor_role', type: 'varchar', length: 64, default: '' })
  actorRole!: string;

  @Column({ type: 'varchar', length: 32 })
  choice!: ProjectAuthenticitySincerityFreezeFeedbackChoice;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
