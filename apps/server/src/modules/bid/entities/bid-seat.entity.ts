import { Column, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'bid_seats' })
@Index('idx_bid_seats_project_bid_unique', ['projectId', 'bidId'], { unique: true })
export class BidSeatEntity {
  @PrimaryColumn({ name: 'seat_id', type: 'varchar', length: 64 })
  seatId!: string;

  @Column({ name: 'project_id', type: 'varchar', length: 64 })
  projectId!: string;

  @Column({ name: 'bid_id', type: 'varchar', length: 64 })
  bidId!: string;

  @Column({ type: 'varchar', length: 32, default: 'locked' })
  state!: 'locked' | 'released' | 'timed_out';

  @Column({ name: 'locked_at', type: 'timestamptz' })
  lockedAt!: Date;

  @Column({ name: 'expires_at', type: 'timestamptz' })
  expiresAt!: Date;

  @Column({ name: 'released_at', type: 'timestamptz', nullable: true })
  releasedAt!: Date | null;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
