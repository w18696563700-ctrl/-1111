import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppTradingReadCorridorController } from './app-trading-read-corridor.controller';
import { TradingReadCorridorController } from './trading-read-corridor.controller';
import { TradingReadCorridorErrorService } from './trading-read-corridor.error.service';
import { TradingReadCorridorService } from './trading-read-corridor.service';

@Module({
  imports: [CoreModule],
  controllers: [
    TradingReadCorridorController,
    AppTradingReadCorridorController,
  ],
  providers: [TradingReadCorridorService, TradingReadCorridorErrorService],
})
export class TradingReadCorridorModule {}
