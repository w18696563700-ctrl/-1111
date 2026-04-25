import { Column, CreateDateColumn, Entity, Index, PrimaryColumn, UpdateDateColumn } from 'typeorm';
import { ContractConfirmationStatus } from '../p0-pay.types';

@Entity({ name: 'contract_confirmations' })
@Index('idx_contract_confirmations_task_bid', ['taskId', 'selectedBidId'])
@Index('idx_contract_confirmations_status', ['contractStatus'])
export class ContractConfirmationEntity {
  @PrimaryColumn({ type: 'varchar', length: 64 })
  id!: string;

  @Column({ name: 'task_id', type: 'varchar', length: 64 })
  taskId!: string;

  @Column({ name: 'selected_bid_id', type: 'varchar', length: 64, nullable: true })
  selectedBidId!: string | null;

  @Column({ name: 'selected_quotation_id', type: 'varchar', length: 64, nullable: true })
  selectedQuotationId!: string | null;

  @Column({ name: 'publisher_organization_id', type: 'varchar', length: 64 })
  publisherOrganizationId!: string;

  @Column({ name: 'factory_organization_id', type: 'varchar', length: 64 })
  factoryOrganizationId!: string;

  @Column({ name: 'final_confirmed_amount', type: 'numeric', precision: 12, scale: 2 })
  finalConfirmedAmount!: string | number;

  @Column({ type: 'varchar', length: 8, default: 'CNY' })
  currency!: string;

  @Column({ name: 'publisher_confirmed_at', type: 'timestamptz', nullable: true })
  publisherConfirmedAt!: Date | null;

  @Column({ name: 'factory_confirmed_at', type: 'timestamptz', nullable: true })
  factoryConfirmedAt!: Date | null;

  @Column({ name: 'contract_status', type: 'varchar', length: 32 })
  contractStatus!: ContractConfirmationStatus;

  @Column({ name: 'contract_file_asset_ids', type: 'jsonb', default: () => "'[]'::jsonb" })
  contractFileAssetIds!: string[];

  @Column({ name: 'platform_service_fee_charge_id', type: 'varchar', length: 64, nullable: true })
  platformServiceFeeChargeId!: string | null;

  @Column({ name: 'request_id', type: 'varchar', length: 64, default: '' })
  requestId!: string;

  @Column({ name: 'trace_id', type: 'varchar', length: 64, default: '' })
  traceId!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
