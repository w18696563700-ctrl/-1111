import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'login_otp_codes' })
export class LoginOtpCodeEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ type: 'varchar', length: 32 })
  mobile!: string;

  @Column({ name: 'otp_code_hash', type: 'varchar', length: 256 })
  otpCodeHash!: string;

  @Column({ type: 'varchar', length: 32 })
  scene!: string;

  @Column({ name: 'expires_at', type: 'timestamptz' })
  expiresAt!: Date;

  @Column({ name: 'consumed_at', type: 'timestamptz', nullable: true })
  consumedAt!: Date | null;

  @Column({ name: 'send_ip', type: 'varchar', length: 64, nullable: true })
  sendIp!: string | null;

  @Column({ name: 'send_device_id', type: 'varchar', length: 64, nullable: true })
  sendDeviceId!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
