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
    p0PaySummary: forceReadOnly(record.p0PaySummary),
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
    estimatedFeeAmount: readFirst(record.estimatedFeeAmount, authorization?.estimatedFeeAmount),
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
    estimatedFeeAmount: readFirst(record.estimatedFeeAmount, authorization?.estimatedFeeAmount),
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
    'nextAction',
    'updatedAt',
  ]);
}

export function readP0PaySummaryReadModel(value: unknown) {
  const record = requireRecord(value, 'P0-Pay summary response must be an object.');
  return {
    taskId: record.taskId,
    taskType: record.taskType,
    platformServiceFee: record.platformServiceFee,
    inquiryDeposit: record.inquiryDeposit,
    contractConfirmation: record.contractConfirmation,
    messageDisplaySummary: readMessageDisplaySummary(record.messageDisplaySummary),
    updatedAt: record.updatedAt,
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

function readMessageDisplaySummary(value: unknown) {
  const record = optionalRecord(value) ?? {};
  return {
    displayAllowed: record.displayAllowed === true,
    readOnly: true,
    statusTextKey: readOptionalString(record.statusTextKey) ?? 'p0_pay_status_unavailable',
    routeTarget: optionalRecord(record.routeTarget) ?? null,
  };
}

function forceReadOnly(value: unknown) {
  const record = optionalRecord(value) ?? {};
  return {
    ...pick(record, [
      'platformServiceFeeStatus',
      'platformServiceFeeEstimatedAmount',
      'platformServiceFeeFinalAmount',
      'inquiryDepositStatus',
      'inquiryDepositAmount',
      'paymentChannelSummary',
    ]),
    readOnly: true,
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
