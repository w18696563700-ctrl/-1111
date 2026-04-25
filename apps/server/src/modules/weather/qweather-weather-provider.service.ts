import { Injectable } from '@nestjs/common';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import type { WeatherProvider } from './weather-provider.port';
import { QWeatherHttpClient } from './qweather-http.client';
import type {
  ResolvedGeoLocation,
  WeatherAlert,
  WeatherCurrentConditions,
  WeatherDailyForecastItem,
  WeatherHourlyForecastItem,
} from './weather.types';

@Injectable()
export class QWeatherWeatherProviderService implements WeatherProvider {
  constructor(
    private readonly http: QWeatherHttpClient,
    private readonly config: RuntimeConfigService,
  ) {}

  async getCurrentWeather(
    location: ResolvedGeoLocation,
  ): Promise<WeatherCurrentConditions | null> {
    const payload = await this.http.getJson('/v7/weather/now', {
      location: location.locationId,
      unit: this.config.qweatherUnit,
    });
    const now = this.asRecord(payload.now);
    if (!now) {
      return null;
    }

    const updatedAt =
      this.readText(payload.updateTime) ??
      this.readText(now.obsTime) ??
      new Date().toISOString();
    const weather = this.readText(now.text);
    const temperature = this.readNumber(now.temp);
    if (!weather || temperature === null) {
      return null;
    }

    return {
      updatedAt,
      weather,
      temperature,
      windSpeed: this.readNumber(now.windSpeed),
      windScale: this.readWindScale(now.windScale),
      precipitationAmount: this.readNumber(now.precip),
    };
  }

  async getHourlyForecast(
    location: ResolvedGeoLocation,
  ): Promise<WeatherHourlyForecastItem[]> {
    const payload = await this.http.getJson('/v7/weather/24h', {
      location: location.locationId,
      unit: this.config.qweatherUnit,
    });
    const updatedAt = this.readText(payload.updateTime) ?? new Date().toISOString();
    const hourly = Array.isArray(payload.hourly) ? payload.hourly : [];
    return hourly
      .map((item) =>
        this.toHourlyForecastItem(this.asRecord(item), updatedAt),
      )
      .filter((item): item is WeatherHourlyForecastItem => Boolean(item));
  }

  async getDailyForecast(
    location: ResolvedGeoLocation,
  ): Promise<WeatherDailyForecastItem[]> {
    const payload = await this.http.getJson('/v7/weather/7d', {
      location: location.locationId,
      unit: this.config.qweatherUnit,
    });
    const updatedAt = this.readText(payload.updateTime) ?? new Date().toISOString();
    const daily = Array.isArray(payload.daily) ? payload.daily : [];
    return daily
      .map((item) => this.toDailyForecastItem(this.asRecord(item), updatedAt))
      .filter((item): item is WeatherDailyForecastItem => Boolean(item));
  }

  async getOfficialAlerts(
    location: ResolvedGeoLocation,
  ): Promise<WeatherAlert[]> {
    const latitude = location.latitude.toFixed(2);
    const longitude = location.longitude.toFixed(2);
    const payload = await this.http.getJson(
      `/weatheralert/v1/current/${latitude}/${longitude}`,
      { localTime: 'true' },
    );
    const alerts = Array.isArray(payload.alerts) ? payload.alerts : [];
    return alerts
      .map((item) => this.toAlertItem(this.asRecord(item)))
      .filter((item): item is WeatherAlert => Boolean(item));
  }

  private toHourlyForecastItem(
    item: Record<string, unknown> | null,
    updatedAt: string,
  ): WeatherHourlyForecastItem | null {
    if (!item) {
      return null;
    }

    const forecastAt = this.readText(item.fxTime);
    const weather = this.readText(item.text);
    const temperature = this.readNumber(item.temp);
    if (!forecastAt || !weather || temperature === null) {
      return null;
    }

    return {
      updatedAt,
      forecastAt,
      weather,
      temperature,
      precipitationProbability: this.readInteger(item.pop) ?? 0,
      precipitationAmount: this.readNumber(item.precip),
      windSpeed: this.readNumber(item.windSpeed),
      windScale: this.readWindScale(item.windScale),
    };
  }

  private toDailyForecastItem(
    item: Record<string, unknown> | null,
    updatedAt: string,
  ): WeatherDailyForecastItem | null {
    if (!item) {
      return null;
    }

    const forecastDate = this.readText(item.fxDate);
    const weather =
      this.readText(item.textDay) ?? this.readText(item.textNight);
    const highTemperature = this.readNumber(item.tempMax);
    const lowTemperature = this.readNumber(item.tempMin);
    if (
      !forecastDate ||
      !weather ||
      highTemperature === null ||
      lowTemperature === null
    ) {
      return null;
    }

    const precipitationAmount = this.readNumber(item.precip);
    const precipitationProbability =
      this.toDailyPrecipitationProbability(precipitationAmount);
    const windSpeed = Math.max(
      this.readNumber(item.windSpeedDay) ?? 0,
      this.readNumber(item.windSpeedNight) ?? 0,
    );
    const windScale = Math.max(
      this.readWindScale(item.windScaleDay) ?? 0,
      this.readWindScale(item.windScaleNight) ?? 0,
    );

    return {
      updatedAt,
      forecastDate,
      weather,
      highTemperature,
      lowTemperature,
      precipitationProbability,
      precipitationAmount,
      windSpeed: windSpeed || null,
      windScale: windScale || null,
    };
  }

  private toAlertItem(item: Record<string, unknown> | null): WeatherAlert | null {
    if (!item) {
      return null;
    }

    const id = this.readText(item.id);
    const title =
      this.readText(item.headline) ??
      this.readText(this.asRecord(item.eventType)?.name);
    if (!id || !title) {
      return null;
    }

    return {
      id,
      title,
      severity: this.readText(item.severity),
      severityColor: this.readText(this.asRecord(item.color)?.code),
      effectiveAt:
        this.readText(item.effectiveTime) ?? this.readText(item.onsetTime),
      expiresAt:
        this.readText(item.expireTime) ?? this.readText(item.expiredTime),
      description: this.readText(item.description),
    };
  }

  private toDailyPrecipitationProbability(value: number | null) {
    if (value === null || value <= 0) {
      return 0;
    }
    if (value < 1) {
      return 40;
    }
    if (value < 5) {
      return 70;
    }
    return 90;
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

  private readInteger(value: unknown) {
    const numberValue = this.readNumber(value);
    if (numberValue === null) {
      return null;
    }
    return Math.round(numberValue);
  }

  private readWindScale(value: unknown) {
    const text = this.readText(value);
    if (!text) {
      return null;
    }

    const parts = text
      .split('-')
      .map((part) => Number(part.trim()))
      .filter((part) => Number.isFinite(part));
    if (!parts.length) {
      const single = Number(text);
      return Number.isFinite(single) ? single : null;
    }
    return Math.max(...parts);
  }
}
