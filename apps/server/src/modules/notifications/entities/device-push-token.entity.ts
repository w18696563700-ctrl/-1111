import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Index('idx_device_push_tokens_user', ['userId'])
@Index('idx_device_push_tokens_org', ['organizationId'])
@Index('idx_device_push_tokens_installation_provider', ['appInstallationId', 'provider'], { unique: true })
@Entity({ name: 'device_push_tokens' })
export class DevicePushTokenEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64 })
  userId!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64, default: '' })
  organizationId!: string;

  @Column({ type: 'varchar', length: 32 })
  platform!: string;

  @Column({ type: 'varchar', length: 32 })
  provider!: string;

  @Column({ name: 'device_token', type: 'text' })
  deviceToken!: string;

  @Column({ name: 'app_installation_id', type: 'varchar', length: 128 })
  appInstallationId!: string;

  @Column({ name: 'app_version', type: 'varchar', length: 64, nullable: true })
  appVersion!: string | null;

  @Column({ name: 'device_label', type: 'varchar', length: 128, nullable: true })
  deviceLabel!: string | null;

  @Column({ name: 'token_state', type: 'varchar', length: 32, default: 'active' })
  tokenState!: string;

  @Column({ name: 'last_registered_at', type: 'timestamptz' })
  lastRegisteredAt!: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
