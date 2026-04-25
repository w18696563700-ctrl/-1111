import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import {
  CurrentActorEligibilityService,
  CurrentOrganizationScope
} from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { InquiryQuoteDepositEntity } from './entities/inquiry-quote-deposit.entity';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { p0PayInvalid, p0PayPermissionDenied, p0PayResourceUnavailable, p0PayStateConflict } from './p0-pay.errors';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayCommandParser } from './p0-pay-command.parser';
import { CreateInquiryDepositOrderCommand, InquiryDepositPayInitCommand } from './p0-pay.commands';
import { P0PayIdempotencyRecordService } from './p0-pay-idempotency-record.service';
import { P0PayIdempotencyService } from './p0-pay-idempotency.service';
import { P0PayPaymentChannelService } from './p0-pay-payment-channel.service';
import { P0PayPresenter } from './p0-pay.presenter';
import { P0_PAY_INQUIRY_DEPOSIT_AMOUNT } from './p0-pay.state';

@Injectable()
export class P0PayInquiryDepositService {
  constructor(
    @InjectRepository(InquiryQuoteDepositEntity)
    private readonly depositRepository: Repository<InquiryQuoteDepositEntity>,
    @InjectRepository(PaymentOrderEntity)
    private readonly paymentOrderRepository: Repository<PaymentOrderEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly commandParser: P0PayCommandParser,
    private readonly idempotencyService: P0PayIdempotencyService,
    private readonly idempotencyRecordService: P0PayIdempotencyRecordService,
    private readonly paymentChannelService: P0PayPaymentChannelService,
    private readonly auditService: P0PayAuditService,
    private readonly presenter: P0PayPresenter
  ) {}

  async createOrder(taskId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.commandParser.toCreateInquiryDepositOrderCommand(taskId, payload);
    this.assertDepositRule(command);
    const ownership = await this.requirePublisherOwnership(command.taskId, context);
    const idempotencyKeyHash = this.idempotencyService.hashKey(command.idempotencyKey);
    const requestHash = this.idempotencyService.hashRequest(command);
    const scopeKey = `task:${command.taskId}:publisher:${ownership.scope.organization.id}`;
    const existing = await this.idempotencyRecordService.findInquiryDeposit(
      'inquiryDepositOrder.create',
      scopeKey,
      idempotencyKeyHash,
      requestHash
    );
    if (existing) {
      const order = existing.paymentOrderId ? await this.paymentOrderRepository.findOneBy({ id: existing.paymentOrderId }) : null;
      return this.presenter.toInquiryDepositResponse(existing, order);
    }

    const deposit = await this.dataSource.transaction(async (manager) => {
      const duplicate = await this.findActiveDeposit(manager, command.taskId);
      if (duplicate) {
        throw p0PayStateConflict('Current inquiry task already has an active sincerity money order.');
      }
      const created = this.depositRepository.create({
        id: randomUUID(),
        taskId: command.taskId,
        publisherOrganizationId: ownership.scope.organization.id,
        amount: P0_PAY_INQUIRY_DEPOSIT_AMOUNT,
        currency: 'CNY',
        paymentChannel: null,
        paymentOrderId: null,
        status: 'pending_payment',
        ruleVersion: command.ruleVersion,
        ruleSnapshotHash: command.ruleSnapshotHash,
        paidAt: null,
        refundRequestedAt: null,
        refundedAt: null,
        deductedAt: null,
        deductionReason: '',
        requestId: context.requestId,
        traceId: context.traceId
      });
      await manager.getRepository(InquiryQuoteDepositEntity).save(created);
      await this.idempotencyRecordService.save(manager, {
        operationKey: 'inquiryDepositOrder.create',
        scopeKey,
        idempotencyKeyHash,
        requestHash,
        resourceType: 'inquiry_quote_deposit',
        resourceId: created.id,
        context
      });
      await this.recordAudit(manager, created, ownership, 'InquiryDepositOrderCreated', '', created.status, context);
      return created;
    });

    return this.presenter.toInquiryDepositResponse(deposit, null);
  }

  async payInit(taskId: string, depositOrderId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.commandParser.toInquiryDepositPayInitCommand(taskId, depositOrderId, payload);
    const ownership = await this.requireDepositOwnership(command.taskId, command.depositOrderId, context);
    const idempotencyKeyHash = this.idempotencyService.hashKey(command.idempotencyKey);
    const requestHash = this.idempotencyService.hashRequest(command);
    const scopeKey = `deposit:${command.depositOrderId}`;
    const existing = await this.idempotencyRecordService.findPaymentOrder(
      'inquiryDeposit.payInit',
      scopeKey,
      idempotencyKeyHash,
      requestHash
    );
    if (existing) {
      const action = this.paymentChannelService.buildChannelAction(this.toChannelActionInput(existing, command.clientPlatform));
      return this.presenter.toInquiryDepositPayInitResponse(ownership.deposit, existing, action);
    }

    const result = await this.dataSource.transaction((manager) =>
      this.createPaymentOrder(manager, ownership, command, {
        scopeKey,
        idempotencyKeyHash,
        requestHash,
        context
      })
    );
    const action = this.paymentChannelService.buildChannelAction(this.toChannelActionInput(result.order, command.clientPlatform));
    return this.presenter.toInquiryDepositPayInitResponse(result.deposit, result.order, action);
  }

  async getOrder(taskId: string, depositOrderId: string, context: RequestContext) {
    const { deposit } = await this.requireDepositOwnership(taskId, depositOrderId, context);
    const order = deposit.paymentOrderId ? await this.paymentOrderRepository.findOneBy({ id: deposit.paymentOrderId }) : null;
    return this.presenter.toInquiryDepositResponse(deposit, order);
  }

  private async createPaymentOrder(
    manager: EntityManager,
    ownership: InquiryDepositOwnership,
    command: InquiryDepositPayInitCommand,
    idempotency: {
      scopeKey: string;
      idempotencyKeyHash: string;
      requestHash: string;
      context: RequestContext;
    }
  ) {
    const deposit = await manager.getRepository(InquiryQuoteDepositEntity).findOneBy({ id: ownership.deposit.id });
    if (!deposit || deposit.status !== 'pending_payment') {
      throw p0PayStateConflict('Current inquiry sincerity money order cannot initialize payment.');
    }
    if (deposit.paymentOrderId) {
      const existingOrder = await manager.getRepository(PaymentOrderEntity).findOneBy({ id: deposit.paymentOrderId });
      if (existingOrder) {
        return { deposit, order: existingOrder };
      }
    }
    const order = this.paymentOrderRepository.create({
      id: randomUUID(),
      businessType: 'inquiry_deposit',
      businessId: deposit.id,
      taskId: deposit.taskId,
      bidId: '',
      payerOrganizationId: ownership.scope.organization.id,
      payeeOrganizationId: '',
      amount: deposit.amount,
      currency: 'CNY',
      paymentChannel: command.payChannel,
      orderRole: 'payment',
      status: 'pending_user_confirm',
      merchantOrderNo: this.idempotencyService.buildMerchantOrderNo('P0PAY_DEP'),
      channelOrderId: null,
      idempotencyKeyHash: this.idempotencyService.hashKey(command.idempotencyKey),
      requestId: idempotency.context.requestId,
      traceId: idempotency.context.traceId,
      expiresAt: new Date(Date.now() + 30 * 60 * 1000)
    });
    deposit.paymentChannel = command.payChannel;
    deposit.paymentOrderId = order.id;
    await manager.getRepository(PaymentOrderEntity).save(order);
    await manager.getRepository(InquiryQuoteDepositEntity).save(deposit);
    await this.idempotencyRecordService.save(manager, {
      operationKey: 'inquiryDeposit.payInit',
      scopeKey: idempotency.scopeKey,
      idempotencyKeyHash: idempotency.idempotencyKeyHash,
      requestHash: idempotency.requestHash,
      resourceType: 'payment_order',
      resourceId: order.id,
      context: idempotency.context
    });
    await this.recordAudit(manager, deposit, ownership, 'PaymentChannelInitIssued', deposit.status, deposit.status, idempotency.context);
    return { deposit, order };
  }

  private async requirePublisherOwnership(taskId: string, context: RequestContext) {
    const project = await this.projectRepository.findOneBy({ id: taskId });
    if (!project) {
      throw p0PayResourceUnavailable('Current inquiry task is unavailable.');
    }
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.currentSessionVerificationService);
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope || scope.organization.id !== project.organizationId) {
      throw p0PayPermissionDenied('Current organization does not own this inquiry task.');
    }
    return { project, scope, currentSession };
  }

  private async requireDepositOwnership(taskId: string, depositId: string, context: RequestContext) {
    const ownership = await this.requirePublisherOwnership(taskId, context);
    const deposit = await this.depositRepository.findOneBy({ id: depositId, taskId });
    if (!deposit) {
      throw p0PayResourceUnavailable('Current inquiry sincerity money order is unavailable.');
    }
    if (deposit.publisherOrganizationId !== ownership.scope.organization.id) {
      throw p0PayPermissionDenied('Current organization does not own this inquiry sincerity money order.');
    }
    return { ...ownership, deposit };
  }

  private assertDepositRule(command: CreateInquiryDepositOrderCommand) {
    if (command.expectedAmount !== P0_PAY_INQUIRY_DEPOSIT_AMOUNT || command.expectedCurrency !== 'CNY') {
      throw p0PayInvalid('Inquiry sincerity money must be 200.00 CNY.');
    }
  }

  private async findActiveDeposit(manager: EntityManager, taskId: string) {
    return manager.getRepository(InquiryQuoteDepositEntity).findOne({
      where: [
        { taskId, status: 'pending_payment' },
        { taskId, status: 'paid' },
        { taskId, status: 'refund_pending' },
        { taskId, status: 'dispute_hold' }
      ]
    });
  }

  private toChannelActionInput(order: PaymentOrderEntity, clientPlatform: string) {
    return {
      paymentOrderId: order.id,
      merchantOrderNo: order.merchantOrderNo,
      amount: order.amount,
      currency: order.currency,
      channel: order.paymentChannel,
      clientPlatform
    };
  }

  private async recordAudit(
    manager: EntityManager,
    deposit: InquiryQuoteDepositEntity,
    ownership: { project: ProjectEntity; scope: CurrentOrganizationScope; currentSession: VerifiedCurrentSessionContext },
    action: string,
    beforeState: string,
    afterState: string,
    context: RequestContext
  ) {
    await this.auditService.record(
      {
        objectType: 'inquiry_quote_deposit',
        objectId: deposit.id,
        objectNo: ownership.project.projectNo,
        action,
        beforeState,
        afterState,
        actorId: ownership.currentSession.userId,
        actorRole: ownership.scope.membership.roleKey,
        reason: `taskId=${deposit.taskId}; amount=${deposit.amount}; currency=${deposit.currency}`
      },
      context,
      manager
    );
  }
}

type InquiryDepositOwnership = {
  project: ProjectEntity;
  scope: CurrentOrganizationScope;
  currentSession: VerifiedCurrentSessionContext;
  deposit: InquiryQuoteDepositEntity;
};
