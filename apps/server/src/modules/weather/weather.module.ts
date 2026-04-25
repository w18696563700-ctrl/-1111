import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { GEO_RESOLVER } from './geo-resolver.port';
import { QWeatherGeoResolverService } from './qweather-geo-resolver.service';
import { QWeatherHttpClient } from './qweather-http.client';
import { QWeatherWeatherProviderService } from './qweather-weather-provider.service';
import { WeatherCacheService } from './weather-cache.service';
import { WeatherLookupService } from './weather-lookup.service';
import { WEATHER_PROVIDER } from './weather-provider.port';
import { WeatherRuleEngineService } from './weather-rule-engine.service';

@Module({
  imports: [CoreModule],
  providers: [
    QWeatherHttpClient,
    QWeatherGeoResolverService,
    QWeatherWeatherProviderService,
    WeatherCacheService,
    WeatherLookupService,
    WeatherRuleEngineService,
    {
      provide: GEO_RESOLVER,
      useExisting: QWeatherGeoResolverService,
    },
    {
      provide: WEATHER_PROVIDER,
      useExisting: QWeatherWeatherProviderService,
    },
  ],
  exports: [WeatherLookupService, WeatherRuleEngineService],
})
export class WeatherModule {}
