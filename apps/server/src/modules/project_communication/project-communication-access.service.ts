import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext, VerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectNameAccessRequestEntity } from '../project_name_access/entities/project-name-access-request.entity';
import { ProjectClarificationEntity } from '../trading_im/entities/project-clarification.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import {
  projectAlbumForbidden,
  projectAlbumInvalid,
  projectAlbumUnavailable,
  projectCommunicationForbidden,
  projectCommunicationInvalid,
  projectCommunicationUnavailable
} from './project-communication.errors';

export type ProjectCommunicationActor = {
  currentSession: VerifiedCurrentSessionContext;
  project: ProjectEntity;
  organizationId: string;
  isOwner: boolean;
};

export type ProjectCommunicationPair = ProjectCommunicationActor & {
  ownerOrganizationId: string;
  counterpartOrganizationId: string;
};

@Injectable()
export class ProjectCommunicationAccessService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectNameAccessRequestEntity)
    private readonly nameAccessRepository: Repository<ProjectNameAccessRequestEntity>,
    @InjectRepository(ProjectClarificationEntity)
    private readonly clarificationRepository: Repository<ProjectClarificationEntity>,
    private readonly sessionVerifier: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async requireProjectActor(
    projectId: string,
    context: RequestContext,
    manager?: EntityManager,
    surface: 'album' | 'communication' = 'communication'
  ) {
    const normalizedProjectId = this.readRequiredId(projectId, 'projectId', surface);
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.sessionVerifier);
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      if (surface === 'album') {
        throw projectAlbumForbidden('Current organization scope is required for project album.');
      }
      throw projectCommunicationForbidden('Current organization scope is required for project communication.');
    }

    const project = await this.projectRepo(manager).findOneBy({ id: normalizedProjectId });
    if (!project) {
      if (surface === 'album') {
        throw projectAlbumUnavailable('Current project is unavailable.');
      }
      throw projectCommunicationUnavailable('Current project is unavailable.');
    }
    return {
      currentSession,
      project,
      organizationId,
      isOwner: project.organizationId === organizationId
    } satisfies ProjectCommunicationActor;
  }

  async requireProjectConversationPair(
    projectId: string,
    counterpartOrganizationId: string | undefined,
    context: RequestContext,
    manager?: EntityManager
  ) {
    const actor = await this.requireProjectActor(projectId, context, manager);
    const requestedCounterpart = this.readOptionalId(counterpartOrganizationId);
    if (actor.isOwner) {
      if (!requestedCounterpart) {
        throw projectCommunicationInvalid('Field `counterpartOrganizationId` is required for owner-side thread open.');
      }
      if (requestedCounterpart === actor.project.organizationId) {
        throw projectCommunicationInvalid('Project owner cannot open a project communication thread with itself.');
      }
      await this.requireProjectRelationship(actor.project.id, requestedCounterpart, manager);
      return {
        ...actor,
        ownerOrganizationId: actor.project.organizationId,
        counterpartOrganizationId: requestedCounterpart
      } satisfies ProjectCommunicationPair;
    }

    if (requestedCounterpart && requestedCounterpart !== actor.project.organizationId) {
      throw projectCommunicationForbidden('Non-owner project communication must point to the project owner.', {
        projectId: actor.project.id,
        requestedCounterpartOrganizationId: requestedCounterpart
      });
    }
    await this.requireProjectRelationship(actor.project.id, actor.organizationId, manager);
    return {
      ...actor,
      ownerOrganizationId: actor.project.organizationId,
      counterpartOrganizationId: actor.organizationId
    } satisfies ProjectCommunicationPair;
  }

  async requireProjectAlbumAccess(projectId: string, context: RequestContext, manager?: EntityManager) {
    const actor = await this.requireProjectActor(projectId, context, manager, 'album');
    if (actor.isOwner) {
      return actor;
    }
    const hasRelationship = await this.hasProjectRelationship(
      actor.project.id,
      actor.organizationId,
      manager
    );
    if (!hasRelationship) {
      throw projectAlbumForbidden('Current organization is not a participant of this project album.', {
        projectId: actor.project.id,
        organizationId: actor.organizationId
      });
    }
    return actor;
  }

  async requireExistingThreadParticipant(
    thread: ProjectCommunicationThreadEntity,
    context: RequestContext,
    manager?: EntityManager
  ) {
    const actor = await this.requireProjectActor(thread.projectId, context, manager);
    if (
      actor.project.organizationId !== thread.ownerOrganizationId ||
      (actor.organizationId !== thread.ownerOrganizationId &&
        actor.organizationId !== thread.counterpartOrganizationId)
    ) {
      throw projectCommunicationForbidden('Current organization is not a participant of this communication thread.', {
        projectId: thread.projectId,
        threadId: thread.id,
        organizationId: actor.organizationId
      });
    }
    return actor;
  }

  private async requireProjectRelationship(
    projectId: string,
    counterpartOrganizationId: string,
    manager?: EntityManager
  ) {
    const hasRelationship = await this.hasProjectRelationship(
      projectId,
      counterpartOrganizationId,
      manager
    );
    if (!hasRelationship) {
      throw projectCommunicationForbidden('Current project has no admitted relationship with this counterpart.', {
        projectId,
        counterpartOrganizationId
      });
    }
  }

  private async hasProjectRelationship(
    projectId: string,
    counterpartOrganizationId: string,
    manager?: EntityManager
  ) {
    const bidCount = await this.bidRepo(manager).countBy({
      projectId,
      bidderOrganizationId: counterpartOrganizationId
    });
    if (bidCount > 0) {
      return true;
    }
    const nameAccessCount = await this.nameAccessRepo(manager).countBy({
      projectId,
      requesterOrganizationId: counterpartOrganizationId
    });
    if (nameAccessCount > 0) {
      return true;
    }
    const clarificationCount = await this.clarificationRepo(manager).countBy({
      projectId,
      authorOrganizationId: counterpartOrganizationId
    });
    return clarificationCount > 0;
  }

  private projectRepo(manager?: EntityManager) {
    return manager?.getRepository(ProjectEntity) ?? this.projectRepository;
  }

  private bidRepo(manager?: EntityManager) {
    return manager?.getRepository(BidEntity) ?? this.bidRepository;
  }

  private nameAccessRepo(manager?: EntityManager) {
    return manager?.getRepository(ProjectNameAccessRequestEntity) ?? this.nameAccessRepository;
  }

  private clarificationRepo(manager?: EntityManager) {
    return manager?.getRepository(ProjectClarificationEntity) ?? this.clarificationRepository;
  }

  private readRequiredId(value: string | undefined, field: string, surface: 'album' | 'communication') {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      if (surface === 'album') {
        throw projectAlbumInvalid(`Field \`${field}\` is required.`);
      }
      throw projectCommunicationInvalid(`Field \`${field}\` is required.`);
    }
    return normalized;
  }

  private readOptionalId(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}
