type Payload = Record<string, unknown>;

export function readTradeTaskCreateReadModel(value: unknown) {
  const record = requireRecord(value, 'Trade task create response must be an object.');
  return pick(record, [
    'taskId',
    'taskType',
    'taskStatus',
    'authenticityLevel',
    'publishGateStatus',
    'paymentRequirement',
    'nextAction',
    'updatedAt',
  ]);
}

export function readTradeTaskDetailReadModel(value: unknown) {
  const record = requireRecord(value, 'Trade task detail response must be an object.');
  return {
    ...pick(record, [
      'taskId',
      'taskType',
      'publisherOrganization',
      'projectSummary',
      'authenticitySummary',
      'quoteSeatSummary',
      'resultProcessingSummary',
      'messageHandoff',
      'contractHandoff',
      'updatedAt',
    ]),
    pricingSummary: forceReadOnlyPricingSummary(readFirst(record.pricingSummary, record.p0PaySummary)),
  };
}

export function readAuthenticityMaterialsReadModel(value: unknown) {
  return pick(requireRecord(value, 'Authenticity material response must be an object.'), [
    'taskId',
    'authenticityLevel',
    'materialCount',
    'updatedAt',
  ]);
}

export function readFixedPriceBidReadModel(value: unknown) {
  return pick(requireRecord(value, 'Fixed-price bid response must be an object.'), [
    'bidId',
    'bidStatus',
    'platformServiceFeeRequirement',
    'nextAction',
    'updatedAt',
  ]);
}

export function readServiceFeeAuthorizationCreateReadModel(value: unknown) {
  const record = requireRecord(value, 'Service-fee authorization response must be an object.');
  const authorization = optionalRecord(record.authorization);
  return {
    authorizationId: readFirst(record.authorizationId, authorization?.authorizationId),
    authorizationStatus: readFirst(record.authorizationStatus, authorization?.status),
    quotedAmount: readFirst(record.quotedAmount, authorization?.quotedAmount),
    feeRate: readFirst(record.feeRate, authorization?.feeRate),
    ...readFeeSnapshot(record, authorization),
    authorizationQuotaAmount: readFirst(
      record.authorizationQuotaAmount,
      record.quotaAmount,
      authorization?.authorizationQuotaAmount,
      authorization?.quotaAmount,
    ),
    quotaAmount: readFirst(
      record.quotaAmount,
      record.authorizationQuotaAmount,
      authorization?.quotaAmount,
      authorization?.authorizationQuotaAmount,
    ),
    currency: readFirst(record.currency, authorization?.currency, 'CNY'),
    channelCandidates: readArray(record.channelCandidates),
    expiresAt: readFirst(record.expiresAt, authorization?.expiresAt, null),
    updatedAt: readFirst(record.updatedAt, authorization?.updatedAt),
  };
}

export function readServiceFeeAuthorizeInitReadModel(value: unknown) {
  const record = requireRecord(value, 'Service-fee authorize-init response must be an object.');
  return {
    authorizationInitStatus: record.authorizationInitStatus,
    authorizationId: record.authorizationId,
    paymentReferenceId: record.paymentReferenceId,
    channelActionType: record.channelActionType,
    channelPayload: optionalRecord(record.channelPayload) ?? null,
    callbackAwaiting: record.callbackAwaiting === true,
    expiresAt: readFirst(record.expiresAt, null),
    updatedAt: record.updatedAt,
  };
}

export function readServiceFeeAuthorizationStatusReadModel(value: unknown) {
  const record = requireRecord(value, 'Service-fee authorization status response must be an object.');
  const authorization = optionalRecord(record.authorization);
  const order = optionalRecord(record.paymentOrder);
  return {
    authorizationId: readFirst(record.authorizationId, authorization?.authorizationId),
    authorizationStatus: readFirst(record.authorizationStatus, authorization?.status),
    quotedAmount: readFirst(record.quotedAmount, authorization?.quotedAmount),
    feeRate: readFirst(record.feeRate, authorization?.feeRate),
    ...readFeeSnapshot(record, authorization),
    authorizationQuotaAmount: readFirst(
      record.authorizationQuotaAmount,
      record.quotaAmount,
      authorization?.authorizationQuotaAmount,
      authorization?.quotaAmount,
    ),
    quotaAmount: readFirst(
      record.quotaAmount,
      record.authorizationQuotaAmount,
      authorization?.quotaAmount,
      authorization?.authorizationQuotaAmount,
    ),
    currency: readFirst(record.currency, authorization?.currency, order?.currency, 'CNY'),
    channelSummary: readFirst(record.channelSummary, compactOptional({
      paymentOrderId: order?.paymentOrderId,
      merchantOrderNo: order?.merchantOrderNo,
      paymentChannel: order?.paymentChannel,
      status: order?.status,
    })),
    failureReasonCode: readFirst(record.failureReasonCode, null),
    updatedAt: readFirst(record.updatedAt, authorization?.updatedAt, order?.updatedAt),
  };
}

export function readInquiryDepositOrderReadModel(value: unknown) {
  const record = requireRecord(value, 'Inquiry deposit response must be an object.');
  return {
    depositOrderId: record.depositOrderId,
    depositStatus: record.depositStatus,
    amount: record.amount,
    currency: readFirst(record.currency, 'CNY'),
    channelCandidates: readArray(record.channelCandidates),
    expiresAt: readFirst(record.expiresAt, null),
    updatedAt: record.updatedAt,
  };
}

export function readProjectAuthenticitySincerityOrderReadModel(value: unknown) {
  const record = requireRecord(value, 'Project authenticity sincerity order response must be an object.');
  return {
    orderId: readFirst(record.orderId, record.depositOrderId),
    orderStatus: readFirst(record.orderStatus, record.depositStatus),
    amount: record.amount,
    currency: readFirst(record.currency, 'CNY'),
    channelCandidates: readArray(record.channelCandidates),
    expiresAt: readFirst(record.expiresAt, null),
    updatedAt: record.updatedAt,
  };
}

export function readInquiryDepositPayInitReadModel(value: unknown) {
  const record = requireRecord(value, 'Inquiry deposit pay-init response must be an object.');
  return {
    paymentInitStatus: record.paymentInitStatus,
    depositOrderId: record.depositOrderId,
    paymentReferenceId: record.paymentReferenceId,
    channelActionType: record.channelActionType,
    channelPayload: optionalRecord(record.channelPayload) ?? null,
    callbackAwaiting: record.callbackAwaiting === true,
    expiresAt: readFirst(record.expiresAt, null),
    updatedAt: record.updatedAt,
  };
}

export function readProjectAuthenticitySincerityPayInitReadModel(value: unknown) {
  const record = requireRecord(value, 'Project authenticity sincerity pay-init response must be an object.');
  return {
    paymentInitStatus: record.paymentInitStatus,
    orderId: readFirst(record.orderId, record.depositOrderId),
    paymentReferenceId: record.paymentReferenceId,
    channelActionType: record.channelActionType,
    channelPayload: optionalRecord(record.channelPayload) ?? null,
    callbackAwaiting: record.callbackAwaiting === true,
    expiresAt: readFirst(record.expiresAt, null),
    updatedAt: record.updatedAt,
  };
}

export function readInquiryDepositStatusReadModel(value: unknown) {
  return pick(requireRecord(value, 'Inquiry deposit status response must be an object.'), [
    'depositOrderId',
    'depositStatus',
    'amount',
    'currency',
    'refundStatus',
    'deductionStatus',
    'deductionReason',
    'channelSummary',
    'updatedAt',
  ]);
}

export function readProjectAuthenticitySincerityStatusReadModel(value: unknown) {
  const record = requireRecord(value, 'Project authenticity sincerity status response must be an object.');
  return {
    orderId: readFirst(record.orderId, record.depositOrderId),
    orderStatus: readFirst(record.orderStatus, record.depositStatus),
    amount: record.amount,
    currency: readFirst(record.currency, 'CNY'),
    refundStatus: readFirst(record.refundStatus, 'not_refunded'),
    withholdStatus: readFirst(record.withholdStatus, record.deductionStatus, 'not_withheld'),
    withholdReasonCode: readFirst(record.withholdReasonCode, record.deductionReason, null),
    channelSummary: readFirst(record.channelSummary, null),
    updatedAt: record.updatedAt,
  };
}

export function readBidServiceFeeAuthorizationCreateReadModel(value: unknown) {
  const record = requireRecord(value, 'Bid service fee authorization response must be an object.');
  const authorization = optionalRecord(record.authorization);
  return {
    authorizationId: readFirst(record.authorizationId, authorization?.authorizationId),
    authorizationStatus: readFirst(record.authorizationStatus, authorization?.status),
    authorizationQuotaAmount: readFirst(
      record.authorizationQuotaAmount,
      record.quotaAmount,
      authorization?.authorizationQuotaAmount,
      authorization?.quotaAmount,
    ),
    currency: readFirst(record.currency, authorization?.currency, 'CNY'),
    channelCandidates: readArray(record.channelCandidates),
    expiresAt: readFirst(record.expiresAt, authorization?.expiresAt, null),
    updatedAt: readFirst(record.updatedAt, authorization?.updatedAt),
  };
}

export function readBidServiceFeeAuthorizationFreezeInitReadModel(value: unknown) {
  const record = requireRecord(value, 'Bid service fee freeze-init response must be an object.');
  return {
    freezeInitStatus: readFirst(record.freezeInitStatus, record.authorizationInitStatus),
    authorizationId: record.authorizationId,
    paymentReferenceId: record.paymentReferenceId,
    channelActionType: record.channelActionType,
    channelPayload: optionalRecord(record.channelPayload) ?? null,
    callbackAwaiting: record.callbackAwaiting === true,
    expiresAt: readFirst(record.expiresAt, null),
    updatedAt: record.updatedAt,
  };
}

export function readBidServiceFeeAuthorizationStatusReadModel(value: unknown) {
  const record = requireRecord(value, 'Bid service fee authorization status response must be an object.');
  const authorization = optionalRecord(record.authorization);
  const order = optionalRecord(record.paymentOrder);
  return {
    authorizationId: readFirst(record.authorizationId, authorization?.authorizationId),
    authorizationStatus: readFirst(record.authorizationStatus, authorization?.status),
    authorizationQuotaAmount: readFirst(
      record.authorizationQuotaAmount,
      record.quotaAmount,
      authorization?.authorizationQuotaAmount,
      authorization?.quotaAmount,
    ),
    currency: readFirst(record.currency, authorization?.currency, order?.currency, 'CNY'),
    chargeStatus: readFirst(record.chargeStatus, authorization?.chargeStatus, 'not_charged'),
    releaseStatus: readFirst(record.releaseStatus, authorization?.releaseStatus, 'not_released'),
    channelSummary: readFirst(record.channelSummary, compactOptional({
      paymentOrderId: order?.paymentOrderId,
      merchantOrderNo: order?.merchantOrderNo,
      paymentChannel: order?.paymentChannel,
      status: order?.status,
    })),
    updatedAt: readFirst(record.updatedAt, authorization?.updatedAt, order?.updatedAt),
  };
}

export function readBidServiceFeeAuthorizationReleaseReadModel(value: unknown) {
  const record = requireRecord(value, 'Bid service fee authorization release response must be an object.');
  return {
    authorizationId: record.authorizationId,
    authorizationStatus: record.authorizationStatus,
    bidSubmissionEligible: record.bidSubmissionEligible === true,
    updatedAt: record.updatedAt,
  };
}

export function readInquiryQuotationReadModel(value: unknown) {
  return pick(requireRecord(value, 'Inquiry quotation response must be an object.'), [
    'quotationId',
    'quotationStatus',
    'quoteSeatSummary',
    'updatedAt',
  ]);
}

export function readInquiryResultReadModel(value: unknown) {
  return pick(requireRecord(value, 'Inquiry result response must be an object.'), [
    'taskId',
    'processingStatus',
    'inquiryDepositStatus',
    'contractHandoff',
    'creditImpactSummary',
    'updatedAt',
  ]);
}

export function readContractConfirmationReadModel(value: unknown) {
  return pick(requireRecord(value, 'Contract confirmation response must be an object.'), [
    'contractConfirmationId',
    'contractStatus',
    'finalConfirmedAmount',
    'platformServiceFeeFinalAmount',
    'platformServiceFeeStatus',
    'platformServiceFeeCharge',
    'nextAction',
    'updatedAt',
  ]);
}

export function readDealConfirmationAcceptedReadModel(value: unknown) {
  const record = requireRecord(value, 'Deal confirmation response must be an object.');
  return {
    dealConfirmationId: readFirst(record.dealConfirmationId, record.contractConfirmationId),
    dealStatus: readFirst(record.dealStatus, record.contractStatus),
    selectedBidId: record.selectedBidId,
    finalConfirmedAmount: record.finalConfirmedAmount,
    platformServiceFeeCalculation: readFirst(record.platformServiceFeeCalculation, record.platformServiceFeeCharge),
    serviceFeeChargeStatus: readFirst(record.serviceFeeChargeStatus, record.platformServiceFeeStatus),
    updatedAt: record.updatedAt,
  };
}

export function readDealConfirmationReadModel(value: unknown) {
  const record = readDealConfirmationAcceptedReadModel(value);
  const source = requireRecord(value, 'Deal confirmation detail response must be an object.');
  return {
    ...record,
    publisherConfirmedAt: readFirst(source.publisherConfirmedAt, null),
    factoryConfirmedAt: readFirst(source.factoryConfirmedAt, null),
    publisherAuthenticitySincerityStatus: readFirst(source.publisherAuthenticitySincerityStatus, null),
  };
}

export function readP0PaySummaryReadModel(value: unknown) {
  return readPricingSummaryReadModel(value);
}

export function readPricingSummaryReadModel(value: unknown) {
  const record = requireRecord(value, 'P0-Pay summary response must be an object.');
  return {
    projectId: readFirst(record.projectId, record.taskId),
    publisherPricing: readPublisherPricing(record),
    bidderPricing: readBidderPricing(record),
    dealSummary: readDealSummary(record),
    updatedAt: record.updatedAt,
    readOnly: true,
  };
}

export function readP0PayStateActionReadModel(value: unknown) {
  return pick(requireRecord(value, 'P0-Pay state action response must be an object.'), [
    'action',
    'changed',
    'authorizationIds',
    'bidId',
    'updatedAt',
  ]);
}

function forceReadOnlyPricingSummary(value: unknown) {
  if (!value) {
    return { readOnly: true };
  }
  return readPricingSummaryReadModel(value);
}

function readPublisherPricing(record: Payload) {
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
    publishGateStatus: status === 'paid' ? 'satisfied' : 'required',
    formalResultProcessingRequired: true,
    nextAction: readPricingNextAction(
      optionalRecord(record.messageDisplaySummary),
      'project_authenticity_sincerity.open',
    ),
  };
}

function readBidderPricing(record: Payload) {
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

function readDealSummary(record: Payload) {
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

function readPricingNextAction(messageDisplaySummary: Payload | undefined, fallbackActionKey: string) {
  const routeTarget = optionalRecord(messageDisplaySummary?.routeTarget);
  return {
    actionKey: readFirst(routeTarget?.actionKey, fallbackActionKey),
    routeTarget: routeTarget ?? null,
  };
}

function pick(record: Payload, keys: string[]) {
  const result: Payload = {};
  for (const key of keys) {
    result[key] = record[key];
  }
  return result;
}

function requireRecord(value: unknown, message: string) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as Payload;
  }
  throw new Error(message);
}

function optionalRecord(value: unknown) {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? (value as Payload)
    : undefined;
}

function compactOptional(value: Payload) {
  const result: Payload = {};
  for (const [key, rawValue] of Object.entries(value)) {
    if (rawValue !== undefined && rawValue !== null) {
      result[key] = rawValue;
    }
  }
  return Object.keys(result).length > 0 ? result : null;
}

function readFeeSnapshot(...records: Array<Payload | undefined>) {
  return {
    feeRateLabel: readFromRecords(records, 'feeRateLabel'),
    feeRateSource: readFromRecords(records, 'feeRateSource'),
    membershipTierSnapshot: readFromRecords(records, 'membershipTierSnapshot'),
    feeRateRuleVersion: readFromRecords(records, 'feeRateRuleVersion'),
    feeRateSnapshotHash: readFromRecords(records, 'feeRateSnapshotHash'),
    feeCalculatedAt: readFromRecords(records, 'feeCalculatedAt'),
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

function readArray(value: unknown) {
  return Array.isArray(value) ? value : [];
}

function readFirst(...values: unknown[]) {
  for (const value of values) {
    if (value !== undefined) {
      return value;
    }
  }
  return undefined;
}

function readOptionalString(value: unknown) {
  return typeof value === 'string' && value.trim() ? value.trim() : undefined;
}
