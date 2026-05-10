import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash } from 'crypto';
import { In, Repository } from 'typeorm';
import { BidEntity } from '../bid/entities/bid.entity';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import { ContractConfirmationEntity } from '../p0_pay/entities/contract-confirmation.entity';
import { PlatformServiceFeeAuthorizationEntity } from '../p0_pay/entities/platform-service-fee-authorization.entity';
import { BID_SERVICE_FEE_AUTHORIZATION_QUOTA_AMOUNT } from '../p0_pay/p0-pay.state';
import { ProjectAttachmentEntity } from '../project/entities/project-attachment.entity';
import { ProjectCommunicationMaterialReviewEntity } from './entities/project-communication-material-review.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import {
  PROJECT_COMMUNICATION_NO_BID_REVIEW_BID_ID,
  ProjectBidMaterialSlot,
  ProjectCommunicationWorkbenchEntryDefinition,
  ProjectQuoteBasisMaterialKind,
  projectCommunicationWorkbenchEntryDefinitions
} from './project-communication-workbench.types';

export type ProjectCommunicationBusinessTodoSummary = {
  bidParticipationReviewPendingCount: number;
  publisherMaterialReviewPendingCount: number;
  bidMaterialReviewPendingCount: number;
  dealConfirmationPendingCount: number;
  totalPendingCount: number;
};

export type ProjectCommunicationChatAvailability = {
  canSendMessage: boolean;
  lockReasonCode:
    | 'bid_participation_review_pending'
    | 'publisher_material_confirmation_pending'
    | 'bid_submission_pending'
    | 'bid_material_confirmation_pending'
    | 'service_fee_authorization_pending'
    | 'deal_confirmation_pending'
    | null;
  lockReasonText: string | null;
  requiredNextAction:
    | 'review_bid_participation'
    | 'confirm_publisher_materials'
    | 'submit_bid_materials'
    | 'confirm_bid_materials'
    | 'complete_service_fee_authorization'
    | 'open_deal_confirmation'
    | 'none';
};

export type ProjectCommunicationBusinessState = {
  businessTodoSummary: ProjectCommunicationBusinessTodoSummary;
  chatAvailability: ProjectCommunicationChatAvailability;
};

export type ProjectCommunicationBusinessStateInput = {
  projectId: string;
  ownerOrganizationId: string;
  counterpartOrganizationId: string;
  viewerOrganizationId: string;
  threadId?: string | null;
  bidId?: string | null;
};

export type ProjectCommunicationBusinessStateBatchInput =
  ProjectCommunicationBusinessStateInput & {
    cacheKey: string;
  };

type MaterialSource = {
  attachmentCount: number;
  sourceVersionToken: string | null;
};

type BusinessStateBatchContext = {
  bidByCacheKey: Map<string, BidEntity | null>;
  pendingParticipationCountByPairKey: Map<string, number>;
  publisherMaterialSourcesByProjectId: Map<string, Map<ProjectQuoteBasisMaterialKind, MaterialSource>>;
  reviewsBySubjectKey: Map<string, ProjectCommunicationMaterialReviewEntity[]>;
  pendingConfirmationsByProjectId: Map<string, ContractConfirmationEntity[]>;
  frozenAuthorizationBySubjectKey: Map<string, PlatformServiceFeeAuthorizationEntity>;
};

const PUBLISHER_MATERIAL_KINDS: ProjectQuoteBasisMaterialKind[] = [
  'effect_image',
  'construction_doc',
  'material_sample',
  'equipment_material_list',
  'service_list'
];

const BID_MATERIAL_SLOTS: ProjectBidMaterialSlot[] = [
  'project_understanding',
  'quote_sheet',
  'schedule_plan'
];

const PENDING_DEAL_CONFIRMATION_STATUSES = [
  'pending_counterparty_confirm',
  'pending_counterparty'
] as const;

@Injectable()
export class ProjectCommunicationBusinessStateService {
  constructor(
    @InjectRepository(BidParticipationRequestEntity)
    private readonly bidParticipationRepository: Repository<BidParticipationRequestEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(ProjectAttachmentEntity)
    private readonly attachmentRepository: Repository<ProjectAttachmentEntity>,
    @InjectRepository(ProjectCommunicationMaterialReviewEntity)
    private readonly reviewRepository: Repository<ProjectCommunicationMaterialReviewEntity>,
    @InjectRepository(ContractConfirmationEntity)
    private readonly contractConfirmationRepository: Repository<ContractConfirmationEntity>,
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository?: Repository<PlatformServiceFeeAuthorizationEntity>
  ) {}

  async buildForThread(input: {
    thread: ProjectCommunicationThreadEntity;
    viewerOrganizationId: string;
    bidId?: string | null;
  }) {
    return this.buildForPair({
      projectId: input.thread.projectId,
      ownerOrganizationId: input.thread.ownerOrganizationId,
      counterpartOrganizationId: input.thread.counterpartOrganizationId,
      viewerOrganizationId: input.viewerOrganizationId,
      threadId: input.thread.id,
      bidId: input.bidId
    });
  }

  async buildForPair(input: ProjectCommunicationBusinessStateInput): Promise<ProjectCommunicationBusinessState> {
    const bid = await this.resolveBid(input);
    const [
      bidParticipationReviewPendingCount,
      publisherMaterialReviewPendingCount,
      bidMaterialReviewPendingCount,
      bidMaterialReviewPendingForChatCount,
      dealConfirmationPendingCount,
      serviceFeeAuthorizationSatisfied
    ] = await Promise.all([
      this.countPendingBidParticipationReviews(input),
      this.countPublisherMaterialReviews(input, bid),
      this.countBidMaterialReviews(input, bid),
      this.countBidMaterialReviewsForChat(input, bid),
      this.countPendingDealConfirmations(input),
      this.hasFrozenServiceFeeAuthorization(input, bid)
    ]);
    const businessTodoSummary = this.toBusinessTodoSummary({
      bidParticipationReviewPendingCount,
      publisherMaterialReviewPendingCount,
      bidMaterialReviewPendingCount,
      dealConfirmationPendingCount
    });
    return {
      businessTodoSummary,
      chatAvailability: this.toChatAvailability({
        hasPendingParticipationReview: await this.hasPendingBidParticipation(input),
        publisherMaterialReviewPendingCount,
        bidMaterialReviewPendingCount: bidMaterialReviewPendingForChatCount,
        dealConfirmationPendingCount,
        bid,
        viewerOrganizationId: input.viewerOrganizationId,
        serviceFeeAuthorizationSatisfied
      })
    };
  }

  async buildForPairs(
    inputs: ProjectCommunicationBusinessStateBatchInput[]
  ): Promise<Map<string, ProjectCommunicationBusinessState>> {
    const normalizedInputs = this.normalizeBatchInputs(inputs);
    if (!normalizedInputs.length) {
      return new Map();
    }
    const context = await this.loadBatchContext(normalizedInputs);
    return new Map(
      normalizedInputs.map((input) => [
        input.cacheKey,
        this.buildStateFromBatchContext(input, context)
      ])
    );
  }

  emptyBusinessTodoSummary(): ProjectCommunicationBusinessTodoSummary {
    return this.toBusinessTodoSummary({
      bidParticipationReviewPendingCount: 0,
      publisherMaterialReviewPendingCount: 0,
      bidMaterialReviewPendingCount: 0,
      dealConfirmationPendingCount: 0
    });
  }

  emptyChatAvailability(): ProjectCommunicationChatAvailability {
    return {
      canSendMessage: true,
      lockReasonCode: null,
      lockReasonText: null,
      requiredNextAction: 'none'
    };
  }

  private normalizeBatchInputs(inputs: ProjectCommunicationBusinessStateBatchInput[]) {
    const map = new Map<string, ProjectCommunicationBusinessStateBatchInput>();
    for (const input of inputs) {
      const cacheKey = input.cacheKey.trim();
      if (!cacheKey || map.has(cacheKey)) {
        continue;
      }
      map.set(cacheKey, {
        ...input,
        cacheKey,
        projectId: input.projectId.trim(),
        ownerOrganizationId: input.ownerOrganizationId.trim(),
        counterpartOrganizationId: input.counterpartOrganizationId.trim(),
        viewerOrganizationId: input.viewerOrganizationId.trim(),
        threadId: input.threadId?.trim() ?? null,
        bidId: input.bidId?.trim() ?? null
      });
    }
    return [...map.values()].filter(
      (input) =>
        input.projectId &&
        input.ownerOrganizationId &&
        input.counterpartOrganizationId &&
        input.viewerOrganizationId
    );
  }

  private async loadBatchContext(
    inputs: ProjectCommunicationBusinessStateBatchInput[]
  ): Promise<BusinessStateBatchContext> {
    const projectIds = this.unique(inputs.map((input) => input.projectId));
    const counterpartOrganizationIds = this.unique(inputs.map((input) => input.counterpartOrganizationId));
    const reviewerOrganizationIds = this.unique(
      inputs.flatMap((input) => [input.viewerOrganizationId, input.ownerOrganizationId])
    );
    const [
      bidByCacheKey,
      pendingParticipationCountByPairKey,
      publisherMaterialSourcesByProjectId,
      reviewsBySubjectKey,
      pendingConfirmationsByProjectId
    ] = await Promise.all([
      this.loadBatchBids(inputs),
      this.loadPendingParticipationCountMap(projectIds, counterpartOrganizationIds),
      this.loadPublisherMaterialSourcesMap(projectIds),
      this.loadReviewMap(projectIds, reviewerOrganizationIds),
      this.loadPendingConfirmationMap(projectIds)
    ]);
    const frozenAuthorizationBySubjectKey = await this.loadFrozenAuthorizationMap([
      ...bidByCacheKey.values()
    ]);
    return {
      bidByCacheKey,
      pendingParticipationCountByPairKey,
      publisherMaterialSourcesByProjectId,
      reviewsBySubjectKey,
      pendingConfirmationsByProjectId,
      frozenAuthorizationBySubjectKey
    };
  }

  private buildStateFromBatchContext(
    input: ProjectCommunicationBusinessStateBatchInput,
    context: BusinessStateBatchContext
  ): ProjectCommunicationBusinessState {
    const bid = context.bidByCacheKey.get(input.cacheKey) ?? null;
    const pendingParticipationCount =
      context.pendingParticipationCountByPairKey.get(this.projectCounterpartKey(input)) ?? 0;
    const bidParticipationReviewPendingCount =
      input.viewerOrganizationId === input.ownerOrganizationId ? pendingParticipationCount : 0;
    const publisherMaterialReviewPendingCount = this.countPublisherMaterialReviewsFromContext(
      input,
      bid,
      context
    );
    const bidMaterialReviewPendingCount = this.countBidMaterialReviewsFromContext(
      input,
      bid,
      input.viewerOrganizationId,
      input.viewerOrganizationId === input.ownerOrganizationId,
      context
    );
    const bidMaterialReviewPendingForChatCount = this.countBidMaterialReviewsFromContext(
      input,
      bid,
      input.ownerOrganizationId,
      Boolean(bid),
      context
    );
    const dealConfirmationPendingCount = this.countPendingDealConfirmationsFromContext(
      input,
      context
    );
    const businessTodoSummary = this.toBusinessTodoSummary({
      bidParticipationReviewPendingCount,
      publisherMaterialReviewPendingCount,
      bidMaterialReviewPendingCount,
      dealConfirmationPendingCount
    });
    return {
      businessTodoSummary,
      chatAvailability: this.toChatAvailability({
        hasPendingParticipationReview: pendingParticipationCount > 0,
        publisherMaterialReviewPendingCount,
        bidMaterialReviewPendingCount: bidMaterialReviewPendingForChatCount,
        dealConfirmationPendingCount,
        bid,
        viewerOrganizationId: input.viewerOrganizationId,
        serviceFeeAuthorizationSatisfied: this.hasFrozenServiceFeeAuthorizationFromContext(
          input,
          bid,
          context
        )
      })
    };
  }

  private async loadBatchBids(inputs: ProjectCommunicationBusinessStateBatchInput[]) {
    const bidIds = this.unique(inputs.map((input) => input.bidId ?? '').filter(Boolean));
    const pairInputs = inputs.filter((input) => !input.bidId);
    const [bidsById, bidsByPair] = await Promise.all([
      bidIds.length ? this.bidRepository.find({ where: { id: In(bidIds) } }) : Promise.resolve([]),
      pairInputs.length
        ? this.bidRepository.find({
            where: pairInputs.map((input) => ({
              projectId: input.projectId,
              bidderOrganizationId: input.counterpartOrganizationId
            }))
          })
        : Promise.resolve([])
    ]);
    const bidById = new Map(bidsById.map((bid) => [bid.id, bid]));
    const bidByPair = new Map(
      bidsByPair.map((bid) => [
        this.projectCounterpartKey({
          projectId: bid.projectId,
          counterpartOrganizationId: this.bidderOrganizationId(bid)
        }),
        bid
      ])
    );
    return new Map(
      inputs.map((input) => {
        const bid = input.bidId
          ? bidById.get(input.bidId) ?? null
          : bidByPair.get(this.projectCounterpartKey(input)) ?? null;
        return [input.cacheKey, this.isPairBid(input, bid) ? bid : null] as const;
      })
    );
  }

  private async loadPendingParticipationCountMap(
    projectIds: string[],
    counterpartOrganizationIds: string[]
  ) {
    if (!projectIds.length || !counterpartOrganizationIds.length) {
      return new Map<string, number>();
    }
    const requests = await this.bidParticipationRepository.find({
      where: {
        projectId: In(projectIds),
        requesterOrganizationId: In(counterpartOrganizationIds),
        state: 'pending'
      }
    });
    const countByPair = new Map<string, number>();
    for (const request of requests) {
      const key = this.projectCounterpartKey({
        projectId: request.projectId,
        counterpartOrganizationId: request.requesterOrganizationId
      });
      countByPair.set(key, (countByPair.get(key) ?? 0) + 1);
    }
    return countByPair;
  }

  private async loadPublisherMaterialSourcesMap(projectIds: string[]) {
    const result = new Map<string, Map<ProjectQuoteBasisMaterialKind, MaterialSource>>();
    for (const projectId of projectIds) {
      result.set(projectId, this.emptyPublisherMaterialSources());
    }
    if (!projectIds.length) {
      return result;
    }
    const attachments = await this.attachmentRepository.find({
      where: {
        projectId: In(projectIds),
        attachmentKind: In(PUBLISHER_MATERIAL_KINDS),
        visibility: 'owner_private'
      },
      order: { projectId: 'ASC', sortOrder: 'ASC', createdAt: 'ASC' }
    });
    const grouped = new Map<string, ProjectAttachmentEntity[]>();
    for (const attachment of attachments) {
      const key = [attachment.projectId, attachment.attachmentKind].join(':');
      grouped.set(key, [...(grouped.get(key) ?? []), attachment]);
    }
    for (const projectId of projectIds) {
      const sources = new Map<ProjectQuoteBasisMaterialKind, MaterialSource>();
      for (const kind of PUBLISHER_MATERIAL_KINDS) {
        const items = grouped.get([projectId, kind].join(':')) ?? [];
        sources.set(kind, {
          attachmentCount: items.length,
          sourceVersionToken: items.length
            ? this.hashSource(items.map((item) => `${item.id}:${item.fileAssetId}:${item.createdAt.toISOString()}`))
            : null
        });
      }
      result.set(projectId, sources);
    }
    return result;
  }

  private async loadReviewMap(projectIds: string[], reviewerOrganizationIds: string[]) {
    if (!projectIds.length || !reviewerOrganizationIds.length) {
      return new Map<string, ProjectCommunicationMaterialReviewEntity[]>();
    }
    const reviews = await this.reviewRepository.find({
      where: {
        projectId: In(projectIds),
        reviewerOrganizationId: In(reviewerOrganizationIds)
      }
    });
    const reviewsBySubjectKey = new Map<string, ProjectCommunicationMaterialReviewEntity[]>();
    for (const review of reviews) {
      const key = this.reviewSubjectKey(review.projectId, review.bidId, review.reviewerOrganizationId);
      reviewsBySubjectKey.set(key, [...(reviewsBySubjectKey.get(key) ?? []), review]);
    }
    return reviewsBySubjectKey;
  }

  private async loadPendingConfirmationMap(projectIds: string[]) {
    if (!projectIds.length) {
      return new Map<string, ContractConfirmationEntity[]>();
    }
    const confirmations = await this.contractConfirmationRepository.find({
      where: {
        taskId: In(projectIds),
        contractStatus: In([...PENDING_DEAL_CONFIRMATION_STATUSES])
      }
    });
    const byProjectId = new Map<string, ContractConfirmationEntity[]>();
    for (const confirmation of confirmations) {
      byProjectId.set(confirmation.taskId, [
        ...(byProjectId.get(confirmation.taskId) ?? []),
        confirmation
      ]);
    }
    return byProjectId;
  }

  private async loadFrozenAuthorizationMap(bids: Array<BidEntity | null>) {
    if (!this.authorizationRepository) {
      return new Map<string, PlatformServiceFeeAuthorizationEntity>();
    }
    const activeBids = bids.filter((bid): bid is BidEntity => Boolean(bid));
    const bidIds = this.unique(activeBids.map((bid) => bid.id));
    const projectIds = this.unique(activeBids.map((bid) => bid.projectId));
    if (!bidIds.length || !projectIds.length) {
      return new Map<string, PlatformServiceFeeAuthorizationEntity>();
    }
    const authorizations = await this.authorizationRepository.find({
      where: {
        taskId: In(projectIds),
        bidId: In(bidIds),
        status: 'frozen'
      },
      order: { updatedAt: 'DESC' }
    });
    const bySubjectKey = new Map<string, PlatformServiceFeeAuthorizationEntity>();
    for (const authorization of authorizations) {
      for (const organizationId of [
        authorization.bidderOrganizationId,
        authorization.factoryOrganizationId
      ]) {
        const bidderOrganizationId = organizationId?.trim() ?? '';
        if (!bidderOrganizationId) {
          continue;
        }
        const key = this.authorizationSubjectKey(
          authorization.taskId,
          authorization.bidId,
          bidderOrganizationId
        );
        if (!bySubjectKey.has(key)) {
          bySubjectKey.set(key, authorization);
        }
      }
    }
    return bySubjectKey;
  }

  private countPublisherMaterialReviewsFromContext(
    input: ProjectCommunicationBusinessStateBatchInput,
    bid: BidEntity | null,
    context: BusinessStateBatchContext
  ) {
    if (input.viewerOrganizationId !== input.counterpartOrganizationId) {
      return 0;
    }
    const publisherSources =
      context.publisherMaterialSourcesByProjectId.get(input.projectId) ??
      this.emptyPublisherMaterialSources();
    const reviews = bid
      ? [
          ...this.reviewsFor(context, input.projectId, bid.id, input.viewerOrganizationId),
          ...this.reviewsFor(
            context,
            input.projectId,
            PROJECT_COMMUNICATION_NO_BID_REVIEW_BID_ID,
            input.viewerOrganizationId
          )
        ]
      : this.reviewsFor(
          context,
          input.projectId,
          PROJECT_COMMUNICATION_NO_BID_REVIEW_BID_ID,
          input.viewerOrganizationId
        );
    return projectCommunicationWorkbenchEntryDefinitions
      .filter((definition) => definition.group === 'publisher_materials')
      .filter((definition) =>
        this.needsMaterialReview(
          publisherSources.get(definition.materialKind as ProjectQuoteBasisMaterialKind),
          definition,
          reviews
        )
      ).length;
  }

  private countBidMaterialReviewsFromContext(
    input: ProjectCommunicationBusinessStateBatchInput,
    bid: BidEntity | null,
    reviewerOrganizationId: string,
    shouldCount: boolean,
    context: BusinessStateBatchContext
  ) {
    if (!shouldCount || !bid) {
      return 0;
    }
    const reviews = this.reviewsFor(context, input.projectId, bid.id, reviewerOrganizationId);
    return this.countBidMaterialReviewsFromReviewList(bid, reviews);
  }

  private countPendingDealConfirmationsFromContext(
    input: ProjectCommunicationBusinessStateBatchInput,
    context: BusinessStateBatchContext
  ) {
    const confirmations = context.pendingConfirmationsByProjectId.get(input.projectId) ?? [];
    return confirmations.filter((confirmation) => {
      if (
        input.viewerOrganizationId === confirmation.publisherOrganizationId &&
        !confirmation.publisherConfirmedAt
      ) {
        return true;
      }
      return (
        input.viewerOrganizationId === confirmation.factoryOrganizationId &&
        !confirmation.factoryConfirmedAt
      );
    }).length;
  }

  private hasFrozenServiceFeeAuthorizationFromContext(
    input: ProjectCommunicationBusinessStateBatchInput,
    bid: BidEntity | null,
    context: BusinessStateBatchContext
  ) {
    if (!bid) {
      return false;
    }
    const authorization = context.frozenAuthorizationBySubjectKey.get(
      this.authorizationSubjectKey(input.projectId, bid.id, this.bidderOrganizationId(bid))
    );
    return (
      authorization?.status === 'frozen' &&
      this.normalizeMoney(authorization.authorizationQuotaAmount) === BID_SERVICE_FEE_AUTHORIZATION_QUOTA_AMOUNT
    );
  }

  private countBidMaterialReviewsFromReviewList(
    bid: BidEntity,
    reviews: ProjectCommunicationMaterialReviewEntity[]
  ) {
    return projectCommunicationWorkbenchEntryDefinitions
      .filter((definition) => definition.group === 'bid_materials')
      .filter((definition) =>
        this.needsMaterialReview(
          this.bidMaterialSource(bid, definition.bidMaterialSlot),
          definition,
          reviews
        )
      ).length;
  }

  private reviewsFor(
    context: BusinessStateBatchContext,
    projectId: string,
    bidId: string,
    reviewerOrganizationId: string
  ) {
    return context.reviewsBySubjectKey.get(
      this.reviewSubjectKey(projectId, bidId, reviewerOrganizationId)
    ) ?? [];
  }

  private emptyPublisherMaterialSources() {
    return new Map(
      PUBLISHER_MATERIAL_KINDS.map((kind) => [
        kind,
        { attachmentCount: 0, sourceVersionToken: null }
      ])
    );
  }

  private projectCounterpartKey(input: {
    projectId: string;
    counterpartOrganizationId: string;
  }) {
    return [input.projectId, input.counterpartOrganizationId].join(':');
  }

  private reviewSubjectKey(
    projectId: string,
    bidId: string,
    reviewerOrganizationId: string
  ) {
    return [projectId, bidId, reviewerOrganizationId].join(':');
  }

  private authorizationSubjectKey(
    projectId: string,
    bidId: string,
    bidderOrganizationId: string
  ) {
    return [projectId, bidId, bidderOrganizationId].join(':');
  }

  private unique(values: string[]) {
    return [...new Set(values.map((value) => value.trim()).filter(Boolean))];
  }

  private async resolveBid(input: ProjectCommunicationBusinessStateInput) {
    if (input.bidId) {
      const bid = await this.bidRepository.findOneBy({
        id: input.bidId,
        projectId: input.projectId
      });
      return this.isPairBid(input, bid) ? bid : null;
    }
    return this.bidRepository.findOneBy({
      projectId: input.projectId,
      bidderOrganizationId: input.counterpartOrganizationId
    });
  }

  private async countPendingBidParticipationReviews(input: ProjectCommunicationBusinessStateInput) {
    if (input.viewerOrganizationId !== input.ownerOrganizationId) {
      return 0;
    }
    return this.bidParticipationRepository.countBy({
      projectId: input.projectId,
      requesterOrganizationId: input.counterpartOrganizationId,
      state: 'pending'
    });
  }

  private async hasPendingBidParticipation(input: ProjectCommunicationBusinessStateInput) {
    const count = await this.bidParticipationRepository.countBy({
      projectId: input.projectId,
      requesterOrganizationId: input.counterpartOrganizationId,
      state: 'pending'
    });
    return count > 0;
  }

  private async countPublisherMaterialReviews(
    input: ProjectCommunicationBusinessStateInput,
    bid: BidEntity | null
  ) {
    if (input.viewerOrganizationId !== input.counterpartOrganizationId) {
      return 0;
    }
    const publisherSources = await this.publisherMaterialSources(input.projectId);
    const reviews = bid
      ? [
          ...(await this.loadReviews(input.projectId, bid.id, input.viewerOrganizationId)),
          ...(await this.loadReviews(
            input.projectId,
            PROJECT_COMMUNICATION_NO_BID_REVIEW_BID_ID,
            input.viewerOrganizationId
          ))
        ]
      : await this.loadReviews(
          input.projectId,
          PROJECT_COMMUNICATION_NO_BID_REVIEW_BID_ID,
          input.viewerOrganizationId
        );
    return projectCommunicationWorkbenchEntryDefinitions
      .filter((definition) => definition.group === 'publisher_materials')
      .filter((definition) =>
        this.needsMaterialReview(
          publisherSources.get(definition.materialKind as ProjectQuoteBasisMaterialKind),
          definition,
          reviews
        )
      ).length;
  }

  private async countBidMaterialReviews(
    input: ProjectCommunicationBusinessStateInput,
    bid: BidEntity | null
  ) {
    if (input.viewerOrganizationId !== input.ownerOrganizationId || !bid) {
      return 0;
    }
    const reviews = await this.loadReviews(input.projectId, bid.id, input.viewerOrganizationId);
    return projectCommunicationWorkbenchEntryDefinitions
      .filter((definition) => definition.group === 'bid_materials')
      .filter((definition) =>
        this.needsMaterialReview(
          this.bidMaterialSource(bid, definition.bidMaterialSlot),
          definition,
          reviews
        )
      ).length;
  }

  private async countBidMaterialReviewsForChat(
    input: ProjectCommunicationBusinessStateInput,
    bid: BidEntity | null
  ) {
    if (!bid) {
      return 0;
    }
    const reviews = await this.loadReviews(input.projectId, bid.id, input.ownerOrganizationId);
    return projectCommunicationWorkbenchEntryDefinitions
      .filter((definition) => definition.group === 'bid_materials')
      .filter((definition) =>
        this.needsMaterialReview(
          this.bidMaterialSource(bid, definition.bidMaterialSlot),
          definition,
          reviews
        )
      ).length;
  }

  private async countPendingDealConfirmations(input: ProjectCommunicationBusinessStateInput) {
    const confirmations = await this.contractConfirmationRepository.find({
      where: {
        taskId: input.projectId,
        contractStatus: In([...PENDING_DEAL_CONFIRMATION_STATUSES])
      }
    });
    return confirmations.filter((confirmation) => {
      if (
        input.viewerOrganizationId === confirmation.publisherOrganizationId &&
        !confirmation.publisherConfirmedAt
      ) {
        return true;
      }
      return (
        input.viewerOrganizationId === confirmation.factoryOrganizationId &&
        !confirmation.factoryConfirmedAt
      );
    }).length;
  }

  private async hasFrozenServiceFeeAuthorization(
    input: ProjectCommunicationBusinessStateInput,
    bid: BidEntity | null
  ) {
    if (!bid || !this.authorizationRepository) {
      return false;
    }
    const bidderOrganizationId = this.bidderOrganizationId(bid);
    const authorization = await this.authorizationRepository.findOne({
      where: [
        {
          taskId: input.projectId,
          bidId: bid.id,
          bidderOrganizationId,
          status: 'frozen'
        },
        {
          taskId: input.projectId,
          bidId: bid.id,
          factoryOrganizationId: bidderOrganizationId,
          status: 'frozen'
        }
      ],
      order: { updatedAt: 'DESC' }
    });
    return (
      authorization?.status === 'frozen' &&
      this.normalizeMoney(authorization.authorizationQuotaAmount) === BID_SERVICE_FEE_AUTHORIZATION_QUOTA_AMOUNT
    );
  }

  private async publisherMaterialSources(projectId: string) {
    const attachments = await this.attachmentRepository.find({
      where: {
        projectId,
        attachmentKind: In(PUBLISHER_MATERIAL_KINDS),
        visibility: 'owner_private'
      },
      order: { sortOrder: 'ASC', createdAt: 'ASC' }
    });
    const grouped = new Map<ProjectQuoteBasisMaterialKind, ProjectAttachmentEntity[]>();
    for (const attachment of attachments) {
      const kind = attachment.attachmentKind as ProjectQuoteBasisMaterialKind;
      grouped.set(kind, [...(grouped.get(kind) ?? []), attachment]);
    }
    const result = new Map<ProjectQuoteBasisMaterialKind, MaterialSource>();
    for (const kind of PUBLISHER_MATERIAL_KINDS) {
      const items = grouped.get(kind) ?? [];
      result.set(kind, {
        attachmentCount: items.length,
        sourceVersionToken: items.length
          ? this.hashSource(items.map((item) => `${item.id}:${item.fileAssetId}:${item.createdAt.toISOString()}`))
          : null
      });
    }
    return result;
  }

  private async loadReviews(projectId: string, bidId: string, reviewerOrganizationId: string) {
    return this.reviewRepository.findBy({
      projectId,
      bidId,
      reviewerOrganizationId
    });
  }

  private needsMaterialReview(
    source: MaterialSource | undefined,
    definition: ProjectCommunicationWorkbenchEntryDefinition,
    reviews: ProjectCommunicationMaterialReviewEntity[]
  ) {
    if (!source?.sourceVersionToken || source.attachmentCount === 0) {
      return false;
    }
    return !reviews.some(
      (item) =>
        item.entryKey === definition.entryKey &&
        item.sourceVersionToken === source.sourceVersionToken &&
        item.reviewState === 'confirmed'
    );
  }

  private bidMaterialSource(bid: BidEntity, slot: ProjectBidMaterialSlot | null) {
    const fileAssetId = slot ? this.bidSlotFileAssetId(bid, slot) : null;
    return {
      attachmentCount: fileAssetId ? 1 : 0,
      sourceVersionToken:
        fileAssetId && slot ? this.hashSource([bid.id, slot, fileAssetId, bid.updatedAt.toISOString()]) : null
    };
  }

  private toChatAvailability(input: {
    hasPendingParticipationReview: boolean;
    publisherMaterialReviewPendingCount: number;
    bidMaterialReviewPendingCount: number;
    dealConfirmationPendingCount: number;
    bid: BidEntity | null;
    viewerOrganizationId: string;
    serviceFeeAuthorizationSatisfied: boolean;
  }): ProjectCommunicationChatAvailability {
    if (input.hasPendingParticipationReview) {
      return this.locked(
        'bid_participation_review_pending',
        '请先由发布方处理参与竞标申请。',
        'review_bid_participation'
      );
    }
    if (!input.bid || !this.hasCompleteBidMaterials(input.bid)) {
      if (input.publisherMaterialReviewPendingCount > 0) {
        return this.locked(
          'publisher_material_confirmation_pending',
          '请先确认发布方提供的报价依据资料。',
          'confirm_publisher_materials'
        );
      }
      return this.locked('bid_submission_pending', '请先完成竞标报价与三项附件提交。', 'submit_bid_materials');
    }
    if (input.bidMaterialReviewPendingCount > 0) {
      return this.locked(
        'bid_material_confirmation_pending',
        '请先由发布方确认竞标报价资料。',
        'confirm_bid_materials'
      );
    }
    if (!input.serviceFeeAuthorizationSatisfied) {
      const bidderOrganizationId = this.bidderOrganizationId(input.bid);
      return this.locked(
        'service_fee_authorization_pending',
        input.viewerOrganizationId === bidderOrganizationId
          ? '资料确认已通过，请先完成 4000 元竞标服务费预授权额度后开启项目级自由发送。'
          : '资料确认已通过，需等待竞标方完成 4000 元竞标服务费预授权额度后开启项目级自由发送。',
        'complete_service_fee_authorization'
      );
    }
    if (input.dealConfirmationPendingCount > 0) {
      return {
        canSendMessage: true,
        lockReasonCode: null,
        lockReasonText: null,
        requiredNextAction: 'open_deal_confirmation'
      };
    }
    return this.emptyChatAvailability();
  }

  private locked(
    lockReasonCode: Exclude<ProjectCommunicationChatAvailability['lockReasonCode'], null>,
    lockReasonText: string,
    requiredNextAction: Exclude<ProjectCommunicationChatAvailability['requiredNextAction'], 'none'>
  ) {
    return {
      canSendMessage: false,
      lockReasonCode,
      lockReasonText,
      requiredNextAction
    };
  }

  private toBusinessTodoSummary(input: Omit<ProjectCommunicationBusinessTodoSummary, 'totalPendingCount'>) {
    return {
      ...input,
      totalPendingCount:
        input.bidParticipationReviewPendingCount +
        input.publisherMaterialReviewPendingCount +
        input.bidMaterialReviewPendingCount +
        input.dealConfirmationPendingCount
    };
  }

  private hasCompleteBidMaterials(bid: BidEntity) {
    return BID_MATERIAL_SLOTS.every((slot) => !!this.bidSlotFileAssetId(bid, slot));
  }

  private bidSlotFileAssetId(bid: BidEntity, slot: ProjectBidMaterialSlot) {
    if (slot === 'project_understanding') return bid.projectUnderstandingFileAssetId;
    if (slot === 'quote_sheet') return bid.quoteSheetFileAssetId;
    return bid.schedulePlanFileAssetId;
  }

  private bidderOrganizationId(bid: BidEntity) {
    return bid.bidderOrganizationId || bid.organizationId;
  }

  private isPairBid(input: ProjectCommunicationBusinessStateInput, bid: BidEntity | null) {
    if (!bid) {
      return false;
    }
    return bid.projectId === input.projectId && this.bidderOrganizationId(bid) === input.counterpartOrganizationId;
  }

  private hashSource(parts: string[]) {
    return createHash('sha256').update(parts.join('|'), 'utf8').digest('hex');
  }

  private normalizeMoney(value: string | number | null) {
    if (value === null || value === undefined) {
      return '';
    }
    const amount = Number(value);
    return Number.isFinite(amount) ? amount.toFixed(2) : '';
  }
}
