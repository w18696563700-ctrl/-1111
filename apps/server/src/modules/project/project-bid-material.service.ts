import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidParticipationRequestAccessService } from '../bid_participation_request/bid-participation-request-access.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';
import { ProjectEntity } from './entities/project.entity';
import { ProjectBidMaterialPresenter } from './project-bid-material.presenter';
import { projectUnavailable } from './project.errors';
import { ProjectCommunicationThreadEntity } from '../project_communication/entities/project-communication-thread.entity';
import { ProjectCommunicationWorkbenchService } from '../project_communication/project-communication-workbench.service';

const BID_VISIBLE_ATTACHMENT_KINDS = [
  'effect_image',
  'construction_doc',
  'material_sample',
  'equipment_material_list',
  'service_list'
] as const;

@Injectable()
export class ProjectBidMaterialService {
  constructor(
    @InjectRepository(ProjectAttachmentEntity)
    private readonly attachmentRepository: Repository<ProjectAttachmentEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(ProjectCommunicationThreadEntity)
    private readonly projectCommunicationThreadRepository: Repository<ProjectCommunicationThreadEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProjectBidMaterialPresenter,
    private readonly bidParticipationAccessService: BidParticipationRequestAccessService,
    private readonly projectCommunicationWorkbenchService: ProjectCommunicationWorkbenchService
  ) {}

  async list(projectId: string, context: RequestContext) {
    const project = await this.requireBidMaterialProject(projectId);
    const { scope } = await this.eligibilityService.requireBidSubmitEligibilityFromContext(
      context,
      this.currentSessionVerificationService,
      project
    );
    await this.bidParticipationAccessService.requireApprovedForOrganization(
      project,
      scope.organization.id,
    );
    const attachments = await this.attachmentRepository.find({
      where: {
        projectId: project.id,
        attachmentKind: In([...BID_VISIBLE_ATTACHMENT_KINDS]),
        visibility: 'owner_private'
      },
      order: { sortOrder: 'ASC', createdAt: 'ASC' }
    });
    const materialReview = await this.buildPublisherMaterialReviewProjection(
      project,
      scope.organization.id,
      context
    );

    return this.presenter.toListResponse(project.id, attachments, materialReview);
  }

  private async buildPublisherMaterialReviewProjection(
    project: ProjectEntity,
    bidderOrganizationId: string,
    context: RequestContext
  ) {
    const thread = await this.projectCommunicationThreadRepository.findOneBy({
      projectId: project.id,
      ownerOrganizationId: project.organizationId,
      counterpartOrganizationId: bidderOrganizationId
    });
    if (!thread) {
      return null;
    }
    const workbench = await this.projectCommunicationWorkbenchService.getWorkbench(
      { projectId: project.id, threadId: thread.id },
      context
    );
    const entries = Array.isArray(workbench.entries)
      ? workbench.entries.filter((entry: Record<string, unknown>) => entry.group === 'publisher_materials')
      : [];
    return {
      projectId: workbench.projectId,
      threadId: workbench.threadId,
      viewerRole: workbench.viewerRole,
      chatAvailability: workbench.chatAvailability,
      entries,
      generatedAt: workbench.generatedAt
    };
  }

  private async requireBidMaterialProject(projectId: string) {
    const normalizedProjectId = projectId.trim();
    if (!normalizedProjectId) {
      throw projectUnavailable('Current project is unavailable.');
    }
    const project = await this.projectRepository.findOneBy({ id: normalizedProjectId });
    if (!project || project.publishedAt === null || project.state !== 'published') {
      throw projectUnavailable('Current project is unavailable.');
    }
    return project;
  }
}
