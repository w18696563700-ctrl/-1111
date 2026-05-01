export type MembershipPurchaseOfferViewModel = {
  skuCode: string;
  skuName: string;
  membershipTier: string;
  durationMonths: number;
  priceAmount: number;
  currency: string;
  entitlementSummary: string[];
  serviceFeeDiscountSummary: string | null;
  isRenewable: boolean;
  isUpgradable: boolean;
  status: string;
};

export type MembershipPurchaseOffersViewModel = {
  offers: MembershipPurchaseOfferViewModel[];
  currentOrganizationMembershipContext: {
    organizationId: string | null;
    paidMembershipTier: string | null;
    purchaseEligible: boolean;
    ineligibleReasonCode: string | null;
  };
  channelCandidates: string[];
  commercialDisclosure: string;
  updatedAt: string;
};

export type MembershipOrderCreateViewModel = {
  membershipOrderId: string;
  orderStatus: string;
  payableAmount: number;
  currency: string;
  entitlementPreview: MembershipSkuSnapshotViewModel;
  channelCandidates: string[];
  expiresAt: string | null;
  updatedAt: string;
};

export type MembershipPayInitViewModel = {
  paymentInitStatus: string;
  membershipOrderId: string;
  paymentReferenceId: string;
  channelActionType: string;
  channelPayload: Record<string, unknown>;
  callbackAwaiting: boolean;
  expiresAt: string | null;
  updatedAt: string;
};

export type MembershipOrderResultViewModel = {
  membershipOrderId: string;
  organizationId: string;
  orderStatus: string;
  paymentStatus: string;
  entitlementStatus: string;
  skuSnapshot: MembershipSkuSnapshotViewModel;
  amountSummary: {
    payableAmount: number;
    currency: string;
  };
  channelSummary: {
    payChannel: string | null;
    paymentReferenceId: string | null;
    callbackAwaiting: boolean;
  };
  effectiveAt: string | null;
  expiresAt: string | null;
  failureReasonCode: string | null;
  updatedAt: string;
};

type MembershipSkuSnapshotViewModel = {
  skuCode: string;
  skuName: string;
  membershipTier: string;
  durationMonths: number;
  serviceFeeDiscountSummary: string | null;
};

export function readMembershipPurchaseOffersViewModel(
  result: Record<string, unknown>,
): MembershipPurchaseOffersViewModel {
  requireKeys(result, [
    'offers',
    'currentOrganizationMembershipContext',
    'channelCandidates',
    'commercialDisclosure',
    'updatedAt',
  ]);
  return {
    offers: readObjectArray(result.offers, 'Invalid membership purchase offers.').map(readOffer),
    currentOrganizationMembershipContext: readPurchaseContext(
      readRecord(result.currentOrganizationMembershipContext, 'Invalid membership purchase context.'),
    ),
    channelCandidates: readStringArray(result.channelCandidates, 'Invalid membership channel candidates.'),
    commercialDisclosure: readRequiredString(result.commercialDisclosure, 'Missing commercial disclosure.'),
    updatedAt: readRequiredString(result.updatedAt, 'Missing purchase offers updatedAt.'),
  };
}

export function readMembershipOrderCreateViewModel(
  result: Record<string, unknown>,
): MembershipOrderCreateViewModel {
  requireKeys(result, [
    'membershipOrderId',
    'orderStatus',
    'payableAmount',
    'currency',
    'entitlementPreview',
    'channelCandidates',
    'expiresAt',
    'updatedAt',
  ]);
  return {
    membershipOrderId: readRequiredString(result.membershipOrderId, 'Missing membershipOrderId.'),
    orderStatus: readRequiredString(result.orderStatus, 'Missing membership orderStatus.'),
    payableAmount: readNumber(result.payableAmount, 'Invalid membership payableAmount.'),
    currency: readRequiredString(result.currency, 'Missing membership currency.'),
    entitlementPreview: readSkuSnapshot(readRecord(result.entitlementPreview, 'Invalid entitlementPreview.')),
    channelCandidates: readStringArray(result.channelCandidates, 'Invalid channelCandidates.'),
    expiresAt: readNullableString(result.expiresAt),
    updatedAt: readRequiredString(result.updatedAt, 'Missing updatedAt.'),
  };
}

export function readMembershipPayInitViewModel(
  result: Record<string, unknown>,
): MembershipPayInitViewModel {
  requireKeys(result, [
    'paymentInitStatus',
    'membershipOrderId',
    'paymentReferenceId',
    'channelActionType',
    'channelPayload',
    'callbackAwaiting',
    'expiresAt',
    'updatedAt',
  ]);
  return {
    paymentInitStatus: readRequiredString(result.paymentInitStatus, 'Missing paymentInitStatus.'),
    membershipOrderId: readRequiredString(result.membershipOrderId, 'Missing membershipOrderId.'),
    paymentReferenceId: readRequiredString(result.paymentReferenceId, 'Missing paymentReferenceId.'),
    channelActionType: readRequiredString(result.channelActionType, 'Missing channelActionType.'),
    channelPayload: readRecord(result.channelPayload, 'Invalid channelPayload.'),
    callbackAwaiting: readBoolean(result.callbackAwaiting, 'Invalid callbackAwaiting.'),
    expiresAt: readNullableString(result.expiresAt),
    updatedAt: readRequiredString(result.updatedAt, 'Missing updatedAt.'),
  };
}

export function readMembershipOrderResultViewModel(
  result: Record<string, unknown>,
): MembershipOrderResultViewModel {
  requireKeys(result, [
    'membershipOrderId',
    'organizationId',
    'orderStatus',
    'paymentStatus',
    'entitlementStatus',
    'skuSnapshot',
    'amountSummary',
    'channelSummary',
    'updatedAt',
  ]);
  const amount = readRecord(result.amountSummary, 'Invalid amountSummary.');
  const channel = readRecord(result.channelSummary, 'Invalid channelSummary.');
  return {
    membershipOrderId: readRequiredString(result.membershipOrderId, 'Missing membershipOrderId.'),
    organizationId: readRequiredString(result.organizationId, 'Missing organizationId.'),
    orderStatus: readRequiredString(result.orderStatus, 'Missing orderStatus.'),
    paymentStatus: readRequiredString(result.paymentStatus, 'Missing paymentStatus.'),
    entitlementStatus: readRequiredString(result.entitlementStatus, 'Missing entitlementStatus.'),
    skuSnapshot: readSkuSnapshot(readRecord(result.skuSnapshot, 'Invalid skuSnapshot.')),
    amountSummary: {
      payableAmount: readNumber(amount.payableAmount, 'Invalid payableAmount.'),
      currency: readRequiredString(amount.currency, 'Missing amount currency.'),
    },
    channelSummary: {
      payChannel: readNullableString(channel.payChannel),
      paymentReferenceId: readNullableString(channel.paymentReferenceId),
      callbackAwaiting: readBoolean(channel.callbackAwaiting, 'Invalid channel callbackAwaiting.'),
    },
    effectiveAt: readNullableString(result.effectiveAt),
    expiresAt: readNullableString(result.expiresAt),
    failureReasonCode: readNullableString(result.failureReasonCode),
    updatedAt: readRequiredString(result.updatedAt, 'Missing updatedAt.'),
  };
}

function readOffer(item: Record<string, unknown>): MembershipPurchaseOfferViewModel {
  requireKeys(item, [
    'skuCode',
    'skuName',
    'membershipTier',
    'durationMonths',
    'priceAmount',
    'currency',
    'entitlementSummary',
    'serviceFeeDiscountSummary',
    'status',
  ]);
  return {
    skuCode: readRequiredString(item.skuCode, 'Missing skuCode.'),
    skuName: readRequiredString(item.skuName, 'Missing skuName.'),
    membershipTier: readRequiredString(item.membershipTier, 'Missing membershipTier.'),
    durationMonths: readInteger(item.durationMonths, 'Invalid durationMonths.'),
    priceAmount: readNumber(item.priceAmount, 'Invalid priceAmount.'),
    currency: readRequiredString(item.currency, 'Missing currency.'),
    entitlementSummary: readStringArray(item.entitlementSummary, 'Invalid entitlementSummary.'),
    serviceFeeDiscountSummary: readNullableString(item.serviceFeeDiscountSummary),
    isRenewable: readOptionalBoolean(item.isRenewable),
    isUpgradable: readOptionalBoolean(item.isUpgradable),
    status: readRequiredString(item.status, 'Missing status.'),
  };
}

function readPurchaseContext(item: Record<string, unknown>) {
  requireKeys(item, ['organizationId', 'paidMembershipTier', 'purchaseEligible']);
  return {
    organizationId: readNullableString(item.organizationId),
    paidMembershipTier: readNullableString(item.paidMembershipTier),
    purchaseEligible: readBoolean(item.purchaseEligible, 'Invalid purchaseEligible.'),
    ineligibleReasonCode: readNullableString(item.ineligibleReasonCode),
  };
}

function readSkuSnapshot(item: Record<string, unknown>): MembershipSkuSnapshotViewModel {
  requireKeys(item, ['skuCode', 'skuName', 'membershipTier', 'durationMonths', 'serviceFeeDiscountSummary']);
  return {
    skuCode: readRequiredString(item.skuCode, 'Missing skuCode.'),
    skuName: readRequiredString(item.skuName, 'Missing skuName.'),
    membershipTier: readRequiredString(item.membershipTier, 'Missing membershipTier.'),
    durationMonths: readInteger(item.durationMonths, 'Invalid durationMonths.'),
    serviceFeeDiscountSummary: readNullableString(item.serviceFeeDiscountSummary),
  };
}

function requireKeys(source: Record<string, unknown>, keys: string[]) {
  if (!keys.every((key) => Object.prototype.hasOwnProperty.call(source, key))) {
    throw new Error('Membership purchase response is missing required fields.');
  }
}

function readRecord(value: unknown, message: string): Record<string, unknown> {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

function readObjectArray(value: unknown, message: string) {
  if (!Array.isArray(value)) {
    throw new Error(message);
  }
  return value.map((item) => readRecord(item, message));
}

function readStringArray(value: unknown, message: string) {
  if (!Array.isArray(value)) {
    throw new Error(message);
  }
  return value.map((item) => readRequiredString(item, message));
}

function readRequiredString(value: unknown, message: string) {
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(message);
  }
  return value.trim();
}

function readNullableString(value: unknown) {
  if (value === null || value === undefined) {
    return null;
  }
  return readRequiredString(value, 'Expected nullable string.');
}

function readNumber(value: unknown, message: string) {
  const parsed = typeof value === 'number'
    ? value
    : Number(readRequiredString(value, message));
  if (!Number.isFinite(parsed)) {
    throw new Error(message);
  }
  return parsed;
}

function readInteger(value: unknown, message: string) {
  const parsed = typeof value === 'number'
    ? value
    : Number.parseInt(readRequiredString(value, message), 10);
  if (!Number.isInteger(parsed)) {
    throw new Error(message);
  }
  return parsed;
}

function readBoolean(value: unknown, message: string) {
  if (typeof value !== 'boolean') {
    throw new Error(message);
  }
  return value;
}

function readOptionalBoolean(value: unknown) {
  return typeof value === 'boolean' ? value : false;
}
