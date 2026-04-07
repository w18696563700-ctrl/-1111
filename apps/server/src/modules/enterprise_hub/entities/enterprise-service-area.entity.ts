import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'enterprise_service_area' })
export class EnterpriseServiceAreaEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'area_type', type: 'varchar', length: 32 })
  areaType!: string;

  @Column({ name: 'province_code', type: 'varchar', length: 32 })
  provinceCode!: string;

  @Column({ name: 'province_name', type: 'varchar', length: 64 })
  provinceName!: string;

  @Column({ name: 'city_code', type: 'varchar', length: 32, nullable: true })
  cityCode!: string | null;

  @Column({ name: 'city_name', type: 'varchar', length: 64, nullable: true })
  cityName!: string | null;
}
