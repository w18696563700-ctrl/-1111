import {
  compactOptional,
  optionalRecord,
  pick,
  readArray,
  readBidderPricing,
  readDealSummary,
  readFeeSnapshot,
  readFirst,
  readPublisherPricing,
  requireRecord,
} from './exhibition-p0-pay.read-model-support';

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
    estimatedFeeAmount: readFirst(
      record.serviceFeeEstimatedAmount,
      record.estimatedFeeAmount,
      authorization?.serviceFeeEstimatedAmount,
      authorization?.estimatedFeeAmount,
    ),
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
    estimatedFeeAmount: readFirst(
      record.serviceFeeEstimatedAmount,
      record.estimatedFeeAmount,
      authorization?.serviceFeeEstimatedAmount,
      authorization?.estimatedFeeAmount,
    ),
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

export function readProjectAuthenticitySincerityFreezeFeedbackReadModel(value: unknown) {
  const record = requireRecord(value, 'Project authenticity sincerity freeze feedback response must be an object.');
  return {
    projectId: record.projectId,
    myChoice: record.myChoice,
    supportFreezeCount: readFirst(record.supportFreezeCount, 0),
    opposeFreezeCount: readFirst(record.opposeFreezeCount, 0),
    updatedAt: record.updatedAt,
    traceId: readFirst(record.traceId, null),
  };
}

export function readProjectAuthenticitySincerityRefundReadModel(value: unknown) {
  const record = requireRecord(value, 'Project authenticity sincerity refund response must be an object.');
  return {
    orderId: readFirst(record.orderId, record.depositOrderId),
    refundOrderId: readFirst(record.refundOrderId, null),
    refundReferenceId: readFirst(record.refundReferenceId, null),
    refundStatus: readFirst(record.refundStatus, 'not_refunded'),
    orderStatus: readFirst(record.orderStatus, record.depositStatus),
    amount: record.amount,
    currency: readFirst(record.currency, 'CNY'),
    refundChannel: readFirst(record.refundChannel, null),
    callbackAwaiting: record.callbackAwaiting === true,
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
    authorizationStatus: record.authorizationStatus,
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

export function readProjectSettlementSummaryReadModel(value: unknown) {
  const record = requireRecord(value, 'Project settlement response must be an object.');
  const summary = optionalRecord(record.settlementSummary) ?? {};
  return {
    projectId: readFirst(record.projectId, null),
    settlementSummary: {
      settlementStatus: readFirst(summary.settlementStatus, 'empty'),
      platformIncomeAmount: readFirst(summary.platformIncomeAmount, '0.00'),
      pendingSettlementAmount: readFirst(summary.pendingSettlementAmount, '0.00'),
      settledAmount: readFirst(summary.settledAmount, '0.00'),
      refundedAmount: readFirst(summary.refundedAmount, '0.00'),
      abnormalHoldAmount: readFirst(summary.abnormalHoldAmount, '0.00'),
      reconciliationStatus: readFirst(summary.reconciliationStatus, 'balanced'),
      reconciliationDifferenceAmount: readFirst(summary.reconciliationDifferenceAmount, '0.00'),
      autoPayoutEnabled: summary.autoPayoutEnabled === true,
      payoutStatus: readFirst(summary.payoutStatus, 'not_started'),
      updatedAt: readFirst(summary.updatedAt, record.updatedAt, null),
    },
    charges: readArray(record.charges),
    batchDraft: readFirst(record.batchDraft, null),
    reconciliationSummary: readFirst(record.reconciliationSummary, null),
    updatedAt: record.updatedAt,
    readOnly: true,
  };
}

function forceReadOnlyPricingSummary(value: unknown) {
  if (!value) {
    return { readOnly: true };
  }
  return readPricingSummaryReadModel(value);
}
