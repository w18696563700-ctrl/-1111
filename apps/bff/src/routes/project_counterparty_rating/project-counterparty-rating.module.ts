import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppProjectCounterpartyRatingController } from './app-project-counterparty-rating.controller';
import { ProjectCounterpartyRatingService } from './project-counterparty-rating.service';

@Module({
  imports: [CoreModule],
  controllers: [AppProjectCounterpartyRatingController],
  providers: [ProjectCounterpartyRatingService]
})
export class ProjectCounterpartyRatingModule {}
