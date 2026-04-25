import { Column, CreateDateColumn, Entity, Index, PrimaryColumn } from 'typeorm';

@Index('idx_project_album_photos_project_category_order', ['projectId', 'category', 'sortOrder', 'createdAt'])
@Index('idx_project_album_photos_file_asset', ['fileAssetId'])
@Entity({ name: 'project_album_photos' })
export class ProjectAlbumPhotoEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'file_asset_id', type: 'varchar', length: 64 })
  fileAssetId!: string;

  @Column({ type: 'varchar', length: 32 })
  category!: string;

  @Column({ type: 'text', nullable: true })
  caption!: string | null;

  @Column({ name: 'mime_type', type: 'varchar', length: 128 })
  mimeType!: string;

  @Column({ name: 'sort_order', type: 'integer', default: 0 })
  sortOrder!: number;

  @Column({ name: 'photo_state', type: 'varchar', length: 32, default: 'active' })
  photoState!: string;

  @Column({ name: 'uploaded_by_user_id', type: 'varchar', length: 64 })
  uploadedByUserId!: string;

  @Column({ name: 'uploaded_by_actor_id', type: 'varchar', length: 64, nullable: true })
  uploadedByActorId!: string | null;

  @Column({ name: 'uploaded_by_organization_id', type: 'varchar', length: 64 })
  uploadedByOrganizationId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @Column({ name: 'removed_at', type: 'timestamptz', nullable: true })
  removedAt!: Date | null;
}
