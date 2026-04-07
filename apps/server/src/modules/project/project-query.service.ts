import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  CurrentSessionVerificationResult,
  requireVerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from './entities/project.entity';
import { projectUnavailable } from './project.errors';
import { ProjectPresenter } from './project.presenter';

type ProjectViewerRelation = 'owner' | 'non_owner';

@Injectable()
export class ProjectQueryService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ProjectPresenter
  ) {}

  async listProjects(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      return this.presenter.toListResponse([]);
    }

    const projects = await this.projectRepository.find({
      where: { organizationId: scope.organization.id },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    return this.presenter.toListResponse(projects);
  }

  async getProjectById(projectId: string, context: RequestContext) {
    const normalized = projectId.trim();
    if (!normalized) {
      throw projectUnavailable('Current project is unavailable.');
    }

    const project = await this.projectRepository.findOneBy({ id: normalized });
    if (!project) {
      throw projectUnavailable('Current project is unavailable.');
    }

    return {
      ...this.presenter.toReadModel(project),
      viewerProjectRelation: await this.resolveViewerProjectRelation(project, context)
    };
  }

  private async resolveViewerProjectRelation(project: ProjectEntity, context: RequestContext) {
    const verification = await this.verifyOptionalCurrentSession(context);
    if (verification.outcome !== 'verified') {
      return 'non_owner' satisfies ProjectViewerRelation;
    }

    const currentSession = verification.currentSession;
    if (!this.sameUser(project.creatorUserId, currentSession.userId)) {
      return 'non_owner' satisfies ProjectViewerRelation;
    }

    try {
      const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
      if (!scope) {
        return 'non_owner' satisfies ProjectViewerRelation;
      }
      return scope.organization.id === project.organizationId
        ? ('owner' satisfies ProjectViewerRelation)
        : ('non_owner' satisfies ProjectViewerRelation);
    } catch {
      return 'non_owner' satisfies ProjectViewerRelation;
    }
  }

  private async verifyOptionalCurrentSession(context: RequestContext) {
    if (!context.authorization.trim()) {
      return {
        outcome: 'failed' as const,
        reason: 'missing_current_session_carrier' as const,
        requestId: context.requestId,
        traceId: context.traceId
      } satisfies Extract<CurrentSessionVerificationResult, { outcome: 'failed' }>;
    }

    return this.currentSessionVerificationService.verifyCurrentSessionContext(context);
  }

  private sameUser(projectCreatorUserId: string | null, currentUserId: string) {
    const creatorUserId = projectCreatorUserId?.trim() ?? '';
    const viewerUserId = currentUserId.trim();
    return Boolean(creatorUserId) && creatorUserId === viewerUserId;
  }
}
