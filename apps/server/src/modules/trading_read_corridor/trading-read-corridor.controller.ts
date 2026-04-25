import { Controller, Get, Headers, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { TradingReadCorridorQueryService } from './trading-read-corridor.query.service';

@Controller('server')
export class TradingReadCorridorController {
  constructor(private readonly queryService: TradingReadCorridorQueryService) {}

  @Get('order/detail')
  getOrderDetail(
    @Query('orderId') orderId: string | undefined,
    @Query('projectId') projectId: string | undefined,
    @Headers() headers: HeaderBag
  ) {
    return this.queryService.getOrderDetail(
      orderId,
      projectId,
      resolveRequestContext(headers)
    );
  }

  @Get('contract/detail')
  getContractDetail(
    @Query('orderId') orderId: string | undefined,
    @Headers() headers: HeaderBag
  ) {
    return this.queryService.getContractDetail(orderId, resolveRequestContext(headers));
  }

  @Get('milestone/list')
  listMilestones(
    @Query('orderId') orderId: string | undefined,
    @Headers() headers: HeaderBag
  ) {
    return this.queryService.listMilestones(orderId, resolveRequestContext(headers));
  }

  @Get('inspection/detail')
  getInspectionDetail(
    @Query('milestoneId') milestoneId: string | undefined,
    @Headers() headers: HeaderBag
  ) {
    return this.queryService.getInspectionDetail(
      milestoneId,
      resolveRequestContext(headers)
    );
  }
}
