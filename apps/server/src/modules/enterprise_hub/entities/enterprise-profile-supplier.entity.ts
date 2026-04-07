import { Column, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'enterprise_profile_supplier' })
export class EnterpriseProfileSupplierEntity {
  @PrimaryColumn({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'supply_categories', type: 'jsonb', default: () => "'[]'" })
  supplyCategories!: string[];

  @Column({ name: 'supply_mode', type: 'jsonb', default: () => "'[]'" })
  supplyMode!: string[];

  @Column({ name: 'core_products_or_services', type: 'jsonb', default: () => "'[]'" })
  coreProductsOrServices!: string[];

  @Column({ name: 'response_sla_desc', type: 'text', nullable: true })
  responseSlaDesc!: string | null;

  @Column({ name: 'stock_status_desc', type: 'text', nullable: true })
  stockStatusDesc!: string | null;

  @Column({ name: 'delivery_range', type: 'text', nullable: true })
  deliveryRange!: string | null;

  @Column({ name: 'aftersales_policy', type: 'text', nullable: true })
  aftersalesPolicy!: string | null;

  @Column({ name: 'partner_cases_desc', type: 'text', nullable: true })
  partnerCasesDesc!: string | null;

  @Column({ name: 'supply_qualification_desc', type: 'text', nullable: true })
  supplyQualificationDesc!: string | null;

  @Column({ name: 'board_score_supplier', type: 'numeric', precision: 5, scale: 2, nullable: true })
  boardScoreSupplier!: number | null;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
