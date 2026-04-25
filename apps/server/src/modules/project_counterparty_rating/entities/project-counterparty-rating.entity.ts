import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index(
  'idx_project_counterparty_ratings_unique_direction',
  ['orderId', 'raterOrganizationId', 'rateeOrganizationId'],
  { unique: true }
)
@Index('idx_project_counterparty_ratings_project', ['projectId', 'submittedAt'])
@Entity({ name: 'project_counterparty_ratings' })
export class ProjectCounterpartyRatingEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'order_id', type: 'varchar', length: 64 })
  orderId!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'rater_organization_id', type: 'varchar', length: 64 })
  raterOrganizationId!: string;

  @Column({ name: 'ratee_organization_id', type: 'varchar', length: 64 })
  rateeOrganizationId!: string;

  @Column({ name: 'rater_user_id', type: 'varchar', length: 64 })
  raterUserId!: string;

  @Column({ name: 'rater_actor_id', type: 'varchar', length: 64, nullable: true })
  raterActorId!: string | null;

  @Column({ name: 'score_value', type: 'integer' })
  scoreValue!: number;

  @Column({ name: 'score_label', type: 'varchar', length: 32 })
  scoreLabel!: string;

  @Column({ name: 'comment_text', type: 'text', nullable: true })
  commentText!: string | null;

  @Column({ name: 'rating_state', type: 'varchar', length: 32, default: 'submitted' })
  ratingState!: string;

  @Column({ name: 'submitted_at', type: 'timestamptz' })
  submittedAt!: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
