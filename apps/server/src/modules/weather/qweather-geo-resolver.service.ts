import { Injectable } from '@nestjs/common';
import type { GeoResolver } from './geo-resolver.port';
import { QWeatherHttpClient } from './qweather-http.client';
import type { GeoLookupRequest, ResolvedGeoLocation } from './weather.types';

@Injectable()
export class QWeatherGeoResolverService implements GeoResolver {
  constructor(private readonly http: QWeatherHttpClient) {}

  async resolve(
    request: GeoLookupRequest,
  ): Promise<ResolvedGeoLocation | null> {
    const lookup = this.toLookupQuery(request);
    if (!lookup.location) {
      return null;
    }

    const payload = await this.http.getJson('/geo/v2/city/lookup', {
      location: lookup.location,
      adm: lookup.adm,
      range: 'cn',
      number: 1,
    });

    const locations = Array.isArray(payload.location) ? payload.location : [];
    const first = this.asRecord(locations[0]);
    if (!first) {
      return null;
    }

    const locationId = this.readText(first.id);
    const latitude = this.readNumber(first.lat);
    const longitude = this.readNumber(first.lon);
    if (!locationId || latitude === null || longitude === null) {
      return null;
    }

    const provinceName = this.normalizeProvinceName(this.readText(first.adm1));
    const placeName = this.normalizePlaceName(this.readText(first.name));
    const parentCityName = this.normalizeCityName(this.readText(first.adm2));

    return {
      locationId,
      latitude,
      longitude,
      provinceCode: request.provinceCode,
      provinceName,
      cityName: this.resolveCityName(placeName, parentCityName, provinceName),
      districtName: this.resolveDistrictName(
        placeName,
        parentCityName,
        provinceName,
      ),
      timezone: this.readText(first.tz),
      queryLabel:
        placeName ??
        parentCityName ??
        provinceName ??
        request.displayName ??
        request.provinceName ??
        '当前地区',
    };
  }

  private toLookupQuery(request: GeoLookupRequest) {
    if (request.latitude !== null && request.longitude !== null) {
      return {
        location: `${request.longitude.toFixed(2)},${request.latitude.toFixed(2)}`,
        adm: null,
      };
    }
    if (request.provinceCode) {
      return {
        location: request.provinceCode,
        adm: null,
      };
    }
    if (request.districtName) {
      return {
        location: request.districtName,
        adm: request.cityName ?? request.provinceName,
      };
    }
    if (request.cityName) {
      return {
        location: request.cityName,
        adm: request.provinceName,
      };
    }
    if (request.provinceName) {
      return {
        location: request.provinceName,
        adm: null,
      };
    }
    return {
      location: request.displayName,
      adm: null,
    };
  }

  private resolveCityName(
    placeName: string | null,
    parentCityName: string | null,
    provinceName: string | null,
  ) {
    if (placeName && parentCityName && placeName !== parentCityName) {
      return parentCityName;
    }
    if (parentCityName && parentCityName !== provinceName) {
      return parentCityName;
    }
    return null;
  }

  private resolveDistrictName(
    placeName: string | null,
    parentCityName: string | null,
    provinceName: string | null,
  ) {
    if (!placeName) {
      return null;
    }
    if (placeName === parentCityName || placeName === provinceName) {
      return null;
    }
    return placeName;
  }

  private normalizeProvinceName(value: string | null) {
    if (!value) {
      return null;
    }
    return value
      .replace(/壮族自治区|回族自治区|维吾尔自治区|特别行政区|自治区|省|市$/u, '')
      .trim();
  }

  private normalizeCityName(value: string | null) {
    if (!value) {
      return null;
    }
    return value.replace(/自治州|地区|盟|市$/u, '').trim();
  }

  private normalizePlaceName(value: string | null) {
    if (!value) {
      return null;
    }
    return value.replace(/区|县|市$/u, '').trim();
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      return null;
    }
    return value as Record<string, unknown>;
  }

  private readText(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private readNumber(value: unknown) {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value;
    }
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = Number(value);
    return Number.isFinite(normalized) ? normalized : null;
  }
}
