import { Module } from '@nestjs/common';
import { WeatherModule } from '../weather/weather.module';
import { ExhibitionHomeAggregationService } from './exhibition-home-aggregation.service';
import { ExhibitionHomeController } from './exhibition-home.controller';
import { ExhibitionHomePresenter } from './exhibition-home.presenter';
import { ExhibitionHomeQueryService } from './exhibition-home.query.service';

@Module({
  imports: [WeatherModule],
  controllers: [ExhibitionHomeController],
  providers: [
    ExhibitionHomeAggregationService,
    ExhibitionHomePresenter,
    ExhibitionHomeQueryService,
  ],
})
export class ExhibitionHomeModule {}
