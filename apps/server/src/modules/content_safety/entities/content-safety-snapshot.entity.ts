import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'content_safety_snapshots' })
export class ContentSafetySnapshotEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'subject_type', type: 'varchar', length: 64 })
  subjectType!: string;

  @Column({ name: 'subject_id', type: 'varchar', length: 64 })
  subjectId!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64 })
  userId!: string;

  @Column({ name: 'content_type', type: 'varchar', length: 64 })
  contentType!: string;

  @Column({ name: 'field_key', type: 'varchar', length: 32 })
  fieldKey!: string;

  @Column({ name: 'current_value', type: 'text', nullable: true })
  currentValue!: string | null;

  @Column({ name: 'proposed_value', type: 'text', nullable: true })
  proposedValue!: string | null;

  @Column({ name: 'file_asset_id', type: 'varchar', length: 64, nullable: true })
  fileAssetId!: string | null;

  @Column({ type: 'jsonb', default: () => "'{}'" })
  metadata!: Record<string, unknown>;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
