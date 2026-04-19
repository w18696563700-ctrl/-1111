import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppBidThreadController, AppProjectClarificationController } from './trading-im.controller';
import { TradingImService } from './trading-im.service';

@Module({
  imports: [CoreModule],
  controllers: [AppProjectClarificationController, AppBidThreadController],
  providers: [TradingImService]
})
export class TradingImModule {}
