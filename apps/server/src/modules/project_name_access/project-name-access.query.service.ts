import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectNameAccessRequestEntity } from './entities/project-name-access-request.entity';
import { ProjectNameAccessPresenter } from './project-name-access.presenter';
import { ProjectNameAccessProjectionService } from './project-name-access-projection.service';
import {
  projectNameAccessForbidden,
  projectNameAccessInvalid,
  projectNameAccessUnavailable,
} from './project-name-access.errors';

@Injectable()
export class ProjectNameAccessQueryService {
  constructor(
    @InjectRepository(ProjectNameAccessRequestEntity)
    private readonly requestRepository: Repository<ProjectNameAccessRequestEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly sessionVerifier: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProjectNameAccessPresenter,
    private readonly projectionService: ProjectNameAccessProjectionService,
  ) {}

  async listPendingRequests(projectId: string | undefined, context: RequestContext) {
    const project = await this.requireOwnerProject(projectId, context);
    const requests = await this.requestRepository.find({
      where: { projectId: project.id, state: 'pending' },
      order: { createdAt: 'DESC' },
    });
    const organizationIds = [...new Set(requests.map((item) => item.requesterOrganizationId))];
    const userIds = [...new Set(requests.map((item) => item.requestedByUserId))];
    const [organizations, users] = await Promise.all([
      organizationIds.length
        ? this.organizationRepository.findBy({ id: In(organizationIds) })
        : Promise.resolve([]),
      userIds.length ? this.userRepository.findBy({ id: In(userIds) }) : Promise.resolve([]),
    ]);
    const organizationMap = new Map(organizations.map((item) => [item.id, item]));
    const userMap = new Map(users.map((item) => [item.id, item]));
    return this.presenter.toPendingListResponse({
      projectId: project.id,
      items: requests.map((request) => ({
        request,
        requesterOrganization: organizationMap.get(request.requesterOrganizationId) ?? null,
        requesterUser: userMap.get(request.requestedByUserId) ?? null,
      })),
    });
  }

  async getThreadDetail(threadId: string | undefined, context: RequestContext) {
    const normalizedThreadId = this.readRequiredId(threadId, 'threadId');
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw projectNameAccessForbidden('Current organization scope is required for project name access.');
    }

    const request = await this.requestRepository.findOneBy({ id: normalizedThreadId });
    if (!request) {
      throw projectNameAccessUnavailable('Current project name access request is unavailable.');
    }

    const project = await this.projectRepository.findOneBy({ id: request.projectId });
    if (!project || project.publishedAt == null || project.state === 'archived') {
      throw projectNameAccessUnavailable('Current project name access request is unavailable.');
    }

    const isOwnerViewer = project.organizationId === organizationId;
    const isRequesterViewer = request.requesterOrganizationId === organizationId;
    if (!isOwnerViewer && !isRequesterViewer) {
      throw projectNameAccessForbidden('Current actor cannot access this project name access thread.');
    }

    const [requesterOrganization, projection] = await Promise.all([
      this.organizationRepository.findOneBy({ id: request.requesterOrganizationId }),
      this.projectionService.buildSingleProjectProjection({
        project,
        viewerOrganizationId: organizationId,
        isOwnerViewer,
      }),
    ]);

    return this.presenter.toThreadDetail({
      threadId: request.id,
      projectId: project.id,
      request,
      displayTitle: projection.displayTitle,
      requesterOrganizationName:
        requesterOrganization?.name?.trim() || '当前申请组织',
      ownerCanReview: isOwnerViewer,
    });
  }

  private async requireOwnerProject(projectId: string | undefined, context: RequestContext) {
    const normalizedProjectId = this.readRequiredId(projectId, 'projectId');
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    const scope = await this.eligibilityService.requireProjectPublishEligibility(currentSession);
    const project = await this.projectRepository.findOneBy({ id: normalizedProjectId });
    if (!project || project.state === 'archived') {
      throw projectNameAccessUnavailable('Current project is unavailable.');
    }
    if (scope.organization.id !== project.organizationId) {
      throw projectNameAccessForbidden('Current actor cannot review project name access for this project.');
    }
    return project;
  }

  private readRequiredId(value: string | undefined, fieldName: string) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw projectNameAccessInvalid(`Field \`${fieldName}\` is required.`);
    }
    return normalized;
  }
}
