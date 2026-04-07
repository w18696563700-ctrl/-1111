import { Injectable } from '@nestjs/common';
import { ExhibitionHomeLocationInput, ExhibitionHomePresenter } from './exhibition-home.presenter';
import { exhibitionHomeLocationRequired } from './exhibition-home.errors';

type HomeLocationPermissionState = 'granted' | 'denied' | 'unavailable' | 'unknown';

@Injectable()
export class ExhibitionHomeQueryService {
  constructor(private readonly presenter: ExhibitionHomePresenter) {}

  getHome(query: Record<string, unknown>) {
    return this.presenter.toReadModel(this.resolveLocationFromQuery(query));
  }

  refreshHome(body: unknown) {
    return this.presenter.toReadModel(this.resolveLocationFromRefreshBody(body));
  }

  selectLocation(body: unknown) {
    return this.presenter.toReadModel(this.resolveLocationFromSelectBody(body));
  }

  private resolveLocationFromQuery(query: Record<string, unknown>) {
    return this.toLocationInput(query, { manualSelection: false });
  }

  private resolveLocationFromRefreshBody(body: unknown) {
    const source = this.asRecord(body) ?? {};
    const locationContext = this.asRecord(source?.locationContext) ?? {};
    return this.toLocationInput(locationContext, { manualSelection: false });
  }

  private resolveLocationFromSelectBody(body: unknown) {
    const source = this.asRecord(body) ?? {};
    const provinceName = this.readOptionalString(source?.provinceName);
    if (!provinceName) {
      throw exhibitionHomeLocationRequired(
        'Current exhibition home manual location selection requires `provinceName`.'
      );
    }

    return this.toLocationInput(
      {
        ...source,
        provinceName
      },
      { manualSelection: true }
    );
  }

  private toLocationInput(
    source: Record<string, unknown>,
    options: { manualSelection: boolean }
  ): ExhibitionHomeLocationInput {
    const provinceCode = this.readOptionalString(source.provinceCode);
    const provinceName = this.readOptionalString(source.provinceName);
    const cityName = this.readOptionalString(source.cityName);
    const districtName = this.readOptionalString(source.districtName);
    const latitude = this.readOptionalNumber(source.latitude);
    const longitude = this.readOptionalNumber(source.longitude);
    const locationPermissionState = this.readLocationPermissionState(
      source.locationPermissionState
    );
    const hasLocationHints =
      Boolean(provinceName || cityName || districtName) || latitude !== null || longitude !== null;
    const locationSource = options.manualSelection
      ? 'manual_selection'
      : hasLocationHints || locationPermissionState === 'granted'
        ? 'device_location'
        : 'system_default';

    return {
      displayName:
        this.readOptionalString(source.displayName) ??
        this.composeDisplayName({
          provinceName,
          cityName,
          districtName
        }),
      provinceCode,
      provinceName: provinceName ?? '当前地区',
      cityName,
      districtName,
      latitude,
      longitude,
      source: locationSource,
      selectionScope: 'request_only',
      selectionNotice: this.toSelectionNotice(locationSource),
      isUsingDeviceLocation: locationSource === 'device_location'
    };
  }

  private toSelectionNotice(source: ExhibitionHomeLocationInput['source']) {
    switch (source) {
      case 'manual_selection':
        return '当前地区仅用于本次首页查看，不会写入长期位置设置。';
      case 'device_location':
        return '当前位置仅用于本次首页查看，可重新定位或手动切换。';
      case 'system_default':
        return '当前使用系统默认地区说明；可重新定位或手动选择地区。';
    }
  }

  private composeDisplayName(input: {
    provinceName: string | null;
    cityName: string | null;
    districtName: string | null;
  }) {
    const parts = [input.provinceName, input.cityName, input.districtName].filter(
      (value): value is string => Boolean(value)
    );
    if (!parts.length) {
      return '当前地区';
    }
    return parts.join('');
  }

  private readLocationPermissionState(value: unknown): HomeLocationPermissionState | null {
    const normalized = this.readOptionalString(value);
    if (!normalized) {
      return null;
    }
    if (
      normalized === 'granted' ||
      normalized === 'denied' ||
      normalized === 'unavailable' ||
      normalized === 'unknown'
    ) {
      return normalized;
    }
    return null;
  }

  private readOptionalString(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private readOptionalNumber(value: unknown) {
    if (typeof value === 'number' && Number.isFinite(value)) {
      return value;
    }
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = Number(value);
    return Number.isFinite(normalized) ? normalized : null;
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      return null;
    }
    return value as Record<string, unknown>;
  }
}
