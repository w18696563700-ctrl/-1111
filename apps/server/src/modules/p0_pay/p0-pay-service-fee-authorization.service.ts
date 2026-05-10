import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import {
  CurrentActorEligibilityService,
  CurrentOrganizationScope
} from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import { AuthorizeInitCommand, CreateAuthorizationCommand } from './p0-pay.commands';
import {
  bidServiceFeeAuthorizationFreezeInitRejected,
  p0PayPermissionDenied,
  p0PayResourceUnavailable,
  p0PayStateConflict
} from './p0-pay.errors';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayCommandParser } from './p0-pay-command.parser';
import { P0PayControlledOtherCallbackService } from './p0-pay-controlled-other-callback.service';
import { P0PayIdempotencyRecordService } from './p0-pay-idempotency-record.service';
import { P0PayIdempotencyService } from './p0-pay-idempotency.service';
import { P0PayPaymentChannelService } from './p0-pay-payment-channel.service';
import { P0PayPresenter } from './p0-pay.presenter';
import { P0PayServiceFeeFactory } from './p0-pay-service-fee.factory';
import {
  PLATFORM_PRICING_AUDIT_ACTIONS,
  PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS,
  PLATFORM_PRICING_RESOURCE_TYPES
} from './p0-pay.state';
import {
  normalizeBidServiceFeeAuthorizationStatus,
  P0PayPaymentChannel,
  P0PayPaymentOrderStatus,
  PlatformServiceFeeAuthorizationStatus
} from './p0-pay.types';

@Injectable()
export class P0PayServiceFeeAuthorizationService {
  constructor(
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository: Repository<PlatformServiceFeeAuthorizationEntity>,
    @InjectRepository(PaymentOrderEntity)
    private readonly paymentOrderRepository: Repository<PaymentOrderEntity>,
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
    private readonly paymentChannelService: P0PayPaymentChannelService,
    private readonly controlledOtherCallbackService: P0PayControlledOtherCallbackService,
    private readonly serviceFeeFactory: P0PayServiceFeeFactory,
    private readonly auditService: P0PayAuditService,
    private readonly presenter: P0PayPresenter
  ) {}

  async createAuthorizationOrder(
    taskId: string,
    bidId: string,
    payload: Record<string, unknown>,
    context: RequestContext
  ) {
    const command = this.commandParser.toCreateCommand(taskId, bidId, payload);
    const { bid, project, scope, currentSession } = await this.requireBidOwnership(command, context);
    const idempotencyKeyHash = this.idempotencyService.hashKey(command.idempotencyKey);
    const requestHash = this.idempotencyService.hashRequest(command);
    const feeRequirement = await this.serviceFeeFactory.assertExpectedAmounts(command, bid);

    const scopeKey = this.buildCreateScopeKey(command.taskId, command.bidId, scope.organization.id);
    const existing = await this.idempotencyRecordService.findAuthorization(
      PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.bidServiceFeeAuthorizationCreate,
      scopeKey,
      idempotencyKeyHash,
      requestHash
    );
    if (existing) {
      return this.presenter.toServiceFeeAuthorizationResponse(existing, null);
    }

    const created = await this.dataSource.transaction(async (manager) => {
      const record = await this.idempotencyRecordService.findRecordInTransaction(
        manager,
        PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.bidServiceFeeAuthorizationCreate,
        scopeKey,
        idempotencyKeyHash
      );
      if (record) {
        return this.idempotencyRecordService.loadAuthorizationFromRecord(manager, record, requestHash);
      }
      const authorization = this.serviceFeeFactory.buildAuthorization({
        bid,
        project,
        currentSession,
        context,
        feeRequirement
      });
      await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(authorization);
      await this.saveAuthorizationIdempotency(manager, scopeKey, idempotencyKeyHash, requestHash, authorization.id, context);
      await this.recordCreatedAudit(manager, authorization, bid, project, scope, currentSession.userId, context);
      return authorization;
    });

    return this.presenter.toServiceFeeAuthorizationResponse(created, null);
  }

  async authorizeInit(
    taskId: string,
    bidId: string,
    authorizationId: string,
    payload: Record<string, unknown>,
    context: RequestContext
  ) {
    const command = this.commandParser.toAuthorizeInitCommand(taskId, bidId, authorizationId, payload);
    const ownership = await this.requireAuthorizationOwnership(command, context);
    const idempotencyKeyHash = this.idempotencyService.hashKey(command.idempotencyKey);
    const requestHash = this.idempotencyService.hashRequest(command);
    const scopeKey = `authorization:${ownership.authorization.id}`;
    const existing = await this.idempotencyRecordService.findPaymentOrder(
      PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.bidServiceFeeAuthorizationFreezeInit,
      scopeKey,
      idempotencyKeyHash,
      requestHash
    );
    if (existing) {
      await this.controlledOtherCallbackService.completeAuthorizationFreezeIfEligible(existing, context);
      const authorization = await this.reloadAuthorization(ownership.authorization.id);
      const action = this.paymentChannelService.buildChannelAction(
        this.toChannelActionInput(existing, command.clientPlatform)
      );
      return this.presenter.toAuthorizeInitResponse(authorization ?? ownership.authorization, existing, action);
    }

    const existingAuthorizationOrder = await this.resolveExistingAuthorizeInitOrder(
      ownership.authorization,
      command.payChannel
    );
    if (existingAuthorizationOrder) {
      await this.controlledOtherCallbackService.completeAuthorizationFreezeIfEligible(existingAuthorizationOrder, context);
      const authorization = await this.reloadAuthorization(ownership.authorization.id);
      const currentAuthorization = authorization ?? ownership.authorization;
      const action = this.isAuthorizationFreezeCompleted(currentAuthorization.status)
        ? this.completedAuthorizationAction(existingAuthorizationOrder, command.clientPlatform)
        : this.paymentChannelService.buildChannelAction(
            this.toChannelActionInput(existingAuthorizationOrder, command.clientPlatform)
          );
      return this.presenter.toAuthorizeInitResponse(currentAuthorization, existingAuthorizationOrder, action);
    }

    const result = await this.dataSource.transaction((manager) =>
      this.createPaymentOrderInTransaction(manager, ownership, command, {
        scopeKey,
        idempotencyKeyHash,
        requestHash,
        context
      })
    );
    await this.controlledOtherCallbackService.completeAuthorizationFreezeIfEligible(result.order, context);
    const action = this.paymentChannelService.buildChannelAction(
      this.toChannelActionInput(result.order, command.clientPlatform)
    );
    return this.presenter.toAuthorizeInitResponse(result.authorization, result.order, action);
  }

  async getAuthorization(taskId: string, bidId: string, authorizationId: string, context: RequestContext) {
    const command = { taskId, bidId, authorizationId };
    const { authorization } = await this.requireAuthorizationReadOwnership(command, context);
    const order = authorization.paymentOrderId
      ? await this.paymentOrderRepository.findOneBy({ id: authorization.paymentOrderId })
      : null;
    return this.presenter.toServiceFeeAuthorizationResponse(authorization, order);
  }

  private async createPaymentOrderInTransaction(
    manager: EntityManager,
    ownership: AuthorizationOwnership,
    command: AuthorizeInitCommand,
    idempotency: {
      scopeKey: string;
      idempotencyKeyHash: string;
      requestHash: string;
      context: RequestContext;
    }
  ) {
    const auth = await manager.getRepository(PlatformServiceFeeAuthorizationEntity).findOneBy({
      id: ownership.authorization.id
    });
    if (!auth) {
      throw p0PayResourceUnavailable('Current service fee authorization is unavailable.');
    }
    const existingOrder = await this.resolveExistingOrderForAuthorization(auth, command.payChannel, manager);
    if (existingOrder) {
      if (!this.canReuseExistingAuthorizeInitOrder(auth.status, existingOrder.status)) {
        throw this.authorizationInitRejected(auth.status);
      }
      return { authorization: auth, order: existingOrder };
    }
    if (auth.status !== 'pending_freeze') {
      throw this.authorizationInitRejected(auth.status);
    }
    const order = this.serviceFeeFactory.buildPaymentOrder({
      authorization: auth,
      command,
      payerOrganizationId: ownership.scope.organization.id,
      context: idempotency.context
    });
    auth.paymentChannel = command.payChannel;
    auth.paymentOrderId = order.id;
    auth.authorizationOrderId = order.merchantOrderNo;
    await manager.getRepository(PaymentOrderEntity).save(order);
    await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(auth);
    await this.savePaymentOrderIdempotency(manager, idempotency, order.id);
    await this.recordInitAudit(manager, auth, order, ownership, idempotency.context);
    return { authorization: auth, order };
  }

  private async requireBidOwnership(
    command: Pick<CreateAuthorizationCommand, 'taskId' | 'bidId'>,
    context: RequestContext
  ) {
    const [bid, project] = await Promise.all([
      this.bidRepository.findOneBy({ id: command.bidId, projectId: command.taskId }),
      this.projectRepository.findOneBy({ id: command.taskId })
    ]);
    if (!bid || !project) {
      throw p0PayResourceUnavailable('Current fixed-price bid is unavailable for service fee authorization.');
    }
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const scope = await this.eligibilityService.requireBidQualifiedScope(currentSession, 'bid submit');
    if (scope.organization.id !== bid.bidderOrganizationId) {
      throw p0PayPermissionDenied('Current organization does not own this fixed-price bid.');
    }
    if (project.state !== 'published' || project.publishedAt === null || bid.state !== 'submitted') {
      throw p0PayStateConflict('Current fixed-price bid is not ready for service fee authorization.');
    }
    return { bid, project, scope, currentSession };
  }

  private async requireAuthorizationOwnership(
    command: Pick<AuthorizeInitCommand, 'taskId' | 'bidId' | 'authorizationId'>,
    context: RequestContext
  ) {
    const ownership = await this.requireBidOwnership(command, context);
    const authorization = await this.authorizationRepository.findOneBy({
      id: command.authorizationId,
      taskId: command.taskId,
      bidId: command.bidId
    });
    if (!authorization) {
      throw p0PayResourceUnavailable('Current service fee authorization is unavailable.');
    }
    if (authorization.factoryOrganizationId !== ownership.scope.organization.id) {
      throw p0PayPermissionDenied('Current organization does not own this service fee authorization.');
    }
    return { ...ownership, authorization };
  }

  private async requireAuthorizationReadOwnership(
    command: Pick<AuthorizeInitCommand, 'taskId' | 'bidId' | 'authorizationId'>,
    context: RequestContext
  ) {
    const [authorization, bid, project] = await Promise.all([
      this.authorizationRepository.findOneBy({
        id: command.authorizationId,
        taskId: command.taskId,
        bidId: command.bidId
      }),
      this.bidRepository.findOneBy({ id: command.bidId, projectId: command.taskId }),
      this.projectRepository.findOneBy({ id: command.taskId })
    ]);
    if (!authorization || !bid || !project) {
      throw p0PayResourceUnavailable('Current service fee authorization is unavailable.');
    }

    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const scope = await this.eligibilityService.requireBidQualifiedScope(currentSession, 'bid submit');
    if (
      scope.organization.id !== authorization.factoryOrganizationId ||
      scope.organization.id !== bid.bidderOrganizationId
    ) {
      throw p0PayPermissionDenied('Current organization does not own this service fee authorization.');
    }

    return { bid, project, scope, currentSession, authorization };
  }

  private async resolveExistingOrderForAuthorization(
    authorization: PlatformServiceFeeAuthorizationEntity,
    payChannel: P0PayPaymentChannel,
    manager: EntityManager
  ) {
    if (!authorization.paymentOrderId) {
      return null;
    }
    const order = await manager.getRepository(PaymentOrderEntity).findOneBy({ id: authorization.paymentOrderId });
    if (!order) {
      throw p0PayResourceUnavailable('Current payment order is unavailable for authorization init.');
    }
    if (order.paymentChannel !== payChannel) {
      throw bidServiceFeeAuthorizationFreezeInitRejected(
        '当前竞标服务费预授权已使用其他支付通道，请刷新状态后继续处理。'
      );
    }
    return order;
  }

  private async resolveExistingAuthorizeInitOrder(
    authorization: PlatformServiceFeeAuthorizationEntity,
    payChannel: P0PayPaymentChannel
  ) {
    if (!authorization.paymentOrderId) {
      if (this.isAuthorizationFreezeCompleted(authorization.status)) {
        return null;
      }
      if (authorization.status !== 'pending_freeze') {
        throw this.authorizationInitRejected(authorization.status);
      }
      return null;
    }
    const order = await this.paymentOrderRepository.findOneBy({ id: authorization.paymentOrderId });
    if (!order) {
      throw p0PayResourceUnavailable('Current payment order is unavailable for authorization init.');
    }
    if (order.paymentChannel !== payChannel) {
      throw bidServiceFeeAuthorizationFreezeInitRejected(
        '当前竞标服务费预授权已使用其他支付通道，请刷新状态后继续处理。'
      );
    }
    if (!this.canReuseExistingAuthorizeInitOrder(authorization.status, order.status)) {
      throw this.authorizationInitRejected(authorization.status);
    }
    return order;
  }

  private canReuseExistingAuthorizeInitOrder(
    authorizationStatus: PlatformServiceFeeAuthorizationStatus,
    orderStatus: P0PayPaymentOrderStatus
  ) {
    if (this.isAuthorizationFreezeCompleted(authorizationStatus)) {
      return orderStatus === 'succeeded';
    }
    if (!this.isAuthorizationFreezeInitOpen(authorizationStatus)) {
      return false;
    }
    return orderStatus === 'created' || orderStatus === 'pending_user_confirm';
  }

  private isAuthorizationFreezeInitOpen(status: PlatformServiceFeeAuthorizationStatus) {
    return status === 'pending_freeze' || status === 'pending_authorization';
  }

  private isAuthorizationFreezeCompleted(status: PlatformServiceFeeAuthorizationStatus) {
    const normalized = normalizeBidServiceFeeAuthorizationStatus(status);
    return normalized === 'frozen';
  }

  private authorizationInitRejected(status: PlatformServiceFeeAuthorizationStatus) {
    const normalized = normalizeBidServiceFeeAuthorizationStatus(status);
    return bidServiceFeeAuthorizationFreezeInitRejected(
      `当前竞标服务费预授权状态为 ${normalized}，暂不能重新拉起支付宝确认，请刷新状态后处理。`
    );
  }

  private async reloadAuthorization(authorizationId: string) {
    return this.authorizationRepository.findOneBy({ id: authorizationId });
  }

  private completedAuthorizationAction(order: PaymentOrderEntity, clientPlatform: string) {
    return {
      channelActionType: 'unavailable' as const,
      channelPayload: {
        provider: order.paymentChannel,
        reasonCode: 'authorization_already_frozen',
        paymentOrderId: order.id,
        merchantOrderNo: order.merchantOrderNo,
        amount: order.amount,
        currency: order.currency,
        clientPlatform,
        callbackAwaiting: false
      },
      callbackAwaiting: false
    };
  }

  private async saveAuthorizationIdempotency(
    manager: EntityManager,
    scopeKey: string,
    idempotencyKeyHash: string,
    requestHash: string,
    authorizationId: string,
    context: RequestContext
  ) {
    await this.idempotencyRecordService.save(manager, {
      operationKey: PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.bidServiceFeeAuthorizationCreate,
      scopeKey,
      idempotencyKeyHash,
      requestHash,
      resourceType: PLATFORM_PRICING_RESOURCE_TYPES.bidServiceFeeAuthorization,
      resourceId: authorizationId,
      context
    });
  }

  private async savePaymentOrderIdempotency(
    manager: EntityManager,
    input: {
      scopeKey: string;
      idempotencyKeyHash: string;
      requestHash: string;
      context: RequestContext;
    },
    orderId: string
  ) {
    await this.idempotencyRecordService.save(manager, {
      operationKey: PLATFORM_PRICING_IDEMPOTENCY_OPERATION_KEYS.bidServiceFeeAuthorizationFreezeInit,
      scopeKey: input.scopeKey,
      idempotencyKeyHash: input.idempotencyKeyHash,
      requestHash: input.requestHash,
      resourceType: PLATFORM_PRICING_RESOURCE_TYPES.paymentOrder,
      resourceId: orderId,
      context: input.context
    });
  }

  private async recordCreatedAudit(
    manager: EntityManager,
    authorization: PlatformServiceFeeAuthorizationEntity,
    bid: BidEntity,
    project: ProjectEntity,
    scope: AuthorizationOwnership['scope'],
    actorUserId: string,
    context: RequestContext
  ) {
    await this.auditService.record(
      {
        objectType: PLATFORM_PRICING_RESOURCE_TYPES.bidServiceFeeAuthorization,
        objectId: authorization.id,
        objectNo: project.projectNo,
        action: PLATFORM_PRICING_AUDIT_ACTIONS.bidServiceFeeAuthorizationCreated,
        beforeState: '',
        afterState: authorization.status,
        actorId: actorUserId,
        actorRole: scope.membership.roleKey,
        reason: `projectId=${project.id}; bidId=${bid.id}; quotaAmount=${authorization.authorizationQuotaAmount}; organizationScope=${scope.organization.id}`
      },
      context,
      manager
    );
  }

  private async recordInitAudit(
    manager: EntityManager,
    authorization: PlatformServiceFeeAuthorizationEntity,
    order: PaymentOrderEntity,
    ownership: AuthorizationOwnership,
    context: RequestContext
  ) {
    await this.auditService.record(
      {
        objectType: PLATFORM_PRICING_RESOURCE_TYPES.bidServiceFeeAuthorization,
        objectId: authorization.id,
        objectNo: ownership.project.projectNo,
        action: PLATFORM_PRICING_AUDIT_ACTIONS.bidServiceFeeAuthorizationFreezeInitIssued,
        beforeState: 'pending_freeze',
        afterState: authorization.status,
        actorId: ownership.currentSession.userId,
        actorRole: ownership.scope.membership.roleKey,
        reason: `projectId=${ownership.project.id}; bidId=${ownership.bid.id}; paymentOrderId=${order.id}; quotaAmount=${order.amount}; organizationScope=${ownership.scope.organization.id}; channel=${order.paymentChannel}`
      },
      context,
      manager
    );
  }

  private buildCreateScopeKey(taskId: string, bidId: string, factoryOrganizationId: string) {
    return `task:${taskId}:bid:${bidId}:factory:${factoryOrganizationId}`;
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
}

type BidOwnership = {
  bid: BidEntity;
  project: ProjectEntity;
  scope: CurrentOrganizationScope;
  currentSession: VerifiedCurrentSessionContext;
};

type AuthorizationOwnership = BidOwnership & {
  authorization: PlatformServiceFeeAuthorizationEntity;
};
