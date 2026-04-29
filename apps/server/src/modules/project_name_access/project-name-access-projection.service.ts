import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectNameAccessRequestEntity } from './entities/project-name-access-request.entity';
import {
  buildProjectDisplayTitle,
  PROJECT_NAME_ACCESS_MASKED_TITLE,
} from './project-name-access.support';
import { ProjectNameAccessProjection } from './project-name-access.types';

@Injectable()
export class ProjectNameAccessProjectionService {
  constructor(
    @InjectRepository(ProjectNameAccessRequestEntity)
    private readonly requestRepository: Repository<ProjectNameAccessRequestEntity>,
    @InjectRepository(BidParticipationRequestEntity)
    private readonly bidParticipationRepository: Repository<BidParticipationRequestEntity>,
  ) {}

  async buildPublicProjectionMap(input: {
    projects: ProjectEntity[];
    viewerOrganizationId: string | null;
    ownerProjectIds: Set<string>;
  }) {
    if (!input.projects.length) {
      return new Map<string, ProjectNameAccessProjection>();
    }

    const latestRequestByProjectId = await this.loadLatestRequestByProjectId(
      input.projects.map((project) => project.id),
      input.viewerOrganizationId,
    );
    const result = new Map<string, ProjectNameAccessProjection>();
    for (const project of input.projects) {
      const isOwnerViewer = input.ownerProjectIds.has(project.id);
      const latestRequest = latestRequestByProjectId.get(project.id) ?? null;
      result.set(
        project.id,
        this.toProjection(project, {
          isOwnerViewer,
          viewerOrganizationId: input.viewerOrganizationId,
          latestRequest,
        }),
      );
    }
    return result;
  }

  async buildSingleProjectProjection(input: {
    project: ProjectEntity;
    viewerOrganizationId: string | null;
    isOwnerViewer: boolean;
  }) {
    const latestRequestByProjectId = await this.loadLatestRequestByProjectId(
      [input.project.id],
      input.viewerOrganizationId,
    );
    return this.toProjection(input.project, {
      isOwnerViewer: input.isOwnerViewer,
      viewerOrganizationId: input.viewerOrganizationId,
      latestRequest: latestRequestByProjectId.get(input.project.id) ?? null,
    });
  }

  private async loadLatestRequestByProjectId(projectIds: string[], viewerOrganizationId: string | null) {
    if (!viewerOrganizationId || !projectIds.length) {
      return new Map<string, ProjectNameAccessRequestEntity | BidParticipationRequestEntity>();
    }

    const [nameAccessRequests, bidParticipationRequests] = await Promise.all([
      this.requestRepository.find({
        where: {
          projectId: In(projectIds),
          requesterOrganizationId: viewerOrganizationId,
        },
        order: { createdAt: 'DESC' },
      }),
      this.bidParticipationRepository.find({
        where: {
          projectId: In(projectIds),
          requesterOrganizationId: viewerOrganizationId,
        },
        order: { createdAt: 'DESC' },
      }),
    ]);
    const result = new Map<string, ProjectNameAccessRequestEntity | BidParticipationRequestEntity>();
    for (const request of [...bidParticipationRequests, ...nameAccessRequests]) {
      const current = result.get(request.projectId);
      if (!current || this.requestSortTime(current) < this.requestSortTime(request)) {
        result.set(request.projectId, request);
      }
    }
    for (const request of [...bidParticipationRequests, ...nameAccessRequests]) {
      if (request.state === 'approved') {
        result.set(request.projectId, request);
      }
    }
    return result;
  }

  private toProjection(
    project: ProjectEntity,
    input: {
      isOwnerViewer: boolean;
      viewerOrganizationId: string | null;
      latestRequest: ProjectNameAccessRequestEntity | BidParticipationRequestEntity | null;
    },
  ): ProjectNameAccessProjection {
    const visibleDisplayTitle = buildProjectDisplayTitle(project);
    if (input.isOwnerViewer) {
      return {
        displayTitle: visibleDisplayTitle,
        title: project.title,
        exhibitionName: this.nullable(project.exhibitionName),
        brandName: this.nullable(project.brandName),
        nameAccess: {
          status: 'visible',
          canRequest: false,
          requestId: input.latestRequest?.id ?? null,
        },
      };
    }

    if (input.latestRequest?.state === 'approved') {
      return {
        displayTitle: visibleDisplayTitle,
        title: project.title,
        exhibitionName: this.nullable(project.exhibitionName),
        brandName: this.nullable(project.brandName),
        nameAccess: {
          status: 'visible',
          canRequest: false,
          requestId: input.latestRequest.id,
        },
      };
    }

    if (input.latestRequest?.state === 'pending') {
      return this.toMaskedProjection({
        requestId: input.latestRequest.id,
        status: 'pending',
        canRequest: false,
      });
    }

    if (input.latestRequest?.state === 'rejected') {
      return this.toMaskedProjection({
        requestId: input.latestRequest.id,
        status: 'rejected',
        canRequest: Boolean(input.viewerOrganizationId),
      });
    }

    return this.toMaskedProjection({
      requestId: null,
      status: 'requestable',
      canRequest: Boolean(input.viewerOrganizationId),
    });
  }

  private toMaskedProjection(input: {
    requestId: string | null;
    status: 'requestable' | 'pending' | 'rejected';
    canRequest: boolean;
  }): ProjectNameAccessProjection {
    return {
      displayTitle: PROJECT_NAME_ACCESS_MASKED_TITLE,
      title: PROJECT_NAME_ACCESS_MASKED_TITLE,
      exhibitionName: null,
      brandName: null,
      nameAccess: {
        status: input.status,
        canRequest: input.canRequest,
        requestId: input.requestId,
      },
    };
  }

  private nullable(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private requestSortTime(request: ProjectNameAccessRequestEntity | BidParticipationRequestEntity) {
    return request.createdAt.getTime();
  }
}
