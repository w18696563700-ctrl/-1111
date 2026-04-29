import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { DataSource, EntityManager, In, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { PaymentTransactionEntity } from './entities/payment-transaction.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import { BidEntity } from '../bid/entities/bid.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { p0PayInvalid } from './p0-pay.errors';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayIdempotencyService } from './p0-pay-idempotency.service';
import {
  PLATFORM_PRICING_AUDIT_ACTIONS,
  PLATFORM_PRICING_PAYMENT_BUSINESS_TYPES,
  PLATFORM_PRICING_RESOURCE_TYPES
} from './p0-pay.state';

type ReleaseReason = 'non_winning_bid' | 'publisher_breach';

@Injectable()
export class P0PayStateActionService {
  constructor(
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository: Repository<PlatformServiceFeeAuthorizationEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    private readonly dataSource: DataSource,
    private readonly auditService: P0PayAuditService,
    private readonly idempotencyService: P0PayIdempotencyService
  ) {}

  releaseNonWinningAuthorizations(taskId: string, winningBidId: string, context: RequestContext) {
    if (!taskId.trim() || !winningBidId.trim()) {
      throw p0PayInvalid('taskId and winningBidId are required for non-winning release.');
    }
    return this.dataSource.transaction(async (manager) => {
      const authorizations = await manager.getRepository(PlatformServiceFeeAuthorizationEntity).find({
        where: {
          taskId: taskId.trim(),
          status: In(['frozen', 'charge_pending', 'authorized', 'pending_contract_confirm'])
        }
      });
      const targets = authorizations.filter((item) => item.bidId !== winningBidId.trim());
      return this.releaseMany(manager, targets, 'non_winning_bid', context);
    });
  }

  releaseForPublisherBreach(taskId: string, bidId: string | null, context: RequestContext) {
    if (!taskId.trim()) {
      throw p0PayInvalid('taskId is required for publisher breach release.');
    }
    return this.dataSource.transaction(async (manager) => {
      await this.markPublisherBreach(manager, taskId.trim(), bidId, context);
      const authorizations = await manager.getRepository(PlatformServiceFeeAuthorizationEntity).find({
        where: {
          taskId: taskId.trim(),
          status: In(['frozen', 'charge_pending', 'authorized', 'pending_contract_confirm', 'breach_hold'])
        }
      });
      const targets = bidId ? authorizations.filter((item) => item.bidId === bidId) : authorizations;
      return this.releaseMany(manager, targets, 'publisher_breach', context);
    });
  }

  holdForFactoryRefusal(taskId: string, bidId: string, context: RequestContext) {
    if (!taskId.trim() || !bidId.trim()) {
      throw p0PayInvalid('taskId and bidId are required for factory refusal hold.');
    }
    return this.dataSource.transaction(async (manager) => {
      const authorization = await manager.getRepository(PlatformServiceFeeAuthorizationEntity).findOne({
        where: {
          taskId: taskId.trim(),
          bidId: bidId.trim(),
          status: In(['frozen', 'charge_pending', 'authorized', 'pending_contract_confirm'])
        },
        order: { updatedAt: 'DESC' }
      });
      if (!authorization) {
        return { action: 'factory_refusal_breach_hold', changed: 0, authorizationIds: [] };
      }
      const bid = await manager.getRepository(BidEntity).findOneBy({
        id: bidId.trim(),
        projectId: taskId.trim()
      });
      const beforeState = authorization.status;
      const now = new Date();
      authorization.status = 'breach_hold';
      authorization.breachHoldReason = 'factory_refusal_requires_breach_rule_adjudication_not_service_fee_charge';
      authorization.breachHeldAt = now;
      await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(authorization);
      if (bid) {
        const bidBeforeState = bid.state;
        bid.state = 'breach_hold';
        await manager.getRepository(BidEntity).save(bid);
        await this.auditService.record(
          {
            objectType: 'bid',
            objectId: bid.id,
            objectNo: bid.projectId,
            action: 'P0PayFactoryRefusalMarked',
            beforeState: bidBeforeState,
            afterState: bid.state,
            reason: 'factory_refusal_requires_breach_hold_not_service_fee_charge'
          },
          context,
          manager
        );
      }
      await this.auditService.record(
        {
          objectType: PLATFORM_PRICING_RESOURCE_TYPES.bidServiceFeeAuthorization,
          objectId: authorization.id,
          objectNo: authorization.taskId,
          action: 'P0PayStateTransitionBlocked',
          beforeState,
          afterState: authorization.status,
          reason: 'factory_refusal_requires_breach_rule_adjudication_not_service_fee_charge'
        },
        context,
        manager
      );
      return {
        action: 'factory_refusal_breach_hold',
        changed: 1,
        authorizationIds: [authorization.id],
        bidId: bid?.id ?? bidId.trim()
      };
    });
  }

  private async markPublisherBreach(
    manager: EntityManager,
    taskId: string,
    bidId: string | null,
    context: RequestContext
  ) {
    const project = await manager.getRepository(ProjectEntity).findOneBy({ id: taskId });
    if (!project) return;
    const beforeState = String(project.state ?? '');
    const summary = project.summary && typeof project.summary === 'object' && !Array.isArray(project.summary)
      ? project.summary
      : {};
    const p0PayTask = summary.p0PayTask && typeof summary.p0PayTask === 'object' && !Array.isArray(summary.p0PayTask)
      ? summary.p0PayTask as Record<string, unknown>
      : {};
    project.summary = {
      ...summary,
      p0PayTask: {
        ...p0PayTask,
        publisherBreach: {
          bidId,
          reasonCode: 'publisher_breach_release',
          creditImpactCandidate: true,
          releasedByRule: true,
          markedAt: new Date().toISOString()
        }
      }
    };
    await manager.getRepository(ProjectEntity).save(project);
    await this.auditService.record(
      {
        objectType: PLATFORM_PRICING_RESOURCE_TYPES.project,
        objectId: project.id,
        objectNo: project.projectNo,
        action: PLATFORM_PRICING_AUDIT_ACTIONS.bidServiceFeeAuthorizationReleaseRequested,
        beforeState,
        afterState: project.state,
        reason: `projectId=${project.id}; bidId=${bidId ?? ''}; releaseReason=publisher_breach`
      },
      context,
      manager
    );
  }

  private async releaseMany(
    manager: EntityManager,
    authorizations: PlatformServiceFeeAuthorizationEntity[],
    reason: ReleaseReason,
    context: RequestContext
  ) {
    const releasedIds: string[] = [];
    for (const authorization of authorizations) {
      const beforeState = authorization.status;
      authorization.status = 'released';
      authorization.releasedAt = new Date();
      if (reason === 'publisher_breach') {
        authorization.refundedAt = authorization.releasedAt;
      }
      await manager.getRepository(PlatformServiceFeeAuthorizationEntity).save(authorization);
      await this.saveReleaseOrder(manager, authorization, reason, context);
      await this.recordReleaseAudit(manager, authorization, beforeState, reason, context);
      releasedIds.push(authorization.id);
    }
    return {
      action: reason === 'non_winning_bid' ? 'release_non_winning_authorizations' : 'publisher_breach_release',
      changed: releasedIds.length,
      authorizationIds: releasedIds
    };
  }

  private async saveReleaseOrder(
    manager: EntityManager,
    authorization: PlatformServiceFeeAuthorizationEntity,
    reason: ReleaseReason,
    context: RequestContext
  ) {
    const order = manager.getRepository(PaymentOrderEntity).create({
      id: randomUUID(),
      businessType: PLATFORM_PRICING_PAYMENT_BUSINESS_TYPES.bidServiceFeeAuthorizationRelease,
      businessId: authorization.id,
      taskId: authorization.taskId,
      bidId: authorization.bidId,
      payerOrganizationId: authorization.factoryOrganizationId,
      payeeOrganizationId: '',
      amount: authorization.authorizationQuotaAmount ?? authorization.estimatedFeeAmount,
      currency: 'CNY',
      paymentChannel: authorization.paymentChannel ?? 'other',
      orderRole: 'release',
      status: 'released',
      merchantOrderNo: this.idempotencyService.buildMerchantOrderNo('P0PAY_REL'),
      channelOrderId: authorization.authorizationOrderId,
      idempotencyKeyHash: this.idempotencyService.hashKey(`${reason}:${authorization.id}`),
      requestId: context.requestId,
      traceId: context.traceId,
      expiresAt: null
    });
    await manager.getRepository(PaymentOrderEntity).save(order);
    await manager.getRepository(PaymentTransactionEntity).save({
      id: randomUUID(),
      paymentOrderId: order.id,
      transactionType: 'release',
      paymentChannel: order.paymentChannel,
      channelTransactionId: order.channelOrderId,
      amount: order.amount,
      requestedAmount: order.amount,
      confirmedAmount: order.amount,
      status: 'succeeded',
      channelActionType: 'unavailable',
      channelReference: reason,
      rawStatus: 'released',
      initiatedAt: authorization.releasedAt,
      confirmedAt: authorization.releasedAt,
      failedAt: null,
      failureReasonCode: '',
      occurredAt: authorization.releasedAt
    });
  }

  private async recordReleaseAudit(
    manager: EntityManager,
    authorization: PlatformServiceFeeAuthorizationEntity,
    beforeState: string,
    reason: ReleaseReason,
    context: RequestContext
  ) {
    await this.auditService.record(
      {
        objectType: PLATFORM_PRICING_RESOURCE_TYPES.bidServiceFeeAuthorization,
        objectId: authorization.id,
        objectNo: authorization.taskId,
        action: PLATFORM_PRICING_AUDIT_ACTIONS.bidServiceFeeAuthorizationReleased,
        beforeState,
        afterState: authorization.status,
        reason
      },
      context,
      manager
    );
  }
}
