import { Injectable } from '@nestjs/common';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import { RedisClientService } from '../../core/redis-client.service';
import type {
  GeoLookupRequest,
  ResolvedGeoLocation,
  WeatherAlert,
  WeatherCurrentConditions,
  WeatherDailyForecastItem,
  WeatherHourlyForecastItem,
} from './weather.types';

@Injectable()
export class WeatherCacheService {
  constructor(
    private readonly redis: RedisClientService,
    private readonly config: RuntimeConfigService,
  ) {}

  getGeoResolution(request: GeoLookupRequest) {
    return this.redis.getJson<ResolvedGeoLocation>(this.geoResolutionKey(request));
  }

  setGeoResolution(request: GeoLookupRequest, value: ResolvedGeoLocation) {
    return this.redis.setJson(
      this.geoResolutionKey(request),
      value,
      this.config.weatherCacheGeoTtlSeconds,
    );
  }

  getCurrentWeather(locationId: string) {
    return this.redis.getJson<WeatherCurrentConditions>(
      this.currentWeatherKey(locationId),
    );
  }

  setCurrentWeather(locationId: string, value: WeatherCurrentConditions) {
    return this.redis.setJson(
      this.currentWeatherKey(locationId),
      value,
      this.config.weatherCacheCurrentTtlSeconds,
    );
  }

  getHourlyForecast(locationId: string) {
    return this.redis.getJson<WeatherHourlyForecastItem[]>(
      this.hourlyForecastKey(locationId),
    );
  }

  setHourlyForecast(locationId: string, value: WeatherHourlyForecastItem[]) {
    return this.redis.setJson(
      this.hourlyForecastKey(locationId),
      value,
      this.config.weatherCacheHourlyTtlSeconds,
    );
  }

  getDailyForecast(locationId: string) {
    return this.redis.getJson<WeatherDailyForecastItem[]>(
      this.dailyForecastKey(locationId),
    );
  }

  setDailyForecast(locationId: string, value: WeatherDailyForecastItem[]) {
    return this.redis.setJson(
      this.dailyForecastKey(locationId),
      value,
      this.config.weatherCacheDailyTtlSeconds,
    );
  }

  getOfficialAlerts(latitude: number, longitude: number) {
    return this.redis.getJson<WeatherAlert[]>(this.alertsKey(latitude, longitude));
  }

  setOfficialAlerts(latitude: number, longitude: number, value: WeatherAlert[]) {
    return this.redis.setJson(
      this.alertsKey(latitude, longitude),
      value,
      this.config.weatherCacheAlertTtlSeconds,
    );
  }

  private geoResolutionKey(request: GeoLookupRequest) {
    return this.prefixedKey('geo', [
      request.provinceCode,
      request.provinceName,
      request.cityName,
      request.districtName,
      request.displayName,
      request.latitude?.toFixed(4) ?? null,
      request.longitude?.toFixed(4) ?? null,
    ]);
  }

  private currentWeatherKey(locationId: string) {
    return this.prefixedKey('current', [locationId]);
  }

  private hourlyForecastKey(locationId: string) {
    return this.prefixedKey('hourly', [locationId]);
  }

  private dailyForecastKey(locationId: string) {
    return this.prefixedKey('daily', [locationId]);
  }

  private alertsKey(latitude: number, longitude: number) {
    return this.prefixedKey('alerts', [
      latitude.toFixed(2),
      longitude.toFixed(2),
    ]);
  }

  private prefixedKey(prefix: string, parts: Array<string | null>) {
    const normalized = parts.map((part) => part ?? '').join('|');
    return `weather:${prefix}:${Buffer.from(normalized).toString('base64url')}`;
  }
}
