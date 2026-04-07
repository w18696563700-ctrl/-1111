import { Column, CreateDateColumn, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'organization_invitations' })
export class OrganizationInvitationEntity {
  @PrimaryColumn({ type: 'uuid' })
  id!: string;

  @Column({ name: 'organization_id', type: 'uuid' })
  organizationId!: string;

  @Column({ name: 'invite_code', type: 'varchar', length: 128 })
  inviteCode!: string;

  @Column({ name: 'role_key', type: 'varchar', length: 64 })
  roleKey!: string;

  @Column({ name: 'inviter_user_id', type: 'uuid' })
  inviterUserId!: string;

  @Column({ name: 'expires_at', type: 'timestamptz' })
  expiresAt!: Date;

  @Column({ name: 'used_at', type: 'timestamptz', nullable: true })
  usedAt!: Date | null;

  @Column({ name: 'used_by', type: 'uuid', nullable: true })
  usedBy!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
