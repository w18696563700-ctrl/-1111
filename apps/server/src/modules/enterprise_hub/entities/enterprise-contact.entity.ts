import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'enterprise_contact' })
export class EnterpriseContactEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'contact_name', type: 'varchar', length: 64 })
  contactName!: string;

  @Column({ type: 'varchar', length: 32, nullable: true })
  mobile!: string | null;

  @Column({ type: 'varchar', length: 64, nullable: true })
  wechat!: string | null;

  @Column({ type: 'varchar', length: 32, nullable: true })
  phone!: string | null;

  @Column({ type: 'varchar', length: 128, nullable: true })
  email!: string | null;

  @Column({ type: 'varchar', length: 64, nullable: true })
  position!: string | null;

  @Column({ name: 'is_primary', type: 'boolean', default: false })
  isPrimary!: boolean;

  @Column({ name: 'visible_to_public', type: 'boolean', default: false })
  visibleToPublic!: boolean;
}
