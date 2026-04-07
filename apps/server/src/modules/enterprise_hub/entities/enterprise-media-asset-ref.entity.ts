import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'enterprise_media_asset_ref' })
export class EnterpriseMediaAssetRefEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'owner_type', type: 'varchar', length: 64 })
  ownerType!: string;

  @Column({ name: 'owner_id', type: 'varchar', length: 64 })
  ownerId!: string;

  @Column({ name: 'media_role', type: 'varchar', length: 64 })
  mediaRole!: string;

  @Column({ name: 'file_asset_id', type: 'varchar', length: 64 })
  fileAssetId!: string;

  @Column({ name: 'sort_order', type: 'integer', nullable: true })
  sortOrder!: number | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
