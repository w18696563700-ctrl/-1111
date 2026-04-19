import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'sessions' })
export class SessionEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64 })
  userId!: string;

  @Column({ name: 'refresh_token_hash', type: 'varchar', length: 256 })
  refreshTokenHash!: string;

  @Column({ name: 'organization_id', type: 'varchar', length: 64, nullable: true })
  organizationId!: string | null;

  @Column({ name: 'device_id', type: 'varchar', length: 64, nullable: true })
  deviceId!: string | null;

  @Column({ name: 'device_name', type: 'varchar', length: 128, nullable: true })
  deviceName!: string | null;

  @Column({ name: 'auth_mode', type: 'varchar', length: 32, default: 'otp_login' })
  authMode!: string;

  @Column({ name: 'issue_reason', type: 'text', nullable: true })
  issueReason!: string | null;

  @Column({ name: 'agreement_version', type: 'varchar', length: 64, nullable: true })
  agreementVersion!: string | null;

  @Column({ name: 'privacy_version', type: 'varchar', length: 64, nullable: true })
  privacyVersion!: string | null;

  @Column({ name: 'agreed_at', type: 'timestamptz', nullable: true })
  agreedAt!: Date | null;

  @Column({ type: 'varchar', length: 64, nullable: true })
  ip!: string | null;

  @Column({ name: 'user_agent', type: 'text', nullable: true })
  userAgent!: string | null;

  @Column({ type: 'varchar', length: 32, default: 'valid' })
  status!: string;

  @Column({ name: 'expires_at', type: 'timestamptz' })
  expiresAt!: Date;

  @Column({ name: 'revoked_at', type: 'timestamptz', nullable: true })
  revokedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
