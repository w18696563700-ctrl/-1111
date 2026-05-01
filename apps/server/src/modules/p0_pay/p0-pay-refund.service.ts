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
import { p0PayPermissionDenied, p0PayResourceUnavailable, p0PayStateConflict } from './p0-pay.errors';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayCommandParser } from './p0-pay-command.parser';
import { ProjectAuthenticitySincerityRefundCommand } from './p0-pay.commands';
import { P0PayIdempotencyRecordService } from './p0-pay-idempotency-record.service';
import { P0PayIdempotencyService } from './p0-pay-idempotency.service';
import { P0PayPresenter } from './p0-pay.presenter';
import {
  PLATFORM_PRICING_AUDIT_ACTIONS,
  PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS,
  PLATFORM_PRICING_PAYMENT_BUSINESS_TYPES,
  PLATFORM_PRICING_RESOURCE_TYPES
} from './p0-pay.state';

@Injectable()
export class P0PayRefundService {
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
    private readonly auditService: P0PayAuditService,
    private readonly presenter: P0PayPresenter
  ) {}

  async requestProjectAuthenticitySincerityRefund(
    projectId: string,
    orderId: string,
    payload: Record<string, unknown>,
    context: RequestContext
  ) {
    const command = this.commandParser.toProjectAuthenticitySincerityRefundCommand(projectId, orderId, payload);
    const ownership = await this.requireDepositOwnership(command.projectId, command.orderId, context);
    const idempotencyKeyHash = this.idempotencyService.hashKey(command.idempotencyKey);
    const requestHash = this.idempotencyService.hashRequest(command);
    const scopeKey = `deposit:${ownership.deposit.id}:refund`;
    const existing = await this.idempotencyRecordService.findPaymentOrder(
      PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.projectAuthenticitySincerityRefund,
      scopeKey,
      idempotencyKeyHash,
      requestHash
    );
    if (existing) {
      return this.presenter.toInquiryDepositRefundResponse(ownership.deposit, existing);
    }

    const result = await this.dataSource.transaction((manager) =>
      this.createRefundOrder(manager, ownership, command, {
        scopeKey,
        idempotencyKeyHash,
        requestHash,
        context
      })
    );
    return this.presenter.toInquiryDepositRefundResponse(result.deposit, result.refundOrder);
  }

  async getProjectAuthenticitySincerityRefund(projectId: string, orderId: string, context: RequestContext) {
    const ownership = await this.requireDepositOwnership(projectId, orderId, context);
    const refundOrder = await this.findRefundOrder(null, ownership.deposit.id);
    return this.presenter.toInquiryDepositRefundResponse(ownership.deposit, refundOrder);
  }

  private async createRefundOrder(
    manager: EntityManager,
    ownership: RefundOwnership,
    command: ProjectAuthenticitySincerityRefundCommand,
    idempotency: {
      scopeKey: string;
      idempotencyKeyHash: string;
      requestHash: string;
      context: RequestContext;
    }
  ) {
    const depositRepository = manager.getRepository(InquiryQuoteDepositEntity);
    const deposit = await depositRepository.findOneBy({ id: ownership.deposit.id });
    if (!deposit) {
      throw p0PayResourceUnavailable('Current project authenticity sincerity order is unavailable.');
    }
    const existingRefundOrder = await this.findRefundOrder(manager, deposit.id);
    if (existingRefundOrder) {
      await this.saveIdempotency(manager, existingRefundOrder.id, idempotency);
      return { deposit, refundOrder: existingRefundOrder };
    }
    if (deposit.status === 'refunded') {
      return { deposit, refundOrder: null };
    }
    if (deposit.status !== 'paid') {
      throw p0PayStateConflict('Current project authenticity sincerity order is not refundable.');
    }
    const refundOrder = manager.getRepository(PaymentOrderEntity).create({
      id: randomUUID(),
      businessType: PLATFORM_PRICING_PAYMENT_BUSINESS_TYPES.projectAuthenticitySincerityRefund,
      businessId: deposit.id,
      taskId: deposit.taskId,
      bidId: '',
      payerOrganizationId: '',
      payeeOrganizationId: deposit.publisherOrganizationId,
      amount: deposit.amount,
      currency: deposit.currency,
      paymentChannel: deposit.paymentChannel ?? 'other',
      orderRole: 'refund',
      status: 'refund_pending',
      merchantOrderNo: this.idempotencyService.buildMerchantOrderNo('P0PAY_REF'),
      channelOrderId: null,
      idempotencyKeyHash: idempotency.idempotencyKeyHash,
      requestId: idempotency.context.requestId,
      traceId: idempotency.context.traceId,
      expiresAt: null
    });
    const beforeState = deposit.status;
    deposit.status = 'refund_pending';
    deposit.refundRequestedAt = new Date();
    await manager.getRepository(PaymentOrderEntity).save(refundOrder);
    await depositRepository.save(deposit);
    await this.saveIdempotency(manager, refundOrder.id, idempotency);
    await this.recordRefundAudit(
      manager,
      deposit,
      ownership,
      PLATFORM_PRICING_AUDIT_ACTIONS.projectAuthenticitySincerityRefundRequested,
      beforeState,
      deposit.status,
      `reasonCode=${command.refundReasonCode}; reasonText=${command.refundReasonText}`,
      idempotency.context
    );
    return { deposit, refundOrder };
  }

  private async saveIdempotency(
    manager: EntityManager,
    resourceId: string,
    input: {
      scopeKey: string;
      idempotencyKeyHash: string;
      requestHash: string;
      context: RequestContext;
    }
  ) {
    const existing = await this.idempotencyRecordService.findRecordInTransaction(
      manager,
      PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.projectAuthenticitySincerityRefund,
      input.scopeKey,
      input.idempotencyKeyHash
    );
    if (existing) {
      return;
    }
    await this.idempotencyRecordService.save(manager, {
      operationKey: PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.projectAuthenticitySincerityRefund,
      scopeKey: input.scopeKey,
      idempotencyKeyHash: input.idempotencyKeyHash,
      requestHash: input.requestHash,
      resourceType: PLATFORM_PRICING_RESOURCE_TYPES.paymentOrder,
      resourceId,
      context: input.context
    });
  }

  private async findRefundOrder(manager: EntityManager | null, depositId: string) {
    const repository = manager?.getRepository(PaymentOrderEntity) ?? this.paymentOrderRepository;
    return repository.findOne({
      where: {
        businessType: PLATFORM_PRICING_PAYMENT_BUSINESS_TYPES.projectAuthenticitySincerityRefund,
        businessId: depositId
      },
      order: { updatedAt: 'DESC' }
    });
  }

  private async requireDepositOwnership(projectId: string, orderId: string, context: RequestContext) {
    const project = await this.projectRepository.findOneBy({ id: projectId });
    if (!project) {
      throw p0PayResourceUnavailable('Current project is unavailable.');
    }
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.currentSessionVerificationService);
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope || scope.organization.id !== project.organizationId) {
      throw p0PayPermissionDenied('Current organization does not own this project authenticity sincerity order.');
    }
    const deposit = await this.depositRepository.findOneBy({ id: orderId, taskId: projectId });
    if (!deposit) {
      throw p0PayResourceUnavailable('Current project authenticity sincerity order is unavailable.');
    }
    if (deposit.publisherOrganizationId !== scope.organization.id) {
      throw p0PayPermissionDenied('Current organization does not own this project authenticity sincerity order.');
    }
    return { project, scope, currentSession, deposit };
  }

  private async recordRefundAudit(
    manager: EntityManager,
    deposit: InquiryQuoteDepositEntity,
    ownership: RefundOwnership,
    action: string,
    beforeState: string,
    afterState: string,
    reason: string,
    context: RequestContext
  ) {
    await this.auditService.record(
      {
        objectType: PLATFORM_PRICING_RESOURCE_TYPES.projectAuthenticitySincerityOrder,
        objectId: deposit.id,
        objectNo: ownership.project.projectNo,
        action,
        beforeState,
        afterState,
        actorId: ownership.currentSession.userId,
        actorRole: ownership.scope.membership.roleKey,
        reason: `projectId=${deposit.taskId}; amount=${deposit.amount}; ${reason}`
      },
      context,
      manager
    );
  }
}

type RefundOwnership = {
  project: ProjectEntity;
  scope: CurrentOrganizationScope;
  currentSession: VerifiedCurrentSessionContext;
  deposit: InquiryQuoteDepositEntity;
};
