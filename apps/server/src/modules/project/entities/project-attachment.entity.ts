import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'project_attachments' })
export class ProjectAttachmentEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'file_asset_id', type: 'varchar', length: 64 })
  fileAssetId!: string;

  @Column({ name: 'file_name', type: 'text' })
  fileName!: string;

  @Column({ name: 'attachment_kind', type: 'varchar', length: 32 })
  attachmentKind!: string;

  @Column({ name: 'mime_type', type: 'varchar', length: 128 })
  mimeType!: string;

  @Column({ type: 'varchar', length: 32 })
  visibility!: string;

  @Column({ name: 'sort_order', type: 'integer', default: 0 })
  sortOrder!: number;

  @Column({ name: 'created_by', type: 'varchar', length: 64 })
  createdBy!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
