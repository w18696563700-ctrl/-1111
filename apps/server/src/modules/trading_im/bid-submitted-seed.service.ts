import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { EntityManager, Repository } from 'typeorm';
import { BidEntity } from '../bid/entities/bid.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidThreadMessageEntity } from './entities/bid-thread-message.entity';
import { BidPrivateThreadEntity } from './entities/bid-private-thread.entity';
import {
  buildBidSubmittedSeedBody,
  TRADING_IM_MESSAGE_KIND_SYSTEM_SEED
} from './trading-im-system-seed.support';

@Injectable()
export class BidSubmittedSeedService {
  async createForSubmittedBid(input: {
    manager: EntityManager;
    project: ProjectEntity;
    bid: BidEntity;
    bidderDisplayName: string;
  }) {
    const threadRepository = input.manager.getRepository(BidPrivateThreadEntity);
    const messageRepository = input.manager.getRepository(BidThreadMessageEntity);
    const thread = await this.resolveOrCreateThread(threadRepository, input.project, input.bid);
    const existingSeed = await messageRepository.findOneBy({
      threadId: thread.id,
      projectId: input.project.id,
      bidId: input.bid.id,
      senderRole: TRADING_IM_MESSAGE_KIND_SYSTEM_SEED
    });
    if (existingSeed) {
      return {
        threadId: thread.id,
        seedMessageId: existingSeed.id
      };
    }

    const message = messageRepository.create({
      id: randomUUID(),
      threadId: thread.id,
      projectId: input.project.id,
      bidId: input.bid.id,
      senderUserId: null,
      senderActorId: null,
      senderOrganizationId: input.bid.bidderOrganizationId || input.bid.organizationId,
      senderRole: TRADING_IM_MESSAGE_KIND_SYSTEM_SEED,
      body: buildBidSubmittedSeedBody(input.bidderDisplayName),
      attachmentFileAssetIds: [],
      messageState: 'active'
    });
    await messageRepository.save(message);
    return {
      threadId: thread.id,
      seedMessageId: message.id
    };
  }

  private async resolveOrCreateThread(
    threadRepository: Repository<BidPrivateThreadEntity>,
    project: ProjectEntity,
    bid: BidEntity
  ) {
    const existing = await threadRepository.findOneBy({
      projectId: project.id,
      bidId: bid.id
    });
    if (existing) {
      return existing;
    }
    const thread = threadRepository.create({
      id: randomUUID(),
      projectId: project.id,
      bidId: bid.id,
      projectOwnerOrganizationId: project.organizationId,
      bidderOrganizationId: bid.bidderOrganizationId || bid.organizationId,
      lifecycleState: 'open'
    });
    try {
      return await threadRepository.save(thread);
    } catch (error) {
      if (!this.isUniqueViolation(error)) {
        throw error;
      }
      const raced = await threadRepository.findOneBy({
        projectId: project.id,
        bidId: bid.id
      });
      if (!raced) {
        throw error;
      }
      return raced;
    }
  }

  private isUniqueViolation(error: unknown) {
    return typeof error === 'object' && error !== null && 'code' in error && error.code === '23505';
  }
}
