import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProjectEntity } from '../project/entities/project.entity';
import { bidParticipationRequired } from './bid-participation-request.errors';
import { BidParticipationRequestEntity } from './entities/bid-participation-request.entity';

@Injectable()
export class BidParticipationRequestAccessService {
  constructor(
    @InjectRepository(BidParticipationRequestEntity)
    private readonly requestRepository: Repository<BidParticipationRequestEntity>,
  ) {}

  async hasApproved(projectId: string, requesterOrganizationId: string) {
    const count = await this.requestRepository.countBy({
      projectId,
      requesterOrganizationId,
      state: 'approved',
    });
    return count > 0;
  }

  async requireApprovedForOrganization(project: ProjectEntity, requesterOrganizationId: string) {
    if (project.organizationId === requesterOrganizationId) {
      return;
    }
    const approved = await this.hasApproved(project.id, requesterOrganizationId);
    if (!approved) {
      throw bidParticipationRequired(
        '当前主体需要先通过参与竞标申请，才能查看报价依据资料或提交竞标。',
      );
    }
  }
}

