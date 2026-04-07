import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'enterprise_case' })
export class EnterpriseCaseEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'board_type', type: 'varchar', length: 32 })
  boardType!: string;

  @Column({ type: 'varchar', length: 128 })
  title!: string;

  @Column({ name: 'exhibition_type', type: 'varchar', length: 128, nullable: true })
  exhibitionType!: string | null;

  @Column({ type: 'varchar', length: 128, nullable: true })
  city!: string | null;

  @Column({ name: 'event_time', type: 'date', nullable: true })
  eventTime!: string | null;

  @Column({ type: 'text' })
  summary!: string;

  @Column({ name: 'case_cover_file_asset_id', type: 'varchar', length: 64 })
  caseCoverFileAssetId!: string;

  @Column({ name: 'case_media_file_asset_ids', type: 'jsonb', default: () => "'[]'" })
  caseMediaFileAssetIds!: string[];

  @Column({ name: 'is_featured', type: 'boolean', default: false })
  isFeatured!: boolean;

  @Column({ name: 'sort_order', type: 'integer', nullable: true })
  sortOrder!: number | null;

  @Column({ name: 'case_status', type: 'varchar', length: 32, default: 'draft' })
  caseStatus!: string;

  @Column({ name: 'review_note', type: 'text', nullable: true })
  reviewNote!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
