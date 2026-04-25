import type {
  ResolvedGeoLocation,
  WeatherAlert,
  WeatherCurrentConditions,
  WeatherDailyForecastItem,
  WeatherHourlyForecastItem,
} from './weather.types';

export const WEATHER_PROVIDER = Symbol('WEATHER_PROVIDER');

export interface WeatherProvider {
  getCurrentWeather(
    location: ResolvedGeoLocation,
  ): Promise<WeatherCurrentConditions | null>;
  getHourlyForecast(
    location: ResolvedGeoLocation,
  ): Promise<WeatherHourlyForecastItem[]>;
  getDailyForecast(
    location: ResolvedGeoLocation,
  ): Promise<WeatherDailyForecastItem[]>;
  getOfficialAlerts(location: ResolvedGeoLocation): Promise<WeatherAlert[]>;
}
