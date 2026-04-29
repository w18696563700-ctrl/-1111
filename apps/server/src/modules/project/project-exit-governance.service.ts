import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import {
  CurrentActorEligibilityService,
  CurrentOrganizationScope
} from '../organization/current-actor-eligibility.service';
import { ProjectOrderEntity } from '../order/entities/project-order.entity';
import {
  PROJECT_ORDER_ACTIVE_STATE,
  PROJECT_ORDER_CANCELLED_STATE
} from '../order/project-order.state';
import { PlatformServiceFeeAuthorizationEntity } from '../p0_pay/entities/platform-service-fee-authorization.entity';
import { ProjectExitCaseEntity } from './entities/project-exit-case.entity';
import { ProjectEntity } from './entities/project.entity';
import {
  projectBreachRecordInvalid,
  projectCancellationRequestInvalid,
  projectExitInvalidState,
  projectSubmittedDiscardInvalid,
  projectUnavailable,
  projectWithdrawPublishedInvalid
} from './project.errors';
import {
  ACTIVE_CASE_STATUSES,
  buildProjectExitSummary,
  PROJECT_ARCHIVED_STATE,
  PROJECT_AWARDED_STATE,
  PROJECT_CONVERTED_TO_ORDER_STATE,
  PROJECT_PUBLISHED_STATE,
  PROJECT_SUBMITTED_STATE,
  readOptionalProjectExitString,
  readPenaltySafeProjectExitAction,
  readProjectCancellationResponse,
  readProjectExitAction,
  saveProjectExitCase,
  TERMINAL_AUTHORIZATION_STATES
} from './project-exit-governance.support';

@Injectable()
export class ProjectExitGovernanceService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectOrderEntity)
    private readonly orderRepository: Repository<ProjectOrderEntity>,
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository: Repository<PlatformServiceFeeAuthorizationEntity>,
    @InjectRepository(ProjectExitCaseEntity)
    private readonly exitCaseRepository: Repository<ProjectExitCaseEntity>,
    private readonly dataSource: DataSource,
    private readonly auditService: ProjectPublishAuditService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async discardSubmittedProject(payload: Record<string, unknown>, context: RequestContext) {
    const command = readProjectExitAction(payload, projectSubmittedDiscardInvalid);
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );
    const auditContext = this.buildAuditContext(context, currentSession, scope);
    return this.dataSource.transaction(async (manager) => {
      const project = await this.requireOwnedProject(command.projectId, scope.organization.id, manager);
      if (project.state !== PROJECT_SUBMITTED_STATE) {
        throw projectExitInvalidState('Only submitted projects may be discarded.');
      }
      const previousState = project.state;
      project.state = PROJECT_ARCHIVED_STATE;
      project.summary = buildProjectExitSummary(PROJECT_ARCHIVED_STATE);
      project.publishedAt = null;
      await manager.getRepository(ProjectEntity).save(project);
      const exitCase = await saveProjectExitCase(manager, {
        project,
        currentSession,
        scope,
        exitType: 'submitted_discard',
        status: 'recorded',
        reasonCode: readOptionalProjectExitString(payload.reasonCode) ?? 'no_longer_needed',
        reasonText: readOptionalProjectExitString(payload.reasonText),
        noAutomaticPenaltyConfirmed: true
      });
      await this.recordProjectAudit(manager, 'project_submitted_discarded', project, auditContext, {
        previousState,
        nextState: project.state,
        exitCaseId: exitCase.id,
        reasonCode: exitCase.reasonCode,
        noAutomaticPenalty: true
      });
      return {
        projectId: project.id,
        previousState,
        state: project.state,
        action: 'discard_submitted',
        exitCaseId: exitCase.id
      };
    });
  }

  async withdrawPublishedProject(payload: Record<string, unknown>, context: RequestContext) {
    const command = readProjectExitAction(payload, projectWithdrawPublishedInvalid);
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );
    const auditContext = this.buildAuditContext(context, currentSession, scope);
    return this.dataSource.transaction(async (manager) => {
      const project = await this.requireOwnedProject(command.projectId, scope.organization.id, manager);
      if (project.state === PROJECT_AWARDED_STATE || project.state === PROJECT_CONVERTED_TO_ORDER_STATE) {
        throw projectExitInvalidState('Active projects must use the cancellation or breach chain.');
      }
      if (project.state !== PROJECT_PUBLISHED_STATE) {
        throw projectExitInvalidState('Only published projects may be withdrawn to submitted.');
      }
      const bidCount = await manager.getRepository(BidEntity).count({ where: { projectId: project.id } });
      const authorizations = await manager.getRepository(PlatformServiceFeeAuthorizationEntity).find({
        where: { taskId: project.id }
      });
      const cancelledPendingAuthorizationIds = await this.cancelUninitializedPendingAuthorizations(
        manager,
        authorizations
      );
      const blockingAuthorizations = authorizations.filter(
        (authorization) => !TERMINAL_AUTHORIZATION_STATES.has(String(authorization.status))
      );
      if (blockingAuthorizations.length > 0) {
        throw projectExitInvalidState(
          'Current project has frozen bid service fee authorization records and must release them before withdrawal.'
        );
      }

      const previousState = project.state;
      project.state = PROJECT_SUBMITTED_STATE;
      project.summary = buildProjectExitSummary(PROJECT_SUBMITTED_STATE);
      project.publishedAt = null;
      await manager.getRepository(ProjectEntity).save(project);
      const exitCase = await saveProjectExitCase(manager, {
        project,
        currentSession,
        scope,
        exitType: 'published_withdrawal',
        status: 'recorded',
        reasonCode: readOptionalProjectExitString(payload.reasonCode) ?? 'content_needs_revision',
        reasonText: readOptionalProjectExitString(payload.reasonText),
        noAutomaticPenaltyConfirmed: true
      });
      await this.recordProjectAudit(manager, 'project_published_withdrawn_to_submitted', project, auditContext, {
        previousState,
        nextState: project.state,
        exitCaseId: exitCase.id,
        affectedBidCount: bidCount,
        affectedAuthorizationCount: authorizations.length,
        cancelledPendingAuthorizationIds,
        cancelledPendingAuthorizationCount: cancelledPendingAuthorizationIds.length,
        noAutomaticPenalty: true
      });
      return {
        projectId: project.id,
        previousState,
        state: project.state,
        action: 'withdraw_published_to_submitted',
        affectedBidCount: bidCount,
        affectedAuthorizationCount: authorizations.length,
        cancelledPendingAuthorizationCount: cancelledPendingAuthorizationIds.length,
        exitCaseId: exitCase.id
      };
    });
  }

  async requestCancellation(payload: Record<string, unknown>, context: RequestContext) {
    const command = readPenaltySafeProjectExitAction(payload, projectCancellationRequestInvalid);
    const { currentSession, scope } = await this.requireCurrentScope(context);
    const auditContext = this.buildAuditContext(context, currentSession, scope);
    return this.dataSource.transaction(async (manager) => {
      const project = await this.requireProject(command.projectId, manager);
      this.ensureActiveProject(project);
      const order = await this.requireParticipantOrder(manager, project.id, scope.organization.id, command.orderId);
      await this.ensureNoOpenCancellationCase(manager, project.id);
      const exitCase = await saveProjectExitCase(manager, {
        project,
        currentSession,
        scope,
        order,
        exitType: 'mutual_cancellation',
        status: 'requested',
        counterpartyOrganizationId: this.counterpartyOrganizationId(order, scope.organization.id),
        reasonCode: readOptionalProjectExitString(payload.reasonCode) ?? 'mutual_change',
        reasonText: readOptionalProjectExitString(payload.reasonText),
        requestedAt: new Date(),
        noAutomaticPenaltyConfirmed: true
      });
      await this.recordProjectAudit(manager, 'project_cancellation_requested', project, auditContext, {
        exitCaseId: exitCase.id,
        projectState: project.state,
        caseStatus: exitCase.status,
        noAutomaticPenalty: true
      });
      return {
        projectId: project.id,
        exitCaseId: exitCase.id,
        projectState: project.state,
        caseStatus: 'requested',
        action: 'request_cancellation',
        initiatedByOrganizationId: scope.organization.id,
        counterpartyOrganizationId: exitCase.counterpartyOrganizationId
      };
    });
  }

  async respondCancellation(payload: Record<string, unknown>, context: RequestContext) {
    const command = readProjectCancellationResponse(payload);
    const { currentSession, scope } = await this.requireCurrentScope(context);
    const auditContext = this.buildAuditContext(context, currentSession, scope);
    return this.dataSource.transaction(async (manager) => {
      const project = await this.requireProject(command.projectId, manager);
      const exitCase = await this.requireExitCase(command.exitCaseId, project.id, manager);
      if (exitCase.exitType !== 'mutual_cancellation' || exitCase.status !== 'requested') {
        throw projectExitInvalidState('Current cancellation case is not awaiting response.');
      }
      if (exitCase.counterpartyOrganizationId !== scope.organization.id) {
        throw authPermissionInsufficient('Current organization is not the cancellation counterparty.');
      }
      const acceptedOrder =
        command.decision === 'accept'
          ? await this.requireActiveCancellationOrder(manager, project.id, exitCase.orderId)
          : null;
      const previousProjectState = project.state;
      const previousOrderState = acceptedOrder?.state ?? null;
      exitCase.status = command.decision === 'accept' ? 'accepted' : 'rejected';
      exitCase.respondedAt = new Date();
      exitCase.respondedByUserId = currentSession.userId;
      exitCase.closedAt = exitCase.respondedAt;
      await manager.getRepository(ProjectExitCaseEntity).save(exitCase);
      if (acceptedOrder) {
        project.state = PROJECT_SUBMITTED_STATE;
        project.summary = buildProjectExitSummary(PROJECT_SUBMITTED_STATE);
        project.publishedAt = null;
        acceptedOrder.state = PROJECT_ORDER_CANCELLED_STATE;
        await manager.getRepository(ProjectEntity).save(project);
        await manager.getRepository(ProjectOrderEntity).save(acceptedOrder);
      }
      const action = command.decision === 'accept' ? 'accept_cancellation' : 'reject_cancellation';
      await this.recordProjectAudit(
        manager,
        command.decision === 'accept'
          ? 'project_cancellation_accepted'
          : 'project_cancellation_rejected',
        project,
        auditContext,
        {
          exitCaseId: exitCase.id,
          projectState: project.state,
          caseStatus: exitCase.status,
          previousProjectState,
          nextProjectState: project.state,
          orderId: acceptedOrder?.id ?? exitCase.orderId,
          previousOrderState,
          nextOrderState: acceptedOrder?.state ?? previousOrderState,
          noAutomaticPenalty: true
        }
      );
      return {
        projectId: project.id,
        exitCaseId: exitCase.id,
        projectState: project.state,
        caseStatus: exitCase.status,
        action,
        orderId: acceptedOrder?.id ?? exitCase.orderId,
        orderState: acceptedOrder?.state ?? previousOrderState
      };
    });
  }

  recordPublisherBreach(payload: Record<string, unknown>, context: RequestContext) {
    return this.recordBreach(payload, context, 'publisher');
  }

  recordFactoryBreach(payload: Record<string, unknown>, context: RequestContext) {
    return this.recordBreach(payload, context, 'factory');
  }

  private async recordBreach(
    payload: Record<string, unknown>,
    context: RequestContext,
    breachParty: 'publisher' | 'factory'
  ) {
    const command = readPenaltySafeProjectExitAction(payload, projectBreachRecordInvalid);
    const { currentSession, scope } = await this.requireCurrentScope(context);
    const auditContext = this.buildAuditContext(context, currentSession, scope);
    return this.dataSource.transaction(async (manager) => {
      const project = await this.requireProject(command.projectId, manager);
      this.ensureActiveProject(project);
      const order = await this.requireParticipantOrder(manager, project.id, scope.organization.id, command.orderId);
      const exitCase = await saveProjectExitCase(manager, {
        project,
        currentSession,
        scope,
        order,
        exitType: breachParty === 'publisher' ? 'publisher_breach' : 'factory_breach',
        status: 'recorded',
        counterpartyOrganizationId: this.counterpartyOrganizationId(order, scope.organization.id),
        breachParty,
        reasonCode: readOptionalProjectExitString(payload.reasonCode) ?? `${breachParty}_breach`,
        reasonText: readOptionalProjectExitString(payload.reasonText),
        creditImpactCandidate: true,
        noAutomaticPenaltyConfirmed: true,
        closedAt: new Date()
      });
      await this.recordProjectAudit(
        manager,
        breachParty === 'publisher'
          ? 'project_publisher_breach_recorded'
          : 'project_factory_breach_recorded',
        project,
        auditContext,
        {
          exitCaseId: exitCase.id,
          breachParty,
          projectState: project.state,
          caseStatus: exitCase.status,
          creditImpactCandidate: true,
          noAutomaticPenalty: true
        }
      );
      return {
        projectId: project.id,
        exitCaseId: exitCase.id,
        projectState: project.state,
        caseStatus: 'recorded',
        breachParty,
        action: breachParty === 'publisher' ? 'record_publisher_breach' : 'record_factory_breach',
        creditImpactCandidate: true
      };
    });
  }

  private async requireCurrentScope(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw authPermissionInsufficient('Current actor lacks the required organization scope.');
    }
    return { currentSession, scope };
  }

  private async requireOwnedProject(projectId: string, organizationId: string, manager: EntityManager) {
    const project = await manager.getRepository(ProjectEntity).findOneBy({ id: projectId, organizationId });
    if (!project) {
      throw projectUnavailable('Current project is unavailable.');
    }
    return project;
  }

  private async requireProject(projectId: string, manager: EntityManager) {
    const project = await manager.getRepository(ProjectEntity).findOneBy({ id: projectId });
    if (!project) {
      throw projectUnavailable('Current project is unavailable.');
    }
    return project;
  }

  private async requireExitCase(exitCaseId: string, projectId: string, manager: EntityManager) {
    const exitCase = await manager.getRepository(ProjectExitCaseEntity).findOneBy({
      id: exitCaseId,
      projectId
    });
    if (!exitCase) {
      throw projectUnavailable('Current project exit case is unavailable.');
    }
    return exitCase;
  }

  private async requireParticipantOrder(
    manager: EntityManager,
    projectId: string,
    organizationId: string,
    orderId?: string | null
  ) {
    const repository = manager.getRepository(ProjectOrderEntity);
    const order = orderId
      ? await repository.findOneBy({ id: orderId, projectId })
      : await repository.findOneBy({ projectId });
    if (!order) {
      throw projectExitInvalidState('Active project order carrier is unavailable.');
    }
    if (order.buyerOrganizationId !== organizationId && order.sellerOrganizationId !== organizationId) {
      throw authPermissionInsufficient('Current organization is not a participant of this project order.');
    }
    return order;
  }

  private async requireActiveCancellationOrder(
    manager: EntityManager,
    projectId: string,
    orderId: string | null
  ) {
    if (!orderId) {
      throw projectExitInvalidState('Current cancellation case has no order carrier.');
    }
    const order = await manager.getRepository(ProjectOrderEntity).findOneBy({ id: orderId, projectId });
    if (!order) {
      throw projectExitInvalidState('Current cancellation order carrier is unavailable.');
    }
    if (order.state !== PROJECT_ORDER_ACTIVE_STATE) {
      throw projectExitInvalidState('Only active orders may be cancelled by mutual cancellation acceptance.');
    }
    return order;
  }

  private async cancelUninitializedPendingAuthorizations(
    manager: EntityManager,
    authorizations: PlatformServiceFeeAuthorizationEntity[]
  ) {
    const cancelledIds: string[] = [];
    const repository = manager.getRepository(PlatformServiceFeeAuthorizationEntity);
    for (const authorization of authorizations) {
      if (!this.canCancelUninitializedPendingAuthorization(authorization)) {
        continue;
      }
      authorization.status = 'cancelled';
      await repository.save(authorization);
      cancelledIds.push(authorization.id);
    }
    return cancelledIds;
  }

  private canCancelUninitializedPendingAuthorization(authorization: PlatformServiceFeeAuthorizationEntity) {
    return (
      (authorization.status === 'pending_freeze' || authorization.status === 'pending_authorization') &&
      !authorization.paymentOrderId &&
      !authorization.authorizationOrderId &&
      !authorization.authorizedAt &&
      !authorization.frozenAt &&
      !authorization.releasedAt &&
      !authorization.chargedAt
    );
  }

  private async ensureNoOpenCancellationCase(manager: EntityManager, projectId: string) {
    const cases = await manager.getRepository(ProjectExitCaseEntity).find({
      where: { projectId, exitType: 'mutual_cancellation' }
    });
    if (cases.some((item) => ACTIVE_CASE_STATUSES.has(String(item.status)))) {
      throw projectExitInvalidState('Current project already has an open cancellation case.');
    }
  }

  private ensureActiveProject(project: ProjectEntity) {
    if (project.state !== PROJECT_AWARDED_STATE && project.state !== PROJECT_CONVERTED_TO_ORDER_STATE) {
      throw projectExitInvalidState('Only active projects may use cancellation or breach governance.');
    }
  }

  private counterpartyOrganizationId(order: ProjectOrderEntity, organizationId: string) {
    if (order.buyerOrganizationId === organizationId) {
      return order.sellerOrganizationId;
    }
    return order.buyerOrganizationId;
  }

  private recordProjectAudit(
    manager: EntityManager,
    eventType: string,
    project: ProjectEntity,
    context: RequestContext,
    payload: Record<string, unknown>
  ) {
    return this.auditService.record(
      {
        aggregateType: 'project',
        aggregateId: project.id,
        eventType,
        payload: {
          ...payload,
          title: project.title
        }
      },
      context,
      manager
    );
  }

  private buildAuditContext(
    context: RequestContext,
    currentSession: VerifiedCurrentSessionContext,
    scope: CurrentOrganizationScope
  ): RequestContext {
    return {
      ...context,
      actorId: currentSession.actorId,
      userId: currentSession.userId,
      organizationId: scope.organization.id,
      actorRole: scope.membership.roleKey
    };
  }
}
