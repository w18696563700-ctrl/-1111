import { Injectable } from '@nestjs/common';
import { BidSeatEntity } from './entities/bid-seat.entity';
import {
  buildBidSubmissionSnapshotAction,
  buildBidThreadRouteTarget,
  TRADING_IM_SYSTEM_SEED_TYPE_BID_SUBMITTED
} from '../trading_im/trading-im-system-seed.support';

@Injectable()
export class BidPresenter {
  toAcceptedResponse(input: {
    bidId: string;
    projectId: string;
    threadId: string;
    seedMessageId?: string;
  }) {
    return {
      bidId: input.bidId,
      projectId: input.projectId,
      threadId: input.threadId,
      systemSeed: {
        messageId: input.seedMessageId ?? null,
        messageKind: 'system_seed',
        systemSeedType: TRADING_IM_SYSTEM_SEED_TYPE_BID_SUBMITTED,
        systemSeedAction: buildBidSubmissionSnapshotAction({
          projectId: input.projectId,
          bidId: input.bidId
        })
      },
      interactionSeed: {
        seedType: TRADING_IM_SYSTEM_SEED_TYPE_BID_SUBMITTED,
        routeTarget: buildBidThreadRouteTarget({
          threadId: input.threadId,
          projectId: input.projectId,
          bidId: input.bidId
        })
      }
    };
  }

  toSeatLockResponse(seat: BidSeatEntity) {
    return {
      seatId: seat.seatId,
      projectId: seat.projectId,
      bidId: seat.bidId,
      state: seat.state,
      expiresAt: seat.expiresAt.toISOString()
    };
  }

  toSupplementAcceptedResponse(input: {
    bidId: string;
    projectId: string;
    entryKey: string;
  }) {
    return {
      bidId: input.bidId,
      projectId: input.projectId,
      entryKey: input.entryKey,
      reviewState: 'pending_review'
    };
  }

  toSeatReleaseResponse(seat: BidSeatEntity) {
    return {
      seatId: seat.seatId,
      projectId: seat.projectId,
      bidId: seat.bidId,
      state: seat.state,
      releasedAt: seat.releasedAt?.toISOString() ?? null
    };
  }

  toSeatStatusResponse(input: {
    seatId: string | null;
    projectId: string;
    bidId: string;
    state: 'available' | 'locked' | 'released' | 'timed_out';
    expiresAt: Date | null;
    releasedAt: Date | null;
  }) {
    return {
      seatId: input.seatId,
      projectId: input.projectId,
      bidId: input.bidId,
      state: input.state,
      expiresAt: input.expiresAt?.toISOString() ?? null,
      releasedAt: input.releasedAt?.toISOString() ?? null
    };
  }

  toPackageCompletenessResponse(input: {
    projectId: string;
    bidId: string;
    state: 'complete' | 'incomplete';
    missingItems: string[];
    quoteAmountReady: boolean;
    proposalSummaryReady: boolean;
  }) {
    return {
      bidId: input.bidId,
      projectId: input.projectId,
      state: input.state,
      missingItems: [...input.missingItems],
      quoteAmountReady: input.quoteAmountReady,
      proposalSummaryReady: input.proposalSummaryReady
    };
  }
}
