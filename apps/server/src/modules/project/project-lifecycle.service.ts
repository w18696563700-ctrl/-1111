import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { VerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { ProjectEntity } from './entities/project.entity';
import {
  projectArchiveInvalid,
  projectCloseInvalid,
  projectInvalidState,
  projectUnavailable,
  projectWithdrawInvalid,
} from './project.errors';
import { ProjectPresenter } from './project.presenter';

const PROJECT_DRAFT_STATE = 'draft';
const PROJECT_SUBMITTED_STATE = 'submitted';
const PROJECT_PUBLISHED_STATE = 'published';
const PROJECT_AWARDED_STATE = 'awarded';
const PROJECT_CONVERTED_TO_ORDER_STATE = 'converted_to_order';
const PROJECT_ARCHIVED_STATE = 'archived';

type ProjectLifecycleActionCommand = {
  projectId: string;
};

@Injectable()
export class ProjectLifecycleService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly dataSource: DataSource,
    private readonly presenter: ProjectPresenter,
    private readonly auditService: ProjectPublishAuditService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async withdrawProject(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toLifecycleActionCommand(
      payload,
      projectWithdrawInvalid,
      'Project withdraw body must be an object.',
      'Field `projectId` is required for project withdraw.'
    );
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );
    const auditContext = this.buildVerifiedAuditContext(context, currentSession, scope);

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ProjectEntity);
      const project = await this.requireOwnedProject(command.projectId, scope.organization.id, repository);
      this.ensureSubmittedLifecycleAction(project, 'withdraw');

      const previousState = project.state;
      project.state = PROJECT_DRAFT_STATE;
      project.summary = this.buildProjectSummary(PROJECT_DRAFT_STATE);
      project.publishedAt = null;
      await repository.save(project);
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_withdrawn_to_draft',
          payload: {
            previousState,
            nextState: project.state,
            title: project.title
          }
        },
        auditContext,
        manager
      );

      return this.presenter.toAcceptedResponse(project.id, project.state);
    });
  }

  async archiveProject(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toLifecycleActionCommand(
      payload,
      projectArchiveInvalid,
      'Project archive body must be an object.',
      'Field `projectId` is required for project archive.'
    );
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );
    const auditContext = this.buildVerifiedAuditContext(context, currentSession, scope);

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ProjectEntity);
      const project = await this.requireOwnedProject(command.projectId, scope.organization.id, repository);
      this.ensureSubmittedLifecycleAction(project, 'archive');

      const previousState = project.state;
      project.state = PROJECT_ARCHIVED_STATE;
      project.summary = this.buildProjectSummary(PROJECT_ARCHIVED_STATE);
      project.publishedAt = null;
      await repository.save(project);
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_archived',
          payload: {
            previousState,
            nextState: project.state,
            title: project.title
          }
        },
        auditContext,
        manager
      );

      return this.presenter.toAcceptedResponse(project.id, project.state);
    });
  }

  async closeProject(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toLifecycleActionCommand(
      payload,
      projectCloseInvalid,
      'Project close body must be an object.',
      'Field `projectId` is required for project close.'
    );
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );
    const auditContext = this.buildVerifiedAuditContext(context, currentSession, scope);

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ProjectEntity);
      const project = await this.requireOwnedProject(command.projectId, scope.organization.id, repository);
      if (project.state === PROJECT_AWARDED_STATE || project.state === PROJECT_CONVERTED_TO_ORDER_STATE) {
        throw projectInvalidState(
          'Projects that have entered order continuation must use the business close chain.'
        );
      }
      if (project.state !== PROJECT_PUBLISHED_STATE) {
        throw projectInvalidState('Only published projects may be closed.');
      }

      const previousState = project.state;
      project.state = PROJECT_ARCHIVED_STATE;
      project.summary = this.buildProjectSummary(PROJECT_ARCHIVED_STATE);
      project.publishedAt = null;
      await repository.save(project);
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_closed',
          payload: {
            previousState,
            nextState: project.state,
            title: project.title
          }
        },
        auditContext,
        manager
      );

      return this.presenter.toAcceptedResponse(project.id, project.state);
    });
  }

  private ensureSubmittedLifecycleAction(project: ProjectEntity, action: 'withdraw' | 'archive') {
    if (project.state === PROJECT_AWARDED_STATE || project.state === PROJECT_CONVERTED_TO_ORDER_STATE) {
      throw projectInvalidState(
        `Projects that have entered order continuation cannot ${action === 'withdraw' ? 'be withdrawn to draft' : 'be archived from the submission corridor'}.`
      );
    }
    if (project.state !== PROJECT_SUBMITTED_STATE) {
      throw projectInvalidState(
        action === 'withdraw'
          ? 'Only submitted projects may be withdrawn back to draft.'
          : 'Only submitted projects may be archived.'
      );
    }
  }

  private async requireOwnedProject(
    projectId: string,
    organizationId: string,
    repository: Repository<ProjectEntity>
  ) {
    const project = await repository.findOneBy({
      id: projectId,
      organizationId
    });
    if (!project) {
      throw projectUnavailable('Current project is unavailable.');
    }
    return project;
  }

  private buildProjectSummary(state: string) {
    if (state === PROJECT_DRAFT_STATE) {
      return {
        heading: '项目草稿已创建，可继续编辑后提交。',
        stateLabel: '当前项目为草稿，尚未进入公域展示。'
      };
    }
    if (state === PROJECT_ARCHIVED_STATE) {
      return {
        heading: '项目已归档，已退出当前活跃流转。',
        stateLabel: '当前项目已归档，可在历史项目中查看。'
      };
    }
    return {
      heading: '项目已进入最小发布走廊。',
      stateLabel: '当前项目已发布，可继续进入最小竞标继续面。'
    };
  }

  private toLifecycleActionCommand(
    payload: Record<string, unknown>,
    invalidErrorFactory: (message: string) => Error,
    invalidBodyMessage: string,
    invalidProjectIdMessage: string
  ) {
    const source = this.asRecord(payload, invalidErrorFactory, invalidBodyMessage);
    return {
      projectId: this.readRequiredString(
        source.projectId,
        invalidErrorFactory,
        invalidProjectIdMessage
      )
    } satisfies ProjectLifecycleActionCommand;
  }

  private readRequiredString(
    value: unknown,
    invalidErrorFactory: (message: string) => Error,
    message: string
  ) {
    if (typeof value !== 'string') {
      throw invalidErrorFactory(message);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw invalidErrorFactory(message);
    }
    return normalized;
  }

  private buildVerifiedAuditContext(
    context: RequestContext,
    currentSession: VerifiedCurrentSessionContext,
    scope: Awaited<ReturnType<CurrentActorEligibilityService['getCurrentOrganizationScope']>>
  ): RequestContext {
    if (!scope) {
      throw authPermissionInsufficient(
        'Current actor lacks the required organization scope for project lifecycle.'
      );
    }
    return {
      ...context,
      actorId: currentSession.actorId,
      userId: currentSession.userId,
      organizationId: scope.organization.id,
      actorRole: scope.membership.roleKey,
    };
  }

  private asRecord(
    value: unknown,
    invalidErrorFactory: (message: string) => Error,
    message: string
  ) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw invalidErrorFactory(message);
    }
    return value as Record<string, unknown>;
  }
}
