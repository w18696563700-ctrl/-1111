import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';
import { ProjectEntity } from './entities/project.entity';
import { ProjectBidMaterialPresenter } from './project-bid-material.presenter';
import { projectUnavailable } from './project.errors';

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
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProjectBidMaterialPresenter
  ) {}

  async list(projectId: string, context: RequestContext) {
    const project = await this.requireBidMaterialProject(projectId);
    await this.eligibilityService.requireBidSubmitEligibilityFromContext(
      context,
      this.currentSessionVerificationService,
      project
    );
    const attachments = await this.attachmentRepository.find({
      where: {
        projectId: project.id,
        attachmentKind: In([...BID_VISIBLE_ATTACHMENT_KINDS]),
        visibility: 'owner_private'
      },
      order: { sortOrder: 'ASC', createdAt: 'ASC' }
    });

    return this.presenter.toListResponse(project.id, attachments);
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
