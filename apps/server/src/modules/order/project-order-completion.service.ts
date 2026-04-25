import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext,
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient, authResourceUnavailable } from '../organization/organization-auth.errors';
import { ProjectOrderEntity } from './entities/project-order.entity';
import { ProjectOrderCompletionPresenter } from './project-order-completion.presenter';
import {
  projectOrderCompleteInvalid,
  projectOrderCompleteInvalidState,
  projectOrderCompleteUnavailable,
} from './project-order.errors';
import {
  PROJECT_ORDER_ACTIVE_STATE,
  PROJECT_ORDER_COMPLETED_STATE,
  PROJECT_ORDER_COMPLETION_CONFIRMED_STATE,
  PROJECT_ORDER_COMPLETION_DISPUTE_RESERVED_STATE,
  PROJECT_ORDER_COMPLETION_REJECTED_STATE,
  PROJECT_ORDER_COMPLETION_REQUESTED_STATE,
} from './project-order.state';

type CompletionActor = {
  currentSession: VerifiedCurrentSessionContext;
  organizationId: string;
  roleKey: string;
};

type CompletionOrderRow = {
  orderId: string;
  orderNo: string | null;
  projectId: string;
  buyerOrganizationId: string | null;
  sellerOrganizationId: string | null;
  state: string | null;
  completionRequestState: string | null;
};

type CompletionRequestCommand = {
  orderId: string;
  note: string | null;
};

type CompletionConfirmCommand = {
  orderId: string;
};

type CompletionRejectCommand = {
  orderId: string;
  reason: string | null;
  reserveDispute: boolean;
};

@Injectable()
export class ProjectOrderCompletionService {
  constructor(
    @InjectRepository(ProjectOrderEntity)
    private readonly orderRepository: Repository<ProjectOrderEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProjectOrderCompletionPresenter,
  ) {}

  async requestCompletion(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCompletionRequestCommand(payload);
    const actor = await this.requireActor(context);

    return this.orderRepository.manager.transaction(async (manager) => {
      const order = await this.fetchOrderForUpdate(manager, command.orderId);
      if (!order) {
        throw projectOrderCompleteUnavailable('Current order is unavailable for completion request.');
      }
      this.requireSeller(order, actor.organizationId);
      if (this.normalizeState(order.state) !== PROJECT_ORDER_ACTIVE_STATE) {
        throw projectOrderCompleteInvalidState('Only active orders may request completion.');
      }

      const currentCompletionState = this.normalizeCompletionState(order.completionRequestState);
      if (currentCompletionState === PROJECT_ORDER_COMPLETION_REQUESTED_STATE) {
        return this.presenter.toCompletionRequestAccepted({
          orderId: order.orderId,
          projectId: order.projectId,
          state: PROJECT_ORDER_ACTIVE_STATE,
          completionRequestState: PROJECT_ORDER_COMPLETION_REQUESTED_STATE,
        });
      }
      if (currentCompletionState === PROJECT_ORDER_COMPLETION_CONFIRMED_STATE) {
        return this.presenter.toCompletionConfirmAccepted({
          orderId: order.orderId,
          projectId: order.projectId,
          state: PROJECT_ORDER_COMPLETED_STATE,
          completionRequestState: PROJECT_ORDER_COMPLETION_CONFIRMED_STATE,
        });
      }

      await manager.query(
        `
          update public.orders
          set
            completion_request_state = $2,
            completion_requested_at = now(),
            completion_requested_by = $3,
            completion_requested_by_organization_id = $4,
            completion_request_note = $5,
            updated_at = now()
          where id = $1
        `,
        [
          order.orderId,
          PROJECT_ORDER_COMPLETION_REQUESTED_STATE,
          this.resolveActorId(actor.currentSession),
          actor.organizationId,
          command.note,
        ],
      );
      await this.recordAudit(manager, order, actor, {
        action: 'OrderCompletionRequested',
        beforeState: currentCompletionState,
        afterState: PROJECT_ORDER_COMPLETION_REQUESTED_STATE,
        reason: `orderId=${order.orderId}`,
        context,
      });

      return this.presenter.toCompletionRequestAccepted({
        orderId: order.orderId,
        projectId: order.projectId,
        state: PROJECT_ORDER_ACTIVE_STATE,
        completionRequestState: PROJECT_ORDER_COMPLETION_REQUESTED_STATE,
      });
    });
  }

  async confirmCompletion(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCompletionConfirmCommand(payload);
    const actor = await this.requireActor(context);

    return this.orderRepository.manager.transaction(async (manager) => {
      const order = await this.fetchOrderForUpdate(manager, command.orderId);
      if (!order) {
        throw projectOrderCompleteUnavailable('Current order is unavailable for completion confirm.');
      }
      this.requireBuyer(order, actor.organizationId);

      if (this.normalizeState(order.state) === PROJECT_ORDER_COMPLETED_STATE) {
        return this.presenter.toCompletionConfirmAccepted({
          orderId: order.orderId,
          projectId: order.projectId,
          state: PROJECT_ORDER_COMPLETED_STATE,
          completionRequestState: PROJECT_ORDER_COMPLETION_CONFIRMED_STATE,
        });
      }
      if (this.normalizeState(order.state) !== PROJECT_ORDER_ACTIVE_STATE) {
        throw projectOrderCompleteInvalidState('Only active orders may be confirmed completed.');
      }
      if (this.normalizeCompletionState(order.completionRequestState) !== PROJECT_ORDER_COMPLETION_REQUESTED_STATE) {
        throw projectOrderCompleteInvalidState('Completion confirm requires a pending completion request.');
      }

      await manager.query(
        `
          update public.orders
          set
            state = $2,
            completed_at = coalesce(completed_at, now()),
            completion_request_state = $3,
            completion_confirmed_at = now(),
            completion_confirmed_by = $4,
            completion_confirmed_by_organization_id = $5,
            updated_at = now()
          where id = $1
            and state = $6
        `,
        [
          order.orderId,
          PROJECT_ORDER_COMPLETED_STATE,
          PROJECT_ORDER_COMPLETION_CONFIRMED_STATE,
          this.resolveActorId(actor.currentSession),
          actor.organizationId,
          PROJECT_ORDER_ACTIVE_STATE,
        ],
      );
      await this.recordAudit(manager, order, actor, {
        action: 'OrderCompleted',
        beforeState: PROJECT_ORDER_ACTIVE_STATE,
        afterState: PROJECT_ORDER_COMPLETED_STATE,
        reason: `completionRequestState=${PROJECT_ORDER_COMPLETION_REQUESTED_STATE}; orderId=${order.orderId}`,
        context,
      });

      return this.presenter.toCompletionConfirmAccepted({
        orderId: order.orderId,
        projectId: order.projectId,
        state: PROJECT_ORDER_COMPLETED_STATE,
        completionRequestState: PROJECT_ORDER_COMPLETION_CONFIRMED_STATE,
      });
    });
  }

  async rejectCompletion(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCompletionRejectCommand(payload);
    const actor = await this.requireActor(context);

    return this.orderRepository.manager.transaction(async (manager) => {
      const order = await this.fetchOrderForUpdate(manager, command.orderId);
      if (!order) {
        throw projectOrderCompleteUnavailable('Current order is unavailable for completion reject.');
      }
      this.requireBuyer(order, actor.organizationId);
      if (this.normalizeState(order.state) !== PROJECT_ORDER_ACTIVE_STATE) {
        throw projectOrderCompleteInvalidState('Only active orders may reject completion.');
      }
      if (this.normalizeCompletionState(order.completionRequestState) !== PROJECT_ORDER_COMPLETION_REQUESTED_STATE) {
        throw projectOrderCompleteInvalidState('Completion reject requires a pending completion request.');
      }

      const targetState = command.reserveDispute
        ? PROJECT_ORDER_COMPLETION_DISPUTE_RESERVED_STATE
        : PROJECT_ORDER_COMPLETION_REJECTED_STATE;
      await manager.query(
        `
          update public.orders
          set
            completion_request_state = $2,
            completion_rejected_at = now(),
            completion_rejected_by = $3,
            completion_rejected_by_organization_id = $4,
            completion_rejection_reason = $5,
            updated_at = now()
          where id = $1
            and state = $6
        `,
        [
          order.orderId,
          targetState,
          this.resolveActorId(actor.currentSession),
          actor.organizationId,
          command.reason,
          PROJECT_ORDER_ACTIVE_STATE,
        ],
      );
      await this.recordAudit(manager, order, actor, {
        action: command.reserveDispute ? 'OrderCompletionDisputeReserved' : 'OrderCompletionRejected',
        beforeState: PROJECT_ORDER_COMPLETION_REQUESTED_STATE,
        afterState: targetState,
        reason: command.reason ?? `orderId=${order.orderId}`,
        context,
      });

      return this.presenter.toCompletionRejectAccepted({
        orderId: order.orderId,
        projectId: order.projectId,
        state: PROJECT_ORDER_ACTIVE_STATE,
        completionRequestState: targetState,
      });
    });
  }

  private async requireActor(context: RequestContext): Promise<CompletionActor> {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw authResourceUnavailable('Current organization scope is unavailable.');
    }
    return {
      currentSession,
      organizationId,
      roleKey: scope?.membership.roleKey ?? '',
    };
  }

  private async fetchOrderForUpdate(manager: EntityManager, orderId: string) {
    const rows = (await manager.query(
      `
        select
          "order".id as "orderId",
          "order".order_no as "orderNo",
          "order".project_id as "projectId",
          "order".buyer_organization_id as "buyerOrganizationId",
          "order".supplier_organization_id as "sellerOrganizationId",
          "order".state as "state",
          coalesce("order".completion_request_state, 'none') as "completionRequestState"
        from public.orders "order"
        where "order".id = $1
        for update
      `,
      [orderId],
    )) as CompletionOrderRow[];
    return rows[0] ?? null;
  }

  private requireSeller(order: CompletionOrderRow, organizationId: string) {
    if (this.normalizeId(order.sellerOrganizationId) !== organizationId) {
      throw authPermissionInsufficient('Only the seller organization may request order completion.');
    }
  }

  private requireBuyer(order: CompletionOrderRow, organizationId: string) {
    if (this.normalizeId(order.buyerOrganizationId) !== organizationId) {
      throw authPermissionInsufficient('Only the buyer organization may continue order completion.');
    }
  }

  private async recordAudit(
    manager: EntityManager,
    order: CompletionOrderRow,
    actor: CompletionActor,
    input: {
      action: string;
      beforeState: string;
      afterState: string;
      reason: string;
      context: RequestContext;
    },
  ) {
    await manager.getRepository(IdentityAuditLogEntity).save({
      id: randomUUID(),
      objectType: 'order',
      objectId: order.orderId,
      objectNo: order.orderNo ?? '',
      action: input.action,
      actorId: actor.currentSession.userId,
      actorRole: actor.roleKey,
      beforeState: input.beforeState,
      afterState: input.afterState,
      reason: input.reason,
      requestId: input.context.requestId,
      traceId: input.context.traceId,
      occurredAt: new Date(),
    });
  }

  private toCompletionRequestCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      orderId: this.readRequiredString(source.orderId, 'orderId'),
      note: this.readOptionalString(source.note),
    } satisfies CompletionRequestCommand;
  }

  private toCompletionConfirmCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      orderId: this.readRequiredString(source.orderId, 'orderId'),
    } satisfies CompletionConfirmCommand;
  }

  private toCompletionRejectCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      orderId: this.readRequiredString(source.orderId, 'orderId'),
      reason: this.readOptionalString(source.reason),
      reserveDispute: source.reserveDispute === true,
    } satisfies CompletionRejectCommand;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw projectOrderCompleteInvalid('Project order completion body must be an object.');
    }
    return value as Record<string, unknown>;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw projectOrderCompleteInvalid(`Field \`${field}\` is required for project order completion.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw projectOrderCompleteInvalid(`Field \`${field}\` is required for project order completion.`);
    }
    return normalized;
  }

  private readOptionalString(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private resolveActorId(currentSession: VerifiedCurrentSessionContext) {
    return this.normalizeId(currentSession.actorId) ?? this.normalizeId(currentSession.userId);
  }

  private normalizeState(value: string | null | undefined) {
    return this.normalizeId(value);
  }

  private normalizeCompletionState(value: string | null | undefined) {
    return this.normalizeId(value) ?? 'none';
  }

  private normalizeId(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}
