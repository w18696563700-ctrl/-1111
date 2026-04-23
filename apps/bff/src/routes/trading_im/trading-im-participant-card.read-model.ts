type TradingImPayload = Record<string, unknown>;

export function readParticipantCardReadModel(value: unknown) {
  const body = requireRecord(value, 'Participant-card response must be an object.');
  return {
    projectId: readRequiredString(body.projectId, 'projectId'),
    bidId: readRequiredString(body.bidId, 'bidId'),
    participantOrganizationId: readRequiredString(
      body.participantOrganizationId,
      'participantOrganizationId',
    ),
    participantRole: readEnum(body.participantRole, ['project_owner', 'bidder'], 'participantRole'),
    enterpriseSummary: readEnterpriseSummary(body.enterpriseSummary),
    reviewSummary: readReviewSummary(body.reviewSummary),
    formalInfoSummary: readFormalInfoSummary(body.formalInfoSummary),
  };
}

function readEnterpriseSummary(value: unknown) {
  const body = requireRecord(value, 'Participant-card enterpriseSummary must be an object.');
  return {
    enterpriseId: readRequiredString(body.enterpriseId, 'enterpriseSummary.enterpriseId'),
    displayName: readRequiredString(body.displayName, 'enterpriseSummary.displayName'),
    logoUrl: readOptionalString(body.logoUrl),
    primaryBoardType: readRequiredString(
      body.primaryBoardType,
      'enterpriseSummary.primaryBoardType',
    ),
    provinceName: readRequiredString(body.provinceName, 'enterpriseSummary.provinceName'),
    cityName: readRequiredString(body.cityName, 'enterpriseSummary.cityName'),
    verificationStatus: readRequiredString(
      body.verificationStatus,
      'enterpriseSummary.verificationStatus',
    ),
  };
}

function readReviewSummary(value: unknown) {
  const body = requireRecord(value, 'Participant-card reviewSummary must be an object.');
  return {
    avgScore: readOptionalNumber(body.avgScore),
    reviewCount: readRequiredNumber(body.reviewCount, 'reviewSummary.reviewCount'),
    keywordTags: readStringArray(body.keywordTags),
  };
}

function readFormalInfoSummary(value: unknown) {
  const body = requireRecord(value, 'Participant-card formalInfoSummary must be an object.');
  return {
    legalName: readRequiredString(body.legalName, 'formalInfoSummary.legalName'),
    businessType: readOptionalString(body.businessType),
    registeredCapital: readOptionalString(body.registeredCapital),
    establishedAt: readOptionalString(body.establishedAt),
    businessScope: readOptionalString(body.businessScope),
    certificationStatus: readRequiredString(
      body.certificationStatus,
      'formalInfoSummary.certificationStatus',
    ),
  };
}

function requireRecord(value: unknown, message: string) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as TradingImPayload;
  }
  throw new Error(message);
}

function readRequiredString(value: unknown, field: string) {
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error(`Field \`${field}\` is outside frozen contract.`);
  }
  return value.trim();
}

function readOptionalString(value: unknown) {
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized ? normalized : null;
}

function readRequiredNumber(value: unknown, field: string) {
  const normalized = readOptionalNumber(value);
  if (normalized === null) {
    throw new Error(`Field \`${field}\` is outside frozen contract.`);
  }
  return normalized;
}

function readOptionalNumber(value: unknown) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === 'string' && value.trim()) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function readStringArray(value: unknown) {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.flatMap((item) => {
    if (typeof item !== 'string') {
      return [];
    }
    const normalized = item.trim();
    return normalized ? [normalized] : [];
  });
}

function readEnum(value: unknown, admitted: string[], field: string) {
  const normalized = readRequiredString(value, field);
  if (!admitted.includes(normalized)) {
    throw new Error(`Field \`${field}\` is outside frozen contract.`);
  }
  return normalized;
}
