type Payload = Record<string, unknown>;

const ENTRY_KEYS = new Set([
  'publisher_effect_image_review',
  'publisher_construction_doc_review',
  'publisher_material_sample_review',
  'publisher_equipment_material_list_review',
  'publisher_service_list_review',
  'bid_project_understanding_review',
  'bid_quote_sheet_review',
  'bid_schedule_plan_review',
  'contract_confirmation',
  'final_confirmed_amount_confirmation'
]);
const GROUPS = new Set(['publisher_materials', 'bid_materials', 'deal_confirmation']);
const VIEWER_ROLES = new Set(['publisher', 'bidder', 'unknown']);
const SUBJECT_OWNER_ROLES = new Set(['publisher', 'bidder', 'platform']);
const AVAILABILITY_STATES = new Set(['unsubmitted', 'readable', 'unavailable']);
const REVIEW_STATES = new Set(['unsubmitted', 'pending_review', 'confirmed', 'needs_supplement']);
const ACTION_STATES = new Set(['enabled', 'readonly', 'blocked']);
const CHAT_LOCK_REASON_CODES = new Set([
  'bid_participation_review_pending',
  'publisher_material_confirmation_pending',
  'bid_submission_pending',
  'bid_material_confirmation_pending',
  'service_fee_authorization_pending',
  'deal_confirmation_pending'
]);
const CHAT_REQUIRED_NEXT_ACTIONS = new Set([
  'review_bid_participation',
  'confirm_publisher_materials',
  'submit_bid_materials',
  'confirm_bid_materials',
  'complete_service_fee_authorization',
  'open_deal_confirmation',
  'none'
]);

export function readProjectCommunicationWorkbenchReadModel(value: unknown) {
  const source = requireRecord(value, 'Project communication workbench response is invalid.');
  return {
    projectId: readString(source.projectId, 'projectId'),
    threadId: readString(source.threadId, 'threadId'),
    viewerRole: readEnum(source.viewerRole, 'viewerRole', VIEWER_ROLES),
    businessTodoSummary: readBusinessTodoSummary(source.businessTodoSummary),
    chatAvailability: readChatAvailability(source.chatAvailability),
    entries: readArray(source.entries, 'entries').map(readWorkbenchEntry),
    generatedAt: readString(source.generatedAt, 'generatedAt')
  };
}

export function readProjectCommunicationMaterialReviewResponseReadModel(value: unknown) {
  const source = requireRecord(value, 'Project communication material review response is invalid.');
  return {
    entry: readWorkbenchEntry(source.entry),
    entries: source.entries === undefined ? undefined : readArray(source.entries, 'entries').map(readWorkbenchEntry),
    projectId: readString(source.projectId, 'projectId'),
    threadId: readString(source.threadId, 'threadId'),
    viewerRole: readEnum(source.viewerRole, 'viewerRole', VIEWER_ROLES),
    updatedAt: readString(source.updatedAt, 'updatedAt')
  };
}

function readWorkbenchEntry(value: unknown) {
  const source = requireRecord(value, 'Project communication workbench entry is invalid.');
  const group = readEnum(source.group, 'entry.group', GROUPS);
  const reviewState = source.reviewState === null
    ? null
    : readEnum(source.reviewState, 'entry.reviewState', REVIEW_STATES);
  if (group === 'deal_confirmation' && reviewState !== null) {
    throw new Error('Deal confirmation workbench entries must not carry material review state.');
  }
  return {
    entryKey: readEnum(source.entryKey, 'entry.entryKey', ENTRY_KEYS),
    group,
    label: readString(source.label, 'entry.label'),
    summary: readNullableString(source.summary),
    projectId: readString(source.projectId, 'entry.projectId'),
    threadId: readString(source.threadId, 'entry.threadId'),
    bidId: readNullableString(source.bidId),
    viewerRole: readEnum(source.viewerRole, 'entry.viewerRole', VIEWER_ROLES),
    subjectOwnerRole: readEnum(source.subjectOwnerRole, 'entry.subjectOwnerRole', SUBJECT_OWNER_ROLES),
    availabilityState: readEnum(source.availabilityState, 'entry.availabilityState', AVAILABILITY_STATES),
    reviewState,
    actionState: readEnum(source.actionState, 'entry.actionState', ACTION_STATES),
    attachmentCount: readNonNegativeNumber(source.attachmentCount, 'entry.attachmentCount'),
    badgeCount: readNonNegativeNumber(source.badgeCount, 'entry.badgeCount'),
    disabledReason: readNullableString(source.disabledReason),
    sourceFiles: readSourceFiles(source.sourceFiles),
    latestFeedbackText: readNullableString(source.latestFeedbackText),
    latestFeedbackAt: readNullableString(source.latestFeedbackAt),
    reviewedAt: readNullableString(source.reviewedAt),
    routeTarget: readNullableRecord(source.routeTarget),
    truthAnchor: readRecord(source.truthAnchor, 'entry.truthAnchor')
  };
}

function readBusinessTodoSummary(value: unknown) {
  const source = requireRecord(value, 'Project communication businessTodoSummary is invalid.');
  const summary = {
    bidParticipationReviewPendingCount: readNonNegativeNumber(
      source.bidParticipationReviewPendingCount,
      'businessTodoSummary.bidParticipationReviewPendingCount'
    ),
    publisherMaterialReviewPendingCount: readNonNegativeNumber(
      source.publisherMaterialReviewPendingCount,
      'businessTodoSummary.publisherMaterialReviewPendingCount'
    ),
    bidMaterialReviewPendingCount: readNonNegativeNumber(
      source.bidMaterialReviewPendingCount,
      'businessTodoSummary.bidMaterialReviewPendingCount'
    ),
    dealConfirmationPendingCount: readNonNegativeNumber(
      source.dealConfirmationPendingCount,
      'businessTodoSummary.dealConfirmationPendingCount'
    )
  };
  return {
    ...summary,
    totalPendingCount: readNonNegativeNumber(source.totalPendingCount, 'businessTodoSummary.totalPendingCount')
  };
}

function readChatAvailability(value: unknown) {
  const source = requireRecord(value, 'Project communication chatAvailability is invalid.');
  const lockReasonCode =
    source.lockReasonCode === null
      ? null
      : readEnum(source.lockReasonCode, 'chatAvailability.lockReasonCode', CHAT_LOCK_REASON_CODES);
  return {
    canSendMessage: readBoolean(source.canSendMessage, 'chatAvailability.canSendMessage'),
    lockReasonCode,
    lockReasonText: readNullableString(source.lockReasonText),
    requiredNextAction: readEnum(
      source.requiredNextAction,
      'chatAvailability.requiredNextAction',
      CHAT_REQUIRED_NEXT_ACTIONS
    )
  };
}

function readSourceFiles(value: unknown) {
  if (value === undefined || value === null) {
    return [];
  }
  return readArray(value, 'entry.sourceFiles').map((item) => {
    const source = requireRecord(item, 'Project communication workbench source file is invalid.');
    return {
      fileAssetId: readString(source.fileAssetId, 'entry.sourceFiles.fileAssetId'),
      fileName: readString(source.fileName, 'entry.sourceFiles.fileName'),
      mimeType: readString(source.mimeType, 'entry.sourceFiles.mimeType'),
      sortOrder: readNonNegativeNumber(source.sortOrder, 'entry.sourceFiles.sortOrder')
    };
  });
}

function requireRecord(value: unknown, message: string) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw new Error(message);
  }
  return value as Payload;
}

function readRecord(value: unknown, field: string) {
  if (!value || Array.isArray(value) || typeof value !== 'object') {
    throw new Error(`Field \`${field}\` must be an object.`);
  }
  return value as Payload;
}

function readArray(value: unknown, field: string) {
  if (!Array.isArray(value)) {
    throw new Error(`Field \`${field}\` must be an array.`);
  }
  return value;
}

function readString(value: unknown, field: string) {
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`Field \`${field}\` is required in project communication workbench response.`);
  }
  return value.trim();
}

function readEnum(value: unknown, field: string, allowed: Set<string>) {
  const normalized = readString(value, field);
  if (!allowed.has(normalized)) {
    throw new Error(`Field \`${field}\` is unsupported in project communication workbench response.`);
  }
  return normalized;
}

function readNonNegativeNumber(value: unknown, field: string) {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < 0) {
    throw new Error(`Field \`${field}\` must be a non-negative number.`);
  }
  return value;
}

function readBoolean(value: unknown, field: string) {
  if (typeof value !== 'boolean') {
    throw new Error(`Field \`${field}\` must be a boolean.`);
  }
  return value;
}

function readNullableString(value: unknown) {
  if (value === undefined || value === null) {
    return null;
  }
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

function readNullableRecord(value: unknown) {
  if (value === undefined || value === null) {
    return null;
  }
  return readRecord(value, 'entry.routeTarget');
}
