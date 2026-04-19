import { Controller, Get, Headers, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { TradingReadCorridorService } from './trading-read-corridor.service';

@Controller('api/app')
export class AppTradingReadCorridorController {
  constructor(
    private readonly tradingReadCorridorService: TradingReadCorridorService,
  ) {}

  @Get('order/detail')
  getOrderDetail(
    @Query('orderId') orderId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.tradingReadCorridorService.getOrderDetail(orderId, headers);
  }

  @Get('contract/detail')
  getContractDetail(
    @Query('orderId') orderId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.tradingReadCorridorService.getContractDetail(orderId, headers);
  }

  @Get('milestone/list')
  getMilestoneList(
    @Query('orderId') orderId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.tradingReadCorridorService.getMilestoneList(orderId, headers);
  }

  @Get('inspection/detail')
  getInspectionDetail(
    @Query('milestoneId') milestoneId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.tradingReadCorridorService.getInspectionDetail(
      milestoneId,
      headers,
    );
  }
}
