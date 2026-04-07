import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'enterprise_recommendation_slot' })
export class EnterpriseRecommendationSlotEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'board_type', type: 'varchar', length: 32 })
  boardType!: string;

  @Column({ name: 'slot_position', type: 'integer' })
  slotPosition!: number;

  @Column({ name: 'enterprise_id', type: 'varchar', length: 64 })
  enterpriseId!: string;

  @Column({ name: 'start_at', type: 'timestamptz' })
  startAt!: Date;

  @Column({ name: 'end_at', type: 'timestamptz' })
  endAt!: Date;

  @Column({ name: 'source_type', type: 'varchar', length: 32 })
  sourceType!: string;

  @Column({ name: 'score_snapshot', type: 'numeric', precision: 5, scale: 2, nullable: true })
  scoreSnapshot!: number | null;

  @Column({ name: 'slot_status', type: 'varchar', length: 32, default: 'pending' })
  slotStatus!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
