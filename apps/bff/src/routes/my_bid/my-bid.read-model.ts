type BidPayload = Record<string, unknown>;

export function readMyBidsReadModel(value: unknown) {
  const record = requireRecord(value, 'My-bids response must be an object.');
  if (!Array.isArray(record.items)) {
    throw new Error('My-bids response is missing `items`.');
  }

  return {
    items: record.items.map((item, index) =>
      readMyBidItem(
        requireRecord(item, `My-bids response item[${index}] must be an object.`),
      ),
    ),
  };
}

export function readBidSubmissionSnapshotReadModel(value: unknown) {
  const record = requireRecord(value, 'Bid submission snapshot response must be an object.');
  return {
    projectId: readRequiredString(record.projectId, 'projectId'),
    bidId: readRequiredString(record.bidId, 'bidId'),
    bidder: readBidderSummary(
      requireRecord(record.bidder, 'Bid submission snapshot response is missing bidder.'),
    ),
    submittedAt: readRequiredString(record.submittedAt, 'submittedAt'),
    quoteAmount: readRequiredNumber(record.quoteAmount, 'quoteAmount'),
    proposalSummary: readRequiredString(record.proposalSummary, 'proposalSummary'),
    attachmentSummary: readLooseCarrier(record.attachmentSummary, 'attachmentSummary'),
    attachments: readAttachmentList(record.attachments),
    availability: readLooseCarrier(record.availability, 'availability'),
  };
}

function readMyBidItem(record: BidPayload) {
  return {
    bidId: readRequiredString(record.bidId, 'bidId'),
    projectId: readRequiredString(record.projectId, 'projectId'),
    projectTitle: readRequiredString(record.projectTitle, 'projectTitle'),
    submittedAt: readRequiredString(record.submittedAt, 'submittedAt'),
    quoteAmount: readRequiredNumber(record.quoteAmount, 'quoteAmount'),
    outcomeState: readRequiredString(record.outcomeState, 'outcomeState'),
    canOpenBidThread: readRequiredBoolean(record.canOpenBidThread, 'canOpenBidThread'),
    canOpenBidResult: readRequiredBoolean(record.canOpenBidResult, 'canOpenBidResult'),
    snapshotReadable: readRequiredBoolean(record.snapshotReadable, 'snapshotReadable'),
  };
}

function readBidderSummary(record: BidPayload) {
  return {
    organizationId: readRequiredString(record.organizationId, 'bidder.organizationId'),
    displayName: readRequiredString(record.displayName, 'bidder.displayName'),
    avatarUrl: readNullableString(record.avatarUrl),
  };
}

function readAttachmentList(value: unknown) {
  if (!Array.isArray(value)) {
    throw new Error('Bid submission snapshot response is missing `attachments`.');
  }
  return value.map((item, index) =>
    readAttachmentItem(
      requireRecord(item, `Bid submission snapshot attachments[${index}] must be an object.`),
    ),
  );
}

function readAttachmentItem(record: BidPayload) {
  return {
    slotKey: readRequiredString(record.slotKey, 'attachments.slotKey'),
    slotLabel: readRequiredString(record.slotLabel, 'attachments.slotLabel'),
    fileAssetId: readRequiredString(record.fileAssetId, 'attachments.fileAssetId'),
    fileKind: readRequiredString(record.fileKind, 'attachments.fileKind'),
    mimeType: readRequiredString(record.mimeType, 'attachments.mimeType'),
  };
}

function readLooseCarrier(value: unknown, fieldName: string) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw new Error(`Bid submission snapshot response is missing \`${fieldName}\`.`);
  }

  const result: Record<string, string | number | boolean | null> = {};
  for (const [key, rawValue] of Object.entries(value as BidPayload)) {
    if (
      rawValue === null ||
      typeof rawValue === 'string' ||
      typeof rawValue === 'number' ||
      typeof rawValue === 'boolean'
    ) {
      result[key] = rawValue;
    }
  }
  return result;
}

function requireRecord(value: unknown, message: string) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as BidPayload;
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

function readRequiredNumber(value: unknown, fieldName: string) {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    throw new Error(`Bid response is missing \`${fieldName}\`.`);
  }
  return value;
}

function readRequiredBoolean(value: unknown, fieldName: string) {
  if (typeof value !== 'boolean') {
    throw new Error(`Bid response is missing \`${fieldName}\`.`);
  }
  return value;
}

function readNullableString(value: unknown) {
  if (value === null || value === undefined) {
    return null;
  }
  if (typeof value !== 'string') {
    throw new Error('Bid response contains an invalid nullable string field.');
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}
