import { Column, CreateDateColumn, Entity, Index, PrimaryColumn } from 'typeorm';

@Index('idx_push_delivery_attempts_notification', ['notificationId'])
@Index('idx_push_delivery_attempts_token', ['deviceTokenId'])
@Entity({ name: 'push_delivery_attempts' })
export class PushDeliveryAttemptEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'notification_id', type: 'varchar', length: 64 })
  notificationId!: string;

  @Column({ name: 'device_token_id', type: 'varchar', length: 64, nullable: true })
  deviceTokenId!: string | null;

  @Column({ type: 'varchar', length: 32 })
  provider!: string;

  @Column({ name: 'attempt_status', type: 'varchar', length: 32 })
  attemptStatus!: string;

  @Column({ name: 'error_code', type: 'varchar', length: 96, nullable: true })
  errorCode!: string | null;

  @Column({ name: 'error_message', type: 'text', nullable: true })
  errorMessage!: string | null;

  @Column({ name: 'attempted_at', type: 'timestamptz' })
  attemptedAt!: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
