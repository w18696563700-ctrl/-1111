type EnterpriseHubBoardType = 'company' | 'factory' | 'supplier';

export function toEnterpriseHubWorkbenchResponse(payload: Record<string, unknown>) {
  return {
    organizationId: readString(payload.organizationId),
    enterpriseId: readNullableString(payload.enterpriseId),
    boardType: readNullableBoardType(payload.boardType),
    latestApplication: toLatestApplication(payload.latestApplication),
    basic: toBasic(payload.basic),
    boardProfile: asRecord(payload.boardProfile),
    primaryContact: toPrimaryContact(payload.primaryContact),
    cases: toCases(payload.cases),
    certification: toCertification(payload.certification),
    readiness: toReadiness(payload.readiness),
  };
}

function toLatestApplication(value: unknown) {
  const record = asRecord(value);
  if (!record) {
    return null;
  }
  return {
    applicationId: readString(record.applicationId, record.id),
    applicationStatus: readString(record.applicationStatus),
    submittedAt: readNullableString(record.submittedAt),
    reviewedAt: readNullableString(record.reviewedAt),
    rejectionReason: readNullableString(record.rejectionReason),
    reviewNote: readNullableString(record.reviewNote),
  };
}

function toBasic(value: unknown) {
  const record = asRecord(value);
  if (!record) {
    return null;
  }
  return {
    name: readNullableString(record.name),
    logoFileAssetId: readNullableString(record.logoFileAssetId),
    logoUrl: readNullableString(record.logoUrl),
    albumImageFileAssetIds: readStringArray(record.albumImageFileAssetIds),
    albumImageUrlMap: readStringMap(record.albumImageUrlMap),
    shortIntro: readNullableString(record.shortIntro),
    fullIntro: readNullableString(record.fullIntro),
    provinceCode: readNullableString(record.provinceCode),
    provinceName: readNullableString(record.provinceName),
    cityCode: readNullableString(record.cityCode),
    cityName: readNullableString(record.cityName),
    address: readNullableString(record.address),
    location: toLocation(record.location),
    foundedAt: readNullableString(record.foundedAt),
    teamSizeRange: readNullableString(record.teamSizeRange),
    cooperationModes: readStringArray(record.cooperationModes),
    contactVisible: readBoolean(record.contactVisible, false),
  };
}

function toLocation(value: unknown) {
  const record = asRecord(value);
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
    geoSource: readNullableString(record.geoSource),
    geoStatus: readNullableString(record.geoStatus) ?? 'not_provided',
    lastGeocodedAt: readNullableString(record.lastGeocodedAt),
    mapProvider: readNullableString(record.mapProvider),
    mapPreviewUrl: readNullableString(record.mapPreviewUrl),
    mapLinkUrl: readNullableString(record.mapLinkUrl),
  };
}

function toPrimaryContact(value: unknown) {
  const record = asRecord(value);
  if (!record) {
    return null;
  }
  return {
    contactName: readString(record.contactName),
    mobile: readNullableString(record.mobile),
    wechat: readNullableString(record.wechat),
    phone: readNullableString(record.phone),
    email: readNullableString(record.email),
    position: readNullableString(record.position),
    isPrimary: readBoolean(record.isPrimary, false),
    visibleToPublic: readBoolean(record.visibleToPublic, false),
  };
}

function toCases(value: unknown) {
  return readArray(value)
    .map((item) => asRecord(item))
    .filter((item): item is Record<string, unknown> => item !== null)
    .map((record) => ({
      caseId: readString(record.caseId, record.id),
      boardType: readBoardType(record.boardType) ?? 'company',
      title: readString(record.title),
      exhibitionType: readNullableString(record.exhibitionType),
      city: readNullableString(record.city),
      eventTime: readNullableString(record.eventTime),
      summary: readString(record.summary),
      caseCoverFileAssetId: readString(record.caseCoverFileAssetId),
      caseMediaFileAssetIds: readStringArray(record.caseMediaFileAssetIds),
      caseImageUrlMap: readStringMap(record.caseImageUrlMap),
      isFeatured: readBoolean(record.isFeatured, false),
      caseStatus: readString(record.caseStatus),
    }));
}

function toCertification(value: unknown) {
  const record = asRecord(value);
  if (!record) {
    return null;
  }
  return {
    certificationStatus: readString(record.certificationStatus),
    legalName: readNullableString(record.legalName),
    uscc: readNullableString(record.uscc),
    licenseFileId: readNullableString(record.licenseFileId),
    submittedAt: readNullableString(record.submittedAt),
    reviewedAt: readNullableString(record.reviewedAt),
    rejectReason: readNullableString(record.rejectReason),
  };
}

function toReadiness(value: unknown) {
  const record = asRecord(value) ?? {};
  return {
    hasApplication: readBoolean(record.hasApplication, false),
    draftEditable: readBoolean(record.draftEditable, false),
    basicCompleted: readBoolean(record.basicCompleted, false),
    profileCompleted: readBoolean(record.profileCompleted, false),
    hasCase: readBoolean(record.hasCase, false),
    hasContact: readBoolean(record.hasContact, false),
    certificationApproved: readBoolean(record.certificationApproved, false),
    submitReady: readBoolean(record.submitReady, false),
    blockers: readStringArray(record.blockers),
  };
}

function asRecord(value: unknown) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return null;
  }
  return value as Record<string, unknown>;
}

function readArray(value: unknown) {
  return Array.isArray(value) ? value : [];
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
  }
  throw new Error('Workbench response is missing required string field.');
}

function readNullableString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
  }
  return null;
}

function readBoolean(value: unknown, fallback: boolean) {
  return typeof value === 'boolean' ? value : fallback;
}

function readNullableNumber(value: unknown) {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

function readStringArray(value: unknown) {
  return readArray(value)
    .filter((item): item is string => typeof item === 'string')
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
}

function readStringMap(value: unknown) {
  const record = asRecord(value);
  if (!record) {
    return {};
  }
  return Object.fromEntries(
    Object.entries(record)
      .map(([key, rawValue]) => [key.trim(), readNullableString(rawValue)] as const)
      .filter(([key, rawValue]) => key.length > 0 && typeof rawValue === 'string'),
  );
}

function readNullableBoardType(value: unknown): EnterpriseHubBoardType | null {
  return readBoardType(value);
}

function readBoardType(value: unknown): EnterpriseHubBoardType | null {
  if (value === 'company' || value === 'factory' || value === 'supplier') {
    return value;
  }
  return null;
}
