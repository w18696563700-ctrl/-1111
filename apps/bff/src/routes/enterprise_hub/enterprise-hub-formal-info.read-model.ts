export function toEnterpriseHubTargetEnterpriseFormalInfoResponse(
  payload: Record<string, unknown>,
  enterpriseIdFallback?: string,
) {
  return {
    enterpriseId: readString(payload.enterpriseId, enterpriseIdFallback),
    legalName: readNullableString(payload.legalName),
    uscc: readNullableString(payload.uscc),
    legalPerson: readNullableString(payload.legalPerson),
    businessType: readNullableString(payload.businessType),
    address: readNullableString(payload.address),
    registeredCapital: readNullableString(payload.registeredCapital),
    establishedAt: readNullableString(payload.establishedAt),
    businessTerm: readNullableString(payload.businessTerm),
    businessScope: readNullableString(payload.businessScope),
    certificationStatus: readNullableString(payload.certificationStatus),
  };
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim().length > 0) {
      return value.trim();
    }
  }
  return "";
}

function readNullableString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string") {
      const normalized = value.trim();
      return normalized.length > 0 ? normalized : null;
    }
    if (value === null) {
      return null;
    }
  }
  return null;
}
