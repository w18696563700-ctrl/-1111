import { Injectable } from '@nestjs/common';
import { WeatherLookupService } from '../weather/weather-lookup.service';
import { WeatherRuleEngineService } from '../weather/weather-rule-engine.service';
import {
  formatClockLabel,
  formatWeatherDateLabel,
} from '../weather/weather-time.util';
import type {
  WeatherDailyForecastItem,
  WeatherLookupResult,
} from '../weather/weather.types';
import type {
  ExhibitionHomeAggregationView,
  ExhibitionHomeDailyForecastView,
  ExhibitionHomeLocationInput,
} from './exhibition-home.types';

@Injectable()
export class ExhibitionHomeAggregationService {
  constructor(
    private readonly weatherLookup: WeatherLookupService,
    private readonly weatherRuleEngine: WeatherRuleEngineService,
  ) {}

  async build(
    locationInput: ExhibitionHomeLocationInput,
  ): Promise<ExhibitionHomeAggregationView> {
    const lookup = await this.weatherLookup.lookup({
      displayName: locationInput.displayName,
      provinceCode: locationInput.provinceCode,
      provinceName: locationInput.provinceName,
      cityName: locationInput.cityName,
      districtName: locationInput.districtName,
      latitude: locationInput.latitude,
      longitude: locationInput.longitude,
    });

    const location = this.resolveLocation(locationInput, lookup.resolvedLocation);
    const risk = this.weatherRuleEngine.evaluate({
      timezone: lookup.resolvedLocation?.timezone ?? 'Asia/Shanghai',
      current: lookup.current,
      hourlyForecast: lookup.hourlyForecast,
      dailyForecast: lookup.dailyForecast,
      officialAlerts: lookup.officialAlerts,
      weatherAvailable: lookup.weatherAvailable,
    });

    return {
      location,
      weather: this.toWeatherView(
        lookup,
        risk,
        lookup.resolvedLocation?.timezone,
      ),
    };
  }

  private resolveLocation(
    input: ExhibitionHomeLocationInput,
    resolved: WeatherLookupResult['resolvedLocation'],
  ) {
    const provinceName = input.provinceName ?? resolved?.provinceName ?? '当前地区';
    const cityName = input.cityName ?? resolved?.cityName ?? null;
    const districtName = input.districtName ?? resolved?.districtName ?? null;

    return {
      displayName:
        input.displayName ??
        this.composeDisplayName(provinceName, cityName, districtName),
      provinceCode: input.provinceCode ?? resolved?.provinceCode ?? null,
      provinceName,
      cityName,
      districtName,
      latitude: input.latitude ?? resolved?.latitude ?? null,
      longitude: input.longitude ?? resolved?.longitude ?? null,
      source: input.source,
      selectionScope: input.selectionScope,
      selectionNotice: input.selectionNotice,
      isUsingDeviceLocation: input.isUsingDeviceLocation,
    };
  }

  private toWeatherView(
    lookup: WeatherLookupResult,
    risk: ReturnType<WeatherRuleEngineService['evaluate']>,
    timezone: string | null | undefined,
  ) {
    const firstHourly = lookup.hourlyForecast[0] ?? null;
    const firstDaily = lookup.dailyForecast[0] ?? null;
    const currentTemperature =
      lookup.current?.temperature ?? firstHourly?.temperature ?? 0;
    const effectiveTimezone = timezone ?? 'Asia/Shanghai';
    const hourlyForecast = lookup.weatherAvailable
      ? lookup.hourlyForecast.slice(0, 12).map((item) => ({
          timeLabel:
            formatClockLabel(item.forecastAt, effectiveTimezone) ??
            item.forecastAt,
          weather: item.weather,
          temperature: item.temperature,
          precipitationProbability: item.precipitationProbability,
        }))
      : [];
    const dailyForecast = lookup.weatherAvailable
      ? lookup.dailyForecast
          .slice(0, 7)
          .map((item) =>
            this.toDailyForecastView(
              item,
              lookup.hourlyForecast,
              effectiveTimezone,
            ),
          )
      : [];

    if (!lookup.weatherAvailable) {
      return {
        state: 'degraded' as const,
        currentWeather: '天气暂不可用',
        currentTemperature: 0,
        highTemperature: 0,
        lowTemperature: 0,
        precipitationProbability: 0,
        constructionRiskLevel: risk.level,
        constructionRiskSummary: risk.summary,
        riskTags: risk.tags,
        riskTimeLabel: risk.timeLabel,
        nightRainExpected: risk.nightRainExpected,
        nightRainTimeLabel: risk.nightRainTimeLabel,
        officialAlerts: [],
        constructionSuggestions: risk.suggestions,
        hourlyForecast,
        dailyForecast,
        updatedAt: lookup.updatedAt,
      };
    }

    return {
      state: 'live' as const,
      currentWeather:
        lookup.current?.weather ??
        firstHourly?.weather ??
        firstDaily?.weather ??
        '天气信息有限',
      currentTemperature,
      highTemperature: firstDaily?.highTemperature ?? currentTemperature,
      lowTemperature: firstDaily?.lowTemperature ?? currentTemperature,
      precipitationProbability: this.resolveTopPrecipitationProbability(
        lookup.hourlyForecast,
        firstDaily,
      ),
      constructionRiskLevel: risk.level,
      constructionRiskSummary: risk.summary,
      riskTags: risk.tags,
      riskTimeLabel: risk.timeLabel,
      nightRainExpected: risk.nightRainExpected,
      nightRainTimeLabel: risk.nightRainTimeLabel,
      officialAlerts: lookup.officialAlerts.map((item) =>
        this.formatOfficialAlert(
          item.title,
          item.expiresAt ?? item.effectiveAt,
          effectiveTimezone,
        ),
      ),
      constructionSuggestions: risk.suggestions,
      hourlyForecast,
      dailyForecast,
      updatedAt: lookup.updatedAt,
    };
  }

  private toDailyForecastView(
    item: WeatherDailyForecastItem,
    hourlyForecast: WeatherLookupResult['hourlyForecast'],
    timezone: string,
  ): ExhibitionHomeDailyForecastView {
    const formatted = formatWeatherDateLabel(item.forecastDate, timezone);
    const precipitationProbability = hourlyForecast
      .filter((hourly) => hourly.forecastAt.slice(0, 10) === item.forecastDate)
      .reduce(
        (highest, hourly) =>
          Math.max(highest, hourly.precipitationProbability),
        item.precipitationProbability,
      );

    return {
      dateLabel: formatted.dateLabel,
      weekdayLabel: formatted.weekdayLabel,
      weather: item.weather,
      highTemperature: item.highTemperature,
      lowTemperature: item.lowTemperature,
      precipitationProbability,
    };
  }

  private resolveTopPrecipitationProbability(
    hourlyForecast: WeatherLookupResult['hourlyForecast'],
    firstDaily: WeatherDailyForecastItem | null,
  ) {
    const topHourly = hourlyForecast
      .slice(0, 12)
      .reduce(
        (highest, item) => Math.max(highest, item.precipitationProbability),
        0,
      );
    return Math.max(topHourly, firstDaily?.precipitationProbability ?? 0);
  }

  private formatOfficialAlert(
    title: string,
    time: string | null,
    timezone: string,
  ) {
    const clock = formatClockLabel(time, timezone);
    if (!clock) {
      return title;
    }
    return `${title}（${clock}）`;
  }

  private composeDisplayName(
    provinceName: string,
    cityName: string | null,
    districtName: string | null,
  ) {
    const parts = [provinceName, cityName, districtName].filter(
      (value): value is string => Boolean(value),
    );
    const uniqueParts = parts.filter((value, index) => {
      if (index === 0) {
        return true;
      }
      return (
        this.normalizeLocationValue(value) !==
        this.normalizeLocationValue(parts[index - 1]!)
      );
    });
    return uniqueParts.join('') || '当前地区';
  }

  private normalizeLocationValue(value: string) {
    return value
      .replace(/省|市|区|县|盟|地区|自治州|特别行政区|自治区/u, '')
      .trim();
  }
}
