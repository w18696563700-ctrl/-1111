import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'file_asset' })
export class FileAssetEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'upload_session_id', type: 'varchar', length: 64, unique: true })
  uploadSessionId!: string;

  @Column({ name: 'business_type', type: 'varchar', length: 32 })
  businessType!: string;

  @Column({ name: 'business_id', type: 'varchar', length: 64, nullable: true })
  businessId!: string | null;

  @Column({ name: 'file_kind', type: 'varchar', length: 32 })
  fileKind!: string;

  @Column({ name: 'object_key', type: 'varchar', length: 255, unique: true })
  objectKey!: string;

  @Column({ name: 'mime_type', type: 'varchar', length: 128 })
  mimeType!: string;

  @Column({ type: 'integer' })
  size!: number;

  @Column({ type: 'varchar', length: 128 })
  checksum!: string;

  @Column({ name: 'actor_id', type: 'varchar', length: 64, nullable: true })
  actorId!: string | null;

  @Column({ name: 'user_id', type: 'varchar', length: 64, nullable: true })
  userId!: string | null;

  @Column({ name: 'organization_id', type: 'varchar', length: 64, default: '' })
  organizationId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
