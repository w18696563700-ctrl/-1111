import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'content_safety_rules' })
export class ContentSafetyRuleEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'rule_key', type: 'varchar', length: 128, unique: true })
  ruleKey!: string;

  @Column({ name: 'rule_type', type: 'varchar', length: 32 })
  ruleType!: string;

  @Column({ name: 'field_scope', type: 'varchar', length: 64 })
  fieldScope!: string;

  @Column({ name: 'match_mode', type: 'varchar', length: 32 })
  matchMode!: string;

  @Column({ type: 'text' })
  pattern!: string;

  @Column({ type: 'varchar', length: 32 })
  decision!: string;

  @Column({ name: 'reason_code', type: 'varchar', length: 64 })
  reasonCode!: string;

  @Column({ name: 'reason_text', type: 'text' })
  reasonText!: string;

  @Column({ name: 'engine_type', type: 'varchar', length: 16, default: 'rule' })
  engineType!: string;

  @Column({ type: 'boolean', default: true })
  enabled!: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
