import {
  ENTERPRISE_HUB_CITY_TRUTH_BY_CODE,
  ENTERPRISE_HUB_PROVINCE_NAME_BY_CODE,
  ENTERPRISE_HUB_REGION_LOOKUP_SOURCE_VERSION,
} from './enterprise-hub-region-lookup.generated';

export type EnterpriseHubRegionDisplayFields = {
  provinceCode: string | null;
  provinceName: string | null;
  cityCode: string | null;
  cityName: string | null;
};

export type EnterpriseHubRegionDisplayTruth =
  EnterpriseHubRegionDisplayFields & {
    provinceLookupHit: boolean;
    cityLookupHit: boolean;
    sourceVersion: string;
  };

export function resolveEnterpriseHubRegionDisplayTruth(
  input: EnterpriseHubRegionDisplayFields,
): EnterpriseHubRegionDisplayTruth {
  const provinceCode = normalizeText(input.provinceCode);
  const cityCode = normalizeText(input.cityCode);
  const provinceHint = normalizeText(input.provinceName);
  const cityHint = normalizeText(input.cityName);

  const provinceName =
    (provinceCode ? ENTERPRISE_HUB_PROVINCE_NAME_BY_CODE[provinceCode] : null) ??
    provinceHint;
  const cityTruth = cityCode ? ENTERPRISE_HUB_CITY_TRUTH_BY_CODE[cityCode] : null;
  const cityName = cityTruth?.cityName ?? cityHint;

  return {
    provinceCode,
    provinceName,
    cityCode,
    cityName,
    provinceLookupHit: Boolean(provinceCode && ENTERPRISE_HUB_PROVINCE_NAME_BY_CODE[provinceCode]),
    cityLookupHit: Boolean(cityTruth),
    sourceVersion: ENTERPRISE_HUB_REGION_LOOKUP_SOURCE_VERSION,
  };
}

export function canonicalizeEnterpriseHubRegionDisplayFields<
  T extends EnterpriseHubRegionDisplayFields,
>(input: T): T {
  const truth = resolveEnterpriseHubRegionDisplayTruth(input);
  return {
    ...input,
    provinceCode: truth.provinceCode,
    provinceName: truth.provinceName,
    cityCode: truth.cityCode,
    cityName: truth.cityName,
  };
}

function normalizeText(value: string | null | undefined) {
  return typeof value === 'string' && value.trim().length > 0
    ? value.trim()
    : null;
}
