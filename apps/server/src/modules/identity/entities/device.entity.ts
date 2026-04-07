import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'devices' })
export class DeviceEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'user_id', type: 'varchar', length: 64 })
  userId!: string;

  @Column({ name: 'device_fingerprint', type: 'varchar', length: 256 })
  deviceFingerprint!: string;

  @Column({ name: 'device_name', type: 'varchar', length: 128, nullable: true })
  deviceName!: string | null;

  @Column({ name: 'os_type', type: 'varchar', length: 64, nullable: true })
  osType!: string | null;

  @Column({ name: 'app_version', type: 'varchar', length: 64, nullable: true })
  appVersion!: string | null;

  @Column({ name: 'first_seen_at', type: 'timestamptz' })
  firstSeenAt!: Date;

  @Column({ name: 'last_seen_at', type: 'timestamptz' })
  lastSeenAt!: Date;

  @Column({ name: 'trust_status', type: 'varchar', length: 32 })
  trustStatus!: string;
}
