import { readBidAwardAcceptedResponse } from './bid.read-model';

export type BidSelectAndCreateOrderAcceptedResponse = {
  bidAwardId: string;
  projectId: string;
  winningBidId: string;
  orderId: string;
  contractId: string;
  state: 'converted_to_order';
  actionKey: 'bid_select_create_order.submit';
  routeTarget: {
    objectType: 'order';
    actionKey: 'order_detail.open';
    canonicalPath: '/api/app/order/detail';
    params: {
      orderId: string;
      projectId: string;
      winningBidId: string;
      bidAwardId: string;
      contractId: string;
    };
  };
};

export function readBidSelectAndCreateOrderAcceptedResponse(
  value: unknown,
): BidSelectAndCreateOrderAcceptedResponse {
  const accepted = readBidAwardAcceptedResponse(value);
  const orderId = requireString(accepted.orderId, 'orderId');
  const contractId = requireString(accepted.contractId, 'contractId');

  return {
    bidAwardId: accepted.bidAwardId,
    projectId: accepted.projectId,
    winningBidId: accepted.winningBidId,
    orderId,
    contractId,
    state: 'converted_to_order',
    actionKey: 'bid_select_create_order.submit',
    routeTarget: {
      objectType: 'order',
      actionKey: 'order_detail.open',
      canonicalPath: '/api/app/order/detail',
      params: {
        orderId,
        projectId: accepted.projectId,
        winningBidId: accepted.winningBidId,
        bidAwardId: accepted.bidAwardId,
        contractId,
      },
    },
  };
}

function requireString(value: unknown, fieldName: string) {
  if (typeof value === 'string' && value.trim().length > 0) {
    return value.trim();
  }
  throw new Error(`Bid selection response is missing \`${fieldName}\`.`);
}
