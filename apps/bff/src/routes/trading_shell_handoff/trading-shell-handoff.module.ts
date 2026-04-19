import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppTradingShellHandoffController } from './app-trading-shell-handoff.controller';
import { TradingShellHandoffController } from './trading-shell-handoff.controller';
import { TradingShellHandoffErrorService } from './trading-shell-handoff.error.service';
import { TradingShellHandoffService } from './trading-shell-handoff.service';

@Module({
  imports: [CoreModule],
  controllers: [
    TradingShellHandoffController,
    AppTradingShellHandoffController,
  ],
  providers: [TradingShellHandoffService, TradingShellHandoffErrorService],
})
export class TradingShellHandoffModule {}
