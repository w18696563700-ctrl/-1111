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
import { p0PayPermissionDenied, p0PayResourceUnavailable, p0PayStateConflict } from './p0-pay.errors';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayCommandParser } from './p0-pay-command.parser';
import { P0PayIdempotencyRecordService } from './p0-pay-idempotency-record.service';
import { P0PayIdempotencyService } from './p0-pay-idempotency.service';
import { P0PayPresenter } from './p0-pay.presenter';
import { P0PayServiceFeeFactory } from './p0-pay-service-fee.factory';
import { P0PayPaymentChannel } from './p0-pay.types';

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
      'serviceFeeAuthorization.create',
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
        'serviceFeeAuthorization.create',
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
      'serviceFeeAuthorization.authorizeInit',
      scopeKey,
      idempotencyKeyHash,
      requestHash
    );
    if (existing) {
      return this.presenter.toAuthorizeInitResponse(ownership.authorization, existing);
    }

    const result = await this.dataSource.transaction((manager) =>
      this.createPaymentOrderInTransaction(manager, ownership, command, {
        scopeKey,
        idempotencyKeyHash,
        requestHash,
        context
      })
    );
    return this.presenter.toAuthorizeInitResponse(result.authorization, result.order);
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
    if (!auth || auth.status !== 'pending_authorization') {
      throw p0PayStateConflict('Current service fee authorization cannot be initialized.');
    }
    const existingOrder = await this.resolveExistingOrderForAuthorization(auth, command.payChannel, manager);
    if (existingOrder) {
      return { authorization: auth, order: existingOrder };
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
      throw p0PayStateConflict('Current service fee authorization already has another payment channel.');
    }
    return order;
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
      operationKey: 'serviceFeeAuthorization.create',
      scopeKey,
      idempotencyKeyHash,
      requestHash,
      resourceType: 'platform_service_fee_authorization',
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
      operationKey: 'serviceFeeAuthorization.authorizeInit',
      scopeKey: input.scopeKey,
      idempotencyKeyHash: input.idempotencyKeyHash,
      requestHash: input.requestHash,
      resourceType: 'payment_order',
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
        objectType: 'platform_service_fee_authorization',
        objectId: authorization.id,
        objectNo: project.projectNo,
        action: 'PlatformServiceFeePreauthorizationCreated',
        beforeState: '',
        afterState: authorization.status,
        actorId: actorUserId,
        actorRole: scope.membership.roleKey,
        reason: `taskId=${project.id}; bidId=${bid.id}; estimatedFeeAmount=${authorization.estimatedFeeAmount}`
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
        objectType: 'platform_service_fee_authorization',
        objectId: authorization.id,
        objectNo: ownership.project.projectNo,
        action: 'PlatformServiceFeePreauthorizationInit',
        beforeState: 'pending_authorization',
        afterState: authorization.status,
        actorId: ownership.currentSession.userId,
        actorRole: ownership.scope.membership.roleKey,
        reason: `taskId=${ownership.project.id}; bidId=${ownership.bid.id}; paymentOrderId=${order.id}; channel=${order.paymentChannel}`
      },
      context,
      manager
    );
  }

  private buildCreateScopeKey(taskId: string, bidId: string, factoryOrganizationId: string) {
    return `task:${taskId}:bid:${bidId}:factory:${factoryOrganizationId}`;
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
