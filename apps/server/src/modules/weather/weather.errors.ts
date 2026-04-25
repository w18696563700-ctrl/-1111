export type WeatherDomainErrorCode =
  | 'WEATHER_PROVIDER_UNAVAILABLE'
  | 'WEATHER_PROVIDER_CONFIG_MISSING'
  | 'WEATHER_REQUEST_FAILED';

export class WeatherDomainError extends Error {
  constructor(
    readonly code: WeatherDomainErrorCode,
    message: string,
  ) {
    super(message);
  }
}

export function weatherProviderUnavailable(message: string) {
  return new WeatherDomainError('WEATHER_PROVIDER_UNAVAILABLE', message);
}

export function weatherProviderConfigMissing(message: string) {
  return new WeatherDomainError('WEATHER_PROVIDER_CONFIG_MISSING', message);
}

export function weatherRequestFailed(message: string) {
  return new WeatherDomainError('WEATHER_REQUEST_FAILED', message);
}
