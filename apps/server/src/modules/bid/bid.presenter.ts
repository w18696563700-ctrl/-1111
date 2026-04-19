import { Injectable } from '@nestjs/common';
import { BidSeatEntity } from './entities/bid-seat.entity';

@Injectable()
export class BidPresenter {
  toAcceptedResponse(bidId: string) {
    return { bidId };
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
