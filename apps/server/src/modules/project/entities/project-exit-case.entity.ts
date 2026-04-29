import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index('idx_project_exit_cases_project_created', ['projectId', 'createdAt'])
@Index('idx_project_exit_cases_project_status', ['projectId', 'status'])
@Index('idx_project_exit_cases_initiator_created', ['initiatorOrganizationId', 'createdAt'])
@Index('idx_project_exit_cases_counterparty_created', ['counterpartyOrganizationId', 'createdAt'])
@Entity({ name: 'project_exit_cases' })
export class ProjectExitCaseEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'order_id', type: 'varchar', length: 64, nullable: true })
  orderId!: string | null;

  @Column({ name: 'contract_id', type: 'varchar', length: 64, nullable: true })
  contractId!: string | null;

  @Column({ name: 'exit_type', type: 'varchar', length: 48 })
  exitType!: string;

  @Column({ type: 'varchar', length: 48 })
  status!: string;

  @Column({ name: 'initiator_organization_id', type: 'varchar', length: 64 })
  initiatorOrganizationId!: string;

  @Column({ name: 'counterparty_organization_id', type: 'varchar', length: 64, nullable: true })
  counterpartyOrganizationId!: string | null;

  @Column({ name: 'breach_party', type: 'varchar', length: 32, nullable: true })
  breachParty!: string | null;

  @Column({ name: 'reason_code', type: 'varchar', length: 64 })
  reasonCode!: string;

  @Column({ name: 'reason_text', type: 'text', nullable: true })
  reasonText!: string | null;

  @Column({ name: 'credit_impact_candidate', type: 'boolean', default: false })
  creditImpactCandidate!: boolean;

  @Column({ name: 'no_automatic_penalty_confirmed', type: 'boolean', default: true })
  noAutomaticPenaltyConfirmed!: boolean;

  @Column({ name: 'requested_at', type: 'timestamptz', nullable: true })
  requestedAt!: Date | null;

  @Column({ name: 'responded_at', type: 'timestamptz', nullable: true })
  respondedAt!: Date | null;

  @Column({ name: 'closed_at', type: 'timestamptz', nullable: true })
  closedAt!: Date | null;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @Column({ name: 'created_by_user_id', type: 'varchar', length: 64, default: '' })
  createdByUserId!: string;

  @Column({ name: 'responded_by_user_id', type: 'varchar', length: 64, nullable: true })
  respondedByUserId!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
