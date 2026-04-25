import { Inject, Injectable, Logger } from '@nestjs/common';
import { GEO_RESOLVER, type GeoResolver } from './geo-resolver.port';
import { WeatherCacheService } from './weather-cache.service';
import { WEATHER_PROVIDER, type WeatherProvider } from './weather-provider.port';
import type {
  GeoLookupRequest,
  ResolvedGeoLocation,
  WeatherAlert,
  WeatherCurrentConditions,
  WeatherDailyForecastItem,
  WeatherHourlyForecastItem,
  WeatherLookupResult,
} from './weather.types';

type ProviderResult<T> = {
  payload: T | null;
  failure: string | null;
};

@Injectable()
export class WeatherLookupService {
  private readonly logger = new Logger(WeatherLookupService.name);

  constructor(
    @Inject(GEO_RESOLVER) private readonly geoResolver: GeoResolver,
    @Inject(WEATHER_PROVIDER) private readonly weatherProvider: WeatherProvider,
    private readonly cache: WeatherCacheService,
  ) {}

  async lookup(request: GeoLookupRequest): Promise<WeatherLookupResult> {
    const resolvedLocation = await this.resolveLocation(request);
    if (!resolvedLocation) {
      return {
        resolvedLocation: null,
        current: null,
        hourlyForecast: [],
        dailyForecast: [],
        officialAlerts: [],
        updatedAt: new Date().toISOString(),
        weatherAvailable: false,
        providerFailures: ['geo_unavailable'],
        degradedReason: 'geo_unavailable',
      };
    }

    const results = await Promise.all([
      this.loadCurrentWeather(resolvedLocation),
      this.loadHourlyForecast(resolvedLocation),
      this.loadDailyForecast(resolvedLocation),
      this.loadOfficialAlerts(resolvedLocation),
    ]);

    const current = results[0].payload;
    const hourlyForecast = results[1].payload ?? [];
    const dailyForecast = results[2].payload ?? [];
    const officialAlerts = results[3].payload ?? [];
    const providerFailures = results
      .map((result) => result.failure)
      .filter((failure): failure is string => Boolean(failure));
    const weatherAvailable =
      Boolean(current) ||
      hourlyForecast.length > 0 ||
      dailyForecast.length > 0 ||
      officialAlerts.length > 0;

    return {
      resolvedLocation,
      current,
      hourlyForecast,
      dailyForecast,
      officialAlerts,
      updatedAt: this.resolveUpdatedAt(
        current,
        hourlyForecast,
        dailyForecast,
        officialAlerts,
      ),
      weatherAvailable,
      providerFailures,
      degradedReason: weatherAvailable ? null : 'provider_unavailable',
    };
  }

  private async resolveLocation(request: GeoLookupRequest) {
    const cached = await this.cache.getGeoResolution(request);
    if (cached) {
      return cached;
    }

    try {
      const resolved = await this.geoResolver.resolve(request);
      if (resolved) {
        await this.cache.setGeoResolution(request, resolved);
      }
      return resolved;
    } catch (error) {
      this.logFailure('geo resolve', error);
      return null;
    }
  }

  private async loadCurrentWeather(
    location: ResolvedGeoLocation,
  ): Promise<ProviderResult<WeatherCurrentConditions>> {
    const cached = await this.cache.getCurrentWeather(location.locationId);
    if (cached) {
      return { payload: cached, failure: null };
    }

    try {
      const live = await this.weatherProvider.getCurrentWeather(location);
      if (live) {
        await this.cache.setCurrentWeather(location.locationId, live);
      }
      return { payload: live, failure: null };
    } catch (error) {
      this.logFailure('current weather', error);
      return { payload: null, failure: 'current_unavailable' };
    }
  }

  private async loadHourlyForecast(
    location: ResolvedGeoLocation,
  ): Promise<ProviderResult<WeatherHourlyForecastItem[]>> {
    const cached = await this.cache.getHourlyForecast(location.locationId);
    if (cached) {
      return { payload: cached, failure: null };
    }

    try {
      const live = await this.weatherProvider.getHourlyForecast(location);
      await this.cache.setHourlyForecast(location.locationId, live);
      return { payload: live, failure: null };
    } catch (error) {
      this.logFailure('hourly forecast', error);
      return { payload: null, failure: 'hourly_unavailable' };
    }
  }

  private async loadDailyForecast(
    location: ResolvedGeoLocation,
  ): Promise<ProviderResult<WeatherDailyForecastItem[]>> {
    const cached = await this.cache.getDailyForecast(location.locationId);
    if (cached) {
      return { payload: cached, failure: null };
    }

    try {
      const live = await this.weatherProvider.getDailyForecast(location);
      await this.cache.setDailyForecast(location.locationId, live);
      return { payload: live, failure: null };
    } catch (error) {
      this.logFailure('daily forecast', error);
      return { payload: null, failure: 'daily_unavailable' };
    }
  }

  private async loadOfficialAlerts(
    location: ResolvedGeoLocation,
  ): Promise<ProviderResult<WeatherAlert[]>> {
    const cached = await this.cache.getOfficialAlerts(
      location.latitude,
      location.longitude,
    );
    if (cached) {
      return { payload: cached, failure: null };
    }

    try {
      const live = await this.weatherProvider.getOfficialAlerts(location);
      await this.cache.setOfficialAlerts(
        location.latitude,
        location.longitude,
        live,
      );
      return { payload: live, failure: null };
    } catch (error) {
      this.logFailure('official alerts', error);
      return { payload: null, failure: 'alerts_unavailable' };
    }
  }

  private resolveUpdatedAt(
    current: WeatherCurrentConditions | null,
    hourlyForecast: WeatherHourlyForecastItem[],
    dailyForecast: WeatherDailyForecastItem[],
    officialAlerts: WeatherAlert[],
  ) {
    const candidates = [
      current?.updatedAt,
      hourlyForecast[0]?.updatedAt,
      dailyForecast[0]?.updatedAt,
      officialAlerts[0]?.effectiveAt,
    ].filter((value): value is string => Boolean(value));
    if (!candidates.length) {
      return new Date().toISOString();
    }
    return candidates.sort().at(-1) ?? new Date().toISOString();
  }

  private logFailure(scope: string, error: unknown) {
    const message =
      error instanceof Error
        ? error.message
        : 'Unknown weather lookup failure.';
    this.logger.warn(`${scope} failed: ${message}`);
  }
}
