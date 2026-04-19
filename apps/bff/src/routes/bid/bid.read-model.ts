import type {
  BidAwardAcceptedResponse,
  BidResultOutcome,
  BidResultReadModel,
  BidResultState,
} from '../../../../../packages/contracts/src/generated/app-api.types';

const BID_AWARD_STATE = 'converted_to_order';
const BID_RESULT_STATES = new Set<BidResultState>(['awarded', 'lost']);
const BID_RESULT_OUTCOMES = new Set<BidResultOutcome>(['won', 'lost']);

export function readBidAwardAcceptedResponse(value: unknown): BidAwardAcceptedResponse {
  const record = requireRecord(value, 'Bid award accepted response must be an object.');
  const bidAwardId = readRequiredString(record.bidAwardId, 'bidAwardId');
  const projectId = readRequiredString(record.projectId, 'projectId');
  const winningBidId = readRequiredString(record.winningBidId, 'winningBidId');
  const orderId = readRequiredString(record.orderId, 'orderId');
  const contractId = readRequiredString(record.contractId, 'contractId');
  const state = readRequiredString(record.state, 'state');
  if (state !== BID_AWARD_STATE) {
    throw new Error('Bid award accepted response returned an unsupported state.');
  }
  return {
    bidAwardId,
    projectId,
    winningBidId,
    orderId,
    contractId,
    state: BID_AWARD_STATE,
  };
}

export function readBidResultReadModel(value: unknown): BidResultReadModel {
  const record = requireRecord(value, 'Bid result response must be an object.');
  const bidId = readRequiredString(record.bidId, 'bidId');
  const projectId = readRequiredString(record.projectId, 'projectId');
  const state = readRequiredString(record.state, 'state');
  const result = readRequiredString(record.result, 'result');
  const reasonCode = readRequiredString(record.reasonCode, 'reasonCode');
  const reasonText = readRequiredString(record.reasonText, 'reasonText');
  const decidedAt = readRequiredString(record.decidedAt, 'decidedAt');

  if (!BID_RESULT_STATES.has(state as BidResultState)) {
    throw new Error('Bid result response returned an unsupported state.');
  }
  if (!BID_RESULT_OUTCOMES.has(result as BidResultOutcome)) {
    throw new Error('Bid result response returned an unsupported result.');
  }

  return {
    bidId,
    projectId,
    state: state as BidResultState,
    result: result as BidResultOutcome,
    reasonCode,
    reasonText,
    decidedAt,
  };
}

function requireRecord(value: unknown, message: string) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

function readRequiredString(value: unknown, fieldName: string) {
  if (typeof value !== 'string') {
    throw new Error(`Bid response is missing \`${fieldName}\`.`);
  }
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`Bid response is missing \`${fieldName}\`.`);
  }
  return normalized;
}
