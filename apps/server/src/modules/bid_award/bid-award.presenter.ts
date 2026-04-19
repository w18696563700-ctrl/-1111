import { Injectable } from '@nestjs/common';
import { BidEntity } from '../bid/entities/bid.entity';
import { BidAwardTruthCarrier } from './bid-award.truth';

@Injectable()
export class BidAwardPresenter {
  toAwardAcceptedResponse(award: BidAwardTruthCarrier) {
    return {
      bidAwardId: award.bidAwardId,
      projectId: award.projectId,
      winningBidId: award.winningBidId,
      orderId: award.orderId,
      contractId: award.contractId,
      state: 'converted_to_order'
    };
  }

  toResultReadModel(bid: BidEntity, award: BidAwardTruthCarrier) {
    const state = bid.state === 'awarded' ? 'awarded' : 'lost';
    return {
      bidId: bid.id,
      projectId: award.projectId,
      state,
      result: state === 'awarded' ? 'won' : 'lost',
      reasonCode: award.reasonCode,
      reasonText: award.reasonText,
      decidedAt: award.decidedAt
    };
  }
}
