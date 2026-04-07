import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { ExhibitionWorkbenchPresenter } from './exhibition-workbench.presenter';

@Injectable()
export class ExhibitionWorkbenchQueryService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ExhibitionWorkbenchPresenter
  ) {}

  async getSummary(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      return this.presenter.toReadModel({
        recentProject: null,
        canCreateProject: false,
        canOpenProjectPool: false
      });
    }

    const recentProject = await this.projectRepository.findOne({
      where: { organizationId: scope.organization.id },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });

    return this.presenter.toReadModel({
      recentProject,
      canCreateProject: scope.roleKeys.includes('buyer_admin'),
      canOpenProjectPool: true
    });
  }
}
