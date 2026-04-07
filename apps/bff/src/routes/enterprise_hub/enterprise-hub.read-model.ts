const BOARD_LABELS = {
  company: '优秀公司',
  factory: '优秀工厂',
  supplier: '优秀供应商',
} as const;

type EnterpriseHubBoardType = keyof typeof BOARD_LABELS;

type ListResponseOptions = {
  boardType: EnterpriseHubBoardType;
};

type DetailResponseOptions = {
  boardType: EnterpriseHubBoardType;
};

type RecommendationResponseOptions = {
  boardType: EnterpriseHubBoardType;
};

export function toEnterpriseHubListResponse(
  payload: Record<string, unknown>,
  options: ListResponseOptions,
) {
  return {
    recommended: toListItems(readArray(payload.recommended), options.boardType),
    items: toListItems(readArray(payload.items), options.boardType),
    pagination: toPagination(payload.pagination, payload),
  };
}

export function toEnterpriseHubDetailResponse(
  payload: Record<string, unknown>,
  options: DetailResponseOptions,
) {
  const headerSource = asRecord(payload.header) ?? payload;
  const basicInfoSource = asRecord(payload.basicInfo) ?? payload;
  const boardType =
    readBoardType(headerSource.primaryBoardType, payload.primaryBoardType) ??
    options.boardType;

  return {
    header: {
      enterpriseId: readString(headerSource.enterpriseId, payload.enterpriseId, payload.id),
      name: readString(headerSource.name, payload.name),
      logoUrl: readDisplayUrl(headerSource, payload, 'logoUrl', 'logoPreviewUrl', 'logo'),
      primaryBoardType: boardType,
      secondaryCapabilities: readBoardTypes(
        headerSource.secondaryCapabilities,
        payload.secondaryCapabilities,
      ),
      shortIntro: readString(headerSource.shortIntro, payload.shortIntro),
      provinceName: readString(headerSource.provinceName, payload.provinceName),
      cityName: readString(headerSource.cityName, payload.cityName),
      verificationStatus: readNullableString(
        headerSource.verificationStatus,
        payload.verificationStatusSnapshot,
        payload.verificationStatus,
      ),
    },
    basicInfo: {
      legalName: readNullableString(basicInfoSource.legalName, payload.legalNameSnapshot),
      foundedAt: readNullableString(basicInfoSource.foundedAt, payload.foundedAt),
      teamSizeRange: readNullableString(basicInfoSource.teamSizeRange, payload.teamSizeRange),
      fullIntro: readNullableString(basicInfoSource.fullIntro, payload.fullIntro),
      address: readNullableString(basicInfoSource.address, payload.address),
    },
    boardProfile: toBoardProfile(payload, boardType),
    serviceAreas: toServiceAreas(payload.serviceAreas),
    cases: toCaseCards(payload.cases),
    certifications: toCertificationCards(payload.certifications),
    reviewSummary: toReviewSummary(payload.reviewSummary),
    contacts: toContactCards(payload.contacts),
  };
}

export function toEnterpriseHubRecommendationListResponse(
  payload: Record<string, unknown>,
  options: RecommendationResponseOptions,
) {
  return {
    boardType: options.boardType,
    items: toListItems(readArray(payload.items), options.boardType),
  };
}

export function toEnterpriseHubCreateApplicationResponse(
  payload: Record<string, unknown>,
) {
  return {
    applicationId: readString(payload.applicationId, payload.id),
    enterpriseId: readString(payload.enterpriseId),
    applicationStatus: readApplicationStatus(payload.applicationStatus),
  };
}

export function toEnterpriseHubCaseCreateResponse(
  payload: Record<string, unknown>,
) {
  return {
    caseId: readString(payload.caseId, payload.id),
    caseStatus: readNullableString(payload.caseStatus) ?? 'draft',
  };
}

export function toActionAckResponse(
  payload: Record<string, unknown>,
  traceId: string,
) {
  return {
    ok: readBoolean(payload.ok, true),
    traceId: readString(payload.traceId, traceId),
  };
}

export function toEnterpriseHubApplicationStatusResponse(
  payload: Record<string, unknown>,
) {
  return {
    applicationId: readString(payload.applicationId, payload.id),
    enterpriseId: readString(payload.enterpriseId),
    applyBoardType: readBoardType(payload.applyBoardType) ?? 'company',
    applicationStatus: readApplicationStatus(payload.applicationStatus),
    rejectionReason: readNullableString(payload.rejectionReason),
    submittedAt: readNullableString(payload.submittedAt),
    reviewedAt: readNullableString(payload.reviewedAt),
  };
}

function toListItems(values: unknown[], boardType: EnterpriseHubBoardType) {
  return values.map((value) => toListItem(asRecord(value), boardType)).filter((value) => value !== null);
}

function toListItem(
  record: Record<string, unknown> | null,
  fallbackBoardType: EnterpriseHubBoardType,
) {
  if (!record) {
    return null;
  }

  const boardType =
    readBoardType(record.boardType, record.primaryBoardType) ?? fallbackBoardType;
  const secondaryLabels = readStringArray(record.secondaryCapabilityLabels);
  const capabilityLabels =
    secondaryLabels.length > 0
      ? secondaryLabels
      : readBoardTypes(record.secondaryCapabilities)
          .filter((value) => value !== boardType)
          .map((value) => BOARD_LABELS[value]);

  return {
    enterpriseId: readString(record.enterpriseId, record.id),
    boardType,
    name: readString(record.name),
    logoUrl: readDisplayUrl(record, undefined, 'logoUrl', 'logoPreviewUrl', 'logo'),
    provinceName: readString(record.provinceName),
    cityName: readString(record.cityName),
    primaryBoardLabel:
      readNullableString(record.primaryBoardLabel) ?? BOARD_LABELS[boardType],
    secondaryCapabilityLabels: capabilityLabels,
    shortIntro: readString(record.shortIntro),
    certificationLabel: toCertificationLabel(record),
    caseCount: readNumber(record.caseCount, readArray(record.cases).length),
    avgScore: readNullableNumber(
      record.avgScore,
      asRecord(record.reviewSummary)?.avgScore,
    ),
    keywordTags: readStringArray(
      record.keywordTags,
      asRecord(record.reviewSummary)?.keywordTags,
    ),
    boardHighlights: toBoardHighlights(record, boardType),
  };
}

function toPagination(value: unknown, fallback: Record<string, unknown>) {
  const record = asRecord(value) ?? {};
  const page = readNumber(record.page, fallback.page, 1);
  const pageSize = readNumber(record.pageSize, fallback.pageSize, 20);
  const total = readNumber(record.total, fallback.total, 0);
  const hasMore = readBoolean(record.hasMore, page * pageSize < total);

  return {
    page,
    pageSize,
    total,
    hasMore,
  };
}

function toBoardProfile(
  payload: Record<string, unknown>,
  boardType: EnterpriseHubBoardType,
) {
  const explicitBoardProfile = asRecord(payload.boardProfile);
  if (explicitBoardProfile) {
    return stripUndefined(explicitBoardProfile);
  }

  if (boardType === 'company') {
    const companyProfile = asRecord(payload.companyProfile) ?? {};
    return stripUndefined({
      exhibitionTypes: readStringArray(
        payload.exhibitionTypes,
        companyProfile.exhibitionTypes,
      ),
      serviceItems: readStringArray(payload.serviceItems, companyProfile.serviceItems),
      serviceCities: readStringArray(payload.serviceCities, companyProfile.serviceCities),
      teamSize: readNullableNumber(payload.teamSize, companyProfile.teamSize),
      maxProjectScale: readNullableString(
        payload.maxProjectScale,
        companyProfile.maxProjectScale,
      ),
      averageDeliveryCycleDays: readNullableNumber(
        payload.averageDeliveryCycleDays,
        companyProfile.averageDeliveryCycleDays,
      ),
      knownClients: readStringArray(payload.knownClients, companyProfile.knownClients),
      qualificationDesc: readNullableString(
        payload.qualificationDesc,
        companyProfile.qualificationDesc,
      ),
      projectManagementCapability: readNullableString(
        payload.projectManagementCapability,
        companyProfile.projectManagementCapability,
      ),
      onsiteExecutionCapability: readNullableString(
        payload.onsiteExecutionCapability,
        companyProfile.onsiteExecutionCapability,
      ),
    });
  }

  if (boardType === 'factory') {
    const factoryProfile = asRecord(payload.factoryProfile) ?? {};
    return stripUndefined({
      processTypes: readStringArray(payload.processTypes, factoryProfile.processTypes),
      coreProducts: readStringArray(payload.coreProducts, factoryProfile.coreProducts),
      equipmentList: readStringArray(payload.equipmentList, factoryProfile.equipmentList),
      plantAreaSqm: readNullableNumber(payload.plantAreaSqm, factoryProfile.plantAreaSqm),
      monthlyCapacityDesc: readNullableString(
        payload.monthlyCapacityDesc,
        factoryProfile.monthlyCapacityDesc,
      ),
      urgentOrderCapability: readNullableString(
        payload.urgentOrderCapability,
        factoryProfile.urgentOrderCapability,
      ),
      urgentCycleDesc: readNullableString(
        payload.urgentCycleDesc,
        factoryProfile.urgentCycleDesc,
      ),
      warehouseCapability: readNullableBoolean(
        payload.warehouseCapability,
        factoryProfile.warehouseCapability,
      ),
      transportCapability: readNullableString(
        payload.transportCapability,
        factoryProfile.transportCapability,
      ),
      maxOrderCapacityDesc: readNullableString(
        payload.maxOrderCapacityDesc,
        factoryProfile.maxOrderCapacityDesc,
      ),
      productionQualificationDesc: readNullableString(
        payload.productionQualificationDesc,
        factoryProfile.productionQualificationDesc,
      ),
      deliveryRadiusDesc: readNullableString(
        payload.deliveryRadiusDesc,
        factoryProfile.deliveryRadiusDesc,
      ),
    });
  }

  const supplierProfile = asRecord(payload.supplierProfile) ?? {};
  return stripUndefined({
    supplyCategories: readStringArray(
      payload.supplyCategories,
      supplierProfile.supplyCategories,
    ),
    supplyMode: readStringArray(payload.supplyMode, supplierProfile.supplyMode),
    coreProductsOrServices: readStringArray(
      payload.coreProductsOrServices,
      supplierProfile.coreProductsOrServices,
    ),
    responseSlaDesc: readNullableString(
      payload.responseSlaDesc,
      supplierProfile.responseSlaDesc,
    ),
    stockStatusDesc: readNullableString(
      payload.stockStatusDesc,
      supplierProfile.stockStatusDesc,
    ),
    deliveryRange: readNullableString(
      payload.deliveryRange,
      supplierProfile.deliveryRange,
    ),
    aftersalesPolicy: readNullableString(
      payload.aftersalesPolicy,
      supplierProfile.aftersalesPolicy,
    ),
    partnerCasesDesc: readNullableString(
      payload.partnerCasesDesc,
      supplierProfile.partnerCasesDesc,
    ),
    supplyQualificationDesc: readNullableString(
      payload.supplyQualificationDesc,
      supplierProfile.supplyQualificationDesc,
    ),
  });
}

function toServiceAreas(value: unknown) {
  return readArray(value)
    .map((item) => asRecord(item))
    .filter((item): item is Record<string, unknown> => item !== null)
    .map((item) => ({
      areaType: readNullableString(item.areaType),
      provinceName: readString(item.provinceName),
      cityName: readNullableString(item.cityName),
    }));
}

function toCaseCards(value: unknown) {
  return readArray(value)
    .map((item) => asRecord(item))
    .filter((item): item is Record<string, unknown> => item !== null)
    .map((item) => ({
      id: readString(item.id, item.caseId),
      title: readString(item.title),
      summary: readString(item.summary),
      coverImageUrl: readDisplayUrl(
        item,
        undefined,
        'coverImageUrl',
        'caseCoverUrl',
        'coverUrl',
      ),
      eventTime: readNullableString(item.eventTime),
      caseStatus: readNullableString(item.caseStatus) ?? 'draft',
    }));
}

function toCertificationCards(value: unknown) {
  return readArray(value)
    .map((item) => asRecord(item))
    .filter((item): item is Record<string, unknown> => item !== null)
    .map((item) => ({
      type: readString(item.type, item.certificationType),
      name: readString(item.name, item.certificationName),
      status: readNullableString(item.status, item.certStatus) ?? 'pending',
    }));
}

function toReviewSummary(value: unknown) {
  const record = asRecord(value) ?? {};
  return {
    avgScore: readNullableNumber(record.avgScore),
    reviewCount: readNullableNumber(record.reviewCount),
    keywordTags: readStringArray(record.keywordTags),
    deliveryScore: readNullableNumber(record.deliveryScore),
    qualityScore: readNullableNumber(record.qualityScore),
    communicationScore: readNullableNumber(record.communicationScore),
  };
}

function toContactCards(value: unknown) {
  return readArray(value)
    .map((item) => asRecord(item))
    .filter((item): item is Record<string, unknown> => item !== null)
    .map((item) => ({
      contactName: readString(item.contactName),
      mobile: readNullableString(item.mobile),
      wechat: readNullableString(item.wechat),
      phone: readNullableString(item.phone),
      email: readNullableString(item.email),
      position: readNullableString(item.position),
    }));
}

function toCertificationLabel(record: Record<string, unknown>) {
  const explicit = readNullableString(record.certificationLabel);
  if (explicit !== null) {
    return explicit;
  }

  const verificationStatus = readNullableString(
    record.verificationStatus,
    record.verificationStatusSnapshot,
  );
  if (verificationStatus === 'verified') {
    return '已认证';
  }
  if (verificationStatus === 'pending') {
    return '认证中';
  }
  if (verificationStatus === 'failed') {
    return '认证未通过';
  }
  return '未认证';
}

function toBoardHighlights(
  record: Record<string, unknown>,
  boardType: EnterpriseHubBoardType,
) {
  const explicit = asRecord(record.boardHighlights);
  if (explicit) {
    return {
      company: explicit.company ?? null,
      factory: explicit.factory ?? null,
      supplier: explicit.supplier ?? null,
    };
  }

  return {
    company:
      boardType === 'company'
        ? {
            exhibitionTypes: readStringArray(record.exhibitionTypes),
            serviceCities: readStringArray(record.serviceCities),
          }
        : null,
    factory:
      boardType === 'factory'
        ? {
            processTypes: readStringArray(record.processTypes),
            deliveryRadiusDesc: readNullableString(record.deliveryRadiusDesc),
          }
        : null,
    supplier:
      boardType === 'supplier'
        ? {
            supplyCategories: readStringArray(record.supplyCategories),
            responseSlaDesc: readNullableString(record.responseSlaDesc),
          }
        : null,
  };
}

function stripUndefined(record: Record<string, unknown>) {
  return Object.fromEntries(
    Object.entries(record).filter(([, value]) => value !== undefined),
  );
}

function readApplicationStatus(value: unknown) {
  return readNullableString(value) ?? 'draft';
}

function readBoardTypes(...values: unknown[]) {
  for (const value of values) {
    const items = readArray(value)
      .map((item) => readBoardType(item))
      .filter((item): item is EnterpriseHubBoardType => item !== null);
    if (items.length > 0) {
      return items;
    }
  }
  return [] as EnterpriseHubBoardType[];
}

function readBoardType(...values: unknown[]) {
  for (const value of values) {
    if (value === 'company' || value === 'factory' || value === 'supplier') {
      return value;
    }
  }
  return null;
}

function readDisplayUrl(
  primary: Record<string, unknown> | undefined,
  secondary: Record<string, unknown> | undefined,
  ...keys: string[]
) {
  for (const key of keys) {
    const primaryValue = primary?.[key];
    if (typeof primaryValue === 'string') {
      return primaryValue;
    }
    if (primaryValue === null) {
      return null;
    }

    const secondaryValue = secondary?.[key];
    if (typeof secondaryValue === 'string') {
      return secondaryValue;
    }
    if (secondaryValue === null) {
      return null;
    }
  }
  return null;
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'string') {
      return value;
    }
  }
  return '';
}

function readNullableString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'string') {
      return value;
    }
    if (value === null) {
      return null;
    }
  }
  return null;
}

function readStringArray(...values: unknown[]) {
  for (const value of values) {
    if (!Array.isArray(value)) {
      continue;
    }

    const items = value.filter((item): item is string => typeof item === 'string');
    if (items.length > 0) {
      return items;
    }

    if (value.length === 0) {
      return [] as string[];
    }
  }
  return [] as string[];
}

function readNumber(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value;
    }
  }
  return 0;
}

function readNullableNumber(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value;
    }
    if (value === null) {
      return null;
    }
  }
  return null;
}

function readBoolean(value: unknown, fallback: boolean) {
  return typeof value === 'boolean' ? value : fallback;
}

function readNullableBoolean(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === 'boolean') {
      return value;
    }
    if (value === null) {
      return null;
    }
  }
  return undefined;
}

function readArray(value: unknown) {
  return Array.isArray(value) ? value : [];
}

function asRecord(value: unknown): Record<string, unknown> | null {
  return value !== null && typeof value === 'object'
    ? (value as Record<string, unknown>)
    : null;
}
