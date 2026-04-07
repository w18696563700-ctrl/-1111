import { BadRequestException, Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';

type ExhibitionHomeQuery = {
  latitude?: string;
  longitude?: string;
  provinceCode?: string;
  provinceName?: string;
  locationPermissionState?: string;
};

@Injectable()
export class ExhibitionHomeService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
  ) {}

  async getHome(headers: IncomingHttpHeaders, query: ExhibitionHomeQuery) {
    try {
      const result = await this.serverClient.get<Record<string, unknown>>(
        '/server/exhibition/home',
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
          params: this.buildQueryParams(query),
        },
      );
      return this.toHomeReadModel(result);
    } catch (error) {
      throw this.normalizeLoadError(error);
    }
  }

  async refreshHome(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/exhibition/home/refresh',
        this.requireOptionalRecord(payload),
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
        },
      );
      return this.toHomeReadModel(result);
    } catch (error) {
      throw this.normalizeRefreshError(error);
    }
  }

  async selectLocation(
    payload: Record<string, unknown> | undefined,
    headers: IncomingHttpHeaders,
  ) {
    try {
      const result = await this.serverClient.post<Record<string, unknown>>(
        '/server/exhibition/home/location/select',
        this.requireRecord(payload, '当前地区选择请求体无效，请检查后重试。'),
        {
          headers: this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
        },
      );
      return this.toHomeReadModel(result);
    } catch (error) {
      throw this.normalizeSelectError(error);
    }
  }

  private normalizeLoadError(error: unknown) {
    return this.errors.toHttpException(
      error,
      'HOME_AGGREGATION_UNAVAILABLE',
      '当前展览首页暂不可用，请稍后再试。',
      {
        400: 'LOCATION_REQUIRED',
        503: 'HOME_AGGREGATION_UNAVAILABLE',
      },
    );
  }

  private normalizeRefreshError(error: unknown) {
    return this.errors.toHttpException(
      error,
      'HOME_AGGREGATION_UNAVAILABLE',
      '当前展览首页刷新暂不可用，请稍后再试。',
      {
        400: 'LOCATION_REQUIRED',
        503: 'HOME_AGGREGATION_UNAVAILABLE',
        504: 'HOME_REFRESH_TIMEOUT',
      },
    );
  }

  private normalizeSelectError(error: unknown) {
    return this.errors.toHttpException(
      error,
      'LOCATION_REQUIRED',
      '当前地区选择暂不可用，请稍后再试。',
      {
        400: 'LOCATION_REQUIRED',
      },
    );
  }

  private toHomeReadModel(result: Record<string, unknown>) {
    this.requireKeys(result, [
      'currentLocation',
      'selectionScope',
      'isUsingDeviceLocation',
      'currentWeather',
      'currentTemperature',
      'highTemperature',
      'lowTemperature',
      'precipitationProbability',
      'constructionRiskLevel',
      'constructionRiskSummary',
      'riskTags',
      'riskTimeLabel',
      'nightRainExpected',
      'nightRainTimeLabel',
      'officialAlerts',
      'constructionSuggestions',
      'hourlyForecast',
      'dailyForecast',
      'updatedAt',
      'sourceLabel',
      'selectionNotice',
      'canExpand',
      'refreshable',
      'modules',
      'recommendationSections',
    ]);

    const currentLocation = this.requirePlainRecord(
      result.currentLocation,
      'Exhibition home response is missing currentLocation.',
    );
    this.requireKeys(currentLocation, [
      'displayName',
      'provinceName',
      'source',
      'persisted',
    ]);

    if (!Array.isArray(result.modules)) {
      throw new Error('Exhibition home response is missing modules.');
    }
    if (!Array.isArray(result.recommendationSections)) {
      throw new Error('Exhibition home response is missing recommendationSections.');
    }

    return result;
  }

  private buildQueryParams(query: ExhibitionHomeQuery) {
    return {
      latitude: this.asOptionalString(query.latitude),
      longitude: this.asOptionalString(query.longitude),
      provinceCode: this.asOptionalString(query.provinceCode),
      provinceName: this.asOptionalString(query.provinceName),
      locationPermissionState: this.asOptionalString(query.locationPermissionState),
    };
  }

  private requireOptionalRecord(value: Record<string, unknown> | undefined) {
    if (value === undefined) {
      return {};
    }
    return this.requireRecord(value, '当前请求体无效，请检查后重试。');
  }

  private requireRecord(value: unknown, message: string) {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }

    throw new BadRequestException({
      statusCode: 400,
      code: 'LOCATION_REQUIRED',
      message,
      source: 'bff',
    });
  }

  private requirePlainRecord(value: unknown, message: string) {
    if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
      return value as Record<string, unknown>;
    }
    throw new Error(message);
  }

  private requireKeys(source: Record<string, unknown>, keys: string[]) {
    if (keys.every((key) => Object.prototype.hasOwnProperty.call(source, key))) {
      return;
    }
    throw new Error('Exhibition home response is missing required fields.');
  }

  private asOptionalString(value: unknown) {
    if (typeof value !== 'string') {
      return undefined;
    }

    const normalized = value.trim();
    return normalized.length > 0 ? normalized : undefined;
  }
}
