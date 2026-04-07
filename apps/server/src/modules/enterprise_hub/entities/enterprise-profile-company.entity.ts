import { Column, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'enterprise_profile_company' })
export class EnterpriseProfileCompanyEntity {
  @PrimaryColumn({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'exhibition_types', type: 'jsonb', default: () => "'[]'" })
  exhibitionTypes!: string[];

  @Column({ name: 'service_items', type: 'jsonb', default: () => "'[]'" })
  serviceItems!: string[];

  @Column({ name: 'service_cities', type: 'jsonb', default: () => "'[]'" })
  serviceCities!: string[];

  @Column({ name: 'team_size', type: 'integer', nullable: true })
  teamSize!: number | null;

  @Column({ name: 'max_project_scale', type: 'varchar', length: 128, nullable: true })
  maxProjectScale!: string | null;

  @Column({ name: 'average_delivery_cycle_days', type: 'integer', nullable: true })
  averageDeliveryCycleDays!: number | null;

  @Column({ name: 'known_clients', type: 'jsonb', default: () => "'[]'" })
  knownClients!: string[];

  @Column({ name: 'qualification_desc', type: 'text', nullable: true })
  qualificationDesc!: string | null;

  @Column({ name: 'project_management_capability', type: 'text', nullable: true })
  projectManagementCapability!: string | null;

  @Column({ name: 'onsite_execution_capability', type: 'text', nullable: true })
  onsiteExecutionCapability!: string | null;

  @Column({ name: 'board_score_company', type: 'numeric', precision: 5, scale: 2, nullable: true })
  boardScoreCompany!: number | null;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
