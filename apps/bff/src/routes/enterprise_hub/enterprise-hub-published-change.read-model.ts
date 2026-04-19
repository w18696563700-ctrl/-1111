type EnterpriseHubBoardType = 'company' | 'factory' | 'supplier';

type ChangeStatus =
  | 'draft'
  | 'submitted'
  | 'under_review'
  | 'revision_required'
  | 'approved'
  | 'rejected'
  | 'applied';

const BOARD_TYPES = new Set<EnterpriseHubBoardType>([
  'company',
  'factory',
  'supplier',
]);

const CHANGE_STATUSES = new Set<ChangeStatus>([
  'draft',
  'submitted',
  'under_review',
  'revision_required',
  'approved',
  'rejected',
  'applied',
]);

export function toEnterpriseHubPublishedChangeWorkbenchResponse(
  payload: Record<string, unknown>,
) {
  return {
    enterpriseId: readString(payload.enterpriseId),
    boardType: readBoardType(payload.boardType),
    liveSnapshot: toLiveSnapshot(payload.liveSnapshot),
    currentChangeRequest: toCurrentChangeRequest(payload.currentChangeRequest),
    basic: toBasic(payload.basic),
    boardProfile: readRecord(payload.boardProfile, 'boardProfile must be an object.'),
    primaryContact: readNullableRecord(payload.primaryContact),
    cases: readCases(payload.cases),
    changeReadiness: toChangeReadiness(payload.changeReadiness),
  };
}

function toBasic(value: unknown) {
  const record = readRecord(value, 'basic must be an object.');
  return {
    ...record,
    logoUrl: readNullableString(record.logoUrl),
    albumImageUrlMap: readStringMap(record.albumImageUrlMap),
    location: toLocation(record.location),
  };
}

function toLocation(value: unknown) {
  const record = readNullableRecord(value);
  if (!record) {
    return null;
  }
  return {
    addressText: readNullableString(record.addressText, record.address),
    publicDisplayAddress: readNullableString(record.publicDisplayAddress),
    provinceCode: readNullableString(record.provinceCode),
    provinceName: readNullableString(record.provinceName),
    cityCode: readNullableString(record.cityCode),
    cityName: readNullableString(record.cityName),
    districtCode: readNullableString(record.districtCode),
    districtName: readNullableString(record.districtName),
    latitude: readNullableNumber(record.latitude),
    longitude: readNullableNumber(record.longitude),
    geoSource: readNullableString(record.geoSource) ?? 'unknown',
    geoStatus: readNullableString(record.geoStatus) ?? 'not_provided',
    lastGeocodedAt: readNullableString(record.lastGeocodedAt),
    mapProvider: readNullableString(record.mapProvider),
    mapPreviewUrl: readNullableString(record.mapPreviewUrl),
    mapLinkUrl: readNullableString(record.mapLinkUrl),
  };
}

export function toEnterpriseHubPublishedChangeStatusResponse(
  payload: Record<string, unknown>,
) {
  return {
    enterpriseId: readString(payload.enterpriseId),
    changeRequestId: readString(payload.changeRequestId),
    changeStatus: readChangeStatus(payload.changeStatus),
    submittedAt: readNullableString(payload.submittedAt),
    reviewedAt: readNullableString(payload.reviewedAt),
    rejectionReason: readNullableString(payload.rejectionReason),
  };
}

export function toEnterpriseHubPublishedChangeCaseCreateResponse(
  payload: Record<string, unknown>,
) {
  return {
    caseId: readString(payload.caseId, payload.id),
    caseStatus: readNullableString(payload.caseStatus) ?? 'draft',
  };
}

export function toEnterpriseHubPublishedChangeCaseUpdateResponse(
  payload: Record<string, unknown>,
) {
  return {
    caseId: readString(payload.caseId, payload.id),
    caseStatus: readNullableString(payload.caseStatus) ?? 'draft',
  };
}

function toLiveSnapshot(value: unknown) {
  const record = readRecord(value, 'liveSnapshot must be an object.');
  return {
    enterpriseStatus: readString(record.enterpriseStatus),
    displayStatus: readString(record.displayStatus),
    publishedAt: readNullableString(record.publishedAt),
  };
}

function toCurrentChangeRequest(value: unknown) {
  const record = readNullableRecord(value);
  if (!record) {
    return null;
  }
  return {
    changeRequestId: readString(record.changeRequestId),
    changeStatus: readChangeStatus(record.changeStatus),
    submittedAt: readNullableString(record.submittedAt),
    reviewedAt: readNullableString(record.reviewedAt),
    rejectionReason: readNullableString(record.rejectionReason),
  };
}

function toChangeReadiness(value: unknown) {
  const record = readRecord(value, 'changeReadiness must be an object.');
  return {
    draftEditable: readBoolean(record.draftEditable, false),
    submitReady: readBoolean(record.submitReady, false),
    blockers: readStringArray(record.blockers),
  };
}

function readCases(value: unknown) {
  if (!Array.isArray(value)) {
    throw new Error('cases must be an array.');
  }
  return value.map((item) => {
    const record = readRecord(item, 'case item must be an object.');
    return {
      caseId: readString(record.caseId, record.id),
      boardType: readBoardType(record.boardType),
      title: readString(record.title),
      exhibitionType: readNullableString(record.exhibitionType),
      city: readNullableString(record.city),
      eventTime: readNullableString(record.eventTime),
      summary: readString(record.summary),
      caseCoverFileAssetId: readNullableString(
        record.caseCoverFileAssetId,
        record.coverFileAssetId,
      ),
      caseMediaFileAssetIds: readStringArray(record.caseMediaFileAssetIds),
      caseImageUrlMap: readStringMap(record.caseImageUrlMap),
      isFeatured: readBoolean(record.isFeatured, false),
      caseStatus: readString(record.caseStatus),
    };
  });
}

function readRecord(value: unknown, message: string): Record<string, unknown> {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  throw new Error(message);
}

function readNullableRecord(value: unknown): Record<string, unknown> | null {
  return value !== null && typeof value === 'object' && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : null;
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
  }
  throw new Error('published change response is missing required string field.');
}

function readNullableString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    if (value === null) {
      return null;
    }
  }
  return null;
}

function readStringArray(value: unknown) {
  if (!Array.isArray(value)) {
    return [] as string[];
  }
  return value
    .filter((item): item is string => typeof item === 'string')
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
}

function readStringMap(value: unknown) {
  const record = readNullableRecord(value);
  if (!record) {
    return {};
  }
  return Object.fromEntries(
    Object.entries(record)
      .map(([key, rawValue]) => [key.trim(), readNullableString(rawValue)] as const)
      .filter(([key, rawValue]) => key.length > 0 && typeof rawValue === 'string'),
  );
}

function readBoolean(value: unknown, fallback: boolean) {
  return typeof value === 'boolean' ? value : fallback;
}

function readNullableNumber(value: unknown) {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

function readBoardType(value: unknown): EnterpriseHubBoardType {
  if (typeof value === 'string' && BOARD_TYPES.has(value as EnterpriseHubBoardType)) {
    return value as EnterpriseHubBoardType;
  }
  throw new Error('published change boardType is invalid.');
}

function readChangeStatus(value: unknown): ChangeStatus {
  if (typeof value === 'string' && CHANGE_STATUSES.has(value as ChangeStatus)) {
    return value as ChangeStatus;
  }
  throw new Error('published change status is invalid.');
}
