export type HomeLocationSource =
  | 'manual_selection'
  | 'device_location'
  | 'system_default';

export type HomeSelectionScope = 'request_only';

export type ExhibitionHomeLocationInput = {
  displayName: string | null;
  provinceCode: string | null;
  provinceName: string | null;
  cityName: string | null;
  districtName: string | null;
  latitude: number | null;
  longitude: number | null;
  source: HomeLocationSource;
  selectionScope: HomeSelectionScope;
  selectionNotice: string;
  isUsingDeviceLocation: boolean;
};

export type ExhibitionHomeResolvedLocation = {
  displayName: string;
  provinceCode: string | null;
  provinceName: string;
  cityName: string | null;
  districtName: string | null;
  latitude: number | null;
  longitude: number | null;
  source: HomeLocationSource;
  selectionScope: HomeSelectionScope;
  selectionNotice: string;
  isUsingDeviceLocation: boolean;
};

export type ExhibitionHomeHourlyForecastView = {
  timeLabel: string;
  weather: string;
  temperature: number;
  precipitationProbability: number;
};

export type ExhibitionHomeDailyForecastView = {
  dateLabel: string;
  weekdayLabel: string | null;
  weather: string;
  highTemperature: number;
  lowTemperature: number;
  precipitationProbability: number;
};

export type ExhibitionHomeWeatherView = {
  state: 'live' | 'degraded';
  currentWeather: string;
  currentTemperature: number;
  highTemperature: number;
  lowTemperature: number;
  precipitationProbability: number;
  constructionRiskLevel: 'low' | 'medium' | 'high' | 'critical';
  constructionRiskSummary: string;
  riskTags: string[];
  riskTimeLabel: string | null;
  nightRainExpected: boolean;
  nightRainTimeLabel: string | null;
  officialAlerts: string[];
  constructionSuggestions: string[];
  hourlyForecast: ExhibitionHomeHourlyForecastView[];
  dailyForecast: ExhibitionHomeDailyForecastView[];
  updatedAt: string;
};

export type ExhibitionHomeAggregationView = {
  location: ExhibitionHomeResolvedLocation;
  weather: ExhibitionHomeWeatherView;
};
