import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import {
  AppBidThreadController,
  AppProjectClarificationController,
  AppTradingParticipantCardController
} from './trading-im.controller';
import { TradingImService } from './trading-im.service';

@Module({
  imports: [CoreModule],
  controllers: [
    AppProjectClarificationController,
    AppBidThreadController,
    AppTradingParticipantCardController
  ],
  providers: [TradingImService]
})
export class TradingImModule {}
