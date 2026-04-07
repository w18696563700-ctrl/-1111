import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'users' })
export class UserEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ type: 'varchar', length: 32 })
  mobile!: string;

  @Column({ name: 'mobile_verified_at', type: 'timestamptz', nullable: true })
  mobileVerifiedAt!: Date | null;

  @Column({ type: 'varchar', length: 128, nullable: true })
  nickname!: string | null;

  @Column({ name: 'avatar_url', type: 'text', nullable: true })
  avatarUrl!: string | null;

  @Column({ name: 'avatar_file_asset_id', type: 'varchar', length: 64, nullable: true })
  avatarFileAssetId!: string | null;

  @Column({ name: 'profile_intro', type: 'text', nullable: true })
  profileIntro!: string | null;

  @Column({ type: 'varchar', length: 32, default: 'new' })
  status!: string;

  @Column({ name: 'last_login_at', type: 'timestamptz', nullable: true })
  lastLoginAt!: Date | null;

  @Column({ name: 'last_login_ip', type: 'varchar', length: 64, nullable: true })
  lastLoginIp!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
