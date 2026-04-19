import {
  EnterpriseHubLocationGeoSource,
  EnterpriseHubLocationGeoStatus,
  EnterpriseHubLocationMapProvider,
} from './enterprise-hub-location.types';

export function readFiniteNumber(value: unknown) {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

export function readOptionalNumber(value: unknown) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = Number(value);
  return Number.isFinite(normalized) ? normalized : null;
}

export function readNullableString(value: unknown) {
  return typeof value === 'string' && value.trim().length > 0
    ? value.trim()
    : null;
}

export function asRecord(value: unknown) {
  if (value && typeof value === 'object' && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return null;
}

export function normalizeCityName(value: unknown, fallbackProvince: unknown) {
  if (typeof value === 'string' && value.trim().length > 0) {
    return value.trim();
  }
  if (Array.isArray(value) && value.length > 0) {
    return readNullableString(value[0]);
  }
  return readNullableString(fallbackProvince);
}

export function parseLngLat(value: string | null): [number | null, number | null] {
  if (!value) {
    return [null, null];
  }
  const [longitudeRaw, latitudeRaw] = value.split(',');
  return [readOptionalNumber(longitudeRaw), readOptionalNumber(latitudeRaw)];
}

export function deriveProvinceCode(adcode: string | null) {
  if (!adcode || adcode.length < 2) {
    return null;
  }
  return `${adcode.slice(0, 2)}0000`;
}

export function deriveCityCode(adcode: string | null) {
  if (!adcode || adcode.length < 4) {
    return null;
  }
  return `${adcode.slice(0, 4)}00`;
}

export function readGeoSource(value: unknown): EnterpriseHubLocationGeoSource {
  if (
    value === 'device_location' ||
    value === 'manual_address_geocode' ||
    value === 'manual_text_only'
  ) {
    return value;
  }
  return 'unknown';
}

export function readGeoStatus(value: unknown): EnterpriseHubLocationGeoStatus {
  if (
    value === 'resolved' ||
    value === 'text_only' ||
    value === 'failed'
  ) {
    return value;
  }
  return 'not_provided';
}

export function readMapProvider(value: unknown): EnterpriseHubLocationMapProvider | null {
  return readNullableString(value) === 'amap' ? 'amap' : null;
}
