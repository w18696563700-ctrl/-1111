import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { BidEntity } from '../bid/entities/bid.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectClarificationEntity } from '../trading_im/entities/project-clarification.entity';
import {
  buildProjectClarificationRouteTarget,
  trimConversationText,
} from './counterpart-conversation.support';
import { CounterpartConversationAvatarService } from './counterpart-conversation-avatar.service';
import { CounterpartConversationDisplayNameService } from './counterpart-conversation-display-name.service';
import {
  CounterpartConversationCardSeed,
  CounterpartConversationCardSource,
} from './counterpart-conversation.seed';

@Injectable()
export class CounterpartConversationClarificationSource
  implements CounterpartConversationCardSource
{
  constructor(
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(ProjectClarificationEntity)
    private readonly clarificationRepository: Repository<ProjectClarificationEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly avatarService: CounterpartConversationAvatarService,
    private readonly displayNameService: CounterpartConversationDisplayNameService,
  ) {}

  async buildSeeds(viewerOrganizationId: string) {
    const context = await this.loadProjectContext(viewerOrganizationId);
    if (!context.projectIds.size) {
      return [];
    }

    const [projects, clarifications] = await Promise.all([
      this.projectRepository.findBy({ id: In([...context.projectIds]) }),
      this.clarificationRepository.find({
        where: { projectId: In([...context.projectIds]), lifecycleState: 'active' },
        order: { updatedAt: 'DESC', createdAt: 'DESC' },
      }),
    ]);
    if (!clarifications.length) {
      return [];
    }

    const projectMap = new Map(projects.map((item) => [item.id, item]));
    const counterpart = await this.loadCounterpartContext({
      clarifications,
      projectMap,
      bidderProjectIds: context.bidderProjectIds,
      viewerOrganizationId,
    });
    const seeds: CounterpartConversationCardSeed[] = [];
    for (const clarification of clarifications) {
      const seed = await this.toSeed({
        clarification,
        projectMap,
        bidderProjectIds: context.bidderProjectIds,
        counterpart,
        viewerOrganizationId,
      });
      if (seed) {
        seeds.push(seed);
      }
    }
    return seeds;
  }

  private async loadProjectContext(viewerOrganizationId: string) {
    const [ownedProjects, viewerBids] = await Promise.all([
      this.projectRepository.find({
        where: { organizationId: viewerOrganizationId },
        order: { updatedAt: 'DESC', createdAt: 'DESC' },
      }),
      this.bidRepository.find({
        where: [
          { bidderOrganizationId: viewerOrganizationId },
          { organizationId: viewerOrganizationId },
        ],
        order: { updatedAt: 'DESC', createdAt: 'DESC' },
      }),
    ]);
    const bidderProjectIds = new Set(viewerBids.map((item) => item.projectId));
    return {
      bidderProjectIds,
      projectIds: new Set(
        ownedProjects.map((item) => item.id).concat([...bidderProjectIds]),
      ),
    };
  }

  private async loadCounterpartContext(input: {
    clarifications: ProjectClarificationEntity[];
    projectMap: Map<string, ProjectEntity>;
    bidderProjectIds: Set<string>;
    viewerOrganizationId: string;
  }) {
    const organizationIds = new Set<string>();
    const userIds = new Set<string>();
    for (const clarification of input.clarifications) {
      const project = this.readVisibleProject(input.projectMap, clarification.projectId);
      if (!project) {
        continue;
      }
      if (project.organizationId === input.viewerOrganizationId) {
        const organizationId = clarification.authorOrganizationId.trim();
        if (!organizationId || organizationId === input.viewerOrganizationId) {
          continue;
        }
        organizationIds.add(organizationId);
        this.addOptional(userIds, clarification.authorUserId);
        continue;
      }
      if (
        input.bidderProjectIds.has(project.id) &&
        clarification.authorOrganizationId === project.organizationId
      ) {
        organizationIds.add(project.organizationId);
        this.addOptional(userIds, project.creatorUserId);
      }
    }
    if (!organizationIds.size) {
      return {
        organizationMap: new Map<string, OrganizationEntity>(),
        userMap: new Map<string, UserEntity>(),
        approvedLegalNameByOrganizationId: new Map<string, string>(),
      };
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
    clarification: ProjectClarificationEntity;
    projectMap: Map<string, ProjectEntity>;
    bidderProjectIds: Set<string>;
    counterpart: Awaited<ReturnType<CounterpartConversationClarificationSource['loadCounterpartContext']>>;
    viewerOrganizationId: string;
  }) {
    const project = this.readVisibleProject(
      input.projectMap,
      input.clarification.projectId,
    );
    if (!project) {
      return null;
    }
    const identity = await this.readCounterpartIdentity(input, project);
    if (!identity) {
      return null;
    }
    const updatedAt = (
      input.clarification.updatedAt ??
      input.clarification.createdAt
    ).toISOString();
    return {
      ...identity,
      projectId: input.clarification.projectId,
      updatedAt,
      card: {
        cardId: `project-clarification:${input.clarification.id}`,
        cardType: 'project_clarification' as const,
        title: '项目澄清',
        summary: trimConversationText(input.clarification.body),
        status: input.clarification.lifecycleState,
        updatedAt,
        truthAnchor: {
          truthType: 'project_clarification' as const,
          projectId: input.clarification.projectId,
          clarificationId: input.clarification.id,
        },
        detailRouteTarget: buildProjectClarificationRouteTarget(
          input.clarification.projectId,
        ),
        decisionAvailability: null,
      },
    };
  }

  private async readCounterpartIdentity(
    input: {
      clarification: ProjectClarificationEntity;
      bidderProjectIds: Set<string>;
      counterpart: Awaited<ReturnType<CounterpartConversationClarificationSource['loadCounterpartContext']>>;
      viewerOrganizationId: string;
    },
    project: ProjectEntity,
  ) {
    if (project.organizationId === input.viewerOrganizationId) {
      const organizationId = input.clarification.authorOrganizationId.trim();
      if (!organizationId || organizationId === input.viewerOrganizationId) {
        return null;
      }
      return this.toIdentity(
        organizationId,
        input.clarification.authorUserId,
        input.counterpart,
      );
    }
    if (!input.bidderProjectIds.has(project.id)) {
      return null;
    }
    if (input.clarification.authorOrganizationId !== project.organizationId) {
      return null;
    }
    return this.toIdentity(project.organizationId, project.creatorUserId, input.counterpart);
  }

  private async toIdentity(
    organizationId: string,
    userId: string | null | undefined,
    counterpart: Awaited<ReturnType<CounterpartConversationClarificationSource['loadCounterpartContext']>>,
  ) {
    const counterpartUser = userId ? counterpart.userMap.get(userId) : null;
    return {
      counterpartOrganizationId: organizationId,
      counterpartDisplayName: this.displayNameService.resolveDisplayName({
        organizationId,
        organizationMap: counterpart.organizationMap,
        approvedLegalNameByOrganizationId:
          counterpart.approvedLegalNameByOrganizationId,
      }),
      counterpartAvatarUrl: await this.avatarService.readAvatarUrl(
        counterpartUser?.avatarUrl ?? null,
      ),
    };
  }

  private readVisibleProject(projectMap: Map<string, ProjectEntity>, projectId: string) {
    const project = projectMap.get(projectId);
    if (!project || project.state === 'archived' || project.publishedAt == null) {
      return null;
    }
    return project;
  }

  private addOptional(values: Set<string>, value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    if (normalized) {
      values.add(normalized);
    }
  }
}
