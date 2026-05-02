import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';
import type {
  ProjectBidMaterialSlot,
  ProjectCommunicationMaterialReviewEntryKey,
  ProjectCommunicationMaterialReviewState,
  ProjectCommunicationMaterialSubjectType,
  ProjectQuoteBasisMaterialKind
} from '../project-communication-workbench.types';

@Entity({ name: 'project_communication_material_reviews' })
@Index('idx_project_communication_material_reviews_project_bid', ['projectId', 'bidId'])
@Index('idx_project_communication_material_reviews_reviewer', ['reviewerOrganizationId'])
@Index('idx_project_communication_material_reviews_state', ['reviewState'])
@Index(
  'idx_project_communication_material_reviews_active_unique',
  ['projectId', 'bidId', 'reviewerOrganizationId', 'entryKey'],
  { unique: true }
)
export class ProjectCommunicationMaterialReviewEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'thread_id', type: 'varchar', length: 64 })
  threadId!: string;

  @Column({ name: 'bid_id', type: 'varchar', length: 64 })
  bidId!: string;

  @Column({ name: 'entry_key', type: 'varchar', length: 96 })
  entryKey!: ProjectCommunicationMaterialReviewEntryKey;

  @Column({ name: 'subject_type', type: 'varchar', length: 64 })
  subjectType!: ProjectCommunicationMaterialSubjectType;

  @Column({ name: 'material_kind', type: 'varchar', length: 64, nullable: true })
  materialKind!: ProjectQuoteBasisMaterialKind | null;

  @Column({ name: 'bid_material_slot', type: 'varchar', length: 64, nullable: true })
  bidMaterialSlot!: ProjectBidMaterialSlot | null;

  @Column({ name: 'subject_owner_organization_id', type: 'varchar', length: 64 })
  subjectOwnerOrganizationId!: string;

  @Column({ name: 'reviewer_organization_id', type: 'varchar', length: 64 })
  reviewerOrganizationId!: string;

  @Column({ name: 'review_state', type: 'varchar', length: 32 })
  reviewState!: ProjectCommunicationMaterialReviewState;

  @Column({ name: 'feedback_reason_codes', type: 'jsonb', default: () => "'[]'::jsonb" })
  feedbackReasonCodes!: string[];

  @Column({ name: 'feedback_text', type: 'text', nullable: true })
  feedbackText!: string | null;

  @Column({ name: 'source_version_token', type: 'varchar', length: 128 })
  sourceVersionToken!: string;

  @Column({ name: 'confirmed_by_user_id', type: 'varchar', length: 64, nullable: true })
  confirmedByUserId!: string | null;

  @Column({ name: 'confirmed_at', type: 'timestamptz', nullable: true })
  confirmedAt!: Date | null;

  @Column({ name: 'feedback_by_user_id', type: 'varchar', length: 64, nullable: true })
  feedbackByUserId!: string | null;

  @Column({ name: 'feedback_at', type: 'timestamptz', nullable: true })
  feedbackAt!: Date | null;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
