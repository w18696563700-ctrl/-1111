import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppRatingController } from './app-rating.controller';
import { RatingController } from './rating.controller';
import { RatingErrorService } from './rating-error.service';
import { RatingService } from './rating.service';

@Module({
  imports: [CoreModule],
  controllers: [RatingController, AppRatingController],
  providers: [RatingService, RatingErrorService],
})
export class RatingModule {}
