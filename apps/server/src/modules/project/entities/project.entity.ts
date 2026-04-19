import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'project' })
export class ProjectEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_no', type: 'varchar', length: 64, unique: true })
  projectNo!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64, default: '' })
  organizationId!: string;

  @Column({ name: 'creator_user_id', type: 'varchar', length: 64, nullable: true })
  creatorUserId!: string | null;

  @Column({ name: 'creator_actor_id', type: 'varchar', length: 64, nullable: true })
  creatorActorId!: string | null;

  @Column({ type: 'varchar', length: 128 })
  title!: string;

  @Column({ name: 'exhibition_name', type: 'text', nullable: true })
  exhibitionName!: string | null;

  @Column({ name: 'brand_name', type: 'text', nullable: true })
  brandName!: string | null;

  @Column({ name: 'building_type', type: 'varchar', length: 64 })
  buildingType!: string;

  @Column({ name: 'budget_amount', type: 'numeric', precision: 12, scale: 2 })
  budgetAmount!: string | number;

  @Column({ name: 'area_sqm', type: 'numeric', precision: 10, scale: 2, nullable: true })
  areaSqm!: string | number | null;

  @Column({ name: 'building_type_remark', type: 'varchar', length: 100, nullable: true })
  buildingTypeRemark!: string | null;

  @Column({ name: 'province_code', type: 'text', nullable: true })
  provinceCode!: string | null;

  @Column({ name: 'province_name', type: 'text', nullable: true })
  provinceName!: string | null;

  @Column({ name: 'city_code', type: 'text', nullable: true })
  cityCode!: string | null;

  @Column({ name: 'city_name', type: 'text', nullable: true })
  cityName!: string | null;

  @Column({ name: 'district_code', type: 'text', nullable: true })
  districtCode!: string | null;

  @Column({ name: 'district_name', type: 'text', nullable: true })
  districtName!: string | null;

  @Column({ name: 'detail_address', type: 'text', nullable: true })
  detailAddress!: string | null;

  @Column({ name: 'scope_summary', type: 'text', nullable: true })
  scopeSummary!: string | null;

  @Column({ name: 'planned_start_at', type: 'date', nullable: true })
  plannedStartAt!: string | null;

  @Column({ name: 'planned_end_at', type: 'date', nullable: true })
  plannedEndAt!: string | null;

  @Column({ name: 'schedule_detail', type: 'varchar', length: 200, nullable: true })
  scheduleDetail!: string | null;

  @Column({ type: 'text', nullable: true })
  description!: string | null;

  @Column({ type: 'varchar', length: 32, default: 'published' })
  state!: string;

  @Column({ type: 'jsonb', default: () => "'{}'" })
  summary!: Record<string, unknown>;

  @Column({ name: 'published_at', type: 'timestamptz', nullable: true })
  publishedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
