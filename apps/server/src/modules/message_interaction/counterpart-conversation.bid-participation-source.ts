import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Brackets, In, Repository } from 'typeorm';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import {
  buildBidParticipationSubmitRouteTarget,
  buildBidParticipationThreadRouteTarget,
  buildBidParticipationThreadSummary,
} from '../bid_participation_request/bid-participation-request.support';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { CounterpartConversationAvatarService } from './counterpart-conversation-avatar.service';
import { CounterpartConversationDisplayNameService } from './counterpart-conversation-display-name.service';
import {
  CounterpartConversationCardSeed,
  CounterpartConversationCardSource,
} from './counterpart-conversation.seed';

@Injectable()
export class CounterpartConversationBidParticipationSource
  implements CounterpartConversationCardSource
{
  private static readonly joinedProjectAliases = {
    id: 'joined_project_id',
    organizationId: 'joined_project_organization_id',
    creatorUserId: 'joined_project_creator_user_id',
    state: 'joined_project_state',
    publishedAt: 'joined_project_published_at',
  } as const;

  constructor(
    @InjectRepository(BidParticipationRequestEntity)
    private readonly requestRepository: Repository<BidParticipationRequestEntity>,
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
    const { requests, projectMap } = await this.loadRequestsWithProjectMap(
      viewerOrganizationId,
    );
    if (!requests.length) {
      return [];
    }

    const counterpart = await this.loadCounterpartContext(
      requests,
      projectMap,
      viewerOrganizationId,
    );
    const avatarUrlCache = new Map<string, Promise<string | null>>();
    const seeds = await Promise.all(requests.map((request) =>
      this.toSeed({
        request,
        projectMap,
        counterpart,
        viewerOrganizationId,
        avatarUrlCache,
      }),
    ));
    return seeds.filter((seed): seed is CounterpartConversationCardSeed =>
      Boolean(seed),
    );
  }

  private async loadRequestsWithProjectMap(viewerOrganizationId: string) {
    const query = this.requestRepository
      .createQueryBuilder('request')
      .innerJoin(ProjectEntity, 'project', 'project.id = request.project_id')
      .where(new Brackets((where) => {
        where
          .where('request.requester_organization_id = :organizationId', {
            organizationId: viewerOrganizationId,
          })
          .orWhere('project.organization_id = :organizationId', {
            organizationId: viewerOrganizationId,
          });
      }));
    if (typeof query.andWhere === 'function') {
      query
        .andWhere('project.state <> :archivedState', { archivedState: 'archived' })
        .andWhere('project.published_at IS NOT NULL');
    }
    if (
      typeof query.addSelect === 'function' &&
      typeof query.getRawAndEntities === 'function'
    ) {
      const aliases = CounterpartConversationBidParticipationSource.joinedProjectAliases;
      query
        .addSelect('project.id', aliases.id)
        .addSelect('project.organization_id', aliases.organizationId)
        .addSelect('project.creator_user_id', aliases.creatorUserId)
        .addSelect('project.state', aliases.state)
        .addSelect('project.published_at', aliases.publishedAt);
      const { raw, entities } = await query
        .orderBy('request.updated_at', 'DESC')
        .addOrderBy('request.created_at', 'DESC')
        .getRawAndEntities();
      return {
        requests: entities,
        projectMap: this.buildProjectMapFromRaw(raw),
      };
    }
    const requests = await query
      .orderBy('request.updated_at', 'DESC')
      .addOrderBy('request.created_at', 'DESC')
      .getMany();
    return {
      requests,
      projectMap: await this.loadProjectMap(requests),
    };
  }

  private async loadProjectMap(requests: BidParticipationRequestEntity[]) {
    const projectIds = [...new Set(requests.map((item) => item.projectId))];
    const projects = await this.projectRepository.findBy({ id: In(projectIds) });
    return new Map(projects.map((item) => [item.id, item]));
  }

  private async loadCounterpartContext(
    requests: BidParticipationRequestEntity[],
    projectMap: Map<string, BidParticipationProjectSnapshot>,
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
      organizationIds.add(request.requesterOrganizationId);
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
    const [organizations, users, approvedCertificationSummaryByOrganizationId] = await Promise.all([
      this.organizationRepository.findBy({ id: In([...organizationIds]) }),
      userIds.size ? this.userRepository.findBy({ id: In([...userIds]) }) : Promise.resolve([]),
      this.displayNameService.loadApprovedCertificationSummaryMap(organizationIds),
    ]);
    return {
      organizationMap: new Map(organizations.map((item) => [item.id, item])),
      userMap: new Map(users.map((item) => [item.id, item])),
      approvedCertificationSummaryByOrganizationId,
      approvedLegalNameByOrganizationId: this.displayNameService.toApprovedLegalNameMap(
        approvedCertificationSummaryByOrganizationId,
      ),
    };
  }

  private async toSeed(input: {
    request: BidParticipationRequestEntity;
    projectMap: Map<string, BidParticipationProjectSnapshot>;
    counterpart: Awaited<ReturnType<CounterpartConversationBidParticipationSource['loadCounterpartContext']>>;
    viewerOrganizationId: string;
    avatarUrlCache: Map<string, Promise<string | null>>;
  }): Promise<CounterpartConversationCardSeed | null> {
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
    const counterpartCompanyName = this.displayNameService.resolveCompanyName({
      organizationId: counterpartOrganizationId,
      organizationMap: input.counterpart.organizationMap,
      approvedLegalNameByOrganizationId:
        input.counterpart.approvedLegalNameByOrganizationId,
    });
    const requesterCompanyName = this.displayNameService.resolveCompanyName({
      organizationId: input.request.requesterOrganizationId,
      organizationMap: input.counterpart.organizationMap,
      approvedLegalNameByOrganizationId:
        input.counterpart.approvedLegalNameByOrganizationId,
    });
    const counterpartDisplayName = counterpartCompanyName;
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
      counterpartNickname: this.displayNameService.resolveNickname(counterpartUser),
      counterpartCompanyName,
      counterpartAvatarUrl: await this.readCachedAvatarUrl(
        input.avatarUrlCache,
        counterpartUser?.avatarUrl ?? null,
      ),
      counterpartCertificationSummary:
        input.counterpart.approvedCertificationSummaryByOrganizationId.get(
          counterpartOrganizationId,
        ) ?? null,
      projectId: input.request.projectId,
      updatedAt,
      card: {
        cardId: `bid-participation:${input.request.id}`,
        cardType: 'bid_participation_request' as const,
        title:
          input.request.state === 'pending'
            ? '参与竞标申请'
            : '参与竞标申请结果',
        summary: buildBidParticipationThreadSummary({
          requesterOrganizationName,
          state: input.request.state as 'pending' | 'approved' | 'rejected',
        }),
        status: input.request.state,
        updatedAt,
        requesterCompanyName,
        requesterOrganizationId: input.request.requesterOrganizationId,
        truthAnchor: {
          truthType: 'bid_participation_request' as const,
          projectId: input.request.projectId,
          requestId: input.request.id,
          threadId: input.request.id,
        },
        detailRouteTarget:
          !isOwnerViewer && input.request.state === 'approved'
            ? buildBidParticipationSubmitRouteTarget({
                projectId: input.request.projectId,
              })
            : buildBidParticipationThreadRouteTarget({
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

  private buildProjectMapFromRaw(rawRows: Record<string, unknown>[]) {
    const aliases = CounterpartConversationBidParticipationSource.joinedProjectAliases;
    const projectMap = new Map<string, BidParticipationProjectSnapshot>();
    for (const row of rawRows) {
      const id = this.readString(row[aliases.id]);
      if (!id) {
        continue;
      }
      projectMap.set(id, {
        id,
        organizationId: this.readString(row[aliases.organizationId]),
        creatorUserId: this.readString(row[aliases.creatorUserId]),
        state: this.readString(row[aliases.state]),
        publishedAt: this.readDate(row[aliases.publishedAt]),
      });
    }
    return projectMap;
  }

  private readString(value: unknown) {
    return typeof value === 'string' ? value.trim() : '';
  }

  private readDate(value: unknown) {
    if (!value) {
      return null;
    }
    if (value instanceof Date) {
      return Number.isNaN(value.getTime()) ? null : value;
    }
    const date = new Date(String(value));
    return Number.isNaN(date.getTime()) ? null : date;
  }

  private async readCachedAvatarUrl(
    cache: Map<string, Promise<string | null>>,
    value: string | null | undefined,
  ) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    const existing = cache.get(normalized);
    if (existing) {
      return existing;
    }
    const pending = this.avatarService.readAvatarUrl(normalized);
    cache.set(normalized, pending);
    return pending;
  }
}

type BidParticipationProjectSnapshot = Pick<
  ProjectEntity,
  'id' | 'organizationId' | 'creatorUserId' | 'state' | 'publishedAt'
>;
