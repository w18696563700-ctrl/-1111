import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { NotificationService } from '../notifications/notification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import {
  bidParticipationConflict,
  bidParticipationForbidden,
  bidParticipationInvalid,
  bidParticipationInvalidState,
  bidParticipationUnavailable,
} from './bid-participation-request.errors';
import { BidParticipationRequestPresenter } from './bid-participation-request.presenter';
import { BidParticipationRequestEntity } from './entities/bid-participation-request.entity';

@Injectable()
export class BidParticipationRequestWriteService {
  constructor(
    @InjectRepository(BidParticipationRequestEntity)
    private readonly requestRepository: Repository<BidParticipationRequestEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly dataSource: DataSource,
    private readonly sessionVerifier: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: BidParticipationRequestPresenter,
    private readonly notificationService: NotificationService,
  ) {}

  async createRequest(payload: Record<string, unknown>, context: RequestContext) {
    const projectId = this.readRequiredProjectId(payload.projectId);
    const project = await this.projectRepository.findOneBy({ id: projectId });
    if (!project || project.publishedAt == null || project.state !== 'published') {
      throw bidParticipationUnavailable('当前项目暂不可申请参与竞标。');
    }

    const { currentSession, scope } =
      await this.eligibilityService.requireBidSubmitEligibilityFromContext(
        context,
        this.sessionVerifier,
        project,
      );
    const organizationId = scope.organization.id;

    const existingRequests = await this.requestRepository.find({
      where: {
        projectId: project.id,
        requesterOrganizationId: organizationId,
      },
      order: { createdAt: 'DESC' },
      take: 8,
    });
    const activePending = existingRequests.find((item) => item.state === 'pending');
    if (activePending) {
      throw bidParticipationConflict('当前主体已有待审核的参与竞标申请。');
    }
    const approved = existingRequests.find((item) => item.state === 'approved');
    if (approved) {
      throw bidParticipationConflict('当前主体已通过参与竞标申请。');
    }

    const request = this.requestRepository.create({
      id: randomUUID(),
      projectId: project.id,
      requesterOrganizationId: organizationId,
      requestedByUserId: currentSession.userId,
      requestedByActorId: currentSession.actorId,
      state: 'pending',
      reviewedByUserId: null,
      reviewedByActorId: null,
      reviewedAt: null,
    });

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(BidParticipationRequestEntity).save(request);
      await this.notificationService.createBidParticipationRequestCreatedNotification(
        request,
        project,
        manager,
      );
      await this.recordAudit(manager.getRepository(IdentityAuditLogEntity), {
        objectType: 'bid_participation_request',
        objectId: request.id,
        objectNo: project.projectNo,
        action: 'BidParticipationRequested',
        actorId: currentSession.userId,
        actorRole: context.actorRole.trim() || 'requester',
        beforeState: '',
        afterState: request.state,
        reason: `projectId=${project.id}; requesterOrganizationId=${organizationId}`,
        context,
      });
    });

    return this.presenter.toRequestAcceptedResponse(request);
  }

  async approveRequest(projectId: string | undefined, requestId: string | undefined, context: RequestContext) {
    return this.reviewRequest(projectId, requestId, 'approved', context);
  }

  async rejectRequest(projectId: string | undefined, requestId: string | undefined, context: RequestContext) {
    return this.reviewRequest(projectId, requestId, 'rejected', context);
  }

  private async reviewRequest(
    projectId: string | undefined,
    requestId: string | undefined,
    nextState: 'approved' | 'rejected',
    context: RequestContext,
  ) {
    const normalizedProjectId = this.readRequiredId(projectId, 'projectId');
    const normalizedRequestId = this.readRequiredId(requestId, 'requestId');
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    const scope = await this.eligibilityService.requireProjectPublishEligibility(currentSession);
    const project = await this.projectRepository.findOneBy({ id: normalizedProjectId });
    if (!project || project.state === 'archived') {
      throw bidParticipationUnavailable('当前项目暂不可处理参与竞标申请。');
    }
    if (scope.organization.id !== project.organizationId) {
      throw bidParticipationForbidden('当前主体暂无参与竞标申请审批权限。');
    }

    const request = await this.requestRepository.findOneBy({
      id: normalizedRequestId,
      projectId: normalizedProjectId,
    });
    if (!request) {
      throw bidParticipationUnavailable('当前参与竞标申请不可用。');
    }
    if (request.state !== 'pending') {
      throw bidParticipationInvalidState('当前参与竞标申请状态已变更，不能重复审批。');
    }

    request.state = nextState;
    request.reviewedByUserId = currentSession.userId;
    request.reviewedByActorId = currentSession.actorId;
    request.reviewedAt = new Date();

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(BidParticipationRequestEntity).save(request);
      await this.recordAudit(manager.getRepository(IdentityAuditLogEntity), {
        objectType: 'bid_participation_request',
        objectId: request.id,
        objectNo: project.projectNo,
        action:
          nextState === 'approved'
            ? 'BidParticipationApproved'
            : 'BidParticipationRejected',
        actorId: currentSession.userId,
        actorRole: context.actorRole.trim() || 'project_owner',
        beforeState: 'pending',
        afterState: nextState,
        reason: `projectId=${project.id}; requesterOrganizationId=${request.requesterOrganizationId}`,
        context,
      });
    });

    return {
      requestId: request.id,
      projectId: project.id,
      status: request.state,
    };
  }

  private readRequiredProjectId(value: unknown) {
    if (typeof value !== 'string' || !value.trim()) {
      throw bidParticipationInvalid('Field `projectId` is required.');
    }
    return value.trim();
  }

  private readRequiredId(value: string | undefined, fieldName: string) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw bidParticipationInvalid(`Field \`${fieldName}\` is required.`);
    }
    return normalized;
  }

  private async recordAudit(
    repository: Repository<IdentityAuditLogEntity>,
    input: {
      objectType: string;
      objectId: string;
      objectNo: string;
      action: string;
      actorId: string;
      actorRole: string;
      beforeState: string;
      afterState: string;
      reason: string;
      context: RequestContext;
    },
  ) {
    await repository.save(
      repository.create({
        id: randomUUID(),
        objectType: input.objectType,
        objectId: input.objectId,
        objectNo: input.objectNo,
        action: input.action,
        actorId: input.actorId.trim() || null,
        actorRole: input.actorRole,
        beforeState: input.beforeState,
        afterState: input.afterState,
        reason: input.reason,
        requestId: input.context.requestId,
        traceId: input.context.traceId,
      }),
    );
  }
}
