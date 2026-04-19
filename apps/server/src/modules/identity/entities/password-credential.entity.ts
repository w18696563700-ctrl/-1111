import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity({ name: 'password_credentials' })
export class PasswordCredentialEntity {
  @PrimaryColumn({ name: 'user_id', type: 'varchar', length: 64 })
  userId!: string;

  @Column({ name: 'password_hash', type: 'text' })
  passwordHash!: string;

  @Column({ name: 'password_algo', type: 'varchar', length: 64 })
  passwordAlgo!: string;

  @Column({ name: 'password_set_at', type: 'timestamptz' })
  passwordSetAt!: Date;

  @Column({ name: 'password_updated_at', type: 'timestamptz' })
  passwordUpdatedAt!: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
