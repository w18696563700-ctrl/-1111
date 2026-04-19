import { Injectable, Logger } from '@nestjs/common';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import {
  locationProviderConfigMissing,
  locationResolveFailed,
  locationResolveProviderUnavailable,
} from './enterprise-hub.errors';
import {
  asRecord,
  normalizeCityName,
  parseLngLat,
  readNullableString,
} from './enterprise-hub-location-reader';

@Injectable()
export class EnterpriseHubAmapLocationProviderService {
  private readonly logger = new Logger(EnterpriseHubAmapLocationProviderService.name);

  constructor(private readonly config: RuntimeConfigService) {}

  requireProviderConfig() {
    if (!this.config.amapWebServiceEnabled) {
      throw locationResolveProviderUnavailable(
        '当前企业位置解析 provider 未启用，请先完成高德运行态配置。',
      );
    }
    if (!this.config.amapWebServiceKey.trim()) {
      throw locationProviderConfigMissing(
        '当前企业位置解析缺少高德 Web 服务 Key，请先完成云端配置后再试。',
      );
    }
  }

  async geocodeAddress(addressText: string, cityName: string | null) {
    const url = new URL('/v3/geocode/geo', this.config.amapWebServiceBaseUrl);
    url.searchParams.set('key', this.config.amapWebServiceKey);
    url.searchParams.set('address', addressText);
    if (cityName) {
      url.searchParams.set('city', cityName);
    }
    const payload = await this.fetchProviderPayload(url);
    const geocodes = Array.isArray(payload.geocodes) ? payload.geocodes : [];
    const first = asRecord(geocodes[0]);
    if (!first) {
      return null;
    }
    const location = readNullableString(first.location);
    const [longitude, latitude] = parseLngLat(location);
    if (latitude === null || longitude === null) {
      return null;
    }
    const adcode = readNullableString(first.adcode);
    return {
      formattedAddress: readNullableString(first.formatted_address) ?? addressText,
      provinceName: readNullableString(first.province),
      cityName: normalizeCityName(first.city, first.province),
      districtName:
        readNullableString(first.district) ?? readNullableString(first.township),
      adcode,
      latitude,
      longitude,
    };
  }

  async reverseGeocode(latitude: number, longitude: number) {
    const url = new URL('/v3/geocode/regeo', this.config.amapWebServiceBaseUrl);
    url.searchParams.set('key', this.config.amapWebServiceKey);
    url.searchParams.set('location', `${longitude},${latitude}`);
    url.searchParams.set('extensions', 'base');
    const payload = await this.fetchProviderPayload(url);
    const regeo = asRecord(payload.regeocode);
    if (!regeo) {
      return null;
    }
    const addressComponent = asRecord(regeo.addressComponent);
    const adcode = readNullableString(addressComponent?.adcode);
    return {
      formattedAddress: readNullableString(regeo.formatted_address),
      provinceName: readNullableString(addressComponent?.province),
      cityName: normalizeCityName(addressComponent?.city, addressComponent?.province),
      districtName: readNullableString(addressComponent?.district),
      adcode,
    };
  }

  buildMapLinkUrl(
    latitude: number | null,
    longitude: number | null,
    addressText: string | null,
  ) {
    if (latitude === null || longitude === null) {
      if (!addressText?.trim()) {
        return null;
      }
      const url = new URL('https://uri.amap.com/search');
      url.searchParams.set('keyword', addressText.trim());
      url.searchParams.set('src', 'exhibition_app');
      return url.toString();
    }
    const url = new URL('https://uri.amap.com/marker');
    url.searchParams.set('position', `${longitude},${latitude}`);
    url.searchParams.set('name', addressText ?? '企业位置');
    url.searchParams.set('src', 'exhibition_app');
    return url.toString();
  }

  buildMapPreviewUrl(latitude: number | null, longitude: number | null) {
    if (latitude === null || longitude === null) {
      return null;
    }
    if (!this.config.amapWebServiceEnabled || !this.config.amapWebServiceKey.trim()) {
      const url = new URL('https://staticmap.openstreetmap.de/staticmap.php');
      url.searchParams.set('center', `${latitude},${longitude}`);
      url.searchParams.set('zoom', '15');
      url.searchParams.set('size', '750x360');
      url.searchParams.set('markers', `${latitude},${longitude},red-pushpin`);
      return url.toString();
    }
    const url = new URL('/v3/staticmap', this.config.amapWebServiceBaseUrl);
    url.searchParams.set('key', this.config.amapWebServiceKey);
    url.searchParams.set('location', `${longitude},${latitude}`);
    url.searchParams.set('zoom', '15');
    url.searchParams.set('size', '750*360');
    url.searchParams.set('markers', `mid,,A:${longitude},${latitude}`);
    return url.toString();
  }

  private async fetchProviderPayload(url: URL): Promise<Record<string, unknown>> {
    try {
      const response = await fetch(url, {
        method: 'GET',
        signal: AbortSignal.timeout(this.config.amapWebServiceTimeoutMs),
      });
      if (!response.ok) {
        throw locationResolveFailed(
          `高德位置解析服务返回 HTTP ${response.status}，当前无法完成企业位置解析。`,
        );
      }
      const payload = (await response.json()) as Record<string, unknown>;
      const status = readNullableString(payload.status);
      if (status == null || status === '1') {
        return payload;
      }
      const info = readNullableString(payload.info) ?? '高德位置解析失败。';
      const infocode = readNullableString(payload.infocode);
      this.logger.warn(`enterprise location provider failed: ${infocode ?? 'unknown'} ${info}`);
      throw locationResolveFailed(infocode ? `${info}（${infocode}）` : info);
    } catch (error) {
      if (error instanceof Error && 'getStatus' in error) {
        throw error;
      }
      const message =
        error instanceof Error ? error.message : '高德位置解析请求失败。';
      this.logger.warn(`enterprise location provider request failed: ${message}`);
      throw locationResolveFailed(message);
    }
  }
}
