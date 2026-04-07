import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'user_block_relations' })
@Index('idx_user_block_relations_active_pair', ['blockerUserId', 'blockedUserId'], {
  unique: true,
  where: "relation_status = 'active'"
})
@Index('idx_user_block_relations_blocker_active', ['blockerUserId', 'relationStatus'])
@Index('idx_user_block_relations_blocked_active', ['blockedUserId', 'relationStatus'])
export class UserBlockRelationEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'blocker_user_id', type: 'varchar', length: 64 })
  blockerUserId!: string;

  @Column({ name: 'blocked_user_id', type: 'varchar', length: 64 })
  blockedUserId!: string;

  @Column({ name: 'relation_status', type: 'varchar', length: 32, default: 'active' })
  relationStatus!: string;

  @Column({ name: 'ended_at', type: 'timestamptz', nullable: true })
  endedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
