import { Injectable, Optional } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectCommunicationUnreadQueryService } from '../project_communication/project-communication-unread.query.service';
import { ProjectNameAccessProjectionService } from '../project_name_access/project-name-access-projection.service';
import { PROJECT_NAME_ACCESS_MASKED_TITLE } from '../project_name_access/project-name-access.support';
import { messageInteractionUnavailable } from './message-interaction.errors';
import { CounterpartConversationBidParticipationSource } from './counterpart-conversation.bid-participation-source';
import { CounterpartConversationBidThreadSource } from './counterpart-conversation.bid-thread-source';
import { CounterpartConversationClarificationSource } from './counterpart-conversation.clarification-source';
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
} from './counterpart-conversation.types';
import { buildCounterpartConversationRouteTarget } from './counterpart-conversation.support';

type ConversationAggregate = {
  conversationId: string;
  counterpart: CounterpartConversationDetailProjection['counterpart'];
  summary: CounterpartConversationDetailProjection['summary'];
  focusProjectId: string;
  pricingSummary?: Record<string, unknown>;
  latestActivityAt: string;
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
  ) {
    this.cardSources = [
      bidThreadSource,
      bidParticipationSource,
      clarificationSource,
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
      }),
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
      projectGroups: this.sortProjectGroups(conversation.projectGroups, focusProjectId),
    };
  }

  private async buildConversationCatalog(viewerOrganizationId: string) {
    const seeds = await this.loadCardSeeds(viewerOrganizationId);
    if (!seeds.length) {
      return [];
    }

    const projectIds = [...new Set(seeds.map((item) => item.projectId))];
    const [projects, ratingEntryMap, unreadByProjectId] = await Promise.all([
      this.projectRepository.findBy({ id: In(projectIds) }),
      this.buildRatingEntryMap(projectIds, viewerOrganizationId),
      this.buildProjectUnreadMap(projectIds, viewerOrganizationId),
    ]);
    const projectMap = new Map(projects.map((item) => [item.id, item]));
    const nameAccessProjectionMap = await this.buildNameAccessProjectionMap({
      projects,
      viewerOrganizationId,
    });
    const conversationMap = this.groupSeedsByConversation(seeds);

    return [...conversationMap.entries()]
      .map(([conversationId, aggregate]): ConversationAggregate => {
        const projectGroups = this.buildProjectGroups({
          aggregate,
          projectMap,
          nameAccessProjectionMap,
          viewerOrganizationId,
          ratingEntryMap,
          unreadByProjectId,
        });
        const focusProject = projectGroups[0];
        const latestCard = focusProject.cards[0];
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
          ...(focusProject.pricingSummary ? { pricingSummary: focusProject.pricingSummary } : {}),
          latestActivityAt: aggregate.latestActivityAt,
          projectGroups,
        };
      })
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
    unreadByProjectId: Map<string, number>;
    nameAccessProjectionMap: Awaited<
      ReturnType<ProjectNameAccessProjectionService['buildPublicProjectionMap']>
    >;
  }) {
    return [...input.aggregate.projectGroups.entries()]
      .map(([projectId, group]): CounterpartConversationProjectGroupProjection => {
        const project = input.projectMap.get(projectId);
        const projection = input.nameAccessProjectionMap.get(projectId);
        const titleVisibility =
          projection?.nameAccess.status === 'visible' ? 'visible' : 'masked';
        const projectUnreadCount = input.unreadByProjectId.get(projectId) ?? 0;
        return {
          projectId,
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
          projectUnreadCount,
          hasProjectUnread: projectUnreadCount > 0,
          ...(group.pricingSummary ? { pricingSummary: group.pricingSummary } : {}),
          ratingEntry:
            input.ratingEntryMap.get(
              this.ratingEntryKey(projectId, input.aggregate.counterpart.organizationId),
            ) ?? null,
          cards: [...group.cards].sort((left, right) =>
            right.updatedAt.localeCompare(left.updatedAt),
          ),
        };
      })
      .sort((left, right) =>
        right.latestActivityAt.localeCompare(left.latestActivityAt),
      );
  }

  private async buildProjectUnreadMap(
    projectIds: string[],
    viewerOrganizationId: string,
  ) {
    if (!this.unreadQueryService) {
      return new Map(projectIds.map((projectId) => [projectId, 0]));
    }
    return this.unreadQueryService.buildUnreadMapForCounterpartProjects(
      projectIds,
      viewerOrganizationId,
    );
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
