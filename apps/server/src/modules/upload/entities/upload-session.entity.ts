import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'upload_session' })
export class UploadSessionEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'business_type', type: 'varchar', length: 32 })
  businessType!: string;

  @Column({ name: 'business_id', type: 'varchar', length: 64, nullable: true })
  businessId!: string | null;

  @Column({ name: 'file_kind', type: 'varchar', length: 32 })
  fileKind!: string;

  @Column({ name: 'mime_type', type: 'varchar', length: 128 })
  mimeType!: string;

  @Column({ type: 'integer' })
  size!: number;

  @Column({ type: 'varchar', length: 128 })
  checksum!: string;

  @Column({ name: 'object_key', type: 'varchar', length: 255, unique: true })
  objectKey!: string;

  @Column({ name: 'direct_upload_url', type: 'text' })
  directUploadUrl!: string;

  @Column({ name: 'direct_upload_method', type: 'varchar', length: 16, default: 'PUT' })
  directUploadMethod!: string;

  @Column({ name: 'direct_upload_headers', type: 'jsonb', default: () => "'{}'" })
  directUploadHeaders!: Record<string, string>;

  @Column({ name: 'session_status', type: 'varchar', length: 32, default: 'initiated' })
  sessionStatus!: string;

  @Column({ name: 'file_asset_id', type: 'varchar', length: 64, nullable: true })
  fileAssetId!: string | null;

  @Column({ name: 'actor_id', type: 'varchar', length: 64, nullable: true })
  actorId!: string | null;

  @Column({ name: 'user_id', type: 'varchar', length: 64, nullable: true })
  userId!: string | null;

  @Column({ name: 'organization_id', type: 'varchar', length: 64, default: '' })
  organizationId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @Column({ name: 'confirmed_at', type: 'timestamptz', nullable: true })
  confirmedAt!: Date | null;
}
