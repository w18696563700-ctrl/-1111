import { Injectable } from '@nestjs/common';
import { BidThreadConfirmationCardEntity } from './entities/bid-thread-confirmation-card.entity';
import { BidThreadMessageEntity } from './entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from './entities/bid-private-thread.entity';
import { ProjectClarificationEntity } from './entities/project-clarification.entity';

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
    messages: BidThreadMessageEntity[];
    confirmationCards: BidThreadConfirmationCardEntity[];
    availability: TradingImAvailability;
  }) {
    const { thread, participantRole, messages, confirmationCards, availability } = params;
    return {
      threadId: thread.id,
      projectId: thread.projectId,
      bidId: thread.bidId,
      participants: [
        {
          participantRole: 'project_owner',
          organizationId: thread.projectOwnerOrganizationId
        },
        {
          participantRole: 'bidder',
          organizationId: thread.bidderOrganizationId
        }
      ],
      viewerParticipantRole: participantRole,
      state: thread.lifecycleState,
      availability,
      messages: messages.map((message) => this.toThreadMessage(message)),
      confirmationCards: confirmationCards.map((card) => this.toConfirmationCard(card))
    };
  }

  toThreadMessage(message: BidThreadMessageEntity) {
    return {
      messageId: message.id,
      threadId: message.threadId,
      projectId: message.projectId,
      bidId: message.bidId,
      senderRole: message.senderRole,
      body: message.body,
      attachmentFileAssetIds: message.attachmentFileAssetIds,
      createdAt: message.createdAt.toISOString()
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
}
