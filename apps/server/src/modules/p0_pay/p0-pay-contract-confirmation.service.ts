import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { readBidAwardTruth } from '../bid_award/bid-award.truth';
import {
  CurrentActorEligibilityService,
  CurrentOrganizationScope
} from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { RequestContext } from '../../shared/request-context';
import { ContractConfirmationEntity } from './entities/contract-confirmation.entity';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { PaymentTransactionEntity } from './entities/payment-transaction.entity';
import { PlatformServiceFeeChargeEntity } from './entities/platform-service-fee-charge.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import { ContractConfirmationCommand } from './p0-pay.commands';
import { p0PayInvalid, p0PayPermissionDenied, p0PayResourceUnavailable, p0PayStateConflict } from './p0-pay.errors';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayCommandParser } from './p0-pay-command.parser';
import { P0PayIdempotencyRecordService } from './p0-pay-idempotency-record.service';
import { P0PayIdempotencyService } from './p0-pay-idempotency.service';
import { P0PayPresenter } from './p0-pay.presenter';
import { P0PayServiceFeeRatePolicy } from './p0-pay-service-fee-rate.policy';
import {
  PLATFORM_PRICING_AUDIT_ACTIONS,
  PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS,
  PLATFORM_PRICING_RESOURCE_TYPES
} from './p0-pay.state';

@Injectable()
export class P0PayContractConfirmationService {
  constructor(
    @InjectRepository(ContractConfirmationEntity)
    private readonly confirmationRepository: Repository<ContractConfirmationEntity>,
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository: Repository<PlatformServiceFeeAuthorizationEntity>,
    @InjectRepository(PlatformServiceFeeChargeEntity)
    private readonly chargeRepository: Repository<PlatformServiceFeeChargeEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly commandParser: P0PayCommandParser,
    private readonly idempotencyService: P0PayIdempotencyService,
    private readonly idempotencyRecordService: P0PayIdempotencyRecordService,
    private readonly auditService: P0PayAuditService,
    private readonly presenter: P0PayPresenter,
    private readonly feeRatePolicy?: P0PayServiceFeeRatePolicy
  ) {}

  async createConfirmation(taskId: string, payload: Record<string, unknown>, context: RequestContext) {
    const result = await this.createConfirmationResult(taskId, payload, context, { chargeOnConfirmed: true });
    return this.presenter.toContractConfirmationResponse(result);
  }

  async createProjectDealConfirmation(projectId: string, payload: Record<string, unknown>, context: RequestContext) {
    const result = await this.createConfirmationResult(projectId, payload, context, { chargeOnConfirmed: false });
    return this.presenter.toDealConfirmationAcceptedResponse({
      ...result,
      serviceFeeCalculation: this.buildDealServiceFeeCalculation(result.confirmation, result.authorization)
    });
  }

  async getProjectDealConfirmation(projectId: string, dealConfirmationId: string, context: RequestContext) {
    const confirmation = await this.confirmationRepository.findOneBy({
      id: dealConfirmationId,
      taskId: projectId
    });
    if (!confirmation) {
      throw p0PayResourceUnavailable('Current deal confirmation is unavailable.');
    }
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.currentSessionVerificationService);
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw p0PayPermissionDenied('Current organization scope is required for deal confirmation.');
    }
    if (
      scope.organization.id !== confirmation.publisherOrganizationId &&
      scope.organization.id !== confirmation.factoryOrganizationId
    ) {
      throw p0PayPermissionDenied('Current organization cannot read this deal confirmation.');
    }
    const [authorization, charge] = await Promise.all([
      confirmation.selectedBidId
        ? this.authorizationRepository.findOne({
            where: { taskId: projectId, bidId: confirmation.selectedBidId },
            order: { updatedAt: 'DESC' }
          })
        : Promise.resolve(null),
      this.chargeRepository.findOneBy({ contractConfirmationId: confirmation.id })
    ]);
    return this.presenter.toDealConfirmationReadModel({
      confirmation,
      authorization,
      charge,
      serviceFeeCalculation: this.buildDealServiceFeeCalculation(confirmation, authorization)
    });
  }

  private async createConfirmationResult(
    taskId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
    options: { chargeOnConfirmed: boolean }
  ) {
    const command = this.commandParser.toContractConfirmationCommand(taskId, payload);
    this.assertFixedPriceCommand(command);
    const ownership = await this.requireContractOwnership(command, context);
    const idempotencyKeyHash = this.idempotencyService.hashKey(command.idempotencyKey);
    const requestHash = this.idempotencyService.hashRequest(command);
    const scopeKey = `task:${command.taskId}:organization:${ownership.scope.organization.id}`;
    const existing = await this.idempotencyRecordService.findContractConfirmation(
      PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.dealConfirmationUpsert,
      scopeKey,
      idempotencyKeyHash,
      requestHash
    );
    if (existing) {
      const charge = await this.chargeRepository.findOneBy({ contractConfirmationId: existing.id });
      return {
        confirmation: existing,
        authorization: ownership.authorization,
        charge
      };
    }

    const result = await this.dataSource.transaction((manager) =>
      this.upsertConfirmation(manager, ownership, command, {
        scopeKey,
        idempotencyKeyHash,
        requestHash,
        context,
        chargeOnConfirmed: options.chargeOnConfirmed
      })
    );
    return result;
  }

  private async upsertConfirmation(
    manager: EntityManager,
    ownership: ContractOwnership,
    command: ContractConfirmationCommand,
    idempotency: {
      scopeKey: string;
      idempotencyKeyHash: string;
      requestHash: string;
      context: RequestContext;
      chargeOnConfirmed: boolean;
    }
  ) {
    const record = await this.idempotencyRecordService.findRecordInTransaction(
      manager,
      PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.dealConfirmationUpsert,
      idempotency.scopeKey,
      idempotency.idempotencyKeyHash
    );
    if (record) {
      const confirmation = await manager.getRepository(ContractConfirmationEntity).findOneBy({ id: record.resourceId });
      if (!confirmation) {
        throw p0PayResourceUnavailable('Current idempotent contract confirmation is unavailable.');
      }
      return this.loadConfirmationResult(manager, confirmation, ownership.authorization);
    }

    const confirmation = await this.resolveConfirmation(manager, ownership, command, idempotency.context);
    await this.idempotencyRecordService.save(manager, {
      operationKey: PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.dealConfirmationUpsert,
      scopeKey: idempotency.scopeKey,
      idempotencyKeyHash: idempotency.idempotencyKeyHash,
      requestHash: idempotency.requestHash,
      resourceType: PLATFORM_PRICING_RESOURCE_TYPES.dealConfirmation,
      resourceId: confirmation.id,
      context: idempotency.context
    });
    await this.recordConfirmationAudit(manager, confirmation, ownership, idempotency.context);
    if (confirmation.contractStatus !== 'confirmed_deal') {
      return this.loadConfirmationResult(manager, confirmation, ownership.authorization);
    }
    if (!idempotency.chargeOnConfirmed) {
      return this.loadConfirmationResult(manager, confirmation, ownership.authorization);
    }
    const charge = await this.ensureCharge(manager, confirmation, ownership, idempotency.context);
    return { confirmation, authorization: ownership.authorization, charge };
  }

  private async resolveConfirmation(
    manager: EntityManager,
    ownership: ContractOwnership,
    command: ContractConfirmationCommand,
    context: RequestContext
  ) {
    const repository = manager.getRepository(ContractConfirmationEntity);
    const existing = await repository.findOne({
      where: { taskId: command.taskId, selectedBidId: command.selectedBidId },
      order: { updatedAt: 'DESC' }
    });
    const confirmation = existing ?? this.buildConfirmation(ownership, command, context);
    this.assertConfirmationCompatible(confirmation, command, ownership);
    this.applyRoleConfirmation(confirmation, command.confirmationRole);
    confirmation.contractStatus =
      confirmation.publisherConfirmedAt && confirmation.factoryConfirmedAt
        ? 'confirmed_deal'
        : 'pending_counterparty_confirm';
    await repository.save(confirmation);
    await this.moveAuthorizationToContractPending(manager, ownership, context);
    return confirmation;
  }

  private async ensureCharge(
    manager: EntityManager,
    confirmation: ContractConfirmationEntity,
    ownership: ContractOwnership,
    context: RequestContext
  ) {
    const chargeRepository = manager.getRepository(PlatformServiceFeeChargeEntity);
    const existing = await chargeRepository.findOneBy({ contractConfirmationId: confirmation.id });
    if (existing) {
      return existing;
    }
    if (!['confirmed_deal', 'confirmed'].includes(confirmation.contractStatus)) {
      throw p0PayStateConflict('Current deal is not confirmed and cannot trigger platform service fee charge.');
    }
    if (!ownership.authorization.paymentChannel) {
      throw p0PayStateConflict('Current service fee authorization has no payment channel to charge.');
    }
    const lockedFeeRate = ownership.authorization.feeRate;
    const feeCalculation = this.requireFeeRatePolicy().calculateDealServiceFee({
      finalConfirmedAmount: confirmation.finalConfirmedAmount,
      membershipTierSnapshot: ownership.authorization.membershipTierSnapshot,
      authorizationQuotaAmount: ownership.authorization.authorizationQuotaAmount
    });
    const chargeId = randomUUID();
    const order = await this.createChargePaymentOrder(
      manager,
      confirmation,
      ownership,
      chargeId,
      feeCalculation.finalFeeAmount,
      context
    );
    const charge = this.chargeRepository.create({
      id: chargeId,
      taskId: confirmation.taskId,
      contractConfirmationId: confirmation.id,
      authorizationId: ownership.authorization.id,
      factoryOrganizationId: ownership.bid.bidderOrganizationId,
      finalConfirmedAmount: confirmation.finalConfirmedAmount,
      feeRate: lockedFeeRate,
      baseFeeAmount: feeCalculation.baseFeeAmount,
      membershipDiscountRate: feeCalculation.membershipDiscountRate,
      capAmount: feeCalculation.capAmount,
      finalFeeAmount: feeCalculation.finalFeeAmount,
      releasedRemainderAmount: feeCalculation.releasedRemainderAmount,
      feeRateLabel: ownership.authorization.feeRateLabel,
      feeRateSource: ownership.authorization.feeRateSource,
      membershipTierSnapshot: ownership.authorization.membershipTierSnapshot,
      feeRateRuleVersion: ownership.authorization.feeRateRuleVersion || ownership.authorization.ruleVersion,
      feeRateSnapshotHash: ownership.authorization.feeRateSnapshotHash || ownership.authorization.ruleSnapshotHash,
      feeCalculatedAt: ownership.authorization.feeCalculatedAt ?? ownership.authorization.agreedAt,
      paymentOrderId: order.id,
      chargeStatus: 'charged',
      chargedAt: new Date(),
      refundedAt: null,
      requestId: context.requestId,
      traceId: context.traceId
    });
    await chargeRepository.save(charge);
    await this.saveChargeTransaction(manager, order, charge);
    confirmation.platformServiceFeeChargeId = charge.id;
    await manager.getRepository(ContractConfirmationEntity).save(confirmation);
    await this.markAuthorizationCharged(manager, ownership.authorization, confirmation, feeCalculation, charge.chargedAt);
    await this.recordChargeAudit(manager, charge, ownership, context);
    return charge;
  }

  private async createChargePaymentOrder(
    manager: EntityManager,
    confirmation: ContractConfirmationEntity,
    ownership: ContractOwnership,
    chargeId: string,
    finalFeeAmount: string,
    context: RequestContext
  ) {
    const order = manager.getRepository(PaymentOrderEntity).create({
      id: randomUUID(),
      businessType: 'platform_service_fee_charge',
      businessId: chargeId,
      taskId: confirmation.taskId,
      bidId: ownership.bid.id,
      payerOrganizationId: ownership.bid.bidderOrganizationId,
      payeeOrganizationId: '',
      amount: finalFeeAmount,
      currency: 'CNY',
      paymentChannel: ownership.authorization.paymentChannel ?? 'other',
      orderRole: 'payment',
      status: 'succeeded',
      merchantOrderNo: this.idempotencyService.buildMerchantOrderNo('P0PAY_CHG'),
      channelOrderId: ownership.authorization.authorizationOrderId,
      idempotencyKeyHash: this.idempotencyService.hashKey(`charge:${confirmation.id}`),
      requestId: context.requestId,
      traceId: context.traceId,
      expiresAt: null
    });
    await manager.getRepository(PaymentOrderEntity).save(order);
    return order;
  }

  private async requireContractOwnership(command: ContractConfirmationCommand, context: RequestContext) {
    const [project, bid] = await Promise.all([
      this.projectRepository.findOneBy({ id: command.taskId }),
      this.bidRepository.findOneBy({ id: command.selectedBidId ?? '', projectId: command.taskId })
    ]);
    if (!project || !bid) {
      throw p0PayResourceUnavailable('Current selected fixed-price bid is unavailable for contract confirmation.');
    }
    const award = readBidAwardTruth(project.summary);
    if (!award || award.winningBidId !== bid.id || bid.state !== 'awarded') {
      throw p0PayStateConflict('Current fixed-price bid has not entered awarded contract confirmation state.');
    }
    const authorization = await this.authorizationRepository.findOne({
      where: { taskId: command.taskId, bidId: bid.id },
      order: { updatedAt: 'DESC' }
    });
    if (!authorization || !['frozen', 'charge_pending', 'authorized', 'pending_contract_confirm'].includes(authorization.status)) {
      throw p0PayStateConflict('Current service fee authorization cannot enter contract confirmation.');
    }
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.currentSessionVerificationService);
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw p0PayPermissionDenied('Current organization scope is required for contract confirmation.');
    }
    this.assertRoleScope(command, project, bid, scope);
    return { project, bid, authorization, scope, currentSession };
  }

  private assertFixedPriceCommand(command: ContractConfirmationCommand) {
    if (!command.selectedBidId || command.selectedQuotationId) {
      throw p0PayInvalid('Current P0-Pay contract confirmation supports fixed-price selectedBidId only.');
    }
  }

  private assertRoleScope(
    command: ContractConfirmationCommand,
    project: ProjectEntity,
    bid: BidEntity,
    scope: CurrentOrganizationScope
  ) {
    if (command.confirmationRole === 'publisher' && scope.organization.id !== project.organizationId) {
      throw p0PayPermissionDenied('Current publisher organization cannot confirm this contract.');
    }
    if (command.confirmationRole === 'factory' && scope.organization.id !== bid.bidderOrganizationId) {
      throw p0PayPermissionDenied('Current factory organization cannot confirm this contract.');
    }
  }

  private buildConfirmation(ownership: ContractOwnership, command: ContractConfirmationCommand, context: RequestContext) {
    return this.confirmationRepository.create({
      id: randomUUID(),
      taskId: command.taskId,
      selectedBidId: command.selectedBidId,
      selectedQuotationId: null,
      publisherOrganizationId: ownership.project.organizationId,
      factoryOrganizationId: ownership.bid.bidderOrganizationId,
      finalConfirmedAmount: command.finalConfirmedAmount,
      currency: 'CNY',
      publisherConfirmedAt: null,
      factoryConfirmedAt: null,
      contractStatus: 'pending_counterparty_confirm',
      contractFileAssetIds: command.contractFileAssetIds,
      platformServiceFeeChargeId: null,
      requestId: context.requestId,
      traceId: context.traceId
    });
  }

  private assertConfirmationCompatible(
    confirmation: ContractConfirmationEntity,
    command: ContractConfirmationCommand,
    ownership: ContractOwnership
  ) {
    if (
      ['confirmed_deal', 'confirmed'].includes(confirmation.contractStatus) ||
      String(confirmation.finalConfirmedAmount) !== command.finalConfirmedAmount ||
      confirmation.factoryOrganizationId !== ownership.bid.bidderOrganizationId
    ) {
      throw p0PayStateConflict('Current contract confirmation is not compatible with this request.');
    }
  }

  private applyRoleConfirmation(confirmation: ContractConfirmationEntity, role: ContractConfirmationCommand['confirmationRole']) {
    if (role === 'publisher' && !confirmation.publisherConfirmedAt) {
      confirmation.publisherConfirmedAt = new Date();
    }
    if (role === 'factory' && !confirmation.factoryConfirmedAt) {
      confirmation.factoryConfirmedAt = new Date();
    }
  }

  private async moveAuthorizationToContractPending(
    manager: EntityManager,
    ownership: ContractOwnership,
    context: RequestContext
  ) {
    if (!['frozen', 'authorized'].includes(ownership.authorization.status)) {
      return;
    }
    const beforeState = ownership.authorization.status;
    ownership.authorization.status = 'charge_pending';
    await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(ownership.authorization);
    await this.auditService.record(
      {
        objectType: PLATFORM_PRICING_RESOURCE_TYPES.bidServiceFeeAuthorization,
        objectId: ownership.authorization.id,
        objectNo: ownership.project.projectNo,
        action: PLATFORM_PRICING_AUDIT_ACTIONS.dealConfirmationSubmitted,
        beforeState,
        afterState: ownership.authorization.status,
        actorId: ownership.currentSession.userId,
        actorRole: ownership.scope.membership.roleKey,
        reason: `projectId=${ownership.project.id}; bidId=${ownership.bid.id}; organizationScope=${ownership.scope.organization.id}`
      },
      context,
      manager
    );
  }

  private async markAuthorizationCharged(
    manager: EntityManager,
    authorization: PlatformServiceFeeAuthorizationEntity,
    confirmation: ContractConfirmationEntity,
    feeCalculation: {
      finalFeeAmount: string;
      releasedRemainderAmount: string;
    },
    chargedAt: Date | null
  ) {
    authorization.finalConfirmedAmount = confirmation.finalConfirmedAmount;
    authorization.finalFeeAmount = feeCalculation.finalFeeAmount;
    authorization.chargedAmountUsed = feeCalculation.finalFeeAmount;
    authorization.releasedAmount = feeCalculation.releasedRemainderAmount;
    authorization.status = 'charged';
    authorization.chargedAt = chargedAt;
    await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(authorization);
  }

  private async saveChargeTransaction(manager: EntityManager, order: PaymentOrderEntity, charge: PlatformServiceFeeChargeEntity) {
    await manager.getRepository(PaymentTransactionEntity).save({
      id: randomUUID(),
      paymentOrderId: order.id,
      transactionType: 'payment',
      paymentChannel: order.paymentChannel,
      channelTransactionId: order.channelOrderId,
      amount: charge.finalFeeAmount,
      requestedAmount: charge.finalFeeAmount,
      confirmedAmount: charge.finalFeeAmount,
      status: 'succeeded',
      channelActionType: 'server_capture',
      channelReference: charge.authorizationId,
      rawStatus: 'captured',
      initiatedAt: charge.chargedAt,
      confirmedAt: charge.chargedAt,
      failedAt: null,
      failureReasonCode: '',
      occurredAt: charge.chargedAt
    });
  }

  private async loadConfirmationResult(
    manager: EntityManager,
    confirmation: ContractConfirmationEntity,
    authorization: PlatformServiceFeeAuthorizationEntity | null
  ) {
    const charge = await manager.getRepository(PlatformServiceFeeChargeEntity).findOneBy({
      contractConfirmationId: confirmation.id
    });
    return { confirmation, authorization, charge };
  }

  private async recordConfirmationAudit(
    manager: EntityManager,
    confirmation: ContractConfirmationEntity,
    ownership: ContractOwnership,
    context: RequestContext
  ) {
    await this.auditService.record(
      {
        objectType: PLATFORM_PRICING_RESOURCE_TYPES.dealConfirmation,
        objectId: confirmation.id,
        objectNo: ownership.project.projectNo,
        action:
          confirmation.contractStatus === 'confirmed_deal'
            ? PLATFORM_PRICING_AUDIT_ACTIONS.dealConfirmationConfirmed
            : PLATFORM_PRICING_AUDIT_ACTIONS.dealConfirmationSubmitted,
        beforeState: '',
        afterState: confirmation.contractStatus,
        actorId: ownership.currentSession.userId,
        actorRole: ownership.scope.membership.roleKey,
        reason: `projectId=${confirmation.taskId}; selectedBidId=${confirmation.selectedBidId}; finalConfirmedAmount=${confirmation.finalConfirmedAmount}; organizationScope=${ownership.scope.organization.id}`
      },
      context,
      manager
    );
  }

  private async recordChargeAudit(
    manager: EntityManager,
    charge: PlatformServiceFeeChargeEntity,
    ownership: ContractOwnership,
    context: RequestContext
  ) {
    await this.auditService.record(
      {
        objectType: 'platform_service_fee_charge',
        objectId: charge.id,
        objectNo: ownership.project.projectNo,
        action: PLATFORM_PRICING_AUDIT_ACTIONS.platformServiceFeeCharged,
        beforeState: 'pending_charge',
        afterState: charge.chargeStatus,
        actorId: ownership.currentSession.userId,
        actorRole: ownership.scope.membership.roleKey,
        reason: `projectId=${charge.taskId}; contractConfirmationId=${charge.contractConfirmationId}; baseFeeAmount=${charge.baseFeeAmount}; membershipDiscountRate=${charge.membershipDiscountRate}; capAmount=${charge.capAmount}; finalFeeAmount=${charge.finalFeeAmount}; releasedRemainderAmount=${charge.releasedRemainderAmount}; organizationScope=${ownership.scope.organization.id}`
      },
      context,
      manager
    );
  }

  private buildDealServiceFeeCalculation(
    confirmation: ContractConfirmationEntity,
    authorization: PlatformServiceFeeAuthorizationEntity | null
  ) {
    const calculation = this.requireFeeRatePolicy().calculateDealServiceFee({
      finalConfirmedAmount: confirmation.finalConfirmedAmount,
      membershipTierSnapshot: authorization?.membershipTierSnapshot ?? 'none',
      authorizationQuotaAmount: authorization?.authorizationQuotaAmount ?? '4000.00'
    });
    return {
      ruleVersion: authorization?.feeRateRuleVersion || authorization?.ruleVersion || 'p0_pay_membership_service_fee_v1',
      baseFeeAmount: Number(calculation.baseFeeAmount),
      membershipTierApplied: authorization?.membershipTierSnapshot ?? null,
      membershipDiscountRate: Number(calculation.membershipDiscountRate),
      capAmount: Number(calculation.capAmount),
      discountedFeeAmount: Number(calculation.finalFeeAmount),
      finalFeeAmount: Number(calculation.finalFeeAmount),
      pricingSnapshotHash: authorization?.feeRateSnapshotHash || authorization?.ruleSnapshotHash || '',
      feeCalculatedAt: (authorization?.feeCalculatedAt ?? authorization?.agreedAt ?? confirmation.updatedAt).toISOString()
    };
  }

  private requireFeeRatePolicy() {
    if (!this.feeRatePolicy) {
      throw p0PayResourceUnavailable('Current platform pricing fee policy is unavailable.');
    }
    return this.feeRatePolicy;
  }
}

type ContractOwnership = { project: ProjectEntity; bid: BidEntity; authorization: PlatformServiceFeeAuthorizationEntity;
  scope: CurrentOrganizationScope; currentSession: VerifiedCurrentSessionContext };
