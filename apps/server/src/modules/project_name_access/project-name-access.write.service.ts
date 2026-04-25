import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectNameAccessRequestEntity } from './entities/project-name-access-request.entity';
import { ProjectNameAccessPresenter } from './project-name-access.presenter';
import {
  projectNameAccessConflict,
  projectNameAccessForbidden,
  projectNameAccessInvalid,
  projectNameAccessInvalidState,
  projectNameAccessUnavailable,
} from './project-name-access.errors';

@Injectable()
export class ProjectNameAccessWriteService {
  constructor(
    @InjectRepository(ProjectNameAccessRequestEntity)
    private readonly requestRepository: Repository<ProjectNameAccessRequestEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly dataSource: DataSource,
    private readonly sessionVerifier: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProjectNameAccessPresenter,
  ) {}

  async createRequest(payload: Record<string, unknown>, context: RequestContext) {
    const projectId = this.readRequiredProjectId(payload.projectId);
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw projectNameAccessForbidden('Current organization scope is required for project name access request.');
    }

    const project = await this.projectRepository.findOneBy({ id: projectId });
    if (!project || project.publishedAt == null || project.state === 'archived') {
      throw projectNameAccessUnavailable('Current project is unavailable.');
    }
    if (project.organizationId === organizationId) {
      throw projectNameAccessConflict('Current organization already owns this project and can view the project name.');
    }

    const existingRequests = await this.requestRepository.find({
      where: {
        projectId: project.id,
        requesterOrganizationId: organizationId,
      },
      order: { createdAt: 'DESC' },
      take: 5,
    });
    const activePending = existingRequests.find((item) => item.state === 'pending');
    if (activePending) {
      throw projectNameAccessConflict('Current organization already has a pending project name access request.');
    }
    const approved = existingRequests.find((item) => item.state === 'approved');
    if (approved) {
      throw projectNameAccessConflict('Current organization already has approved access to the project name.');
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
      await manager.getRepository(ProjectNameAccessRequestEntity).save(request);
      await this.recordAudit(manager.getRepository(IdentityAuditLogEntity), {
        objectType: 'project_name_access_request',
        objectId: request.id,
        objectNo: project.projectNo,
        action: 'ProjectNameAccessRequested',
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
      throw projectNameAccessUnavailable('Current project is unavailable.');
    }
    if (scope.organization.id !== project.organizationId) {
      throw projectNameAccessForbidden('Current actor cannot review project name access for this project.');
    }

    const request = await this.requestRepository.findOneBy({
      id: normalizedRequestId,
      projectId: normalizedProjectId,
    });
    if (!request) {
      throw projectNameAccessUnavailable('Current project name access request is unavailable.');
    }
    if (request.state !== 'pending') {
      throw projectNameAccessInvalidState('Current project name access request is no longer pending.');
    }

    request.state = nextState;
    request.reviewedByUserId = currentSession.userId;
    request.reviewedByActorId = currentSession.actorId;
    request.reviewedAt = new Date();

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(ProjectNameAccessRequestEntity).save(request);
      await this.recordAudit(manager.getRepository(IdentityAuditLogEntity), {
        objectType: 'project_name_access_request',
        objectId: request.id,
        objectNo: project.projectNo,
        action:
          nextState === 'approved'
            ? 'ProjectNameAccessApproved'
            : 'ProjectNameAccessRejected',
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
      throw projectNameAccessInvalid('Field `projectId` is required.');
    }
    return value.trim();
  }

  private readRequiredId(value: string | undefined, fieldName: string) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw projectNameAccessInvalid(`Field \`${fieldName}\` is required.`);
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

