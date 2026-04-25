import { Injectable } from '@nestjs/common';
import { BidThreadConfirmationCardEntity } from './entities/bid-thread-confirmation-card.entity';
import { BidThreadMessageEntity } from './entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from './entities/bid-private-thread.entity';
import { ProjectClarificationEntity } from './entities/project-clarification.entity';
import {
  buildBidSubmissionSnapshotAction,
  TRADING_IM_MESSAGE_KIND_ACTOR,
  TRADING_IM_MESSAGE_KIND_SYSTEM_SEED,
  TRADING_IM_SYSTEM_SEED_TYPE_BID_SUBMITTED
} from './trading-im-system-seed.support';

export type TradingImParticipantRole = 'project_owner' | 'bidder' | 'viewer';

export type TradingImAvailability = {
  canSendMessage: boolean;
  canCreateConfirmation: boolean;
  reason: string;
};

@Injectable()
export class TradingImPresenter {
  toClarificationList(
    projectId: string,
    items: ProjectClarificationEntity[],
    availability: { canCreate: boolean; reason: string }
  ) {
    return {
      projectId,
      availability,
      items: items.map((item) => this.toClarification(item))
    };
  }

  toClarification(item: ProjectClarificationEntity) {
    return {
      clarificationId: item.id,
      projectId: item.projectId,
      authorRole: item.authorRole,
      body: item.body,
      attachmentFileAssetIds: item.attachmentFileAssetIds,
      state: item.lifecycleState,
      createdAt: item.createdAt.toISOString()
    };
  }

  toThreadDetail(params: {
    thread: BidPrivateThreadEntity;
    participantRole: TradingImParticipantRole;
    participants: Array<{
      participantRole: Exclude<TradingImParticipantRole, 'viewer'>;
      organizationId: string;
      displayName: string | null;
      avatarUrl: string | null;
    }>;
    messages: BidThreadMessageEntity[];
    confirmationCards: BidThreadConfirmationCardEntity[];
    availability: TradingImAvailability;
  }) {
    const { thread, participantRole, participants, messages, confirmationCards, availability } = params;
    return {
      threadId: thread.id,
      projectId: thread.projectId,
      bidId: thread.bidId,
      participants,
      viewerParticipantRole: participantRole,
      state: thread.lifecycleState,
      availability,
      messages: messages.map((message) => this.toThreadMessage(message)),
      confirmationCards: confirmationCards.map((card) => this.toConfirmationCard(card))
    };
  }

  toThreadMessage(message: BidThreadMessageEntity) {
    const isSystemSeed = message.senderRole === TRADING_IM_MESSAGE_KIND_SYSTEM_SEED;
    return {
      messageId: message.id,
      threadId: message.threadId,
      projectId: message.projectId,
      bidId: message.bidId,
      senderRole: message.senderRole,
      body: message.body,
      attachmentFileAssetIds: message.attachmentFileAssetIds,
      createdAt: message.createdAt.toISOString(),
      messageKind: isSystemSeed
        ? TRADING_IM_MESSAGE_KIND_SYSTEM_SEED
        : TRADING_IM_MESSAGE_KIND_ACTOR,
      ...(isSystemSeed
        ? {
            systemSeedType: TRADING_IM_SYSTEM_SEED_TYPE_BID_SUBMITTED,
            systemSeedAction: buildBidSubmissionSnapshotAction({
                projectId: message.projectId,
                bidId: message.bidId
              })
          }
        : {})
    };
  }

  toConfirmationCard(card: BidThreadConfirmationCardEntity) {
    return {
      confirmationId: card.id,
      threadId: card.threadId,
      projectId: card.projectId,
      bidId: card.bidId,
      confirmationType: card.confirmationType,
      summary: card.summary,
      sourceMessageId: card.sourceMessageId,
      createdAt: card.createdAt.toISOString()
    };
  }

  toParticipantCard(params: {
    projectId: string;
    bidId: string;
    participantOrganizationId: string;
    participantRole: Exclude<TradingImParticipantRole, 'viewer'>;
    enterpriseSummary: {
      enterpriseId: string;
      displayName: string;
      logoUrl: string | null;
      primaryBoardType: string;
      provinceName: string;
      cityName: string;
      verificationStatus: string;
    };
    reviewSummary: {
      avgScore: number | null;
      reviewCount: number;
      keywordTags: string[];
    };
    formalInfoSummary: {
      legalName: string;
      businessType: string | null;
      registeredCapital: string | null;
      establishedAt: string | null;
      businessScope: string | null;
      certificationStatus: string;
    };
  }) {
    return {
      projectId: params.projectId,
      bidId: params.bidId,
      participantOrganizationId: params.participantOrganizationId,
      participantRole: params.participantRole,
      enterpriseSummary: params.enterpriseSummary,
      reviewSummary: params.reviewSummary,
      formalInfoSummary: params.formalInfoSummary
    };
  }
}
