import { Injectable, Optional } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { ProjectEntity } from '../project/entities/project.entity';
import {
  ProjectCommunicationUnreadQueryService,
  ProjectCommunicationUnreadStats,
} from '../project_communication/project-communication-unread.query.service';
import {
  ProjectCommunicationBusinessStateService,
  ProjectCommunicationBusinessState,
  ProjectCommunicationBusinessTodoSummary,
} from '../project_communication/project-communication-business-state.service';
import { ProjectCommunicationThreadEntity } from '../project_communication/entities/project-communication-thread.entity';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import { ProjectNameAccessProjectionService } from '../project_name_access/project-name-access-projection.service';
import { PROJECT_NAME_ACCESS_MASKED_TITLE } from '../project_name_access/project-name-access.support';
import { messageInteractionUnavailable } from './message-interaction.errors';
import { CounterpartConversationBidParticipationSource } from './counterpart-conversation.bid-participation-source';
import { CounterpartConversationBidThreadSource } from './counterpart-conversation.bid-thread-source';
import { CounterpartConversationClarificationSource } from './counterpart-conversation.clarification-source';
import { CounterpartConversationProjectNameAccessSource } from './counterpart-conversation.project-name-access-source';
import {
  CounterpartConversationCardSeed,
  CounterpartConversationCardSource,
} from './counterpart-conversation.seed';
import {
  CounterpartConversationBusinessCardProjection,
  CounterpartConversationDetailProjection,
  CounterpartConversationListItemProjection,
  CounterpartConversationProjectGroupProjection,
  CounterpartConversationRatingEntryProjection,
  CounterpartConversationRouteTarget,
} from './counterpart-conversation.types';
import { buildCounterpartConversationRouteTarget } from './counterpart-conversation.support';

type ConversationAggregate = {
  conversationId: string;
  counterpart: CounterpartConversationDetailProjection['counterpart'];
  summary: CounterpartConversationDetailProjection['summary'];
  focusProjectId: string;
  focusThreadId: string;
  pricingSummary?: Record<string, unknown>;
  latestActivityAt: string;
  conversationUnreadCount: number;
  hasUnread: boolean;
  latestUnreadMessageAt: string | null;
  myPublishedUnreadCount: number;
  myBidUnreadCount: number;
  projectGroups: CounterpartConversationProjectGroupProjection[];
};

type RatingOrderRow = {
  orderId: string;
  projectId: string;
  buyerOrganizationId: string;
  supplierOrganizationId: string | null;
  orderState: string | null;
  ratingState: string | null;
};

type ProjectGroupAggregate = {
  latestActivityAt: string;
  pricingSummary?: Record<string, unknown>;
  cards: CounterpartConversationBusinessCardProjection[];
};

type SeedConversationAggregate = {
  counterpart: CounterpartConversationDetailProjection['counterpart'];
  latestActivityAt: string;
  projectGroups: Map<string, ProjectGroupAggregate>;
};

@Injectable()
export class CounterpartConversationProjectionService {
  private readonly cardSources: CounterpartConversationCardSource[];

  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly projectNameAccessProjectionService: ProjectNameAccessProjectionService,
    bidThreadSource: CounterpartConversationBidThreadSource,
    bidParticipationSource: CounterpartConversationBidParticipationSource,
    clarificationSource: CounterpartConversationClarificationSource,
    @Optional()
    private readonly unreadQueryService?: ProjectCommunicationUnreadQueryService,
    @Optional()
    private readonly businessStateService?: ProjectCommunicationBusinessStateService,
    @Optional()
    projectNameAccessSource?: CounterpartConversationProjectNameAccessSource,
    @Optional()
    @InjectRepository(ProjectCommunicationThreadEntity)
    private readonly threadRepository?: Repository<ProjectCommunicationThreadEntity>,
    @Optional()
    @InjectRepository(BidParticipationRequestEntity)
    private readonly bidParticipationRepository?: Repository<BidParticipationRequestEntity>,
  ) {
    this.cardSources = [
      bidThreadSource,
      bidParticipationSource,
      clarificationSource,
      ...(projectNameAccessSource ? [projectNameAccessSource] : []),
    ];
  }

  async listConversations(
    viewerOrganizationId: string,
  ): Promise<CounterpartConversationListItemProjection[]> {
    const catalog = await this.buildConversationCatalog(viewerOrganizationId);
    return catalog.map((conversation) => ({
      interactionId: conversation.conversationId,
      interactionType: 'counterpart_conversation',
      conversationId: conversation.conversationId,
      projectId: conversation.focusProjectId,
      counterpart: conversation.counterpart,
      summary: conversation.summary,
      ...(conversation.pricingSummary ? { pricingSummary: conversation.pricingSummary } : {}),
      updatedAt: conversation.latestActivityAt,
      routeTarget: buildCounterpartConversationRouteTarget({
        conversationId: conversation.conversationId,
        projectId: conversation.focusProjectId,
        threadId: conversation.focusThreadId,
      }),
      conversationUnreadCount: conversation.conversationUnreadCount,
      hasUnread: conversation.hasUnread,
      latestUnreadMessageAt: conversation.latestUnreadMessageAt,
    }));
  }

  async getConversationDetail(input: {
    viewerOrganizationId: string;
    conversationId: string;
    focusProjectId?: string;
  }): Promise<CounterpartConversationDetailProjection> {
    const catalog = await this.buildConversationCatalog(input.viewerOrganizationId);
    const conversation = catalog.find(
      (item) => item.conversationId === input.conversationId,
    );
    if (!conversation) {
      throw messageInteractionUnavailable(
        'Current counterpart conversation is unavailable.',
      );
    }

    if (
      input.focusProjectId &&
      !conversation.projectGroups.some(
        (group) => group.projectId === input.focusProjectId,
      )
    ) {
      throw messageInteractionUnavailable(
        'Current counterpart conversation project group is unavailable.',
      );
    }

    const focusProjectId = input.focusProjectId?.trim() || conversation.focusProjectId;
    return {
      conversationId: conversation.conversationId,
      counterpart: conversation.counterpart,
      summary: conversation.summary,
      focusProjectId,
      latestActivityAt: conversation.latestActivityAt,
      conversationUnreadCount: conversation.conversationUnreadCount,
      hasUnread: conversation.hasUnread,
      latestUnreadMessageAt: conversation.latestUnreadMessageAt,
      myPublishedUnreadCount: conversation.myPublishedUnreadCount,
      myBidUnreadCount: conversation.myBidUnreadCount,
      projectGroups: this.sortProjectGroups(conversation.projectGroups, focusProjectId),
    };
  }

  private async buildConversationCatalog(viewerOrganizationId: string) {
    const seeds = await this.loadCardSeeds(viewerOrganizationId);
    if (!seeds.length) {
      return [];
    }

    const projectIds = [...new Set(seeds.map((item) => item.projectId))];
    const [projects, ratingEntryMap, unreadStatsByProjectId] = await Promise.all([
      this.projectRepository.findBy({ id: In(projectIds) }),
      this.buildRatingEntryMap(projectIds, viewerOrganizationId),
      this.buildProjectUnreadStatsMap(projectIds, viewerOrganizationId),
    ]);
    const projectMap = new Map(projects.map((item) => [item.id, item]));
    const nameAccessProjectionMap = await this.buildNameAccessProjectionMap({
      projects,
      viewerOrganizationId,
    });
    const conversationMap = this.groupSeedsByConversation(seeds);

    const conversations = await Promise.all([...conversationMap.entries()]
      .map(async ([conversationId, aggregate]): Promise<ConversationAggregate | null> => {
        const businessStateByProjectId =
          await this.buildBusinessStateMap({
            aggregate,
            projectMap,
            viewerOrganizationId,
          });
        const threadIdByProjectId = await this.buildProjectCommunicationThreadIdMap({
          aggregate,
          projectMap,
          viewerOrganizationId,
        });
        const serviceFeeAuthorizationRouteTargetByProjectId =
          await this.buildServiceFeeAuthorizationRouteTargetMap({
            aggregate,
            projectMap,
            viewerOrganizationId,
            businessStateByProjectId,
          });
        const projectGroups = this.buildProjectGroups({
          aggregate,
          projectMap,
          nameAccessProjectionMap,
          viewerOrganizationId,
          ratingEntryMap,
          unreadStatsByProjectId,
          businessStateByProjectId,
          threadIdByProjectId,
          serviceFeeAuthorizationRouteTargetByProjectId,
        });
        const focusProject = projectGroups[0];
        if (!focusProject) {
          return null;
        }
        const latestCard = focusProject.cards[0];
        const unreadSummary = this.summarizeProjectGroupUnread(projectGroups);
        return {
          conversationId,
          counterpart: aggregate.counterpart,
          summary: {
            focusProjectId: focusProject.projectId,
            title: latestCard.title,
            text: latestCard.summary,
            projectCount: projectGroups.length,
            latestCardType: latestCard.cardType,
          },
          focusProjectId: focusProject.projectId,
          focusThreadId: focusProject.threadId,
          ...(focusProject.pricingSummary ? { pricingSummary: focusProject.pricingSummary } : {}),
          latestActivityAt: aggregate.latestActivityAt,
          conversationUnreadCount: unreadSummary.conversationUnreadCount,
          hasUnread: unreadSummary.conversationUnreadCount > 0,
          latestUnreadMessageAt: unreadSummary.latestUnreadMessageAt,
          myPublishedUnreadCount: unreadSummary.myPublishedUnreadCount,
          myBidUnreadCount: unreadSummary.myBidUnreadCount,
          projectGroups,
        };
      }));
    return conversations
      .filter((conversation): conversation is ConversationAggregate =>
        Boolean(conversation),
      )
      .sort((left, right) =>
        right.latestActivityAt.localeCompare(left.latestActivityAt),
      );
  }

  private async loadCardSeeds(viewerOrganizationId: string) {
    const seedGroups = await Promise.all(
      this.cardSources.map((source) => source.buildSeeds(viewerOrganizationId)),
    );
    return seedGroups
      .flat()
      .sort((left, right) => right.updatedAt.localeCompare(left.updatedAt));
  }

  private async buildNameAccessProjectionMap(input: {
    projects: ProjectEntity[];
    viewerOrganizationId: string;
  }) {
    const ownerProjectIds = new Set(
      input.projects
        .filter((item) => item.organizationId === input.viewerOrganizationId)
        .map((item) => item.id),
    );
    return this.projectNameAccessProjectionService.buildPublicProjectionMap({
      projects: input.projects,
      viewerOrganizationId: input.viewerOrganizationId,
      ownerProjectIds,
    });
  }

  private groupSeedsByConversation(seeds: CounterpartConversationCardSeed[]) {
    const conversationMap = new Map<
      string,
      SeedConversationAggregate
    >();

    for (const seed of seeds) {
      const aggregate = conversationMap.get(seed.counterpartOrganizationId);
      if (!aggregate) {
        conversationMap.set(
          seed.counterpartOrganizationId,
          this.createConversationAggregate(seed),
        );
        continue;
      }
      this.appendSeedToAggregate(aggregate, seed);
    }
    return conversationMap;
  }

  private createConversationAggregate(seed: CounterpartConversationCardSeed): SeedConversationAggregate {
    return {
      counterpart: {
        organizationId: seed.counterpartOrganizationId,
        displayName: seed.counterpartDisplayName,
        nickname: seed.counterpartNickname,
        companyName: seed.counterpartCompanyName,
        avatarUrl: seed.counterpartAvatarUrl,
        certificationSummary: seed.counterpartCertificationSummary,
        role: 'counterpart' as const,
      },
      latestActivityAt: seed.updatedAt,
      projectGroups: new Map([
        [
          seed.projectId,
          {
            latestActivityAt: seed.updatedAt,
            pricingSummary: seed.pricingSummary,
            cards: [seed.card],
          },
        ],
      ]),
    };
  }

  private appendSeedToAggregate(
    aggregate: SeedConversationAggregate,
    seed: CounterpartConversationCardSeed,
  ) {
    if (seed.updatedAt > aggregate.latestActivityAt) {
      aggregate.latestActivityAt = seed.updatedAt;
      aggregate.counterpart = {
        organizationId: seed.counterpartOrganizationId,
        displayName: seed.counterpartDisplayName,
        nickname: seed.counterpartNickname,
        companyName: seed.counterpartCompanyName,
        avatarUrl: seed.counterpartAvatarUrl,
        certificationSummary: seed.counterpartCertificationSummary,
        role: 'counterpart',
      };
    }

    const group = aggregate.projectGroups.get(seed.projectId);
    if (!group) {
      aggregate.projectGroups.set(seed.projectId, {
        latestActivityAt: seed.updatedAt,
        pricingSummary: seed.pricingSummary,
        cards: [seed.card],
      });
      return;
    }
    if (seed.updatedAt > group.latestActivityAt) {
      group.latestActivityAt = seed.updatedAt;
      group.pricingSummary = seed.pricingSummary;
    }
    group.cards.push(seed.card);
  }

  private buildProjectGroups(input: {
    aggregate: SeedConversationAggregate;
    projectMap: Map<string, ProjectEntity>;
    viewerOrganizationId: string;
    ratingEntryMap: Map<string, CounterpartConversationRatingEntryProjection>;
    unreadStatsByProjectId: Map<string, ProjectCommunicationUnreadStats>;
    businessStateByProjectId: Map<string, ProjectCommunicationBusinessState>;
    threadIdByProjectId: Map<string, string>;
    serviceFeeAuthorizationRouteTargetByProjectId: Map<string, CounterpartConversationRouteTarget>;
    nameAccessProjectionMap: Awaited<
      ReturnType<ProjectNameAccessProjectionService['buildPublicProjectionMap']>
    >;
  }) {
    return [...input.aggregate.projectGroups.entries()]
      .map(([projectId, group]): CounterpartConversationProjectGroupProjection | null => {
        const project = input.projectMap.get(projectId);
        const projection = input.nameAccessProjectionMap.get(projectId);
        const titleVisibility =
          projection?.nameAccess.status === 'visible' ? 'visible' : 'masked';
        const unreadStats =
          input.unreadStatsByProjectId.get(projectId) ?? this.emptyUnreadStats();
        const threadId = input.threadIdByProjectId.get(projectId);
        if (!threadId) {
          return null;
        }
        const cards = this.withServiceFeeAuthorizationRouteTarget(
          group.cards,
          input.serviceFeeAuthorizationRouteTargetByProjectId.get(projectId),
        );
        const businessState = input.businessStateByProjectId.get(projectId);
        return {
          projectId,
          threadId,
          projectDisplayTitle: this.buildCounterpartProjectDisplayTitle({
            project,
            projection,
            titleVisibility,
          }),
          titleVisibility,
          projectRelation: this.resolveProjectRelation({
            project,
            viewerOrganizationId: input.viewerOrganizationId,
          }),
          projectState: project?.state ?? null,
          projectPublishedAt: project?.publishedAt?.toISOString() ?? null,
          projectUpdatedAt: project?.updatedAt?.toISOString() ?? null,
          latestActivityAt: group.latestActivityAt,
          projectUnreadCount: unreadStats.unreadCount,
          hasProjectUnread: unreadStats.hasUnread,
          latestUnreadMessageAt: unreadStats.latestUnreadMessageAt,
          businessTodoSummary:
            businessState?.businessTodoSummary ??
            this.emptyBusinessTodoSummary(),
          ...(group.pricingSummary ? { pricingSummary: group.pricingSummary } : {}),
          ratingEntry:
            input.ratingEntryMap.get(
              this.ratingEntryKey(projectId, input.aggregate.counterpart.organizationId),
            ) ?? null,
          cards: cards.sort((left, right) =>
            right.updatedAt.localeCompare(left.updatedAt),
          ),
        };
      })
      .filter((group): group is CounterpartConversationProjectGroupProjection =>
        Boolean(group),
      )
      .sort((left, right) =>
        right.latestActivityAt.localeCompare(left.latestActivityAt),
      );
  }

  private async buildProjectUnreadStatsMap(
    projectIds: string[],
    viewerOrganizationId: string,
  ) {
    if (!this.unreadQueryService) {
      return new Map(projectIds.map((projectId) => [projectId, this.emptyUnreadStats()]));
    }
    return this.unreadQueryService.buildUnreadStatsForCounterpartProjects(
      projectIds,
      viewerOrganizationId,
    );
  }

  private async buildBusinessStateMap(input: {
    aggregate: SeedConversationAggregate;
    projectMap: Map<string, ProjectEntity>;
    viewerOrganizationId: string;
  }) {
    if (!this.businessStateService) {
      return new Map(
        [...input.aggregate.projectGroups.keys()].map((projectId) => [
          projectId,
          this.emptyBusinessState(),
        ]),
      );
    }
    const entries = await Promise.all([...input.aggregate.projectGroups.keys()].map(async (projectId) => {
      const project = input.projectMap.get(projectId);
      if (!project?.organizationId) {
        return [projectId, this.emptyBusinessState()] as const;
      }
      const state = await this.businessStateService.buildForPair({
        projectId,
        ownerOrganizationId: project.organizationId,
        counterpartOrganizationId: this.resolveThreadCounterpartOrganizationId({
          project,
          aggregate: input.aggregate,
          viewerOrganizationId: input.viewerOrganizationId,
        }),
        viewerOrganizationId: input.viewerOrganizationId,
      });
      return [projectId, state] as const;
    }));
    return new Map(entries);
  }

  private async buildServiceFeeAuthorizationRouteTargetMap(input: {
    aggregate: SeedConversationAggregate;
    projectMap: Map<string, ProjectEntity>;
    viewerOrganizationId: string;
    businessStateByProjectId: Map<string, ProjectCommunicationBusinessState>;
  }) {
    if (!this.bidParticipationRepository) {
      return new Map<string, CounterpartConversationRouteTarget>();
    }
    const candidateProjectIds = [...input.aggregate.projectGroups.keys()]
      .filter((projectId) => {
        const project = input.projectMap.get(projectId);
        const businessState = input.businessStateByProjectId.get(projectId);
        return (
          project?.organizationId &&
          project.organizationId !== input.viewerOrganizationId &&
          businessState?.chatAvailability.requiredNextAction ===
            'complete_service_fee_authorization'
        );
      });
    if (!candidateProjectIds.length) {
      return new Map<string, CounterpartConversationRouteTarget>();
    }
    const requests = await this.bidParticipationRepository.find({
      where: candidateProjectIds.map((projectId) => ({
        projectId,
        requesterOrganizationId: input.viewerOrganizationId,
        state: 'approved',
      })),
      order: { reviewedAt: 'DESC', updatedAt: 'DESC', createdAt: 'DESC' },
    });
    const requestByProjectId = new Map<string, BidParticipationRequestEntity>();
    for (const request of requests) {
      if (!requestByProjectId.has(request.projectId)) {
        requestByProjectId.set(request.projectId, request);
      }
    }
    return new Map(
      candidateProjectIds
        .map((projectId) => {
          const request = requestByProjectId.get(projectId);
          return request
            ? [
                projectId,
                this.toServiceFeeAuthorizationRouteTarget(
                  request,
                  input.aggregate.projectGroups.get(projectId),
                ),
              ] as const
            : null;
        })
        .filter((entry): entry is readonly [
          string,
          CounterpartConversationRouteTarget,
        ] => Boolean(entry)),
    );
  }

  private toServiceFeeAuthorizationRouteTarget(
    request: BidParticipationRequestEntity,
    group: ProjectGroupAggregate | undefined,
  ): CounterpartConversationRouteTarget {
    const bidId = this.serviceFeeAuthorizationBidId(group);
    return {
      objectType: 'bid_service_fee_authorization',
      actionKey: 'bid_service_fee_authorization.open',
      canonicalPath: '/api/app/project/{projectId}/bid-service-fee-authorizations',
      params: {
        projectId: request.projectId,
        bidParticipationRequestId: request.id,
        ...(bidId ? { bidId } : {}),
      },
    };
  }

  private withServiceFeeAuthorizationRouteTarget(
    cards: CounterpartConversationBusinessCardProjection[],
    routeTarget: CounterpartConversationRouteTarget | undefined,
  ) {
    if (!routeTarget) {
      return [...cards];
    }
    return cards.map((card) => {
      if (
        card.cardType !== 'bid_participation_request' ||
        card.truthAnchor.requestId !== routeTarget.params.bidParticipationRequestId
      ) {
        return card;
      }
      return {
        ...card,
        detailRouteTarget: routeTarget,
      };
    });
  }

  private serviceFeeAuthorizationBidId(group: ProjectGroupAggregate | undefined) {
    return group?.cards.find((card) => card.truthAnchor.bidId)?.truthAnchor.bidId ?? null;
  }

  private async buildProjectCommunicationThreadIdMap(input: {
    aggregate: SeedConversationAggregate;
    projectMap: Map<string, ProjectEntity>;
    viewerOrganizationId: string;
  }) {
    const projectGroups = [...input.aggregate.projectGroups.entries()];
    if (!this.threadRepository) {
      return new Map(
        projectGroups
          .map(([projectId, group]) => [
            projectId,
            this.legacyProjectCommunicationThreadId(group),
          ] as const)
          .filter((entry): entry is readonly [string, string] => Boolean(entry[1])),
      );
    }
    const lookup = projectGroups
      .map(([projectId]) => {
        const project = input.projectMap.get(projectId);
        const ownerOrganizationId = project?.organizationId?.trim() ?? '';
        const counterpartOrganizationId = project
          ? this.resolveThreadCounterpartOrganizationId({
              project,
              aggregate: input.aggregate,
              viewerOrganizationId: input.viewerOrganizationId,
            })
          : '';
        if (
          !ownerOrganizationId ||
          !counterpartOrganizationId ||
          ownerOrganizationId === counterpartOrganizationId
        ) {
          return null;
        }
        return {
          projectId,
          ownerOrganizationId,
          counterpartOrganizationId,
        };
      })
      .filter((item): item is {
        projectId: string;
        ownerOrganizationId: string;
        counterpartOrganizationId: string;
      } => Boolean(item));
    if (!lookup.length) {
      return new Map<string, string>();
    }
    const threads = await this.threadRepository.find({
      where: lookup.map((item) => ({
        projectId: item.projectId,
        ownerOrganizationId: item.ownerOrganizationId,
        counterpartOrganizationId: item.counterpartOrganizationId,
      })),
    });
    const threadIdByPair = new Map(
      threads.map((thread) => [
        this.projectThreadKey({
          projectId: thread.projectId,
          ownerOrganizationId: thread.ownerOrganizationId,
          counterpartOrganizationId: thread.counterpartOrganizationId,
        }),
        thread.id,
      ]),
    );
    return new Map(
      lookup
        .map((item) => [
          item.projectId,
          threadIdByPair.get(this.projectThreadKey(item)),
        ] as const)
        .filter((entry): entry is readonly [string, string] => Boolean(entry[1])),
    );
  }

  private legacyProjectCommunicationThreadId(group: ProjectGroupAggregate) {
    return group.cards.find((card) => card.truthAnchor.threadId)?.truthAnchor.threadId ?? null;
  }

  private resolveThreadCounterpartOrganizationId(input: {
    project: ProjectEntity;
    aggregate: SeedConversationAggregate;
    viewerOrganizationId: string;
  }) {
    const ownerOrganizationId = input.project.organizationId?.trim() ?? '';
    return input.aggregate.counterpart.organizationId === ownerOrganizationId
      ? input.viewerOrganizationId
      : input.aggregate.counterpart.organizationId;
  }

  private projectThreadKey(input: {
    projectId: string;
    ownerOrganizationId: string;
    counterpartOrganizationId: string;
  }) {
    return [
      input.projectId,
      input.ownerOrganizationId,
      input.counterpartOrganizationId,
    ].join(':');
  }

  private summarizeProjectGroupUnread(
    projectGroups: CounterpartConversationProjectGroupProjection[],
  ) {
    return projectGroups.reduce(
      (summary, group) => {
        const unreadCount = group.projectUnreadCount;
        summary.conversationUnreadCount += unreadCount;
        summary.latestUnreadMessageAt = this.maxIso(
          summary.latestUnreadMessageAt,
          group.latestUnreadMessageAt,
        );
        if (group.projectRelation === 'my_published') {
          summary.myPublishedUnreadCount += unreadCount;
        }
        if (group.projectRelation === 'my_bid') {
          summary.myBidUnreadCount += unreadCount;
        }
        return summary;
      },
      {
        conversationUnreadCount: 0,
        latestUnreadMessageAt: null as string | null,
        myPublishedUnreadCount: 0,
        myBidUnreadCount: 0,
      },
    );
  }

  private maxIso(left: string | null, right: string | null) {
    if (!right) {
      return left;
    }
    if (!left) {
      return right;
    }
    return left >= right ? left : right;
  }

  private emptyUnreadStats(): ProjectCommunicationUnreadStats {
    return {
      unreadCount: 0,
      hasUnread: false,
      latestUnreadMessageAt: null,
    };
  }

  private emptyBusinessTodoSummary(): ProjectCommunicationBusinessTodoSummary {
    return (
      this.businessStateService?.emptyBusinessTodoSummary() ?? {
        bidParticipationReviewPendingCount: 0,
        publisherMaterialReviewPendingCount: 0,
        bidMaterialReviewPendingCount: 0,
        dealConfirmationPendingCount: 0,
        totalPendingCount: 0,
      }
    );
  }

  private emptyBusinessState(): ProjectCommunicationBusinessState {
    return {
      businessTodoSummary: this.emptyBusinessTodoSummary(),
      chatAvailability: {
        canSendMessage: false,
        lockReasonCode: null,
        lockReasonText: null,
        requiredNextAction: 'none',
      },
    };
  }

  private buildCounterpartProjectDisplayTitle(input: {
    project: ProjectEntity | undefined;
    projection:
      | {
          displayTitle: string;
          nameAccess: { status: string };
        }
      | undefined;
    titleVisibility: 'masked' | 'visible';
  }) {
    if (input.titleVisibility === 'masked') {
      return (
        this.normalizeTitle(input.projection?.displayTitle) ??
        PROJECT_NAME_ACCESS_MASKED_TITLE
      );
    }

    return (
      this.normalizeTitle(input.project?.title) ??
      this.composeExhibitionBrandTitle(input.project) ??
      this.normalizeTitle(input.projection?.displayTitle) ??
      '未命名项目'
    );
  }

  private composeExhibitionBrandTitle(project: ProjectEntity | undefined) {
    if (!project) {
      return null;
    }
    const exhibitionName = this.normalizeTitle(project.exhibitionName);
    const brandName = this.normalizeTitle(project.brandName);
    if (exhibitionName && brandName) {
      return `${exhibitionName} - ${brandName}`;
    }
    return exhibitionName ?? brandName;
  }

  private normalizeTitle(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized || null;
  }

  private resolveProjectRelation(input: {
    project: ProjectEntity | undefined;
    viewerOrganizationId: string;
  }): CounterpartConversationProjectGroupProjection['projectRelation'] {
    if (!input.project) {
      return 'unknown';
    }
    return input.project.organizationId === input.viewerOrganizationId
      ? 'my_published'
      : 'my_bid';
  }

  private sortProjectGroups(
    projectGroups: CounterpartConversationProjectGroupProjection[],
    focusProjectId: string,
  ) {
    return [...projectGroups].sort((left, right) => {
      if (left.projectId === focusProjectId) {
        return -1;
      }
      if (right.projectId === focusProjectId) {
        return 1;
      }
      return right.latestActivityAt.localeCompare(left.latestActivityAt);
    });
  }

  private async buildRatingEntryMap(
    projectIds: string[],
    viewerOrganizationId: string,
  ) {
    if (!projectIds.length) {
      return new Map<string, CounterpartConversationRatingEntryProjection>();
    }
    const rows = (await this.projectRepository.query(
      `
        select
          "order".id as "orderId",
          "order".project_id as "projectId",
          "order".buyer_organization_id as "buyerOrganizationId",
          "order".supplier_organization_id as "supplierOrganizationId",
          "order".state as "orderState",
          rating.state as "ratingState"
        from public.orders "order"
        left join lateral (
          select state
          from public.ratings rating
          where rating.order_id = "order".id
          order by rating.updated_at desc nulls last, rating.created_at desc nulls last, rating.id desc
          limit 1
        ) rating on true
        where "order".project_id = any($1::varchar[])
          and (
            "order".buyer_organization_id = $2
            or "order".supplier_organization_id = $2
          )
      `,
      [projectIds, viewerOrganizationId],
    )) as RatingOrderRow[];
    const map = new Map<string, CounterpartConversationRatingEntryProjection>();
    for (const row of rows) {
      const counterpartOrganizationId =
        row.buyerOrganizationId === viewerOrganizationId
          ? row.supplierOrganizationId
          : row.buyerOrganizationId;
      if (!counterpartOrganizationId) {
        continue;
      }
      const canRate =
        row.buyerOrganizationId === viewerOrganizationId &&
        row.orderState === 'completed' &&
        row.ratingState === 'draft';
      map.set(this.ratingEntryKey(row.projectId, counterpartOrganizationId), {
        orderId: row.orderId,
        projectId: row.projectId,
        rateeOrganizationId: counterpartOrganizationId,
        canRate,
        reason: this.ratingUnavailableReason(row, viewerOrganizationId),
        ratingState: row.ratingState,
      });
    }
    return map;
  }

  private ratingUnavailableReason(
    row: RatingOrderRow,
    viewerOrganizationId: string,
  ) {
    if (row.buyerOrganizationId !== viewerOrganizationId) {
      return '当前最小评价接口仅开放发布方/买方评价。';
    }
    if (row.orderState !== 'completed') {
      return '当前项目尚未结束，评价入口不会开放。';
    }
    if (row.ratingState !== 'draft') {
      return '当前评价已提交或暂不可重复提交。';
    }
    return null;
  }

  private ratingEntryKey(projectId: string, counterpartOrganizationId: string) {
    return `${projectId}:${counterpartOrganizationId}`;
  }
}
