export type GeoLookupRequest = {
  displayName: string | null;
  provinceCode: string | null;
  provinceName: string | null;
  cityName: string | null;
  districtName: string | null;
  latitude: number | null;
  longitude: number | null;
};

export type ResolvedGeoLocation = {
  locationId: string;
  latitude: number;
  longitude: number;
  provinceCode: string | null;
  provinceName: string | null;
  cityName: string | null;
  districtName: string | null;
  timezone: string | null;
  queryLabel: string;
};

export type WeatherCurrentConditions = {
  updatedAt: string;
  weather: string;
  temperature: number;
  windSpeed: number | null;
  windScale: number | null;
  precipitationAmount: number | null;
};

export type WeatherHourlyForecastItem = {
  updatedAt: string;
  forecastAt: string;
  weather: string;
  temperature: number;
  precipitationProbability: number;
  precipitationAmount: number | null;
  windSpeed: number | null;
  windScale: number | null;
};

export type WeatherDailyForecastItem = {
  updatedAt: string;
  forecastDate: string;
  weather: string;
  highTemperature: number;
  lowTemperature: number;
  precipitationProbability: number;
  precipitationAmount: number | null;
  windSpeed: number | null;
  windScale: number | null;
};

export type WeatherAlert = {
  id: string;
  title: string;
  severity: string | null;
  severityColor: string | null;
  effectiveAt: string | null;
  expiresAt: string | null;
  description: string | null;
};

export type WeatherRiskTag =
  | 'rain'
  | 'night_rain'
  | 'high_temp'
  | 'low_temp'
  | 'strong_wind'
  | 'lightning'
  | 'official_alert';

export type WeatherRiskLevel = 'low' | 'medium' | 'high' | 'critical';

export type WeatherRiskAssessment = {
  level: WeatherRiskLevel;
  tags: WeatherRiskTag[];
  timeLabel: string | null;
  nightRainExpected: boolean;
  nightRainTimeLabel: string | null;
  summary: string;
  suggestions: string[];
};

export type WeatherLookupResult = {
  resolvedLocation: ResolvedGeoLocation | null;
  current: WeatherCurrentConditions | null;
  hourlyForecast: WeatherHourlyForecastItem[];
  dailyForecast: WeatherDailyForecastItem[];
  officialAlerts: WeatherAlert[];
  updatedAt: string;
  weatherAvailable: boolean;
  providerFailures: string[];
  degradedReason: 'geo_unavailable' | 'provider_unavailable' | null;
};
