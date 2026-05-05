import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash } from 'crypto';
import { In, Repository } from 'typeorm';
import { BidEntity } from '../bid/entities/bid.entity';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import { ContractConfirmationEntity } from '../p0_pay/entities/contract-confirmation.entity';
import { ProjectAttachmentEntity } from '../project/entities/project-attachment.entity';
import { ProjectCommunicationMaterialReviewEntity } from './entities/project-communication-material-review.entity';
import { ProjectCommunicationThreadEntity } from './entities/project-communication-thread.entity';
import {
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
    | 'deal_confirmation_pending'
    | null;
  lockReasonText: string | null;
  requiredNextAction:
    | 'review_bid_participation'
    | 'confirm_publisher_materials'
    | 'submit_bid_materials'
    | 'confirm_bid_materials'
    | 'open_deal_confirmation'
    | 'none';
};

export type ProjectCommunicationBusinessState = {
  businessTodoSummary: ProjectCommunicationBusinessTodoSummary;
  chatAvailability: ProjectCommunicationChatAvailability;
};

type ProjectCommunicationBusinessStateInput = {
  projectId: string;
  ownerOrganizationId: string;
  counterpartOrganizationId: string;
  viewerOrganizationId: string;
  threadId?: string | null;
  bidId?: string | null;
};

type MaterialSource = {
  attachmentCount: number;
  sourceVersionToken: string | null;
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
    private readonly contractConfirmationRepository: Repository<ContractConfirmationEntity>
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
      dealConfirmationPendingCount
    ] = await Promise.all([
      this.countPendingBidParticipationReviews(input),
      this.countPublisherMaterialReviews(input, bid),
      this.countBidMaterialReviews(input, bid),
      this.countPendingDealConfirmations(input)
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
        bidMaterialReviewPendingCount,
        dealConfirmationPendingCount,
        bid
      })
    };
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
      ? await this.loadReviews(input.projectId, bid.id, input.viewerOrganizationId)
      : [];
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
    const review = reviews.find((item) => item.entryKey === definition.entryKey);
    return review?.sourceVersionToken !== source.sourceVersionToken || review.reviewState !== 'confirmed';
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
  }): ProjectCommunicationChatAvailability {
    if (input.hasPendingParticipationReview) {
      return this.locked(
        'bid_participation_review_pending',
        '请先由发布方处理参与竞标申请。',
        'review_bid_participation'
      );
    }
    if (input.publisherMaterialReviewPendingCount > 0) {
      return this.locked(
        'publisher_material_confirmation_pending',
        '请先确认发布方提供的报价依据资料。',
        'confirm_publisher_materials'
      );
    }
    if (!input.bid || !this.hasCompleteBidMaterials(input.bid)) {
      return this.locked('bid_submission_pending', '请先完成竞标报价与三项附件提交。', 'submit_bid_materials');
    }
    if (input.bidMaterialReviewPendingCount > 0) {
      return this.locked(
        'bid_material_confirmation_pending',
        '请先由发布方确认竞标报价资料。',
        'confirm_bid_materials'
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

  private isPairBid(input: ProjectCommunicationBusinessStateInput, bid: BidEntity | null) {
    if (!bid) {
      return false;
    }
    const bidderOrganizationId = bid.bidderOrganizationId || bid.organizationId;
    return bid.projectId === input.projectId && bidderOrganizationId === input.counterpartOrganizationId;
  }

  private hashSource(parts: string[]) {
    return createHash('sha256').update(parts.join('|'), 'utf8').digest('hex');
  }
}
