import { Column, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'enterprise_profile_factory' })
export class EnterpriseProfileFactoryEntity {
  @PrimaryColumn({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'process_types', type: 'jsonb', default: () => "'[]'" })
  processTypes!: string[];

  @Column({ name: 'core_products', type: 'jsonb', default: () => "'[]'" })
  coreProducts!: string[];

  @Column({ name: 'equipment_list', type: 'jsonb', default: () => "'[]'" })
  equipmentList!: string[];

  @Column({ name: 'plant_area_sqm', type: 'integer', nullable: true })
  plantAreaSqm!: number | null;

  @Column({ name: 'monthly_capacity_desc', type: 'text', nullable: true })
  monthlyCapacityDesc!: string | null;

  @Column({ name: 'urgent_order_capability', type: 'varchar', length: 32, nullable: true })
  urgentOrderCapability!: string | null;

  @Column({ name: 'urgent_cycle_desc', type: 'text', nullable: true })
  urgentCycleDesc!: string | null;

  @Column({ name: 'warehouse_capability', type: 'boolean', nullable: true })
  warehouseCapability!: boolean | null;

  @Column({ name: 'transport_capability', type: 'varchar', length: 32, nullable: true })
  transportCapability!: string | null;

  @Column({ name: 'max_order_capacity_desc', type: 'text', nullable: true })
  maxOrderCapacityDesc!: string | null;

  @Column({ name: 'production_qualification_desc', type: 'text', nullable: true })
  productionQualificationDesc!: string | null;

  @Column({ name: 'delivery_radius_desc', type: 'text', nullable: true })
  deliveryRadiusDesc!: string | null;

  @Column({ name: 'board_score_factory', type: 'numeric', precision: 5, scale: 2, nullable: true })
  boardScoreFactory!: number | null;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
