import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import {
  bidParticipationForbidden,
  bidParticipationInvalid,
  bidParticipationUnavailable,
} from './bid-participation-request.errors';
import { BidParticipationRequestPresenter } from './bid-participation-request.presenter';
import { buildBidParticipationDisplayTitle, BID_PARTICIPATION_MASKED_TITLE } from './bid-participation-request.support';
import { BidParticipationRequestEntity } from './entities/bid-participation-request.entity';

@Injectable()
export class BidParticipationRequestQueryService {
  constructor(
    @InjectRepository(BidParticipationRequestEntity)
    private readonly requestRepository: Repository<BidParticipationRequestEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly certificationRepository: Repository<OrganizationCertificationEntity>,
    private readonly sessionVerifier: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: BidParticipationRequestPresenter,
  ) {}

  async listPendingRequests(projectId: string | undefined, context: RequestContext) {
    const project = await this.requireOwnerProject(projectId, context);
    const requests = await this.requestRepository.find({
      where: { projectId: project.id, state: 'pending' },
      order: { createdAt: 'DESC' },
    });
    const requesterContext = await this.loadRequesterContext(requests);
    return this.presenter.toPendingListResponse({
      projectId: project.id,
      items: requests.map((request) => ({
        request,
        requesterOrganization:
          requesterContext.organizationMap.get(request.requesterOrganizationId) ?? null,
        requesterUser: requesterContext.userMap.get(request.requestedByUserId) ?? null,
        requesterCertification:
          requesterContext.certificationMap.get(request.requesterOrganizationId) ?? null,
      })),
    });
  }

  async getThreadDetail(threadId: string | undefined, context: RequestContext) {
    const normalizedThreadId = this.readRequiredId(threadId, 'threadId');
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw bidParticipationForbidden('Current organization scope is required for bid participation request.');
    }

    const request = await this.requestRepository.findOneBy({ id: normalizedThreadId });
    if (!request) {
      throw bidParticipationUnavailable('当前参与竞标申请不可用。');
    }

    const project = await this.projectRepository.findOneBy({ id: request.projectId });
    if (!project || project.publishedAt == null || project.state === 'archived') {
      throw bidParticipationUnavailable('当前参与竞标申请不可用。');
    }

    const isOwnerViewer = project.organizationId === organizationId;
    const isRequesterViewer = request.requesterOrganizationId === organizationId;
    if (!isOwnerViewer && !isRequesterViewer) {
      throw bidParticipationForbidden('当前主体不能查看这条参与竞标申请。');
    }

    const requesterContext = await this.loadRequesterContext([request]);
    const approvedVisible = isOwnerViewer || request.state === 'approved';
    return this.presenter.toThreadDetail({
      threadId: request.id,
      projectId: project.id,
      request,
      displayTitle: approvedVisible
        ? buildBidParticipationDisplayTitle(project)
        : BID_PARTICIPATION_MASKED_TITLE,
      requesterOrganization:
        requesterContext.organizationMap.get(request.requesterOrganizationId) ?? null,
      requesterUser: requesterContext.userMap.get(request.requestedByUserId) ?? null,
      requesterCertification:
        requesterContext.certificationMap.get(request.requesterOrganizationId) ?? null,
      ownerCanReview: isOwnerViewer,
      requesterCanSubmit: isRequesterViewer,
    });
  }

  private async requireOwnerProject(projectId: string | undefined, context: RequestContext) {
    const normalizedProjectId = this.readRequiredId(projectId, 'projectId');
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    const scope = await this.eligibilityService.requireProjectPublishEligibility(currentSession);
    const project = await this.projectRepository.findOneBy({ id: normalizedProjectId });
    if (!project || project.state === 'archived') {
      throw bidParticipationUnavailable('当前项目不可用。');
    }
    if (scope.organization.id !== project.organizationId) {
      throw bidParticipationForbidden('当前主体暂无参与竞标申请审批权限。');
    }
    return project;
  }

  private async loadRequesterContext(requests: BidParticipationRequestEntity[]) {
    const organizationIds = [...new Set(requests.map((item) => item.requesterOrganizationId))];
    const userIds = [...new Set(requests.map((item) => item.requestedByUserId))];
    const [organizations, users, certifications] = await Promise.all([
      organizationIds.length
        ? this.organizationRepository.findBy({ id: In(organizationIds) })
        : Promise.resolve([]),
      userIds.length ? this.userRepository.findBy({ id: In(userIds) }) : Promise.resolve([]),
      organizationIds.length
        ? this.certificationRepository.find({
            where: { organizationId: In(organizationIds) },
            order: { updatedAt: 'DESC' },
          })
        : Promise.resolve([]),
    ]);
    return {
      organizationMap: new Map(organizations.map((item) => [item.id, item])),
      userMap: new Map(users.map((item) => [item.id, item])),
      certificationMap: this.toLatestCertificationMap(certifications),
    };
  }

  private toLatestCertificationMap(certifications: OrganizationCertificationEntity[]) {
    const result = new Map<string, OrganizationCertificationEntity>();
    for (const certification of certifications) {
      if (!result.has(certification.organizationId)) {
        result.set(certification.organizationId, certification);
      }
    }
    return result;
  }

  private readRequiredId(value: string | undefined, fieldName: string) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw bidParticipationInvalid(`Field \`${fieldName}\` is required.`);
    }
    return normalized;
  }
}
