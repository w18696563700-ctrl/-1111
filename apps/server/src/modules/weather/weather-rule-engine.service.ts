import { Injectable } from '@nestjs/common';
import {
  formatRiskTimeLabel,
  isNightForecast,
} from './weather-time.util';
import type {
  WeatherAlert,
  WeatherCurrentConditions,
  WeatherDailyForecastItem,
  WeatherHourlyForecastItem,
  WeatherRiskAssessment,
  WeatherRiskLevel,
  WeatherRiskTag,
} from './weather.types';

type RiskInput = {
  timezone: string | null;
  current: WeatherCurrentConditions | null;
  hourlyForecast: WeatherHourlyForecastItem[];
  dailyForecast: WeatherDailyForecastItem[];
  officialAlerts: WeatherAlert[];
  weatherAvailable: boolean;
};

@Injectable()
export class WeatherRuleEngineService {
  evaluate(input: RiskInput): WeatherRiskAssessment {
    if (!input.weatherAvailable) {
      return {
        level: 'medium',
        tags: [],
        timeLabel: null,
        nightRainExpected: false,
        nightRainTimeLabel: null,
        summary:
          '今日施工重点：当前地区已同步，天气暂不可用，请按保守方案安排露天施工并稍后刷新重试。',
        suggestions: [
          '优先按保守天气方案安排露天、高处和吊装作业，避免连续重载施工。',
          '现场先复核临时用电、防滑、防潮和排水条件，再决定是否放开室外工序。',
          '天气恢复后再刷新首页，确认小时预报、每日预报和官方预警是否变化。',
        ],
      };
    }

    const tags = this.collectTags(input);
    const level = this.resolveLevel(tags, input.officialAlerts);
    const timeLabel = this.resolveRiskTimeLabel(input);
    const nightRainTimeLabel = this.resolveNightRainTimeLabel(input);

    return {
      level,
      tags,
      timeLabel,
      nightRainExpected: Boolean(nightRainTimeLabel),
      nightRainTimeLabel,
      summary: this.buildSummary(tags, level),
      suggestions: this.buildSuggestions(tags),
    };
  }

  private collectTags(input: RiskInput): WeatherRiskTag[] {
    const tags = new Set<WeatherRiskTag>();

    if (input.officialAlerts.length > 0) {
      tags.add('official_alert');
    }

    const hasLightningAlert = input.officialAlerts.some((alert) =>
      this.containsWeatherKeyword(alert.title, ['雷', 'lightning', 'thunder']),
    );
    const hasLightningWeather = input.hourlyForecast.some((item) =>
      this.containsWeatherKeyword(item.weather, ['雷', 'lightning', 'thunder']),
    );
    if (hasLightningAlert || hasLightningWeather) {
      tags.add('lightning');
    }

    const rainySlot = input.hourlyForecast.find(
      (item) =>
        item.precipitationProbability >= 55 ||
        (item.precipitationAmount ?? 0) >= 1,
    );
    if (rainySlot) {
      tags.add('rain');
    }

    const nightRainSlot = input.hourlyForecast.find(
      (item) =>
        isNightForecast(item.forecastAt, input.timezone) &&
        (item.precipitationProbability >= 50 ||
            (item.precipitationAmount ?? 0) >= 1),
    );
    if (nightRainSlot) {
      tags.add('night_rain');
    }

    const strongWind = [
      input.current?.windScale ?? 0,
      ...input.hourlyForecast.map((item) => item.windScale ?? 0),
      ...input.dailyForecast.map((item) => item.windScale ?? 0),
    ].some((value) => value >= 6);
    if (strongWind) {
      tags.add('strong_wind');
    }

    const highTemperature = [
      input.current?.temperature ?? Number.NEGATIVE_INFINITY,
      ...input.dailyForecast.map((item) => item.highTemperature),
    ].some((value) => value >= 35);
    if (highTemperature) {
      tags.add('high_temp');
    }

    const lowTemperature = [
      input.current?.temperature ?? Number.POSITIVE_INFINITY,
      ...input.dailyForecast.map((item) => item.lowTemperature),
    ].some((value) => value <= 5);
    if (lowTemperature) {
      tags.add('low_temp');
    }

    return Array.from(tags);
  }

  private resolveLevel(tags: WeatherRiskTag[], alerts: WeatherAlert[]) {
    const alertSeverity = this.resolveAlertSeverity(alerts);
    if (alertSeverity === 'critical') {
      return 'critical';
    }
    if (
      alertSeverity === 'high' ||
      tags.includes('lightning') ||
      tags.includes('strong_wind')
    ) {
      return 'high';
    }
    if (
      alertSeverity === 'medium' ||
      tags.includes('rain') ||
      tags.includes('night_rain') ||
      tags.includes('high_temp') ||
      tags.includes('low_temp')
    ) {
      return 'medium';
    }
    return 'low';
  }

  private resolveAlertSeverity(
    alerts: WeatherAlert[],
  ): WeatherRiskLevel | null {
    const severities = alerts.map((alert) => {
      const color = alert.severityColor?.toLowerCase();
      const severity = alert.severity?.toLowerCase();
      if (
        color === 'red' ||
        severity === 'extreme' ||
        severity === 'severe'
      ) {
        return 'critical';
      }
      if (color === 'orange' || severity === 'moderate') {
        return 'high';
      }
      if (
        color === 'yellow' ||
        color === 'blue' ||
        severity === 'minor'
      ) {
        return 'medium';
      }
      return null;
    });

    if (severities.includes('critical')) {
      return 'critical';
    }
    if (severities.includes('high')) {
      return 'high';
    }
    if (severities.includes('medium')) {
      return 'medium';
    }
    return null;
  }

  private resolveRiskTimeLabel(input: RiskInput) {
    const firstHourlyRisk = input.hourlyForecast.find(
      (item) =>
        item.precipitationProbability >= 55 ||
        (item.precipitationAmount ?? 0) >= 1 ||
        (item.windScale ?? 0) >= 6 ||
        this.containsWeatherKeyword(item.weather, ['雷', 'lightning', 'thunder']),
    );
    const firstAlert = input.officialAlerts.find((alert) => alert.effectiveAt);
    return formatRiskTimeLabel(
      firstAlert?.effectiveAt ?? firstHourlyRisk?.forecastAt ?? null,
      input.timezone,
    );
  }

  private resolveNightRainTimeLabel(input: RiskInput) {
    const slot = input.hourlyForecast.find(
      (item) =>
        isNightForecast(item.forecastAt, input.timezone) &&
        (item.precipitationProbability >= 50 ||
            (item.precipitationAmount ?? 0) >= 1),
    );
    return formatRiskTimeLabel(
      slot?.forecastAt ?? null,
      input.timezone,
      '今夜',
    );
  }

  private buildSummary(tags: WeatherRiskTag[], level: WeatherRiskLevel) {
    if (tags.includes('official_alert')) {
      return '今日施工重点：存在官方预警，露天、高处和吊装施工应按预警要求收紧节奏。';
    }
    if (tags.includes('lightning')) {
      return '今日施工重点：雷电风险偏高，室外高处、临边和临时用电作业应前置收口。';
    }
    if (tags.includes('strong_wind')) {
      return '今日施工重点：风力偏强，围挡、吊装和高处作业需先做加固复核。';
    }
    if (tags.includes('rain') || tags.includes('night_rain')) {
      return '今日施工重点：有降雨影响，材料防潮、地面防滑和排水检查要前置完成。';
    }
    if (tags.includes('high_temp')) {
      return '今日施工重点：高温时段需错峰施工并加强补水与中暑防护。';
    }
    if (tags.includes('low_temp')) {
      return '今日施工重点：低温条件下应复核材料固化、地面防滑和保温保护措施。';
    }
    if (level === 'low') {
      return '今日施工重点：天气总体平稳，可按计划推进施工，并持续复核现场防护。';
    }
    return '今日施工重点：天气存在波动，请优先压缩露天和高风险工序。';
  }

  private buildSuggestions(tags: WeatherRiskTag[]) {
    const suggestions = new Set<string>();

    if (tags.includes('official_alert')) {
      suggestions.add('优先执行官方预警要求，必要时暂停露天、高处和吊装工序。');
    }
    if (tags.includes('rain') || tags.includes('night_rain')) {
      suggestions.add('提前检查排水路径、材料遮盖和通道防滑，避免夜间积水影响明早开工。');
    }
    if (tags.includes('strong_wind')) {
      suggestions.add('复核围挡、脚手、广告画面和吊装点位，风力增大时及时收口。');
    }
    if (tags.includes('lightning')) {
      suggestions.add('雷电影响时压缩室外临电、高处和金属构件作业，人员尽快转入安全区域。');
    }
    if (tags.includes('high_temp')) {
      suggestions.add('高温时段尽量错峰施工，补足饮水、遮阳和轮换休息安排。');
    }
    if (tags.includes('low_temp')) {
      suggestions.add('低温条件下复核材料固化时间、地面防滑和早晚保温措施。');
    }
    if (!suggestions.size) {
      suggestions.add('按计划推进施工，同时继续复核临时用电、消防和现场防护。');
    }

    suggestions.add('开工前复核材料、排水、围挡和临时用电状态，避免现场条件与预报脱节。');
    suggestions.add('刷新首页前优先查看小时预报和官方预警，避免沿用过期判断。');

    const normalized = Array.from(suggestions);
    if (normalized.length < 3) {
      normalized.push('关键露天工序尽量前置留出机动窗口，天气波动时优先收口高风险工序。');
    }
    return normalized.slice(0, 5);
  }

  private containsWeatherKeyword(value: string | null, patterns: string[]) {
    if (!value) {
      return false;
    }
    const normalized = value.toLowerCase();
    return patterns.some((pattern) =>
      normalized.includes(pattern.toLowerCase()),
    );
  }
}
