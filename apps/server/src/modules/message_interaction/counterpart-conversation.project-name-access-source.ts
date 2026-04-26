import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectNameAccessRequestEntity } from '../project_name_access/entities/project-name-access-request.entity';
import {
  buildProjectNameAccessThreadRouteTarget,
  buildProjectNameAccessThreadSummary,
} from '../project_name_access/project-name-access.support';
import { CounterpartConversationAvatarService } from './counterpart-conversation-avatar.service';
import { CounterpartConversationDisplayNameService } from './counterpart-conversation-display-name.service';
import {
  CounterpartConversationCardSeed,
  CounterpartConversationCardSource,
} from './counterpart-conversation.seed';

@Injectable()
export class CounterpartConversationProjectNameAccessSource
  implements CounterpartConversationCardSource
{
  constructor(
    @InjectRepository(ProjectNameAccessRequestEntity)
    private readonly requestRepository: Repository<ProjectNameAccessRequestEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly avatarService: CounterpartConversationAvatarService,
    private readonly displayNameService: CounterpartConversationDisplayNameService,
  ) {}

  async buildSeeds(viewerOrganizationId: string) {
    const requests = await this.requestRepository
      .createQueryBuilder('request')
      .innerJoin(ProjectEntity, 'project', 'project.id = request.project_id')
      .where('request.requester_organization_id = :organizationId', {
        organizationId: viewerOrganizationId,
      })
      .orWhere('project.organization_id = :organizationId', {
        organizationId: viewerOrganizationId,
      })
      .orderBy('request.updated_at', 'DESC')
      .addOrderBy('request.created_at', 'DESC')
      .getMany();
    if (!requests.length) {
      return [];
    }

    const projectMap = await this.loadProjectMap(requests);
    const counterpart = await this.loadCounterpartContext(
      requests,
      projectMap,
      viewerOrganizationId,
    );
    const seeds: CounterpartConversationCardSeed[] = [];
    for (const request of requests) {
      const seed = await this.toSeed({
        request,
        projectMap,
        counterpart,
        viewerOrganizationId,
      });
      if (seed) {
        seeds.push(seed);
      }
    }
    return seeds;
  }

  private async loadProjectMap(requests: ProjectNameAccessRequestEntity[]) {
    const projectIds = [...new Set(requests.map((item) => item.projectId))];
    const projects = await this.projectRepository.findBy({ id: In(projectIds) });
    return new Map(projects.map((item) => [item.id, item]));
  }

  private async loadCounterpartContext(
    requests: ProjectNameAccessRequestEntity[],
    projectMap: Map<string, ProjectEntity>,
    viewerOrganizationId: string,
  ) {
    const organizationIds = new Set<string>();
    const userIds = new Set<string>();
    for (const request of requests) {
      const project = projectMap.get(request.projectId);
      if (!project) {
        continue;
      }
      const isOwnerViewer = project.organizationId === viewerOrganizationId;
      organizationIds.add(
        isOwnerViewer ? request.requesterOrganizationId : project.organizationId,
      );
      const userId = isOwnerViewer
        ? request.requestedByUserId?.trim() ?? ''
        : project.creatorUserId?.trim() ?? '';
      if (userId) {
        userIds.add(userId);
      }
    }
    const [organizations, users, approvedLegalNameByOrganizationId] = await Promise.all([
      this.organizationRepository.findBy({ id: In([...organizationIds]) }),
      userIds.size ? this.userRepository.findBy({ id: In([...userIds]) }) : Promise.resolve([]),
      this.displayNameService.loadApprovedLegalNameMap(organizationIds),
    ]);
    return {
      organizationMap: new Map(organizations.map((item) => [item.id, item])),
      userMap: new Map(users.map((item) => [item.id, item])),
      approvedLegalNameByOrganizationId,
    };
  }

  private async toSeed(input: {
    request: ProjectNameAccessRequestEntity;
    projectMap: Map<string, ProjectEntity>;
    counterpart: Awaited<ReturnType<CounterpartConversationProjectNameAccessSource['loadCounterpartContext']>>;
    viewerOrganizationId: string;
  }) {
    const project = input.projectMap.get(input.request.projectId);
    if (!project || project.state === 'archived' || project.publishedAt == null) {
      return null;
    }
    const isOwnerViewer = project.organizationId === input.viewerOrganizationId;
    const counterpartOrganizationId = isOwnerViewer
      ? input.request.requesterOrganizationId
      : project.organizationId;
    const counterpartUserId = isOwnerViewer
      ? input.request.requestedByUserId?.trim() ?? ''
      : project.creatorUserId?.trim() ?? '';
    const counterpartUser = counterpartUserId
      ? input.counterpart.userMap.get(counterpartUserId)
      : null;
    const counterpartDisplayName = this.displayNameService.resolveDisplayName({
      organizationId: counterpartOrganizationId,
      organizationMap: input.counterpart.organizationMap,
      approvedLegalNameByOrganizationId:
        input.counterpart.approvedLegalNameByOrganizationId,
    });
    const requesterOrganizationName =
      input.request.requesterOrganizationId === counterpartOrganizationId
        ? counterpartDisplayName
        : '当前申请组织';
    const updatedAt = (
      input.request.reviewedAt ??
      input.request.updatedAt ??
      input.request.createdAt
    ).toISOString();
    return {
      counterpartOrganizationId,
      counterpartDisplayName,
      counterpartAvatarUrl: await this.avatarService.readAvatarUrl(
        counterpartUser?.avatarUrl ?? null,
      ),
      projectId: input.request.projectId,
      updatedAt,
      card: {
        cardId: `project-name-access:${input.request.id}`,
        cardType: 'project_name_access_request' as const,
        title:
          input.request.state === 'pending'
            ? '项目名称查看申请'
            : '项目名称查看结果',
        summary: buildProjectNameAccessThreadSummary({
          requesterOrganizationName,
          state: input.request.state as 'pending' | 'approved' | 'rejected',
        }),
        status: input.request.state,
        updatedAt,
        truthAnchor: {
          truthType: 'project_name_access_request' as const,
          projectId: input.request.projectId,
          requestId: input.request.id,
          threadId: input.request.id,
        },
        detailRouteTarget: buildProjectNameAccessThreadRouteTarget({
          threadId: input.request.id,
          projectId: input.request.projectId,
          requestId: input.request.id,
        }),
        decisionAvailability:
          isOwnerViewer && input.request.state === 'pending'
            ? { canApprove: true, canReject: true }
            : null,
      },
    };
  }
}
