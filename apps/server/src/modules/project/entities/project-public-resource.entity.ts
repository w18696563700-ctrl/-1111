import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'project_public_resources' })
export class ProjectPublicResourceEntity {
  @PrimaryColumn({ name: 'resource_id', type: 'varchar', length: 64 })
  resourceId!: string;

  @Column({ name: 'resource_category', type: 'varchar', length: 32 })
  resourceCategory!: string;

  @Column({ type: 'varchar', length: 128 })
  title!: string;

  @Column({ type: 'text', nullable: true })
  summary!: string | null;

  @Column({ name: 'file_asset_id', type: 'varchar', length: 64 })
  fileAssetId!: string;

  @Column({ name: 'file_name', type: 'text' })
  fileName!: string;

  @Column({ name: 'mime_type', type: 'varchar', length: 128 })
  mimeType!: string;

  @Column({ type: 'varchar', length: 32 })
  visibility!: string;

  @Column({ name: 'sort_order', type: 'integer', default: 0 })
  sortOrder!: number;

  @Column({ name: 'published_at', type: 'timestamptz' })
  publishedAt!: Date;

  @Column({ name: 'published_by', type: 'varchar', length: 64 })
  publishedBy!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
