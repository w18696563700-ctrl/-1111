import { Injectable } from '@nestjs/common';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import {
  locationResolveInvalid,
  locationWriteInvalid,
  permissionDenied,
} from './enterprise-hub.errors';
import { EnterpriseHubAmapLocationProviderService } from './enterprise-hub-amap-location-provider.service';
import {
  asRecord,
  deriveCityCode,
  deriveProvinceCode,
  readFiniteNumber,
  readGeoSource,
  readGeoStatus,
  readMapProvider,
  readNullableString,
  readOptionalNumber,
} from './enterprise-hub-location-reader';
import {
  EnterpriseHubLocationFallback,
  EnterpriseHubLocationTruth,
} from './enterprise-hub-location.types';
import { inferEnterpriseHubRegionFromAddress } from './enterprise-hub-address-region-truth';
import { resolveEnterpriseHubRegionDisplayTruth } from './enterprise-hub-region-lookup';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';

@Injectable()
export class EnterpriseHubLocationService {
  constructor(
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly amapLocationProvider: EnterpriseHubAmapLocationProviderService,
  ) {}

  toReadModel(listing: EnterpriseListingEntity): EnterpriseHubLocationTruth {
    const publicDisplayAddress =
      readNullableString(listing.publicDisplayAddress) ??
      readNullableString(listing.address);
    const inferredRegion = publicDisplayAddress
      ? inferEnterpriseHubRegionFromAddress(publicDisplayAddress)
      : {
          provinceCode: null,
          provinceName: null,
          cityCode: null,
          cityName: null,
        };
    const regionTruth = resolveEnterpriseHubRegionDisplayTruth({
      provinceCode: inferredRegion.provinceCode ?? readNullableString(listing.provinceCode),
      provinceName: inferredRegion.provinceName ?? readNullableString(listing.provinceName),
      cityCode: inferredRegion.cityCode ?? readNullableString(listing.cityCode),
      cityName: inferredRegion.cityName ?? readNullableString(listing.cityName),
    });
    const latitude = readFiniteNumber(listing.latitude);
    const longitude = readFiniteNumber(listing.longitude);
    const geoStatus = readGeoStatus(listing.geoStatus);
    const mapProvider = readMapProvider(listing.mapProvider);
    return {
      addressText: readNullableString(listing.address),
      publicDisplayAddress,
      provinceCode: regionTruth.provinceCode,
      provinceName: regionTruth.provinceName,
      cityCode: regionTruth.cityCode,
      cityName: regionTruth.cityName,
      districtCode: readNullableString(listing.districtCode),
      districtName: readNullableString(listing.districtName),
      latitude,
      longitude,
      geoSource: readGeoSource(listing.geoSource),
      geoStatus,
      lastGeocodedAt: listing.lastGeocodedAt?.toISOString() ?? null,
      mapProvider,
      mapPreviewUrl: this.amapLocationProvider.buildMapPreviewUrl(latitude, longitude),
      mapLinkUrl: this.amapLocationProvider.buildMapLinkUrl(
        latitude,
        longitude,
        publicDisplayAddress,
      ),
    };
  }

  normalizeWriteLocation(
    raw: unknown,
    fallback: EnterpriseHubLocationFallback,
  ): EnterpriseHubLocationTruth {
    const payload = asRecord(raw);
    if (!payload) {
      return this.buildFallbackLocationTruth(fallback);
    }

    const addressText =
      readNullableString(payload.addressText) ?? fallback.addressText;
    const publicDisplayAddress =
      readNullableString(payload.publicDisplayAddress) ?? addressText;
    const latitude = readOptionalNumber(payload.latitude);
    const longitude = readOptionalNumber(payload.longitude);
    const geoStatus = readGeoStatus(payload.geoStatus);
    if (geoStatus === 'resolved' && (latitude === null || longitude === null)) {
      throw locationWriteInvalid(
        '当前企业位置已标记为 resolved，但缺少 latitude / longitude。',
      );
    }

    return this.canonicalizeLocationTruth({
      addressText,
      publicDisplayAddress,
      provinceCode:
        readNullableString(payload.provinceCode) ?? fallback.provinceCode,
      provinceName:
        readNullableString(payload.provinceName) ?? fallback.provinceName,
      cityCode: readNullableString(payload.cityCode) ?? fallback.cityCode,
      cityName: readNullableString(payload.cityName) ?? fallback.cityName,
      districtCode: readNullableString(payload.districtCode),
      districtName: readNullableString(payload.districtName),
      latitude,
      longitude,
      geoSource: readGeoSource(payload.geoSource),
      geoStatus,
      lastGeocodedAt: readNullableString(payload.lastGeocodedAt),
      mapProvider: readMapProvider(payload.mapProvider),
      mapPreviewUrl: this.amapLocationProvider.buildMapPreviewUrl(latitude, longitude),
      mapLinkUrl: this.amapLocationProvider.buildMapLinkUrl(
        latitude,
        longitude,
        publicDisplayAddress,
      ),
    });
  }

  applyToListing(
    listing: EnterpriseListingEntity,
    location: EnterpriseHubLocationTruth,
  ) {
    const normalizedLocation = this.canonicalizeLocationTruth(location);
    listing.address = normalizedLocation.addressText;
    listing.publicDisplayAddress = normalizedLocation.publicDisplayAddress;
    listing.provinceCode = normalizedLocation.provinceCode?.trim() ?? '';
    listing.provinceName = normalizedLocation.provinceName?.trim() ?? '';
    listing.cityCode = normalizedLocation.cityCode?.trim() ?? '';
    listing.cityName = normalizedLocation.cityName?.trim() ?? '';
    listing.districtCode = normalizedLocation.districtCode;
    listing.districtName = normalizedLocation.districtName;
    listing.latitude = normalizedLocation.latitude;
    listing.longitude = normalizedLocation.longitude;
    listing.geoSource = normalizedLocation.geoSource;
    listing.geoStatus = normalizedLocation.geoStatus;
    listing.lastGeocodedAt = normalizedLocation.lastGeocodedAt
      ? new Date(normalizedLocation.lastGeocodedAt)
      : null;
    listing.mapProvider = normalizedLocation.mapProvider;
  }

  async resolve(
    payload: Record<string, unknown>,
    context: RequestContext,
  ): Promise<{ location: EnterpriseHubLocationTruth; message: string | null }> {
    await this.requireEnterpriseHubResolveContext(context);
    const input = this.readResolveInput(payload);
    this.amapLocationProvider.requireProviderConfig();

    if (input.resolveMode === 'manual_address') {
      return this.resolveManualAddress(input);
    }
    return this.resolveDeviceLocation(input);
  }

  private async requireEnterpriseHubResolveContext(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(
      currentSession,
    );
    if (!scope?.organization?.id) {
      throw permissionDenied(
        'Current actor must carry organization scope for enterprise location resolve.',
      );
    }
  }

  private async resolveManualAddress(input: {
    resolveMode: 'manual_address';
    addressText: string;
    provinceCode: string | null;
    provinceName: string | null;
    cityCode: string | null;
    cityName: string | null;
    districtCode: string | null;
    districtName: string | null;
    latitude: number | null;
    longitude: number | null;
  }): Promise<{ location: EnterpriseHubLocationTruth; message: string }> {
    const result = await this.amapLocationProvider.geocodeAddress(
      input.addressText,
      input.cityName,
    );
    if (!result) {
      return {
        location: this.canonicalizeLocationTruth({
          addressText: input.addressText,
          publicDisplayAddress: input.addressText,
          provinceCode: input.provinceCode,
          provinceName: input.provinceName,
          cityCode: input.cityCode,
          cityName: input.cityName,
          districtCode: input.districtCode,
          districtName: input.districtName,
          latitude: null,
          longitude: null,
          geoSource: 'manual_text_only',
          geoStatus: 'text_only',
          lastGeocodedAt: null,
          mapProvider: 'amap',
          mapPreviewUrl: null,
          mapLinkUrl: null,
        }),
        message: '当前文字地址未解析出可用坐标，已先按文字地址保留。',
      };
    }
    const lastGeocodedAt = new Date().toISOString();
    const publicDisplayAddress =
      result.formattedAddress ?? input.addressText;
    return {
      location: this.canonicalizeLocationTruth({
        addressText: publicDisplayAddress,
        publicDisplayAddress,
        provinceCode:
          deriveProvinceCode(result.adcode) ?? input.provinceCode,
        provinceName: result.provinceName ?? input.provinceName,
        cityCode: deriveCityCode(result.adcode) ?? input.cityCode,
        cityName: result.cityName ?? input.cityName,
        districtCode: result.adcode ?? input.districtCode,
        districtName: result.districtName ?? input.districtName,
        latitude: result.latitude,
        longitude: result.longitude,
        geoSource: 'manual_address_geocode',
        geoStatus: 'resolved',
        lastGeocodedAt,
        mapProvider: 'amap',
        mapPreviewUrl: this.amapLocationProvider.buildMapPreviewUrl(
          result.latitude,
          result.longitude,
        ),
        mapLinkUrl: this.amapLocationProvider.buildMapLinkUrl(
          result.latitude,
          result.longitude,
          publicDisplayAddress,
        ),
      }),
      message: '文字地址已解析为可公开展示的位置结果。',
    };
  }

  private async resolveDeviceLocation(input: {
    resolveMode: 'device_location';
    addressText: string | null;
    provinceCode: string | null;
    provinceName: string | null;
    cityCode: string | null;
    cityName: string | null;
    districtCode: string | null;
    districtName: string | null;
    latitude: number;
    longitude: number;
  }): Promise<{ location: EnterpriseHubLocationTruth; message: string }> {
    const result = await this.amapLocationProvider.reverseGeocode(
      input.latitude,
      input.longitude,
    );
    if (!result) {
      const fallbackAddress =
        input.addressText ??
        `当前位置：${input.latitude.toFixed(6)}, ${input.longitude.toFixed(6)}`;
      return {
        location: this.canonicalizeLocationTruth({
          addressText: fallbackAddress,
          publicDisplayAddress: fallbackAddress,
          provinceCode: input.provinceCode,
          provinceName: input.provinceName,
          cityCode: input.cityCode,
          cityName: input.cityName,
          districtCode: input.districtCode,
          districtName: input.districtName,
          latitude: input.latitude,
          longitude: input.longitude,
          geoSource: 'device_location',
          geoStatus: 'failed',
          lastGeocodedAt: null,
          mapProvider: 'amap',
          mapPreviewUrl: this.amapLocationProvider.buildMapPreviewUrl(
            input.latitude,
            input.longitude,
          ),
          mapLinkUrl: this.amapLocationProvider.buildMapLinkUrl(
            input.latitude,
            input.longitude,
            fallbackAddress,
          ),
        }),
        message:
          '当前位置暂未解析出可用地址，已保留定位坐标，请继续补充门牌号等详细地址。',
      };
    }
    const lastGeocodedAt = new Date().toISOString();
    const publicDisplayAddress =
      result.formattedAddress ??
      input.addressText ??
      `${input.latitude.toFixed(6)}, ${input.longitude.toFixed(6)}`;
    return {
      location: this.canonicalizeLocationTruth({
        addressText: publicDisplayAddress,
        publicDisplayAddress,
        provinceCode:
          deriveProvinceCode(result.adcode) ?? input.provinceCode,
        provinceName: result.provinceName ?? input.provinceName,
        cityCode: deriveCityCode(result.adcode) ?? input.cityCode,
        cityName: result.cityName ?? input.cityName,
        districtCode: result.adcode ?? input.districtCode,
        districtName: result.districtName ?? input.districtName,
        latitude: input.latitude,
        longitude: input.longitude,
        geoSource: 'device_location',
        geoStatus: 'resolved',
        lastGeocodedAt,
        mapProvider: 'amap',
        mapPreviewUrl: this.amapLocationProvider.buildMapPreviewUrl(
          input.latitude,
          input.longitude,
        ),
        mapLinkUrl: this.amapLocationProvider.buildMapLinkUrl(
          input.latitude,
          input.longitude,
          publicDisplayAddress,
        ),
      }),
      message: '已按当前位置解析出可公开展示的位置结果。',
    };
  }

  private readResolveInput(payload: Record<string, unknown>) {
    const resolveMode = payload.resolveMode;
    if (resolveMode !== 'manual_address' && resolveMode !== 'device_location') {
      throw locationResolveInvalid(
        'Field `resolveMode` must be `manual_address` or `device_location`.',
      );
    }

    const addressText = readNullableString(payload.addressText);
    const latitude = readOptionalNumber(payload.latitude);
    const longitude = readOptionalNumber(payload.longitude);
    const base = {
      resolveMode,
      addressText,
      provinceCode: readNullableString(payload.provinceCode),
      provinceName: readNullableString(payload.provinceName),
      cityCode: readNullableString(payload.cityCode),
      cityName: readNullableString(payload.cityName),
      districtCode: readNullableString(payload.districtCode),
      districtName: readNullableString(payload.districtName),
      latitude,
      longitude,
    };
    if (resolveMode === 'manual_address') {
      if (!addressText) {
        throw locationResolveInvalid(
          'Field `addressText` is required when resolveMode = manual_address.',
        );
      }
      return base as {
        resolveMode: 'manual_address';
        addressText: string;
        provinceCode: string | null;
        provinceName: string | null;
        cityCode: string | null;
        cityName: string | null;
        districtCode: string | null;
        districtName: string | null;
        latitude: number | null;
        longitude: number | null;
      };
    }
    if (latitude === null || longitude === null) {
      throw locationResolveInvalid(
        'Fields `latitude` and `longitude` are required when resolveMode = device_location.',
      );
    }
    return base as {
      resolveMode: 'device_location';
      addressText: string | null;
      provinceCode: string | null;
      provinceName: string | null;
      cityCode: string | null;
      cityName: string | null;
      districtCode: string | null;
      districtName: string | null;
      latitude: number;
      longitude: number;
    };
  }

  private buildFallbackLocationTruth(
    fallback: EnterpriseHubLocationFallback,
  ): EnterpriseHubLocationTruth {
    if (fallback.addressText) {
      return this.canonicalizeLocationTruth({
        addressText: fallback.addressText,
        publicDisplayAddress: fallback.addressText,
        provinceCode: fallback.provinceCode,
        provinceName: fallback.provinceName,
        cityCode: fallback.cityCode,
        cityName: fallback.cityName,
        districtCode: null,
        districtName: null,
        latitude: null,
        longitude: null,
        geoSource: 'manual_text_only',
        geoStatus: 'text_only',
        lastGeocodedAt: null,
        mapProvider: null,
        mapPreviewUrl: null,
        mapLinkUrl: null,
      });
    }
    return this.canonicalizeLocationTruth({
      addressText: null,
      publicDisplayAddress: null,
      provinceCode: fallback.provinceCode,
      provinceName: fallback.provinceName,
      cityCode: fallback.cityCode,
      cityName: fallback.cityName,
      districtCode: null,
      districtName: null,
      latitude: null,
      longitude: null,
      geoSource: 'unknown',
      geoStatus: 'not_provided',
      lastGeocodedAt: null,
      mapProvider: null,
      mapPreviewUrl: null,
      mapLinkUrl: null,
    });
  }

  private canonicalizeLocationTruth(
    location: EnterpriseHubLocationTruth,
  ): EnterpriseHubLocationTruth {
    const regionTruth = resolveEnterpriseHubRegionDisplayTruth({
      provinceCode: location.provinceCode,
      provinceName: location.provinceName,
      cityCode: location.cityCode,
      cityName: location.cityName,
    });
    return {
      ...location,
      provinceCode: regionTruth.provinceCode,
      provinceName: regionTruth.provinceName,
      cityCode: regionTruth.cityCode,
      cityName: regionTruth.cityName,
    };
  }
}
