import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { EntityManager, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { PaymentIdempotencyRecordEntity } from './entities/payment-idempotency-record.entity';
import { InquiryQuoteDepositEntity } from './entities/inquiry-quote-deposit.entity';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { ContractConfirmationEntity } from './entities/contract-confirmation.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import { p0PayIdempotencyConflict, p0PayResourceUnavailable } from './p0-pay.errors';

@Injectable()
export class P0PayIdempotencyRecordService {
  constructor(
    @InjectRepository(PaymentIdempotencyRecordEntity)
    private readonly idempotencyRecordRepository: Repository<PaymentIdempotencyRecordEntity>,
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository: Repository<PlatformServiceFeeAuthorizationEntity>,
    @InjectRepository(InquiryQuoteDepositEntity)
    private readonly inquiryDepositRepository: Repository<InquiryQuoteDepositEntity>,
    @InjectRepository(ContractConfirmationEntity)
    private readonly contractConfirmationRepository: Repository<ContractConfirmationEntity>,
    @InjectRepository(PaymentOrderEntity)
    private readonly paymentOrderRepository: Repository<PaymentOrderEntity>
  ) {}

  async findAuthorization(operationKey: string, scopeKey: string, keyHash: string, requestHash: string) {
    const record = await this.findRecord(operationKey, scopeKey, keyHash);
    if (!record) {
      return null;
    }
    return this.loadAuthorizationFromRecord(null, record, requestHash);
  }

  async findBidServiceFeeAuthorization(operationKey: string, scopeKey: string, keyHash: string, requestHash: string) {
    return this.findAuthorization(operationKey, scopeKey, keyHash, requestHash);
  }

  async findPaymentOrder(operationKey: string, scopeKey: string, keyHash: string, requestHash: string) {
    const record = await this.findRecord(operationKey, scopeKey, keyHash);
    if (!record) {
      return null;
    }
    this.assertSameRequest(record, requestHash);
    const order = await this.paymentOrderRepository.findOneBy({ id: record.resourceId });
    if (!order) {
      throw p0PayResourceUnavailable('Current idempotent payment order resource is unavailable.');
    }
    return order;
  }

  async findInquiryDeposit(operationKey: string, scopeKey: string, keyHash: string, requestHash: string) {
    const record = await this.findRecord(operationKey, scopeKey, keyHash);
    if (!record) {
      return null;
    }
    this.assertSameRequest(record, requestHash);
    const deposit = await this.inquiryDepositRepository.findOneBy({ id: record.resourceId });
    if (!deposit) {
      throw p0PayResourceUnavailable('Current idempotent inquiry deposit resource is unavailable.');
    }
    return deposit;
  }

  async findProjectAuthenticitySincerityOrder(
    operationKey: string,
    scopeKey: string,
    keyHash: string,
    requestHash: string
  ) {
    return this.findInquiryDeposit(operationKey, scopeKey, keyHash, requestHash);
  }

  async findContractConfirmation(operationKey: string, scopeKey: string, keyHash: string, requestHash: string) {
    const record = await this.findRecord(operationKey, scopeKey, keyHash);
    if (!record) {
      return null;
    }
    this.assertSameRequest(record, requestHash);
    const confirmation = await this.contractConfirmationRepository.findOneBy({ id: record.resourceId });
    if (!confirmation) {
      throw p0PayResourceUnavailable('Current idempotent contract confirmation resource is unavailable.');
    }
    return confirmation;
  }

  async findDealConfirmation(operationKey: string, scopeKey: string, keyHash: string, requestHash: string) {
    return this.findContractConfirmation(operationKey, scopeKey, keyHash, requestHash);
  }

  async findRecordInTransaction(
    manager: EntityManager,
    operationKey: string,
    scopeKey: string,
    keyHash: string
  ) {
    return manager.getRepository(PaymentIdempotencyRecordEntity).findOneBy({
      operationKey,
      scopeKey,
      idempotencyKeyHash: keyHash
    });
  }

  async loadAuthorizationFromRecord(
    manager: EntityManager | null,
    record: PaymentIdempotencyRecordEntity,
    requestHash: string
  ) {
    this.assertSameRequest(record, requestHash);
    const repository = manager
      ? manager.getRepository(PlatformServiceFeeAuthorizationEntity)
      : this.authorizationRepository;
    const authorization = await repository.findOneBy({ id: record.resourceId });
    if (!authorization) {
      throw p0PayResourceUnavailable('Current idempotent authorization resource is unavailable.');
    }
    return authorization;
  }

  async save(
    manager: EntityManager,
    input: {
      operationKey: string;
      scopeKey: string;
      idempotencyKeyHash: string;
      requestHash: string;
      resourceType: string;
      resourceId: string;
      context: RequestContext;
    }
  ) {
    await manager.getRepository(PaymentIdempotencyRecordEntity).save({
      id: randomUUID(),
      operationKey: input.operationKey,
      scopeKey: input.scopeKey,
      idempotencyKeyHash: input.idempotencyKeyHash,
      requestHash: input.requestHash,
      resourceType: input.resourceType,
      resourceId: input.resourceId,
      status: 'succeeded',
      requestId: input.context.requestId,
      traceId: input.context.traceId
    });
  }

  private async findRecord(operationKey: string, scopeKey: string, keyHash: string) {
    return this.idempotencyRecordRepository.findOneBy({
      operationKey,
      scopeKey,
      idempotencyKeyHash: keyHash
    });
  }

  private assertSameRequest(record: PaymentIdempotencyRecordEntity, requestHash: string) {
    if (record.requestHash !== requestHash) {
      throw p0PayIdempotencyConflict();
    }
  }
}
