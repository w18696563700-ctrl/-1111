import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidThreadMessageEntity } from '../trading_im/entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from '../trading_im/entities/bid-private-thread.entity';
import { buildBidThreadRouteTarget } from '../trading_im/trading-im-system-seed.support';
import {
  messageInteractionForbidden,
  messageInteractionInvalid,
} from './message-interaction.errors';
import { MessageInteractionPresenter } from './message-interaction.presenter';

type InteractionLane = 'project_communication';

@Injectable()
export class MessageInteractionQueryService {
  constructor(
    @InjectRepository(BidPrivateThreadEntity)
    private readonly threadRepository: Repository<BidPrivateThreadEntity>,
    @InjectRepository(BidThreadMessageEntity)
    private readonly messageRepository: Repository<BidThreadMessageEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: MessageInteractionPresenter,
  ) {}

  async listInteractions(lane: string | undefined, context: RequestContext) {
    const normalizedLane = this.readLane(lane);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw messageInteractionForbidden(
        'Current organization scope is required for message interactions.',
      );
    }

    const threads = await this.threadRepository.find({
      where: [
        { projectOwnerOrganizationId: organizationId },
        { bidderOrganizationId: organizationId },
      ],
      order: { updatedAt: 'DESC', createdAt: 'DESC' },
    });
    if (!threads.length) {
      return this.presenter.toListResponse(normalizedLane, []);
    }

    const projectIds = [...new Set(threads.map((item) => item.projectId))];
    const bidIds = [...new Set(threads.map((item) => item.bidId))];
    const threadIds = threads.map((item) => item.id);
    const [projects, bids, messages] = await Promise.all([
      this.projectRepository.findBy({ id: In(projectIds) }),
      this.bidRepository.findBy({ id: In(bidIds) }),
      this.messageRepository.find({
        where: { threadId: In(threadIds) },
        order: { threadId: 'ASC', createdAt: 'DESC' },
      }),
    ]);

    const projectMap = new Map(projects.map((item) => [item.id, item]));
    const bidMap = new Map(bids.map((item) => [item.id, item]));
    const latestMessageByThreadId = new Map<string, BidThreadMessageEntity>();
    for (const message of messages) {
      if (!latestMessageByThreadId.has(message.threadId)) {
        latestMessageByThreadId.set(message.threadId, message);
      }
    }

    const counterpartOrganizationIds = new Set<string>();
    const counterpartUserIds = new Set<string>();
    for (const thread of threads) {
      const bid = bidMap.get(thread.bidId);
      const project = projectMap.get(thread.projectId);
      if (!bid || !project) {
        continue;
      }
      const counterpartRole = organizationId === project.organizationId ? 'bidder' : 'project_owner';
      counterpartOrganizationIds.add(
        counterpartRole === 'bidder'
          ? bid.bidderOrganizationId || bid.organizationId
          : project.organizationId,
      );
      const counterpartUserId =
        counterpartRole === 'bidder' ? bid.userId?.trim() ?? '' : project.creatorUserId?.trim() ?? '';
      if (counterpartUserId) {
        counterpartUserIds.add(counterpartUserId);
      }
    }

    const [organizations, users] = await Promise.all([
      counterpartOrganizationIds.size
        ? this.organizationRepository.findBy({ id: In([...counterpartOrganizationIds]) })
        : Promise.resolve([]),
      counterpartUserIds.size
        ? this.userRepository.findBy({ id: In([...counterpartUserIds]) })
        : Promise.resolve([]),
    ]);
    const organizationMap = new Map(organizations.map((item) => [item.id, item]));
    const userMap = new Map(users.map((item) => [item.id, item]));

    const items = [];
    for (const thread of threads) {
      const project = projectMap.get(thread.projectId);
      const bid = bidMap.get(thread.bidId);
      if (!project || !bid) {
        continue;
      }
      const counterpartRole = organizationId === project.organizationId ? 'bidder' : 'project_owner';
      const counterpartOrganizationId =
        counterpartRole === 'bidder'
          ? bid.bidderOrganizationId || bid.organizationId
          : project.organizationId;
      const counterpartUserId =
        counterpartRole === 'bidder' ? bid.userId?.trim() ?? '' : project.creatorUserId?.trim() ?? '';
      const counterpartOrganization = organizationMap.get(counterpartOrganizationId);
      const counterpartUser = counterpartUserId ? userMap.get(counterpartUserId) : null;
      const counterpartDisplayName =
        counterpartUser?.nickname?.trim() ||
        counterpartOrganization?.name?.trim() ||
        bid.submittedBy ||
        '当前沟通对象';
      const latestMessage = latestMessageByThreadId.get(thread.id);
      const lastMessageSummary = this.toLastMessageSummary(latestMessage);
      items.push({
        interactionId: thread.id,
        interactionType: 'bid_thread' as const,
        threadId: thread.id,
        projectId: thread.projectId,
        bidId: thread.bidId,
        counterpart: {
          organizationId: counterpartOrganizationId,
          displayName: counterpartDisplayName,
          avatarUrl: counterpartUser?.avatarUrl?.trim() || null,
          role: counterpartRole,
        },
        seedSummary: {
          seedType: 'bid_submitted' as const,
          title: '新的竞标已提交',
          summary: `${counterpartDisplayName} 已对当前项目提交竞标。`,
          ctaLabel: '点击查看',
        },
        lastMessageSummary,
        updatedAt: (latestMessage?.createdAt ?? bid.submittedAt ?? thread.updatedAt).toISOString(),
        routeTarget: buildBidThreadRouteTarget({
          threadId: thread.id,
          projectId: thread.projectId,
          bidId: thread.bidId,
        }),
      });
    }

    return this.presenter.toListResponse(normalizedLane, items);
  }

  private readLane(value: string | undefined): InteractionLane {
    const normalized = value?.trim() ?? '';
    if (!normalized || normalized === 'project_communication') {
      return 'project_communication';
    }
    throw messageInteractionInvalid('Field `lane` only admits `project_communication`.');
  }

  private toLastMessageSummary(message: BidThreadMessageEntity | undefined) {
    if (!message) {
      return '当前竞标已提交，可继续进入沟通。';
    }
    const body = message.body.trim();
    return body.length > 120 ? `${body.slice(0, 117)}...` : body;
  }
}
