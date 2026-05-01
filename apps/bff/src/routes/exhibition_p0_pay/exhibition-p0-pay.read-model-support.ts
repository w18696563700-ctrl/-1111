export type Payload = Record<string, unknown>;

export function readPublisherPricing(record: Payload) {
  const publisher = optionalRecord(record.publisherPricing);
  if (publisher) {
    return {
      ...publisher,
      nextAction: readFirst(publisher.nextAction, null),
    };
  }
  const sincerity = optionalRecord(record.projectAuthenticitySincerity) ?? optionalRecord(record.inquiryDeposit) ?? {};
  const status = readOptionalString(readFirst(sincerity.status, sincerity.depositStatus, sincerity.orderStatus));
  return {
    authenticitySincerityRequired: true,
    authenticitySincerityAmount: readFirst(sincerity.amount, '200.00'),
    authenticitySincerityStatus: status && status !== 'not_required' ? status : null,
    authenticitySincerityOrderId: readFirst(sincerity.orderId, sincerity.depositOrderId, null),
    authenticitySincerityCurrency: readFirst(sincerity.currency, 'CNY'),
    authenticitySincerityChannelCandidates: readArray(sincerity.channelCandidates),
    authenticitySincerityExpiresAt: readFirst(sincerity.expiresAt, null),
    publishGateStatus: status === 'paid' ? 'satisfied' : 'required',
    formalResultProcessingRequired: true,
    nextAction: readPricingNextAction(
      optionalRecord(record.messageDisplaySummary),
      'project_authenticity_sincerity.open',
    ),
  };
}

export function readBidderPricing(record: Payload) {
  const bidder = optionalRecord(record.bidderPricing);
  if (bidder) {
    return {
      ...bidder,
      nextAction: readFirst(bidder.nextAction, null),
    };
  }
  const authorization =
    optionalRecord(record.bidServiceFeeAuthorization) ?? optionalRecord(record.platformServiceFee) ?? {};
  const status = readOptionalString(readFirst(authorization.status, authorization.authorizationStatus));
  return {
    bidParticipationRequestId: readFirst(authorization.bidParticipationRequestId, null),
    authorizationRequired: Boolean(status && status !== 'not_required'),
    authorizationQuotaAmount: readFirst(
      authorization.authorizationQuotaAmount,
      authorization.quotaAmount,
      '4000.00',
    ),
    authorizationStatus: status && status !== 'not_required' ? status : null,
    bidSubmissionEligible: status === 'frozen',
    nextAction: readPricingNextAction(
      optionalRecord(record.messageDisplaySummary),
      status === 'frozen' ? 'bid_submit.open' : 'bid_service_fee_authorization.open',
    ),
  };
}

export function readDealSummary(record: Payload) {
  const deal = optionalRecord(record.dealSummary);
  if (deal) {
    return deal;
  }
  const confirmation = optionalRecord(record.dealConfirmation) ?? optionalRecord(record.contractConfirmation) ?? {};
  return {
    dealConfirmationId: readFirst(confirmation.dealConfirmationId, confirmation.contractConfirmationId, null),
    dealStatus: readFirst(confirmation.dealStatus, confirmation.status, null),
    selectedBidId: readFirst(confirmation.selectedBidId, null),
    finalConfirmedAmount: readFirst(confirmation.finalConfirmedAmount, null),
    platformServiceFeeAmount: readFirst(confirmation.platformServiceFeeAmount, confirmation.finalFeeAmount, null),
    serviceFeeChargeStatus: readFirst(confirmation.serviceFeeChargeStatus, null),
  };
}

export function pick(record: Payload, keys: string[]) {
  const result: Payload = {};
  for (const key of keys) {
    result[key] = record[key];
  }
  return result;
}

export function requireRecord(value: unknown, message: string) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as Payload;
  }
  throw new Error(message);
}

export function optionalRecord(value: unknown) {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? (value as Payload)
    : undefined;
}

export function compactOptional(value: Payload) {
  const result: Payload = {};
  for (const [key, rawValue] of Object.entries(value)) {
    if (rawValue !== undefined && rawValue !== null) {
      result[key] = rawValue;
    }
  }
  return Object.keys(result).length > 0 ? result : null;
}

export function readFeeSnapshot(...records: Array<Payload | undefined>) {
  return {
    feeRateLabel: readFromRecords(records, 'feeRateLabel'),
    feeRateSource: readFromRecords(records, 'feeRateSource'),
    membershipTierSnapshot: readFromRecords(records, 'membershipTierSnapshot'),
    baseFeeAmount: readFromRecords(records, 'baseFeeAmount'),
    membershipDiscountRate: readFromRecords(records, 'membershipDiscountRate'),
    capAmount: readFromRecords(records, 'capAmount'),
    finalFeeAmount: readFromRecords(records, 'finalFeeAmount'),
    feeRateRuleVersion: readFromRecords(records, 'feeRateRuleVersion'),
    feeRateSnapshotHash: readFromRecords(records, 'feeRateSnapshotHash'),
    feeCalculatedAt: readFromRecords(records, 'feeCalculatedAt'),
  };
}

export function readArray(value: unknown) {
  return Array.isArray(value) ? value : [];
}

export function readFirst(...values: unknown[]) {
  for (const value of values) {
    if (value !== undefined) {
      return value;
    }
  }
  return undefined;
}

function readPricingNextAction(messageDisplaySummary: Payload | undefined, fallbackActionKey: string) {
  const routeTarget = optionalRecord(messageDisplaySummary?.routeTarget);
  return {
    actionKey: readFirst(routeTarget?.actionKey, fallbackActionKey),
    routeTarget: routeTarget ?? null,
  };
}

function readFromRecords(records: Array<Payload | undefined>, key: string) {
  for (const record of records) {
    if (record && record[key] !== undefined) {
      return record[key];
    }
  }
  return undefined;
}

function readOptionalString(value: unknown) {
  return typeof value === 'string' && value.trim() ? value.trim() : undefined;
}
