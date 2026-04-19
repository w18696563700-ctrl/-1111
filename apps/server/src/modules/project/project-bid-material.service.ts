import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { ProjectAttachmentEntity } from './entities/project-attachment.entity';
import { ProjectBidMaterialPresenter } from './project-bid-material.presenter';
import { ProjectQueryService } from './project-query.service';

const BID_VISIBLE_ATTACHMENT_KINDS = ['effect_image', 'construction_doc'] as const;

@Injectable()
export class ProjectBidMaterialService {
  constructor(
    @InjectRepository(ProjectAttachmentEntity)
    private readonly attachmentRepository: Repository<ProjectAttachmentEntity>,
    private readonly projectQueryService: ProjectQueryService,
    private readonly presenter: ProjectBidMaterialPresenter
  ) {}

  async list(projectId: string, context: RequestContext) {
    const project = await this.projectQueryService.getProjectById(projectId, context);
    const attachments = await this.attachmentRepository.find({
      where: {
        projectId: project.projectId,
        attachmentKind: In([...BID_VISIBLE_ATTACHMENT_KINDS])
      },
      order: { sortOrder: 'ASC', createdAt: 'ASC' }
    });

    return this.presenter.toListResponse(project.projectId, attachments);
  }
}
