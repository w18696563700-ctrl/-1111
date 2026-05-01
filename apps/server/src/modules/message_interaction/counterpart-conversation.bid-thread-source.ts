import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { BidEntity } from '../bid/entities/bid.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { InquiryQuoteDepositEntity } from '../p0_pay/entities/inquiry-quote-deposit.entity';
import { PlatformServiceFeeAuthorizationEntity } from '../p0_pay/entities/platform-service-fee-authorization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidThreadMessageEntity } from '../trading_im/entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from '../trading_im/entities/bid-private-thread.entity';
import {
  buildBidThreadRouteTarget,
  TRADING_IM_MESSAGE_KIND_SYSTEM_SEED,
} from '../trading_im/trading-im-system-seed.support';
import { trimConversationText } from './counterpart-conversation.support';
import { CounterpartConversationAvatarService } from './counterpart-conversation-avatar.service';
import { CounterpartConversationDisplayNameService } from './counterpart-conversation-display-name.service';
import {
  CounterpartConversationCardSeed,
  CounterpartConversationCardSource,
} from './counterpart-conversation.seed';

@Injectable()
export class CounterpartConversationBidThreadSource
  implements CounterpartConversationCardSource
{
  constructor(
    @InjectRepository(BidPrivateThreadEntity)
    private readonly threadRepository: Repository<BidPrivateThreadEntity>,
    @InjectRepository(BidThreadMessageEntity)
    private readonly messageRepository: Repository<BidThreadMessageEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository: Repository<PlatformServiceFeeAuthorizationEntity>,
    @InjectRepository(InquiryQuoteDepositEntity)
    private readonly depositRepository: Repository<InquiryQuoteDepositEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    private readonly avatarService: CounterpartConversationAvatarService,
    private readonly displayNameService: CounterpartConversationDisplayNameService,
  ) {}

  async buildSeeds(viewerOrganizationId: string) {
    const threads = await this.threadRepository.find({
      where: [
        { projectOwnerOrganizationId: viewerOrganizationId },
        { bidderOrganizationId: viewerOrganizationId },
      ],
      order: { updatedAt: 'DESC', createdAt: 'DESC' },
    });
    if (!threads.length) {
      return [];
    }

    const context = await this.loadContext(threads);
    const counterpart = await this.loadCounterpartContext(
      threads,
      context.projectMap,
      context.bidMap,
      viewerOrganizationId,
    );
    const seeds: CounterpartConversationCardSeed[] = [];
    for (const thread of threads) {
      const seed = await this.toSeed({
        thread,
        viewerOrganizationId,
        context,
        counterpart,
      });
      if (seed) {
        seeds.push(seed);
      }
    }
    return seeds;
  }

  private async loadContext(threads: BidPrivateThreadEntity[]) {
    const projectIds = [...new Set(threads.map((item) => item.projectId))];
    const bidIds = [...new Set(threads.map((item) => item.bidId))];
    const threadIds = threads.map((item) => item.id);
    const [projects, bids, messages, authorizations, deposits] = await Promise.all([
      this.projectRepository.findBy({ id: In(projectIds) }),
      this.bidRepository.findBy({ id: In(bidIds) }),
      this.messageRepository.find({
        where: { threadId: In(threadIds) },
        order: { threadId: 'ASC', createdAt: 'DESC' },
      }),
      this.authorizationRepository.find({
        where: { taskId: In(projectIds) },
        order: { taskId: 'ASC', updatedAt: 'DESC' },
      }),
      this.depositRepository.find({
        where: { taskId: In(projectIds) },
        order: { taskId: 'ASC', updatedAt: 'DESC' },
      }),
    ]);
    const latestMessageByThreadId = new Map<string, BidThreadMessageEntity>();
    for (const message of messages) {
      if (!latestMessageByThreadId.has(message.threadId)) {
        latestMessageByThreadId.set(message.threadId, message);
      }
    }
    return {
      projectMap: new Map(projects.map((item) => [item.id, item])),
      bidMap: new Map(bids.map((item) => [item.id, item])),
      authorizationByTaskId: this.latestByTaskId(authorizations),
      depositByTaskId: this.latestByTaskId(deposits),
      latestMessageByThreadId,
    };
  }

  private async loadCounterpartContext(
    threads: BidPrivateThreadEntity[],
    projectMap: Map<string, ProjectEntity>,
    bidMap: Map<string, BidEntity>,
    viewerOrganizationId: string,
  ) {
    const organizationIds = new Set<string>();
    const userIds = new Set<string>();
    for (const thread of threads) {
      const project = projectMap.get(thread.projectId);
      const bid = bidMap.get(thread.bidId);
      if (!project || !bid) {
        continue;
      }
      const isOwnerViewer = project.organizationId === viewerOrganizationId;
      organizationIds.add(
        isOwnerViewer
          ? bid.bidderOrganizationId || bid.organizationId
          : project.organizationId,
      );
      const userId = isOwnerViewer
        ? bid.userId?.trim() ?? ''
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
    thread: BidPrivateThreadEntity;
    viewerOrganizationId: string;
    context: Awaited<ReturnType<CounterpartConversationBidThreadSource['loadContext']>>;
    counterpart: Awaited<ReturnType<CounterpartConversationBidThreadSource['loadCounterpartContext']>>;
  }) {
    const project = input.context.projectMap.get(input.thread.projectId);
    const bid = input.context.bidMap.get(input.thread.bidId);
    if (!project || !bid) {
      return null;
    }
    const isOwnerViewer = project.organizationId === input.viewerOrganizationId;
    const counterpartOrganizationId = isOwnerViewer
      ? bid.bidderOrganizationId || bid.organizationId
      : project.organizationId;
    const counterpartUserId = isOwnerViewer
      ? bid.userId?.trim() ?? ''
      : project.creatorUserId?.trim() ?? '';
    const counterpartUser = counterpartUserId
      ? input.counterpart.userMap.get(counterpartUserId)
      : null;
    const counterpartCompanyName = this.displayNameService.resolveCompanyName({
      organizationId: counterpartOrganizationId,
      organizationMap: input.counterpart.organizationMap,
      approvedLegalNameByOrganizationId:
        input.counterpart.approvedLegalNameByOrganizationId,
      fallback: bid.submittedBy,
    });
    const counterpartDisplayName = counterpartCompanyName;
    const latestMessage = input.context.latestMessageByThreadId.get(input.thread.id);
    const updatedAt = (
      latestMessage?.createdAt ??
      bid.submittedAt ??
      input.thread.updatedAt
    ).toISOString();
    return {
      counterpartOrganizationId,
      counterpartDisplayName,
      counterpartNickname: this.displayNameService.resolveNickname(counterpartUser),
      counterpartCompanyName,
      counterpartAvatarUrl: await this.avatarService.readAvatarUrl(
        counterpartUser?.avatarUrl ?? null,
      ),
      counterpartCertificationSummary:
        input.counterpart.approvedCertificationSummaryByOrganizationId.get(
          counterpartOrganizationId,
        ) ?? null,
      projectId: input.thread.projectId,
      pricingSummary: this.buildPricingSummary(project, input.context),
      updatedAt,
      card: {
        cardId: `bid-thread:${input.thread.id}`,
        cardType: 'bid_thread' as const,
        title:
          latestMessage?.senderRole === TRADING_IM_MESSAGE_KIND_SYSTEM_SEED
            ? '新的竞标已提交'
            : '竞标沟通',
        summary: latestMessage
          ? trimConversationText(latestMessage.body)
          : `${counterpartDisplayName} 已对当前项目提交竞标。`,
        status: input.thread.lifecycleState,
        updatedAt,
        requesterCompanyName: null,
        requesterOrganizationId: null,
        truthAnchor: {
          truthType: 'bid_thread' as const,
          projectId: input.thread.projectId,
          bidId: input.thread.bidId,
          threadId: input.thread.id,
        },
        detailRouteTarget: buildBidThreadRouteTarget({
          threadId: input.thread.id,
          projectId: input.thread.projectId,
          bidId: input.thread.bidId,
        }),
        decisionAvailability: null,
      },
    };
  }

  private latestByTaskId<T extends { taskId: string }>(items: T[]) {
    const map = new Map<string, T>();
    for (const item of items) {
      if (!map.has(item.taskId)) {
        map.set(item.taskId, item);
      }
    }
    return map;
  }

  private buildPricingSummary(
    project: ProjectEntity,
    context: Awaited<ReturnType<CounterpartConversationBidThreadSource['loadContext']>>,
  ) {
    const authorization = context.authorizationByTaskId.get(project.id);
    const deposit = context.depositByTaskId.get(project.id);
    if (!authorization && !deposit) {
      return undefined;
    }
    return {
      projectId: project.id,
      pricingRuleVersion: authorization?.ruleVersion ?? deposit?.ruleVersion ?? null,
      readOnly: true,
      bidServiceFeeAuthorization: authorization
        ? {
            authorizationId: authorization.id,
            status: authorization.status,
            quotaAmount: authorization.authorizationQuotaAmount ?? '4000.00',
            chargedAmountUsed: authorization.chargedAmountUsed,
            releasedAmount: authorization.releasedAmount,
            finalFeeAmount: authorization.finalFeeAmount,
            currency: 'CNY',
          }
        : { status: 'not_required' },
      projectAuthenticitySincerity: deposit
        ? { orderId: deposit.id, status: deposit.status, amount: deposit.amount, currency: deposit.currency }
        : { status: 'not_required' },
      dealConfirmation: { status: authorization?.status === 'charged' ? 'confirmed_deal' : 'not_confirmed' },
      messageDisplaySummary: {
        displayAllowed: true,
        readOnly: true,
        statusTextKey: authorization?.status ?? deposit?.status ?? 'pricing_status_unavailable',
        routeTarget: {
          objectType: 'project_pricing',
          actionKey: 'pricing_summary.read',
          canonicalPath: `/api/app/project/${project.id}/pricing-summary`,
          params: { projectId: project.id },
        },
      },
      updatedAt: project.updatedAt.toISOString(),
    };
  }

}
