import { Injectable, Logger } from '@nestjs/common';
import { RuntimeConfigService } from '../../core/runtime-config.service';
import {
  weatherProviderConfigMissing,
  weatherProviderUnavailable,
  weatherRequestFailed,
} from './weather.errors';

@Injectable()
export class QWeatherHttpClient {
  private readonly logger = new Logger(QWeatherHttpClient.name);

  constructor(private readonly config: RuntimeConfigService) {}

  async getJson(
    path: string,
    query: Record<string, string | number | null | undefined>,
  ): Promise<Record<string, unknown>> {
    this.assertConfigured();

    const url = new URL(path, this.normalizeBaseUrl(this.config.qweatherApiHost));
    Object.entries(query).forEach(([key, value]) => {
      if (value === null || value === undefined || value === '') {
        return;
      }
      url.searchParams.set(key, `${value}`);
    });
    url.searchParams.set('lang', this.config.qweatherLanguage);

    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'X-QW-Api-Key': this.config.qweatherApiKey,
        },
        signal: AbortSignal.timeout(this.config.qweatherTimeoutMs),
      });
      if (!response.ok) {
        throw weatherRequestFailed(
          `QWeather returned HTTP ${response.status}.`,
        );
      }

      const payload = (await response.json()) as Record<string, unknown>;
      const code =
        typeof payload.code === 'string' ? payload.code.trim() : null;
      if (code && code !== '200') {
        throw weatherRequestFailed(
          `QWeather returned provider code ${code}.`,
        );
      }
      return payload;
    } catch (error) {
      if (error instanceof Error && 'code' in error) {
        throw error;
      }
      const message =
        error instanceof Error
          ? error.message
          : 'Unknown QWeather request failure.';
      this.logger.warn(`qweather request failed: ${message}`);
      throw weatherRequestFailed(message);
    }
  }

  private assertConfigured() {
    if (!this.config.qweatherEnabled) {
      throw weatherProviderUnavailable(
        'QWeather runtime is disabled for the current server environment.',
      );
    }
    if (!this.config.qweatherApiKey.trim()) {
      throw weatherProviderConfigMissing(
        'QWeather API key is missing for the current server environment.',
      );
    }
  }

  private normalizeBaseUrl(value: string) {
    if (/^https?:\/\//.test(value)) {
      return value;
    }
    return `https://${value}`;
  }
}
