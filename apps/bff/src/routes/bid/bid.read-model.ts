import type {
  BidAwardAcceptedResponse,
  BidResultOutcome,
  BidResultReadModel,
  BidResultState,
} from '../../../../../packages/contracts/src/generated/app-api.types';

const BID_AWARD_STATE = 'converted_to_order';
const BID_RESULT_STATES = new Set<BidResultState>(['awarded', 'lost']);
const BID_RESULT_OUTCOMES = new Set<BidResultOutcome>(['won', 'lost']);
const SYSTEM_SEED_TYPES = new Set(['bid_submitted']);

export function readBidSubmitAcceptedResponse(value: unknown) {
  const record = requireRecord(value, 'Bid submit accepted response must be an object.');
  const bidId = readRequiredString(record.bidId, 'bidId');
  const threadSeed = readOptionalThreadSeed(
    record.threadSeed ?? record.sessionSeed ?? record.conversationSeed,
  ) ?? readInteractionSeedThreadSeed(record);

  return threadSeed ? { bidId, threadSeed } : { bidId };
}

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

function readOptionalThreadSeed(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    return undefined;
  }

  const record = value as Record<string, unknown>;
  const threadId = readRequiredString(record.threadId, 'threadSeed.threadId');
  const projectId = readRequiredString(record.projectId, 'threadSeed.projectId');
  const bidId = readRequiredString(record.bidId, 'threadSeed.bidId');
  const systemSeedType = readRequiredString(record.systemSeedType, 'threadSeed.systemSeedType');
  if (!SYSTEM_SEED_TYPES.has(systemSeedType)) {
    throw new Error('Bid submit accepted response returned an unsupported systemSeedType.');
  }

  return compactRecord({
    threadId,
    projectId,
    bidId,
    messageKind: 'system_seed',
    systemSeedType,
    systemSeedAction: readOptionalSystemSeedAction(record.systemSeedAction),
  });
}

function readOptionalSystemSeedAction(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    return undefined;
  }

  const record = value as Record<string, unknown>;
  const actionKey = readRequiredString(record.actionKey, 'threadSeed.systemSeedAction.actionKey');
  if (actionKey !== 'bid_submission_snapshot.open') {
    throw new Error('Bid submit accepted response returned an unsupported systemSeedAction.');
  }

  return compactRecord({
    objectType: readOptionalString(record.objectType) ?? 'bid_submission_snapshot',
    actionKey,
    canonicalPath: readOptionalString(record.canonicalPath),
    params: readOptionalStringMap(record.params),
  });
}

function readInteractionSeedThreadSeed(record: Record<string, unknown>) {
  if (!record.interactionSeed || Array.isArray(record.interactionSeed) || typeof record.interactionSeed !== 'object') {
    return undefined;
  }

  const interactionSeed = record.interactionSeed as Record<string, unknown>;
  const routeTarget = requireRecord(
    interactionSeed.routeTarget,
    'Bid submit accepted response is missing `interactionSeed.routeTarget`.',
  );
  const actionKey = readRequiredString(
    routeTarget.actionKey,
    'interactionSeed.routeTarget.actionKey',
  );
  if (actionKey !== 'bid_thread.open') {
    throw new Error('Bid submit accepted response returned an unsupported interactionSeed.');
  }

  const routeParams = requireRecord(
    routeTarget.params,
    'Bid submit accepted response is missing `interactionSeed.routeTarget.params`.',
  );
  const threadId = readRequiredString(
    routeParams.threadId ?? record.threadId,
    'interactionSeed.routeTarget.params.threadId',
  );
  const projectId = readRequiredString(
    routeParams.projectId ?? record.projectId,
    'interactionSeed.routeTarget.params.projectId',
  );
  const seedBidId = readRequiredString(
    routeParams.bidId ?? record.bidId,
    'interactionSeed.routeTarget.params.bidId',
  );
  const systemSeed = readOptionalSystemSeedCarrier(record.systemSeed);
  const systemSeedType =
    systemSeed?.systemSeedType ?? readOptionalSupportedSystemSeedType(interactionSeed.seedType);
  if (!systemSeedType) {
    return undefined;
  }

  return compactRecord({
    threadId,
    projectId,
    bidId: seedBidId,
    messageKind: 'system_seed',
    systemSeedType,
    systemSeedAction: systemSeed?.systemSeedAction,
  });
}

function readOptionalSystemSeedCarrier(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    return undefined;
  }

  const record = value as Record<string, unknown>;
  const systemSeedType = readOptionalSupportedSystemSeedType(record.systemSeedType);
  if (!systemSeedType) {
    return undefined;
  }

  return compactRecord({
    systemSeedType,
    systemSeedAction: readOptionalSystemSeedAction(record.systemSeedAction),
  });
}

function readOptionalSupportedSystemSeedType(value: unknown) {
  const normalized = readOptionalString(value);
  if (normalized && SYSTEM_SEED_TYPES.has(normalized)) {
    return normalized;
  }
  return undefined;
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

function readOptionalString(value: unknown) {
  if (typeof value !== 'string') {
    return undefined;
  }
  const normalized = value.trim();
  return normalized ? normalized : undefined;
}

function readOptionalStringMap(value: unknown) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    return undefined;
  }

  const result: Record<string, string> = {};
  for (const [key, rawValue] of Object.entries(value as Record<string, unknown>)) {
    const normalized = readOptionalString(rawValue);
    if (normalized) {
      result[key] = normalized;
    }
  }
  return Object.keys(result).length > 0 ? result : undefined;
}

function compactRecord<T extends Record<string, unknown>>(value: T) {
  const result: Record<string, unknown> = {};
  for (const [key, rawValue] of Object.entries(value)) {
    if (rawValue !== undefined) {
      result[key] = rawValue;
    }
  }
  return result as T;
}
